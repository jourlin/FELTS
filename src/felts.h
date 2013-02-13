/* felts.h : definitions for FELTS

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
  felts.h : définitions pour FELTS

  Copyright (C) 2012-13 Pierre Jourlin — Tous droits réservés.
 
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

#define CRLF "\r\n"
#define VERSION "FELTS 0.0.0"
#define DEFAULT_PORT 8000
#define DEFAULT_DIC "./dic/sample.dic"
#define FATAL(err) { perror((char *) err); exit(1);}

#define MAXWORDS 	2000000
#define LINEMAXLENGTH	(1024*1024)
#define BUFFERMAXLENGTH	(1024*1024)
#define TRUE 		1
#define FALSE		0


typedef struct Node {
		struct Node *next[256];
		unsigned long int number;
		} NODE;

typedef struct Term {
		struct Term *next; /* next word in term */
		struct Term *alter; /* next existing alternative */
		unsigned long int wordid;
		unsigned short int isfinal;
		} TERM;

extern NODE dict;
extern TERM *thesaurus;
extern char * GetLastWord(char *word, char * current, char *start);

extern void serve_client (int fd_client);
extern void send_terms (char textin[]);
extern void failure(char textin[]);
extern void invalid_request();
extern int  tcp_server (int port_number);
extern int  wait_client (int fd_server);

