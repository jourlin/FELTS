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


void NormaliseUTF8(unsigned char *buffer)
{
	static unsigned char from[]= "\047.;,:!?\042ABCDEFGHIJKLMNOPQRSTUVWXYZÅÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ";
	static unsigned char to[]=         "        abcdefghijklmnopqrstuvwxyzåâáàäêéèëïíîöóôöúùûñç";
	unsigned char in[5];
	unsigned char *where;
	unsigned int nbytes, i;
	
	while(*buffer!='\0')	{
		if ((*buffer>=192) && (*buffer<224)) 		/* 2-bytes char */
			nbytes=2;
		else if ((*buffer>=224) && (*buffer<240))  	/* 3-bytes char */
			nbytes=3;
		else if (*buffer>=240)  			/* 4-bytes char */
			nbytes=4;
		else 						/* 1-byte char	*/
			nbytes=1;
		in[nbytes]='\0';	/* copy current char in string 'in' */
		for(i=0; (i<nbytes) && (*buffer!='\0'); i++)
			in[i]=*buffer++;
		where=strstr(from, in);	/* Try and find current char */
		if(where != NULL) 	/* found it, then translate */
			strncpy(buffer-nbytes, to+(where-from), nbytes);	
		
	}
		
}

unsigned char * skip_blanks(unsigned char *s)
{
	while(*s==' '||*s=='\t')
		s++;
	return s;
}

unsigned char * find_word_end(unsigned char *s)
{
	while(*s!=' ' && *s!='\t' && *s!='\n')
		s++;
	return s-1;
}

void serve_client(int fdClient)
{
	FILE * in, * out;
	unsigned char *WordStart, *WordEnd, *TermStart;
	unsigned int Start, End, nwords;
	unsigned char buffer[BUFFERMAXLENGTH];
	unsigned char CurrentTerm[BUFFERMAXLENGTH];
  	cmph_uint32 HashIndex;
  	int fd2;
  	int AtLeastOneTerm;
  	if((in  = fdopen(fdClient,"r"))==NULL) {
		perror("While opening fdClient for reading ");
		exit(EXIT_FAILURE);
	}
	fd2 = dup(fdClient);
	out = fdopen(fd2, "w");

	while(fgets(buffer,BUFFERMAXLENGTH,in) != NULL) {	/* read the text, line after line */
		if(buffer[strlen(buffer)-1]!='\n'){
			fprintf(stderr, "Error: line too long\n");
			exit(-1);
		}
		if(buffer[0]=='\0'){				/* do not process empty lines */
			fprintf(out,"\n"); 
			fflush(out); 
			continue;	   			/* Process next line */
		}
		NormaliseUTF8(buffer);		/* UTF8 tolower + punctuation removal */
		TermStart=buffer;		/* initialize current character */
		TermStart=skip_blanks(TermStart);
		AtLeastOneTerm=FALSE;
		do{				/* For each word in line */
			CurrentTerm[0]='\0';
			nwords=0;
			WordStart=skip_blanks(TermStart);
			Start=WordStart-buffer;
			do{					/* For each possible term word length */

				WordStart=skip_blanks(WordStart);
				WordEnd=find_word_end(WordStart);
				End=WordEnd-buffer;
				strncat(CurrentTerm, WordStart, WordEnd-WordStart+1);
				nwords++;
				HashIndex=cmph_search(hash, CurrentTerm, (cmph_uint32)strlen(CurrentTerm));
				if(HashIndex<=NDistinctTerms && strcmp(LookupTable[HashIndex], CurrentTerm)==0){
					fprintf(out, "%u %u \"%s\"\n", Start, End, CurrentTerm);
					AtLeastOneTerm=TRUE;
				}
				WordStart=WordEnd+1;
				if(*WordStart!='\n')
					strcat(CurrentTerm, " "); 
			}while(*WordStart!='\n' && nwords<MaxWordsPerTerm);
			TermStart=find_word_end(TermStart)+1;
			TermStart=skip_blanks(TermStart);
		}while(*TermStart!='\n');
		if(!AtLeastOneTerm)
			fprintf(out,"\n"); /* end of response */
		fprintf(out,"\n"); /* end of response */
		fflush(out);
	}		
	fclose(in);
	fflush(out);  
	fclose(out);
}


