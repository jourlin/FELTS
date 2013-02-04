all:	bin/felts_server bin/felts_client
clean:	
	rm -f *~ src/*~ bin/*

bin/felts_server:	src/felts_server.c src/felts.h src/tcp_server.c src/felts_extract.c
	gcc -o bin/felts_server src/felts_server.c src/tcp_server.c src/felts_extract.c -lpthread
bin/felts_client:	src/felts_client.c
	gcc -o bin/felts_client src/felts_client.c
	

