FELTS
=====

FELTS is a Fast Extractor for Large Term Sets.
It was successfully tested with over 9.5 millions of distinct multiword terms composed of over 4.5 million distinct words (Wikipedia article titles for french + english + spanish). In this particular task :
- it allows extracting from any text, all occurences of wikipedia french, english or spanish entries
- it only requires 500 Mb of RAM
- it can process ten million of words less than an hour

USE :

- create a dictionnary file with a sorted list of multiword terms (one term per line, one space between words).
- set the DICT variable in makefile to your dictionnary file 
- make the executable files : mkdir bin ; make 
- make the hash function : 
> make mph
- start a server, e.g : 
> bin/felts_server -p 11111 -d dic/sample.dic -f dic/sample.mph
- extract terms, e.g. : 
> cat text_in.txt | sed 's/[[:space:]][[:space:]]*/ /g' | sed 's/^[[:space:]]//' | bin/felts_client localhost 11111 | sed '/^$/d' > terms_out.txt

WARNING : input text should be utf-8, lower case, without punctuation and words must be separated by a single space.
          (that justifies the sequence of filters used before sending the text to felts_client)


