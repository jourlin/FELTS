FELTS
=====

FELTS is a Fast Extractor for Large Term Sets.
It was successfully tested with over 9.5 millions of distinct multiword terms composed of over 4.5 million distinct words (Wikipedia article titles for french + english + spanish). In this particular task :
- it allows extracting from any text, all occurences of wikipedia french, english or spanish entries
- it only requires 500 Mb of RAM
- it can process ten million of words less than an hour

USE :

- create a dictionnary file with a sorted list of multiword terms (one term per line, one space between words).
          - for example :
          - wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles-multistream.xml.bz2
          - bunzip2 enwiki-latest-pages-articles-multistream.xml.bz2
          - egrep -o '\[\[[^]]*\]\]' enwiki-latest-pages-articles-multistream.xml | egrep -v "\[\[[^:]:[^:]" | sed 's:\[\[::g' | sed 's:.*|::' | sed 's:\]\]::g' | egrep -v "Category:" |  tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç' | sort -u > dic/sample.dic
          (This will create in dic/sample.dic a list of all (lower case) terms in english wikipedia articles that are linked explicitly to wikipedia pages.
- set the DICT variable in makefile to your dictionnary file 
- make the executable files : mkdir bin ; make 
- make the hash function : 
> make mph
- start a server, e.g : 
> bin/felts_server -p 11111 -d dic/sample.dic -f dic/sample.mph
- extract terms, e.g. : 
> cat text_in.txt | sed 's/[[:space:]][[:space:]]*/ /g' | sed 's/^[[:space:]]//' |tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç'| bin/felts_client localhost 11111 | sed '/^$/d' > terms_out.txt

WARNING : input text should be utf-8, lower case, without punctuation and words must be separated by a single space.
          (that justifies the sequence of filters used before sending the text to felts_client)

===
Note : Making of the dictionnary of all words used in en+es+fr wikipedia :
---
cat enwiki-20160601-pages-articles-multistream.xml frwiki-20160601-pages-articles-multiream.xml eswiki-20160601-pages-articles-multistream.xml | egrep -o " [A-Za-zÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇâáàäêéèëïíîöóôöúùûñç]* " | sed 's/^ //' | sed 's/ $//' | tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç' | sort -u > en+es+fr+wiki-20160601.dic
---
Remove accents :
---
cat enwiki-20160601-pages-articles-multistream.xml frwiki-20160601-pages-articles-multiream.xml eswiki-20160601-pages-articles-multistream.xml | egrep -o " [A-Za-zÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇâáàäêéèëïíîöóôöúùûñç]* " | sed 's/^ //' | sed 's/ $//' | tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zaaaaeeeeiiioooouuunc' | sort -u > en+es+fr+wiki-20160601.dic
