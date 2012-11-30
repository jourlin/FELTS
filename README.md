FELTS
=====

FELTS is a Fast Extractor for Large Term Sets - successfully tested with over 5 millions distinct multiword terms composed of over 2 million distinct words.
USE:
- start a server, e.g : bin/felts_server sample.dic 11111 
- extract terms, e.g. : cat text_in.txt | tr '.;,:!?"' '\n\n\n\n\n\n\n'| tr 'A-ZÅÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zåâáàäêéèëïíîöóôöúùûñç'| sed 's/[[:space:]][[:space:]]*/ /g' | sed 's/^[[:space:]]//' | bin/felts_client localhost 11111 | sed '/^$/d' > terms_out.txt

WARNING : input text should be utf-8, lower case, without punctuation and words must be separated by a single space.
          (that justifies the sequence of filters used before sending the text to felts_client


