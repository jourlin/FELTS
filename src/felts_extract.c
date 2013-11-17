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
	if(HASH)
		wordid=cmph_search(hash, word, (cmph_uint32)strlen(word));
	else
		wordid=DictFind(word, &dict); /* identify current word */
	if(thesaurus[wordid].wordid==0) /* word was not recognized */
		return NULL;
	tnode=&thesaurus[wordid];
	current+=strlen(word)+1;
	if(tnode->isfinal)
		longuest=current;
	while(sscanf(current,"%s", word)!=EOF)
	{
		if(HASH)
			tnode=Find(tnode, cmph_search(hash, word, (cmph_uint32)strlen(word)));
		else
			tnode=Find(tnode, DictFind(word, &dict));
		if(tnode==NULL)
			break;
		current+= strlen(word)+1;
		if(tnode->isfinal)
			longuest=current;
	}
	return longuest;
}

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

void InverseWords(char *line) {
	static char tmp[BUFFERMAXLENGTH];
	static char *backward, *forward;
	static char word[LINEMAXLENGTH];

	backward=line+strlen(line)-1;	/* skip \000 */
	forward=tmp;
	if(*backward=='\n')		/* skip \n   */
		backward--;
	while(*backward==' ')		/* skip left spaces */
		backward--;
	while(backward>line) {
		backward=GetLastWord(word, backward, line);
		strcpy(forward, word);
		forward+=strlen(word);
		if(backward>line)
			*forward++=' ';
	}
	*forward='\0';
	strcpy(line, tmp);	
}

int CountWords(char *line){
	int count=0;
	while(*line==' ')
		line++; 	/* skip blanks */
	while(*line!='\0' && *line!='\n'){
		while(*line!='\0' && *line!=' ') /* skip word */
			line++;
		count++;
		while(*line==' '||*line=='\n')
			line++; 	/* skip blanks */
	}
	return count;
}

int OffsetWordNumber(char *line, int posword){
	char *pos=line;
	while(*pos==' ')
		pos++; 	/* skip blanks */
	while(posword!=0 && *pos!='\0'){
		while(*pos!='\0' && *pos!=' ') /* skip word */
			pos++;
		posword--;
		while(*pos==' ')
			pos++; 	/* skip blanks */
	}
	return pos-line;
}


void serve_client(int fdClient)
{

	unsigned char *eterm, term[LINEMAXLENGTH];	/* pointers to start and end of term */
	FILE * in, * out;
  	unsigned char word[LINEMAXLENGTH];
	unsigned char *current;
	unsigned char buffer[BUFFERMAXLENGTH];
	unsigned char invbuffer[BUFFERMAXLENGTH];
	int pos, posword;
  	int fd2;
  	int AtLeastOneTerm;
  	if((in  = fdopen(fdClient,"r"))==NULL) {
		perror("While opening fdClient for reading ");
		exit(EXIT_FAILURE);
	}
	fd2 = dup(fdClient);
	out = fdopen(fd2, "w");

	while(fgets(buffer,BUFFERMAXLENGTH,in) != NULL) {	/* read the text, line after line */
		if(buffer[0]=='\0'){		/* do not process empty lines */
			fprintf(out,"\n"); 
			fflush(out); 
			continue;	   /* Process next line */
		}
		NormaliseUTF8(buffer);		/* UTF8 tolower + punctuation removal */
		strcpy(invbuffer, buffer);
		InverseWords(invbuffer);		/* Read words for right to left */
		//printf("**%s**\n", invbuffer);
		current=invbuffer;			/* initialize current character */
		current=skip_blanks(current);
		AtLeastOneTerm=FALSE;
		posword=0;
		while(sscanf(current,"%s", word)!=EOF) { /* For each possible term beginning */
			eterm=FindLonguestTerm(current);
			if(eterm==NULL){	/* Next word */
				current+= strlen(word)+1;
				current=skip_blanks(current);
				posword++;
			}
			else {	/* A term was found */
				AtLeastOneTerm=TRUE;
				strncpy(term, current, eterm-current);
				term[eterm-current]='\0';
				while(term[strlen(term)-1]==' '||term[strlen(term)-1]=='\n') /* remove trailing blanks */
					term[strlen(term)-1]='\0';
				term[strlen(term)]='\0';
				pos=OffsetWordNumber(buffer,CountWords(buffer)-CountWords(term)-posword);
				posword=posword+CountWords(term);
				//printf("Original term: *%s*\n", term);
				InverseWords(term);
				printf("Sending %d, \"%s\" posword %d %d %d\n", pos, term, CountWords(buffer),CountWords(term),posword);
				fprintf(out, "%d,\t\"%s\"\n", pos, term);	
				fflush(out);		
				current=eterm;
				current=skip_blanks(current);	
			}
		}
		if(!AtLeastOneTerm)
			fprintf(out,"\n"); 
		fprintf(out,"\n"); /* end of response */
		fflush(out); 
	}		
	
	fclose(in);
	fflush(out);  
	fclose(out);
}


