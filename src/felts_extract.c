/* 
  felts_extract.c : The main code of the Fast Extractor for Large Term Sets 

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
  felts_extract.c : Serveur pour l'Extracteur Rapide pour Grands Ensembles de Termes

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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "felts.h"

TERM* Find(TERM *current, unsigned long int wordid)
{
	
	if(current->next==NULL) 
		return NULL;
	current=current->next;
	while(current->alter!=NULL && current->wordid!=wordid)
		current=current->alter;
	if(current->wordid==wordid)
		return current;
	else
		return NULL;
};

unsigned char* FindLonguestTerm(char * start)
{
	unsigned char word[LINEMAXLENGTH], *current=start, *longuest=NULL;
	unsigned long int wordid;
	TERM *tnode;
	if(sscanf(current,"%s", word)==EOF)
		return NULL;
	wordid=DictFind(word, &dict); /* identify current word */
	if(thesaurus[wordid].wordid==0) /* word was not recognized */
		return NULL;
	tnode=&thesaurus[wordid];
	current+=strlen(word)+1;
	if(tnode->isfinal)
		longuest=current;
	while(sscanf(current,"%s", word)!=EOF)
	{
		tnode=Find(tnode, DictFind(word, &dict));
		if(tnode==NULL)
			break;
		current+= strlen(word)+1;
		if(tnode->isfinal)
			longuest=current;
	}
	return longuest;
}

void serve_client(int fdClient)
{

	unsigned char *eterm, term[LINEMAXLENGTH];	/* pointers to start and end of term */
	FILE * in, * out;
  	unsigned char word[LINEMAXLENGTH];
	unsigned char input[LINEMAXLENGTH], *current;
	unsigned char buffer[BUFFERMAXLENGTH];

  	int fd2;
  
  	if((in  = fdopen(fdClient,"r"))==NULL) {
		perror("While opening fdClient for reading ");
		exit(EXIT_FAILURE);
	}
	fd2 = dup(fdClient);
	out = fdopen(fd2, "w");
	input[0]='\0';
	while(fgets(buffer,BUFFERMAXLENGTH,in) != NULL) {	/* read the text, line after line */
		current=buffer;			/* initialize current character */
		while(sscanf(current,"%s", word)!=EOF) { /* For each possible term beginning */
			eterm=FindLonguestTerm(current);
			if(eterm==NULL){	/* Next word */
				current+= strlen(word)+1;
			}
			else {	/* A term was found */
				strncpy(term+2, current, eterm-current);
				term[eterm-current+1]='\0';
				term[0]=term[1]='[';
				while(term[strlen(term)-1]==' '||term[strlen(term)-1]=='\n') /* remove trailing blanks */
					term[strlen(term)-1]='\0';
				term[strlen(term)+2]='\0';
				term[strlen(term)]=term[strlen(term)+1]=']';
				printf("Sending %s\n", term);			
				strcat(input, term);
				strcat(input,"\n");	
				current=eterm;
			}
		}
		if(input[0]=='\0')
			strcat(input,"\n");
		fprintf(out, "%s", input);
		fflush(out);
	}		
	
	fclose(in);
	fflush(out);  
	fclose(out);
}


