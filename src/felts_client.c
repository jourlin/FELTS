/* 
  felts_client.c : Client for the Fast Extractor for Large Term Sets 

    Copyright (C) 2012-13  Pierre Jourlin

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
  felts_client.c : Client pour l'Extracteur Rapide pour Grands Ensembles de Termes

  Copyright (C) 2012-2013 Pierre Jourlin — Tous droits réservés.
 
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

    Pierre Jourlin
    L.I.A. / C.E.R.I.
    339, chemin des Meinajariès
    BP 1228 Agroparc
    84911 AVIGNON CEDEX 9
    France 
    pierre.jourlin@univ-avignon.fr
    Tel : +33 4 90 84 35 32
    Fax : +33 4 90 84 35 01

*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 

#include "felts.h"

void error(const char *msg)
{
    perror(msg);
    exit(0);
}

int main(int argc, char *argv[])
{
    int sockfd, portno, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;
    char buffer[BUFFERMAXLENGTH];
    char response[BUFFERMAXLENGTH], *current;
    unsigned int ligne=0;

    if (argc < 3) {
       fprintf(stderr,"usage %s hostname port\n", argv[0]);
       exit(0);
    }
    portno = atoi(argv[2]);
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) 
        error("ERROR opening socket");
    server = gethostbyname(argv[1]);
    if (server == NULL) {
        fprintf(stderr,"ERROR, no such host\n");
        exit(0);
    }
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, 
         (char *)&serv_addr.sin_addr.s_addr,
         server->h_length);
    serv_addr.sin_port = htons(portno);
    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) 
        error("ERROR connecting");    
    while(!feof(stdin))
    {
	bzero(buffer,BUFFERMAXLENGTH);
    	if(fgets(buffer,BUFFERMAXLENGTH-1,stdin)==NULL)
		break;
	ligne++;
    	n = write(sockfd,buffer,strlen(buffer));
    	if (n < 0) 
         	error("ERROR writing to socket");
	response[0]='\0';
	do{
    		bzero(buffer,BUFFERMAXLENGTH);
		n = read(sockfd,buffer,BUFFERMAXLENGTH-1);
    		if (n < 0) 
        		 error("ERROR reading from socket");
		strncat(response, buffer, n);
	}while(n>=0 && (strstr(response,"\n\n")==NULL));
	response[strlen(response)-1]='\0';
	current=response;
	while(*current!='\0'){
		if(*current!='\n'){ 				/* No term, no output */
			printf("%d,\t", ligne);
			while(*current!='\n')
				printf("%c", *current++);
			printf("%c", *current); 		/* Carriage return */
		}
		current++;
	}
    }
    close(sockfd);
    return 0;
}
