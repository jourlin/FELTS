#!/bin/bash
# Languages with more than 100000 wikipedia's articles (november, 8th, 2016)
# https://meta.wikimedia.org/wiki/List_of_Wikipedias#All_Wikipedias_ordered_by_number_of_articles

d="20170301"
LANGUAGES="en sv ceb de nl fr ru it es war pl vi ja pt zh uk ca fa no ar sh fi hu id ro cs ko sr ms tr eu eo bg min da kk sk hy zh-min-nan he lt hr ce sl et gl nn uz la el be simple vo hi th az ur ka af  als  am  an  arz  ast  azb  ba  bar  bat-smg  be-tarask  bn  bpy  br  bs  bug  ckb  cv  cy  fo  fy  ga  gd  gu  hsb  ht  ia  io  is  jv  kn  ku  ky  lb  li  lmo  lv  map-bms  mg  mk  ml  mn  mr  mrj  my  mzn  nah  nap  nds  ne  new  oc  or  os  pa  pms  pnb  qu  sa  sah  scn  sco  si  sq  su  sw  ta  te  tg  tl  tt  vec  wa  yi  yo  zh-yue hif  mhr  ilo  roa-tara  pam  xmf  eml  sd  ps  nso  bh  se  hak  mi  bcl  diq  nds-nl  gan  glk  vls  rue  bo  wuu  mai  fiu-vro  co  tk  szl  sc  csb  vep  lrc  km  crh  gv  kv  frr  zh-classical  as  so  zea  cdo  lad  ay  stq  udm  kw  nrm  ie  koi  ace  rm  pcd  myv  lij  mt  fur  gn  dsb  dv  cbk-zam  ext  lez  ug  kab  ang  ksh  mwl  ln  gag  sn  frp  gom  pag  pi  nv  av  pfl  xal  krc  haw  kaa  bxr  rw  pdc  to  nov  kl  pap  lo  arc  bjn  olo  kbd  jam  ha  tet  tyv  ki  tpi  ig  na  lbe  roa-rup  jbo  ty  kg  za  mdf  lg  wo  srn ab  ltg  chr  zu  sm  om  bi  tcy  tn  chy  cu  rmy  tw  xh  tum  pih  rn  got  pnt  ss  ch  bm  ady  mo  ts  ny  iu  st  fj  ee  ak  ks  ik  sg  ve  dz  ff  ti  cr"
for l in $LANGUAGES
do
    wget https://dumps.wikimedia.org/${l}wiki/${d}/${l}wiki-${d}-pages-articles-multistream.xml.bz2
    bunzip2 ${l}wiki-${d}-pages-articles-multistream.xml.bz2
    # Making simple term dictionnaries for FELTS (anchor based):
    # egrep -o '\[\[[^]]*\]\]' ${l}wiki-${d}-pages-articles-multistream.xml | egrep -v "\[\[[^:]:[^:]" | sed 's:\[\[::g' | sed 's:.*|::' | sed 's:\]\]::g' | egrep -v ":" |  tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç' |sort|uniq -c|sort -nr | grep -v "      [1-9] " | sed 's:^ *[0-9][0-9]* ::'|sort> ../dic/${l}wiki-${d}-pages-articles-multistream.dic
    
    # Making dictionnaries including frequencies for language identification (anchor based):
    #egrep -o '\[\[[^]]*\]\]' ${l}wiki-${d}-pages-articles-multistream.xml | egrep -v "\[\[[^:]:[^:]" | sed 's:\[\[::g' | sed 's:.*|::' | sed 's:\]\]::g' | egrep -v ":" |  tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç' |sort|uniq -c|sort -nr | grep -v "      [1-9] " |sort -k2 > ../dic/${l}wiki-${d}-pages-articles-multistream.freq
    #rm ${l}wiki-${d}-pages-articles-multistream.xml
    
    # Making dictionnaries including frequencies for language identification (full text based)
    xml2 <${l}wiki-${d}-pages-articles-multistream.xml > ${l}wiki-${d}-pages-articles-multistream.txt
    grep "text=" ${l}wiki-${d}-pages-articles-multistream.txt |sed 's:.*text=::' | sed 's:[^\[]*|::g' | sed 's:\[\[::g'|sed 's:\]\]::g'|sed 's:[{}]::g'|tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç' |tr '\t ' '\n'|sort|uniq -c|sort -nr | grep -v "      [1-9] " |sort -k2 > ../dic/${l}wiki-${d}-pages-articles-multistream.freq
    rm ${l}wiki-${d}-pages-articles-multistream.xml
    
done
