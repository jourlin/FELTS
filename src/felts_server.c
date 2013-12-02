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
#include <cmph.h>		// http://cmph.sourceforge.net/ (LGPL / MPL 1.1.)
#include "felts.h"

cmph_t *hash ;
unsigned long int NDistinctTerms=0, MaxWordsPerTerm=0, MaxCharsPerTerm=0;
unsigned char **LookupTable;
	
void error(const char *msg)
{
    perror(msg);
    exit(1);
}

/* -------------------------------------------------------------*/
void usage(char prog[])
{
     printf("Usage : %s [options]\n", prog);
     printf("Options :\n"
            "-h\tthis message\n"
            "-p port\tport number          [%d]\n"
            "-d dic \tdictionary [%s]\n"
	    "-f mph \tminimal_perfect_hash_file [%s]\n",
            DEFAULT_PORT, DEFAULT_DIC, DEFAULT_HASH_FN);
}


/* -------------------------------------------------------------*/

int main(int argc, char *argv[])
{

	unsigned long int WordsPerTerm, CharsPerTerm;

	FILE *MPHFFile;
	int   port 	= DEFAULT_PORT;
     	char *hash_fn 	= DEFAULT_HASH_FN;	/* dictionary file */
	char c;
	int i;
	NDistinctTerms=0;
	WordsPerTerm=0;
	CharsPerTerm=0;
	FILE *DictFile;
	char *DictFileName;
	char *term;

     	while ((c = getopt(argc, argv, "hp:d:f:")) != -1)
          switch (c) {
          	case 'h':
               		usage(argv[0]);
               		exit(EXIT_SUCCESS);
               	break;
          	case 'p':
               		port = atoi(optarg);
               	break;
          	case 'd':
               		DictFileName = optarg;
               	break;
          	case 'f':
               		hash_fn = optarg; 
               	break;
          	case '?':
               		fprintf(stderr, "unrecognized option -%c. -h for help.\n", optopt);
               	break;
        }  
	printf("Initialising server for dictionary %s on port %d\n", DictFileName, port);
	
	if((DictFile=fopen(DictFileName, "r"))==NULL)
	{
		fprintf(stderr, "Could not open %s\n", DictFileName);
		exit(-1);
	}
	while(!feof(DictFile)){				/* Get limits */
		WordsPerTerm=0;
		CharsPerTerm=0;
		do{					/* Process a term */
			CharsPerTerm=0;
			do{
				c=fgetc(DictFile);
				CharsPerTerm++;
			}while(!feof(DictFile) && (c==' ' || c=='\t'));     /* Skip spaces    */
			while(c!=' ' && c!='\t' && c!='\n' && !feof(DictFile)){			/* Process a word */
				c=fgetc(DictFile);
				CharsPerTerm++;
			};
			WordsPerTerm++;
		}while(c!='\n' && !feof(DictFile));
		NDistinctTerms++;
		if(WordsPerTerm>MaxWordsPerTerm)
			MaxWordsPerTerm=WordsPerTerm;
		WordsPerTerm=0;
		if(CharsPerTerm>MaxCharsPerTerm)
			MaxCharsPerTerm=CharsPerTerm;
		CharsPerTerm=0;
	}
	fclose(DictFile);
	printf("Found %lu distinct terms composed of a maximum of %lu words and a maximum of %lu bytes\n", NDistinctTerms, MaxWordsPerTerm, MaxCharsPerTerm);
	if((MPHFFile=fopen(hash_fn, "r"))==NULL){
		fprintf(stderr, "Error : Could not open %s\n", hash_fn);
		exit(-1);
	};	

	/* Load the minimal perfect hash function */
	hash = cmph_load(MPHFFile); 	
	LookupTable=(unsigned char **) malloc(NDistinctTerms*sizeof(unsigned char*));
	for(i=0;i<NDistinctTerms;i++){			/* Make empty strings */
		LookupTable[i]=(char *) malloc(MaxCharsPerTerm*sizeof(unsigned char));
		LookupTable[i][0]='\0';
	}
	term=(char *) malloc(MaxCharsPerTerm*sizeof(unsigned char));
	if((DictFile=fopen(DictFileName, "r"))==NULL)
	{
		fprintf(stderr, "Could not open %s\n", DictFileName);
		exit(-1);
	}
	while(!feof(DictFile)){				/* Load dictionary in RAM 	*/
		fgets(term, MaxCharsPerTerm*sizeof(unsigned char), DictFile);
		term[strlen(term)-1]=0;			/* Replace \n by \0		*/
		strcpy(LookupTable[cmph_search(hash, term, (cmph_uint32)strlen(term))],term);		
	}
	fclose(DictFile);
	printf("Hash Function loaded\n");
	
	
	demarrer_serveur(port, DictFileName);
	/* Destroy hash */
      	cmph_destroy(hash);
	fclose(MPHFFile);
    	exit(EXIT_SUCCESS);
     	return; 
}
		
