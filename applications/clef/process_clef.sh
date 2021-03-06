#!/bin/bash
d="20170301"
LANGUAGES="ru"
#LANGUAGES="en sv ceb de nl fr ru it es war pl vi ja pt zh uk ca fa no ar sh fi hu id ro cs ko sr ms tr eu eo bg min da kk sk hy zh-min-nan he lt hr ce sl et gl nn uz la el be simple vo hi az ur ka af  als  am  an  arz  ast  azb  ba  bar  bat-smg  be-tarask  bn  bpy  br  bs  bug  ckb  cv  cy  fo  fy  ga  gd  gu  hsb  ht  ia  io  is  jv  kn  ku  ky  lb  li  lmo  lv  map-bms  mg  mk  ml  mn  mr  mrj  mzn  nah  nap  nds  ne  new  oc  or  os  pa  pms  pnb  qu  sa  sah  scn  sco  si  sq  su  sw  ta  te  tg  tl  tt  vec  wa  yi  yo  zh-yue hif  mhr  ilo  roa-tara  pam  xmf  eml  sd  ps  nso  bh  se  hak  mi  bcl  diq  nds-nl  gan  glk  vls  rue  bo  wuu  mai  fiu-vro  co  tk  szl  sc  csb  vep  lrc  crh  gv  kv  frr  zh-classical  as  so  zea  cdo  lad  ay  stq  udm  kw  nrm  ie  koi  ace  rm  pcd  myv  lij  mt  fur  gn  dsb  dv  cbk-zam  ext  lez  ug  kab  ang  ksh  mwl  ln  gag  sn  frp  gom  pag  pi  nv  av  pfl  xal  krc  haw  kaa  bxr  rw  pdc  to  nov  kl  pap  arc  bjn  olo  kbd  jam  ha  tet  tyv  ki  tpi  ig  na  lbe  roa-rup  jbo  ty  kg  za  mdf  lg  wo  srn ab  ltg  zu  sm  om  bi  tcy  tn  chy  cu  rmy  tw  xh  tum  pih  rn  got  pnt  ss  ch  bm  ady  mo  ts  ny  iu  st  fj  ee  ak  ks  ik  sg  ve  dz  ff  ti  cr"

# Languages ignored : chr, my, lo, th, km
# cat data/clef_microblogs_festival.txt | cut -f1,4 |sed 's:^[^0-9].*:xxxxxxxxxxxxxxxxxx\t00:'> data/id_lang.csv
# psql -dclef -c"DROP TABLE microblog ;"
# psql -dclef -c"CREATE TABLE microblog (id serial, id_original varchar(32), lang varchar(50));"
# psql -dclef -c "COPY microblog(id_original, lang) FROM '/home/jourlin/Recherche/FELTS/clef/data/id_lang.csv' DELIMITER E'\t' CSV"

# psql -dclef -c "UPDATE microblog SET lang='en' WHERE lang='en-gb' OR lang='en-GB' OR lang='en-IN' OR lang='en-US' OR lang='en-CA' OR lang='en-AU' OR lang='en-xx'";
# psql -dclef -c "UPDATE microblog SET lang='zh' WHERE lang='zh-tw' OR lang='zh-cn' OR lang='zh-TW' OR lang='zh-CN' OR lang='zh-Hans' OR lang='zh-Hant' OR lang='zh-HK' OR lang='zh-SG'";
# psql -dclef -c "UPDATE microblog SET lang='es' WHERE lang='es-MX' OR lang='es-429' OR lang='es-ES'";
# psql -dclef -c "UPDATE microblog SET lang='pt' WHERE lang='pt-PT' OR lang='pt-BR'";
# psql -dclef -c "UPDATE microblog SET lang='fr' WHERE lang='fr-CA' OR lang='fr-CH'";
# psql -dclef -c "UPDATE microblog SET lang='nl' WHERE lang='nl-BE'";
# psql -dclef -c "UPDATE microblog SET lang='de' WHERE lang='de-AT' OR lang='de-CH'";
# psql -dclef -c "UPDATE microblog SET lang='th' WHERE lang='th_th'";
# psql -dclef -c "UPDATE microblog SET lang='00' WHERE lang='xx-lc' OR lang='Select Lan' OR lang='Sélection' OR lang='Selecionar' OR lang='选择语' OR lang='Selecciona' OR lang='選擇語' OR lang='言語を' OR lang='Seleziona' OR lang='Pilih Baha' OR lang='Sprache au' OR lang='เลื' OR lang='Selecione' OR lang='Seleccione' OR lang='Selecteer' OR lang='언어 선' OR lang='lolc' OR lang='Wybierz j' OR lang='Επιλο ' OR lang='Dil Seç..'";

