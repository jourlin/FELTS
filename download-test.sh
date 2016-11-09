#!/bin/bash
# Languages with more than 100000 wikipedia's articles (november, 8th, 2016)
# https://meta.wikimedia.org/wiki/List_of_Wikipedias#All_Wikipedias_ordered_by_number_of_articles

d="20161101"
LANGUAGES="oc"
for l in $LANGUAGES
do
#    wget https://dumps.wikimedia.org/${l}wiki/${d}/${l}wiki-${d}-pages-articles-multistream.xml.bz2
#    bunzip2 ${l}wiki-${d}-pages-articles-multistream.xml.bz2
    egrep -o '\[\[[^]]*\]\]' ${l}wiki-${d}-pages-articles-multistream.xml | egrep -v "\[\[[^:]:[^:]" | sed 's:\[\[::g' | sed 's:.*|::' | sed 's:\]\]::g' | egrep -v ":" |  tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç' |sort|uniq -c|sort -nr | grep -v "      [1-9] " | sed 's:^ *[0-9][0-9]* ::'|sort> ../dic/${l}wiki-${d}-pages-articles-multistream.dic
done
