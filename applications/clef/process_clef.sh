#!/bin/bash

LANGUAGES="en sv ceb de nl fr ru it es war pl vi ja pt zh uk ca fa no ar sh fi hu id ro cs ko sr ms tr eu eo bg min da kk sk hy zh-min-nan he lt hr ce sl et gl nn uz la el be simple vo hi th az ur ka af  als  am  an  arz  ast  azb  ba  bar  bat-smg  be-tarask  bn  bpy  br  bs  bug  ckb  cv  cy  fo  fy  ga  gd  gu  hsb  ht  ia  io  is  jv  kn  ku  ky  lb  li  lmo  lv  map-bms  mg  mk  ml  mn  mr  mrj  my  mzn  nah  nap  nds  ne  new  oc  or  os  pa  pms  pnb  qu  sa  sah  scn  sco  si  sq  su  sw  ta  te  tg  tl  tt  vec  wa  yi  yo  zh-yue hif  mhr  ilo  roa-tara  pam  xmf  eml  sd  ps  nso  bh  se  hak  mi  bcl  diq  nds-nl  gan  glk  vls  rue  bo  wuu  mai  fiu-vro  co  tk  szl  sc  csb  vep  lrc  km  crh  gv  kv  frr  zh-classical  as  so  zea  cdo  lad  ay  stq  udm  kw  nrm  ie  koi  ace  rm  pcd  myv  lij  mt  fur  gn  dsb  dv  cbk-zam  ext  lez  ug  kab  ang  ksh  mwl  ln  gag  sn  frp  gom  pag  pi  nv  av  pfl  xal  krc  haw  kaa  bxr  rw  pdc  to  nov  kl  pap  lo  arc  bjn  olo  kbd  jam  ha  tet  tyv  ki  tpi  ig  na  lbe  roa-rup  jbo  ty  kg  za  mdf  lg  wo  srn ab  ltg  chr  zu  sm  om  bi  tcy  tn  chy  cu  rmy  tw  xh  tum  pih  rn  got  pnt  ss  ch  bm  ady  mo  ts  ny  iu  st  fj  ee  ak  ks  ik  sg  ve  dz  ff  ti  cr"

cat data/clef_microblogs_festival.txt | cut -f1,4 |sed 's:^[^0-9].*:xxxxxxxxxxxxxxxxxx\t00:'> data/id_lang.csv
psql -dclef -c"DROP TABLE microblog ;"
psql -dclef -c"CREATE TABLE microblog (id serial, id_original varchar(32), lang varchar(50));"
psql -dclef -c "COPY microblog(id_original, lang) FROM '/home/lia/jourlin/FELTS/clef/data/id_lang.csv' DELIMITER E'\t' CSV"

psql -dclef -c "UPDATE microblog SET lang='en' WHERE lang='en-gb' OR lang='en-GB' OR lang='en-IN' OR lang='en-US' OR lang='en-CA' OR lang='en-AU' OR lang='en-xx'";
psql -dclef -c "UPDATE microblog SET lang='zh' WHERE lang='zh-tw' OR lang='zh-cn' OR lang='zh-TW' OR lang='zh-CN' OR lang='zh-Hans' OR lang='zh-Hant' OR lang='zh-HK' OR lang='zh-SG'";
psql -dclef -c "UPDATE microblog SET lang='es' WHERE lang='es-MX' OR lang='es-429' OR lang='es-ES'";
psql -dclef -c "UPDATE microblog SET lang='pt' WHERE lang='pt-PT' OR lang='pt-BR'";
psql -dclef -c "UPDATE microblog SET lang='fr' WHERE lang='fr-CA' OR lang='fr-CH'";
psql -dclef -c "UPDATE microblog SET lang='nl' WHERE lang='nl-BE'";
psql -dclef -c "UPDATE microblog SET lang='de' WHERE lang='de-AT' OR lang='de-CH'";
psql -dclef -c "UPDATE microblog SET lang='th' WHERE lang='th_th'";
psql -dclef -c "UPDATE microblog SET lang='00' WHERE lang='xx-lc' OR lang='Select Lan' OR lang='Sélection' OR lang='Selecionar' OR lang='选择语' OR lang='Selecciona' OR lang='選擇語' OR lang='言語を' OR lang='Seleziona' OR lang='Pilih Baha' OR lang='Sprache au' OR lang='เลื' OR lang='Selecione' OR lang='Seleccione' OR lang='Selecteer' OR lang='언어 선' OR lang='lolc' OR lang='Wybierz j' OR lang='Επιλο ' OR lang='Dil Seç..'";



# cut -f11 data/clef_microblogs_festival.txt > data/clef_microblogs_festival.content.txt
# bin/felts_server -p 11111 -d dic/all-languages-20161101.dic -f dic/all-languages-20161101.mph
# cat  data/clef_microblogs_festival.content.txt | sed 's/[[:space:]][[:space:]]*/ /g' | sed 's/^[[:space:]]//' | bin/felts_client localhost 11111 | sed '/^$/d'| sed 's:,\t:,:' |sed 's: :\,:g' > data/clef_microblogs_festival.csv
# psql -dclef -c "CREATE TABLE term(tweet_id bigint, start bigint, \"end\" bigint, term text);"
# psql -dclef -c "COPY term FROM '/home/jourlin/Recherche/FELTS/clef/data/clef_microblogs_festival.csv' DELIMITER ',' CSV;"


#psql -dclef -c "DROP TABLE dictionaries;"
#psql -dclef -c "CREATE TABLE dictionaries (id integer, lang character varying(15), term text);"
nb=1;
for l in $LANGUAGES
do
#    psql -dclef -c "COPY dictionaries(term) FROM '/home/lia/jourlin/FELTS/dic/"$l"wiki-20161101-pages-articles-multistream.dic'  DELIMITER '|' CSV"
#    psql -dclef -c "UPDATE dictionaries SET id="$nb"1, lang='"$l"' WHERE id IS NULL AND lang IS NULL;"
    nb=$(($nb+1))
done
#psql -dclef -c "DROP TABLE counting;"
#psql -dclef -c "CREATE TABLE counting (tweet_id BIGINT, lang CHARACTER VARYING(15), number BIGINT);"
for((i=30200001;i<100000000;i+=100000))
do
psql -dclef -c "INSERT INTO counting (tweet_id, lang, number) SELECT tweet_id, lang, count(*) FROM term, dictionaries WHERE tweet_id>=$i AND tweet_id<($i+100000) AND term.term=dictionaries.term GROUP BY tweet_id, lang"
done

# Automatically choose a language (the one where words are the most frequent) for a million tweets : 
DROP TABLE IF EXISTS auto_lang;
CREATE TABLE auto_lang AS SELECT DISTINCT ON (tweet_id) * from counting WHERE tweet_id<1000000 ORDER BY tweet_id ASC, number DESC ;
# How many correct identifications out of a million tweets :
select count(*)*100/1000000||'%' AS correct FROM (SELECT * FROM microblog where id<=1000000) AS x, auto_lang WHERE tweet_id<=1000000 AND id=tweet_id AND x.lang=auto_lang.lang;
# List of languages ranked by most used
psql -dclef -c"SELECT lang, count(id) FROM microblog GROUP BY lang ORDER BY count(id) DESC;"

