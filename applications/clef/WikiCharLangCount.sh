#!/bin/bash
# Languages with more than 100000 wikipedia's articles (november, 8th, 2016)
# https://meta.wikimedia.org/wiki/List_of_Wikipedias#All_Wikipedias_ordered_by_number_of_articles

# Required packages :
# sudo apt-get install xml2

d="20170301"
PSQL="psql -p5433 -c "
LANGUAGES1="eo fr sv ceb de nl en ru it es war pl vi ja pt zh uk ca fa no ar sh fi hu id ro cs ko sr ms tr eu bg min da kk sk hy zh-min-nan he lt hr ce sl et gl nn uz la el be simple vo hi az ur ka af  als  am  an  arz  ast  azb  ba bar  bat-smg  be-tarask  bn  bpy  br  bs  bug  ckb  cv  cy  fo  fy  ga  gd  gu  hsb  ht  ia  io  is  jv  kn  ku  ky  lb  li  lmo  lv  map-bms  mg  mk  ml  mn  mr  mrj mzn  nah  nap  nds  ne  new  oc  or  os pa  pms  pnb  qu  sa  sah  scn  sco  si  sq  su  sw  ta  te  tg  tl  tt  vec  wa  yi  yo  zh-yue hif  mhr  ilo  roa-tara  pam  xmf  eml  sd  ps  nso  bh  se  hak  mi  bcl  diq  nds-nl  gan  glk  vls  rue  bo  wuu  mai  fiu-vro  co  tk  szl  sc  csb  vep  lrc crh  gv  kv  frr  zh-classical  as  so  zea  cdo  lad  ay  stq  udm  kw  nrm  ie  koi  ace  rm  pcd  myv  lij  mt  fur  gn  dsb  dv  cbk-zam  ext  lez  ug  kab  ang  ksh  mwl  ln  gag  sn  frp  gom  pag  pi  nv  av  pfl  xal  krc  haw  kaa  bxr  rw  pdc  to  nov  kl  pap arc  bjn  olo  kbd jam  ha  tet  tyv  ki  tpi  ig  na  lbe  roa-rup  jbo  ty  kg  za  mdf  lg  wo  srn ab  ltg zu  sm  om  bi  tcy  tn  chy  cu  rmy  tw  xh  tum  pih  rn  got  pnt  ss  ch  bm  ady  mo  ts  ny  iu  st  fj  ee  ak  ks  ik  sg  ve  dz  ff  ti cr chr"
# Does not work for :
# LANGUAGES1="my km lo th"

${PSQL} "DROP TABLE IF EXISTS wikicharfreq;"
${PSQL} "CREATE TABLE wikicharfreq (lang varchar(15), character CHAR(1), freq bigint);"

for l in $LANGUAGES1
do
echo Processing language : ${l}
     wget https://dumps.wikimedia.org/${l}wiki/${d}/${l}wiki-${d}-pages-articles-multistream.xml.bz2
     bunzip2 ${l}wiki-${d}-pages-articles-multistream.xml.bz2
    
     xml2 <${l}wiki-${d}-pages-articles-multistream.xml > ${l}wiki-${d}-pages-articles-multistream.txt
     rm ${l}wiki-${d}-pages-articles-multistream.xml
     sed 's:^.*text=::' ${l}wiki-${d}-pages-articles-multistream.txt |sed 's:\(.\):\1\n:g'|sort|sed '/ $/d'| uniq -c|sort -nr| grep --binary-file=text -v "      [1-9] " > ../dic/${l}wiki-${d}-Char.freq
    rm ${l}wiki-${d}-pages-articles-multistream.txt
cat /home/jourlin/Recherche/FELTS/dic/"$l"wiki-"$d"-Char.freq |sed '/ $/d'| iconv -c -f utf8 -t utf8//IGNORE | sed 's:^ *::'> /home/jourlin/Recherche/FELTS/dic/"$l"wiki-"$d"-Char.freq2
${PSQL} "COPY wikicharfreq(freq, character) FROM '/home/jourlin/Recherche/FELTS/dic/"$l"wiki-"$d"-Char.freq2'  DELIMITER ' ' CSV"
${PSQL} "UPDATE wikicharfreq SET lang='"$l"' WHERE lang IS NULL;"  
done
${PSQL} "DROP TABLE IF EXISTS task1_char;"
${PSQL} "CREATE TABLE  task1_char AS SELECT id_original, regexp_split_to_table(content,'') as char FROM task1;"
${PSQL} "CREATE TABLE wikichar_counting AS SELECT id_original, lang, sum(probability) FROM task1_char, probabilities_wikichar WHERE character=char GROUP BY id_original, lang;"
${PSQL} "CREATE TABLE auto_lang_char AS SELECT DISTINCT ON (id_original) id_original,lang,sum as scorechar from wikichar_counting ORDER BY id_original ASC, sum DESC ;"
${PSQL} "UPDATE task1b_language SET lang3=lang FROM auto_lang_char WHERE id=id_original;"
