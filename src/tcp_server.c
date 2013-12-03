/*
   tcp_server.c : tcp server functions
     Copyright (C) 2002 Michel Billaud

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
***********************************************************************************
  tcp_server.c : tcp server functions

  Copyright (C) 2002 Michel Billaud — Tous droits réservés.
 
  Ce programme est un logiciel libre ; vous pouvez le redistribuer ou le
  modifier suivant les termes de la “GNU General Public License” telle que
  publiée par la Free Software Foundation : soit la version 3 de cette
  licence, soit (à votre gré) toute version ultérieure.
  
  Ce programme est distribué dans l’espoir qu’il vous sera utile, mais SANS
  AUCUNE GARANTIE : sans même la garantie implicite de COMMERCIALISABILITÉ
  ni d’ADÉQUATION À UN OBJECTIF PARTICULIER. Consultez la Licence Générale
  Publique GNU pour plus de détails.
  
  Vous devriez avoir reçu une copie de la Licence Générale Publique GNU avec
  ce programme ; si ce n’est pas le cas, consultez :
  <http://www.gnu.org/licenses/>.

    Michel Billaud
    Laboratoire Bordelais de Recherche en Informatique
    billaud@labri.fr

*/


#include <arpa/inet.h>
#include <netinet/in.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <unistd.h>

#include "felts.h"


void arreter_serveur(int numero_signal);

#define NB_SOUS_SERVEURS 5

/* ------------------------------------------------------------
  Fonctions réseau
------------------------------------------------------------ */

int serveur_tcp (int numero_port)
{
  int fd;

  /* démarre un service TCP sur le port indiqué */

  struct sockaddr_in addr_serveur;
  size_t lg_addr_serveur = sizeof addr_serveur;

  /* création de la prise */
  fd = socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) FATAL("socket");
  
  /* nommage de la prise */
  addr_serveur.sin_family      = AF_INET;
  addr_serveur.sin_addr.s_addr = INADDR_ANY;
  addr_serveur.sin_port        = htons(numero_port);
  if (bind(fd, (struct sockaddr *)&addr_serveur, lg_addr_serveur) < 0)
    FATAL("bind");

  /* ouverture du service */
  listen(fd, 4);
  return (fd);
}

int attendre_client(int fd_serveur)
{
  int fd_client;
  /* A cause des signaux SIGCHLD, la fonction accept()
     peut etre interrompue quand un fils se termine.
     Dans ce cas, on relance accept().
  */
  while ( (fd_client = accept(fd_serveur, NULL, NULL)) < 0) {
    if (errno != EINTR)
      FATAL("Fin anormale de accept().");
  }
  return(fd_client);
}

void arreter_serveur(int numero_signal);

struct donnees_sous_serveur {
     pthread_t       id;		/* identificateur de thread  */
     pthread_mutex_t verrou;
     int             actif;	/* 1 => sous-serveur occupé */
     int             fd;		/* socket du client          */
     char            *repertoire;
};

struct donnees_sous_serveur pool[NB_SOUS_SERVEURS];
int fd_serveur;			/* variable globale, pour partager
				   avec traitement signal fin_serveur */

/* -------------------------------------------------------
   sous_serveur
   ------------------------------------------------------- */
void *executer_sous_serveur(void *data)
{
     struct donnees_sous_serveur *d = data;
     while (1) {
          pthread_mutex_lock(&d->verrou);
          serve_client(d->fd);
          close(d->fd);
          d->actif = 0;
     }
     return NULL; /* jamais exécuté */
}

/* ------------------------------------------------------- */
void creer_sous_serveurs(char repertoire[])
{
     int k;

     for (k = 0; k < NB_SOUS_SERVEURS; k++) {
          struct donnees_sous_serveur *d = pool + k;
          d->actif = 0;
          d->repertoire = repertoire;
          pthread_mutex_init(&d->verrou, NULL);
          pthread_mutex_lock(&d->verrou);
          pthread_create(&d->id, NULL, executer_sous_serveur, (void *) d);
     }
}

/* -----------------------------------------------------
   demarrer_serveur: crée le socket serveur
   et lance des processus pour chaque client
   ----------------------------------------------------- */

int demarrer_serveur(int numero_port, char repertoire[])
{
     int numero_client = 0;
     int fd_client;
     struct sigaction action_fin;

     printf("> Serveur " VERSION " "
            "(port=%d, dict=\"%s\")\n",
            numero_port, repertoire);

     /* signal SIGINT -> arrêt du serveur */

     action_fin.sa_handler = arreter_serveur;
     sigemptyset(&action_fin.sa_mask);
     action_fin.sa_flags = 0;
     sigaction(SIGINT, &action_fin, NULL);

     /* création du socket serveur et du pool de sous-serveurs */
     fd_serveur = serveur_tcp(numero_port);
     creer_sous_serveurs(repertoire);

     /* boucle du serveur */
     while (1) {
          struct sockaddr_in a;
          socklen_t l = sizeof a;
          int k;

          fd_client = attendre_client(fd_serveur);
          getsockname(fd_client, (struct sockaddr *) &a, &l);
          numero_client++;

          /* recherche d'un sous-serveur inoccupé */
          for (k = 0; k < NB_SOUS_SERVEURS; k++)
               if (pool[k].actif == 0)
                    break;
          if (k == NB_SOUS_SERVEURS) {	/* pas de sous-serveur libre ? */
               printf("> client %d [%s] rejeté (surcharge)\n",
                      numero_client, inet_ntoa(a.sin_addr));
               close(fd_client);
          } else {
               /* affectation du travail et déblocage du sous-serveur */
               	printf("> client %d [%s] is being served by subserver %d\n",
                      numero_client, inet_ntoa(a.sin_addr), k);
               	pool[k].fd = fd_client;
               	pool[k].actif = 1;
               	pthread_mutex_unlock(&pool[k].verrou);
          }
     }
}

/* -------------------------------------------------------------
 Traitement des signaux
--------------------------------------------------------------- */

void arreter_serveur(int numero_signal)
{
     printf("=> fin du serveur\n");
     shutdown(fd_serveur, 2);	/* utile ? */
     close(fd_serveur);
     exit(EXIT_SUCCESS);
}


