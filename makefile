# DICT is a file containing one term per line. A term is a list of words separated by a single space.
DICT = dic/sample.dic
BDICT= $(basename $(DICT))
all:	cmph mph bin/felts_server bin/felts_client
clean:	
	rm -f *~ src/*~ bin/*
/usr/local/include/cmph.h:	
	cd "cmph-2.0";./configure;make;sudo make install;cd ..
mph:	/usr/local/include/cmph.h $(DICT)
	cat $(DICT) | tr ' ' '\n'| sort -u > $(BDICT).words
	cmph -v -g -a chd $(BDICT).words
	mv $(BDICT).words.mph $(BDICT).mph
	
bin/felts_server:	src/felts_server.c src/felts.h src/tcp_server.c src/felts_extract.c
	gcc -o bin/felts_server src/felts_server.c src/tcp_server.c src/felts_extract.c -lpthread -lcmph
bin/felts_client:	src/felts_client.c
	gcc -o bin/felts_client src/felts_client.c
	

