#!/bin/bash
# MC2 CLEF 2017
d="20170301"
LANGUAGES1="en es pt fr"
cut -f1,11 data/clef_mc2_task1_topics.txt  > data/clef_mc2_task1_topics.content.txt
cut -f1 data/clef_mc2_task1_topics.txt > data/clef_mc2_task1_ids.txt
psql -c "DROP TABLE IF EXISTS task1_ids;"
psql -c "CREATE TABLE task1_ids(id BIGSERIAL, id_original BIGINT);"
psql -c "COPY task1_ids(id_original) FROM '/home/jourlin/Recherche/FELTS/clef/data/clef_mc2_task1_ids.txt'  DELIMITER ',' CSV"
for l in $LANGUAGES1
do
     wget https://dumps.wikimedia.org/${l}wiki/${d}/${l}wiki-${d}-pages-articles-multistream.xml.bz2
     bunzip2 ${l}wiki-${d}-pages-articles-multistream.xml.bz2    
 grep '<title>' ${l}wiki-${d}-pages-articles-multistream.xml | sed 's:.*<title>::' |sed 's:</title>::'| sed 's: (.*::'|  tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç' | sort -u > ../dic/${l}wiki-${d}.dic
cmph -v -g -a chd ../dic/${l}wiki-${d}.dic
mv ../dic/${l}wiki-${d}.dic.mph ../dic/${l}wiki-${d}.mph
 ../bin/felts_server -p 11111 -d ../dic/${l}wiki-${d}.dic -f ../dic/${l}wiki-${d}.mph &
sleep 60
cat  data/clef_mc2_task1_topics.content.txt | sed 's/[[:space:]][[:space:]]*/ /g' | sed 's/^[[:space:]]//' | sed 's:[@#]::g'| ../bin/felts_client localhost 11111 | sed '/^$/d'| sed 's:,\t:,:' | sed 's:,[^"]*:,:' > data/clef_mc2_task1_topics.${l}.csv
psql -c "DROP TABLE IF EXISTS entity_"${l}";"
psql -c "CREATE TABLE entity_"${l}"(id bigint, term varchar(600));"
psql -c "COPY entity_"${l}"(id, term) FROM '/home/jourlin/Recherche/FELTS/clef/data/clef_mc2_task1_topics.${l}.csv'  DELIMITER ',' CSV"
psql -c "DROP TABLE IF EXISTS mc2_entity_"${l}";"
psql -c "CREATE TABLE mc2_entity_"${l}" AS SELECT id_original as id, term, char_length(term) FROM entity_"${l}", task1_ids WHERE task1_ids.id=entity_"${l}".id ORDER BY id_original ASC, char_length(term) DESC;"
psql -c "DROP TABLE IF EXISTS task1e_entities_"${l}";"
psql -c "CREATE TABLE task1e_entities_"${l}"(id varchar(20), entity0 varchar(80), entity1 varchar(80),entity2 varchar(80),entity3 varchar(80),entity4 varchar(80),entity5 varchar(80),entity6 varchar(80),entity7 varchar(80),entity8 varchar(80),entity9 varchar(80));"
	psql -c "INSERT INTO task1e_entities_"${l}"(id, entity0) SELECT id, term FROM (SELECT id, term, row_number() OVER (PARTITION BY id ORDER BY char_length DESC) FROM mc2_entity_"${l}") as X WHERE X.row_number=1;"
	for i in 1 2 3 4 5 6 7 8 9 
	do
	psql -c "UPDATE task1e_entities_"${l}" SET entity"${i}" = X.term FROM (SELECT id, term, row_number() OVER (PARTITION BY id ORDER BY char_length DESC) FROM mc2_entity_"${l}") as X WHERE task1e_entities_"${l}".id=CAST(X.id AS VARCHAR(20)) AND X.row_number="$[i+1]";"
	done
done