# TASK1 MC2 CLEF 2017
# cut -f1,11 data/clef_mc2_task1_topics.txt > data/task1.csv
# psql -c "DROP TABLE IF EXISTS task1; CREATE TABLE task1 (id_original VARCHAR(32), content VARCHAR(200));"
# psql -c "COPY task1(id_original) FROM '/home/jourlin/Recherche/FELTS/clef/data/task1.csv' DELIMITER E'\t' CSV"


# cut -f11 data/clef_microblogs_festival.txt > data/clef_microblogs_festival.content.txt
# keep only the first 200 characters of each "word"
# cat ../dic/*-${d}-*.freq2 | sed 's:"::g' | sed 's: *: :' | cut -d' ' -f3 |cut -c1-200 | sort -u > ../dic/all-languages-${d}.dic
 
# cmph -v -g -a chd ../dic/all-languages-${d}.dic
# mv ../dic/all-languages-${d}.dic.mph ../dic/all-languages-${d}.mph
# ../bin/felts_server -p 11111 -d ../dic/all-languages-${d}.dic -f ../dic/all-languages-${d}.mph &
# sleep 30
# cat  data/clef_microblogs_festival.content.txt | sed 's/[[:space:]][[:space:]]*/ /g' | sed 's/^[[:space:]]//' | ../bin/felts_client localhost 11111 | sed '/^$/d'| sed 's:,\t:,:' |sed 's: :\,:g' > data/clef_microblogs_festival.csv
# psql -c "DROP TABLE IF EXISTS term;CREATE TABLE term(tweet_id bigint, start bigint, \"end\" bigint, term text);"
# psql -c "COPY term FROM '/home/jourlin/Recherche/FELTS/clef/data/clef_microblogs_festival.csv' DELIMITER ',' CSV;"
# psql -c "UPDATE  term set term=translate(term, ',', ' ');"

psql  -c "DROP TABLE IF EXISTS dictionaries;DROP TABLE IF EXISTS dictionaries2;"
psql  -c "CREATE TABLE dictionaries2 (id integer, freq integer, lang character varying(15), term text);"
psql  -c "CREATE INDEX dic_idx ON dictionaries2 USING HASH (term);"
nb=1;
for l in $LANGUAGES
do
    echo "Processing language $l"
    cat	/home/jourlin/Recherche/FELTS/dic/"$l"wiki-"$d"-pages-articles-multistream.freq | sed 's:^ *::g' | sed 's:  *: \":' | sed 's:$:":'|iconv -c > /home/jourlin/Recherche/FELTS/dic/"$l"wiki-"$d"-pages-articles-multistream.freq2
    psql -c "COPY dictionaries2(freq, term) FROM '/home/jourlin/Recherche/FELTS/dic/"$l"wiki-"$d"-pages-articles-multistream.freq2'  DELIMITER ' ' CSV"
    rm /home/jourlin/Recherche/FELTS/dic/"$l"wiki-"$d"-pages-articles-multistream.freq2
    psql -c "UPDATE dictionaries2 SET id="$nb"1, lang='"$l"' WHERE id IS NULL AND lang IS NULL;"
    nb=$(($nb+1))
done
psql -c "CREATE TABLE dictionaries AS SELECT DISTINCT ON (id, lang,term) id, lang, term, freq FROM dictionaries2 ORDER BY id, term, lang, freq DESC;
";
psql -c "DROP TABLE IF EXISTS dictionaries2;"
by id, term, lang, freq DESC;

