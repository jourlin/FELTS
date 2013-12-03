# DICT is a file containing one term per line. A term is a list of words separated by a single space.
DICT = dic/sample.dic
BDICT= $(basename $(DICT))
OPT = -Wall -O
all:	 /usr/local/include/cmph.h mph bin/felts_server bin/felts_client
clean:	
	rm -f *~ src/*~ bin/*
/usr/local/include/cmph.h:	
	cd "cmph-2.0";./configure;make;sudo make install;cd ..
mph:	/usr/local/include/cmph.h $(DICT)
	cmph -v -g -a chd $(DICT)
	mv $(DICT).mph $(BDICT).mph
	
bin/felts_server:	src/felts_server.c src/felts.h src/tcp_server.c src/felts_extract.c
	gcc $(OPT) -o bin/felts_server src/felts_server.c src/tcp_server.c src/felts_extract.c -lpthread -lcmph
bin/felts_client:	src/felts_client.c
	gcc $(OPT) -o bin/felts_client src/felts_client.c
	

