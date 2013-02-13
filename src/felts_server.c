/* 
  felts_server.c : Server for the Fast Extractor for Large Term Sets 

    Copyright (C) 2012  Pierre Jourlin

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
  felts_server.c : Serveur pour l'Extracteur Rapide pour Grands Ensembles de Termes

  Copyright (C) 2012 Pierre Jourlin — Tous droits réservés.
 
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
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

#include "felts.h"

unsigned long bytecount=0;
NODE dict;
TERM *thesaurus;	/* array of (multi-word) terms */

	
void error(const char *msg)
{
    perror(msg);
    exit(1);
}

TERM* FindOrCreateNextAlternative(TERM *current, unsigned long int wordid)
{
	
	if(current->next==NULL) /* A new next alternative */
	{
		current->next=(TERM *) malloc(sizeof(TERM));
		bytecount+=sizeof(TERM);
		current=current->next;
		current->wordid=wordid;
		current->next=NULL;
		current->alter=NULL;
		current->isfinal=FALSE;
		return current;
	}
	current=current->next;
	while(current->alter!=NULL && current->wordid!=wordid)
		current=current->alter;
	if(current->wordid==wordid)
		return current;
	else
	{
		current->alter=(TERM *) malloc(sizeof(TERM));
		bytecount+=sizeof(TERM);
		current=current->alter;
		current->wordid=wordid;
		current->next=NULL;
		current->alter=NULL;
		current->isfinal=0;
		return current;
	}
};

unsigned long int DictFind(unsigned char *word, NODE *dict)
{
	unsigned char *pt=word;
	NODE *node=dict;
	while((*pt!='\n') && (*pt!='\0') && (node->next[*pt]!=NULL))
		node=node->next[*pt++];
	if(((*pt=='\n') || (*pt=='\0')) && (node->number>0))
		return node->number;
	else
		return 0;	
}

void Blank(NODE *node)
{
	int i;
	if(node!=NULL)
		for(i=0; i<=255; i++)
			node->next[i]=NULL;
	node->number=0;	
}


/* -------------------------------------------------------------*/
void usage(char prog[])
{
     printf("Usage : %s [options]\n", prog);
     printf("Options :\n"
            "-h\tthis message\n"
            "-p port\tport number          [%d]\n"
            "-d dic \tdictionary [%s]\n",
            DEFAULT_PORT, DEFAULT_DIC);
}

char * GetLastWord(char *word, char * current, char *start)
{
	int i=0;
	while(current>=start && *current!=' '){
		current--;
		i++;
	};
	current++;	/* current points to the first character of current word */
	strncpy(word, current, i);
	word[i]='\0';
	if(current!=start)
		current--;
	while((current>=start) && *current==' ')
		current--; 
	return current;
}

/* -------------------------------------------------------------*/

int main(int argc, char *argv[])
{
	/* Thesaurus variables */
	NODE  *cnode=&dict; /* dictionary (words) */
	TERM  *tnode;
	unsigned char cchar;
	unsigned long int nbwords=0, nbterms=0;
	unsigned char input[LINEMAXLENGTH], *current;
	unsigned char word[LINEMAXLENGTH];

	int i;
	FILE *DictFile;

	int   port =       DEFAULT_PORT;
     	char *dic = DEFAULT_DIC;	/* dictionary file */
     	char c;
	
	
     	while ((c = getopt(argc, argv, "hp:d:")) != -1)
          switch (c) {
          	case 'h':
               		usage(argv[0]);
               		exit(EXIT_SUCCESS);
               	break;
          	case 'p':
               		port = atoi(optarg);
               	break;
          	case 'd':
               		dic = optarg;
               	break;
          	case '?':
               		fprintf(stderr, "unrecognized option -%c. -h for help.\n", optopt);
               	break;
          }
	  
	printf("Serving dictionary %s on port %d\n", dic, port);
	/* Initialisation */
	#ifdef DEBUG
		printf("WARNING : %s was compiled with DEBUG and will process a maximum of 1000 terms\n", argv[0]);
	#endif
	
	if((DictFile=fopen(dic, "r"))==NULL)
	{
		fprintf(stderr, "Could not open %s\n", dic);
		exit(-1);
	}	
	Blank(cnode);
	nbterms=0;
	/* Load dictionary in RAM */
	while(!feof(DictFile))
	{
		#ifdef DEBUG
		nbterms++;
		if(nbterms>1000) 
			break;
		#endif

		cchar=fgetc(DictFile);
		if(cchar=='\047')			/* tranforms simple quotes in spaces */
			cchar=' ';
		if(cchar=='\n'||cchar==' ')
		{
			if(nbwords%500000==0)
				printf("Dictionary loaded with %ld words (%ld Mb)\n", nbwords, bytecount/1024/1024);

			if(cnode->number==0) // Word is unseen ?
				cnode->number=++nbwords;
			cnode=&dict;
		}
		else if(cnode->next[cchar]==NULL)
		{
			cnode->next[cchar]=(NODE *) malloc(sizeof(NODE));
			bytecount+=sizeof(NODE);
			Blank(cnode->next[cchar]);
			cnode=cnode->next[cchar];
			cnode->number=0; 
		}
		else
			cnode=cnode->next[cchar];

		
	}
	fclose(DictFile);
	printf("Dictionary loaded with %ld words (%ld Mb)\n", nbwords, bytecount/1024/1024);
	
	/* Thesaurus initialisation */
	thesaurus= (TERM *) malloc(MAXWORDS*sizeof(TERM));
	bytecount+=MAXWORDS*sizeof(TERM);
	printf("Dictionary loaded with %ld words (%ld Mb)\n", nbwords, bytecount/1024/1024);
	for(nbwords=0; nbwords<MAXWORDS; nbwords++)
	{
		thesaurus[nbwords].next=NULL;
		thesaurus[nbwords].alter=NULL;
		thesaurus[nbwords].wordid=0;
		thesaurus[nbwords].isfinal=TRUE;
	}	
	if((DictFile=fopen(dic, "r"))==NULL)
	{
		fprintf(stderr, "Could not open %s\n", dic);
		exit(-1);
	}
	/* Load Thesaurus */
	nbterms=0;
	while(!feof(DictFile))
	{
		if(fgets(input, LINEMAXLENGTH, DictFile)==NULL)
			break;
					/* Turn simple quotes into spaces */
		current=input;
		while(*current!='\0'){
			if(*current=='\047')
				*current=' ';
			current++;
		};
					/* Process Term */
		nbterms++;
#ifdef DEBUG
		if(nbterms>1000) 
			break;
#endif
		
		
		current=input+strlen(input)-2; /* -2 allows to ignore terminal \n\000 */
		current=GetLastWord(word, current, input);
		printf("%s ", word);
		nbwords=DictFind(word, &dict); /* identify current word */
		thesaurus[nbwords].wordid=nbwords;
		tnode=&thesaurus[nbwords];	
		/* current points to the last word's last character of current term */
		while(current>input) /* get words from right to left */
		{
			current=GetLastWord(word, current, input);
			printf("%s ", word);
			tnode=FindOrCreateNextAlternative(tnode, DictFind(word, &dict));
		}
		printf("\n");
		tnode->isfinal=TRUE;
		if(nbterms%1000000==0)
			printf("Thesaurus loaded with %ld terms (%ld Mb)\n", nbterms, bytecount/1024/1024);
	};
	fclose(DictFile);
	printf("Thesaurus loaded with %ld terms (%ld Mb)\n", nbterms, bytecount/1024/1024);
	
	demarrer_serveur(port, dic);
    	exit(EXIT_SUCCESS);
     	return; 
}
		
