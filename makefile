all:	bin/felts_server bin/felts_client
clean:	
	rm -f *~ src/*~ bin/*
bin/felts_server:	src/felts_server.c 
	gcc -o bin/felts_server src/felts_server.c
bin/felts_client:	src/felts_client.c
	gcc -o bin/felts_client src/felts_client.c
	

