learn_from=0;
learn_to=100000;
test_from=100001;
test_to=200000;

# term frequencies in database :
CREATE table frequencies AS SELECT term, count(*) as freq FROM term WHERE tweet_id >=$learn_from AND tweet_id<=$learn_to GROUP BY term ORDER BY count(*) DESC;
# probability of language given a term :
CREATE TABLE probabilities AS SELECT x.term, lang, CAST(count(*) AS float)/(SELECT freq FROM frequencies WHERE frequencies.term=x.term) AS probability FROM (select term, lang from term, microblog WHERE tweet_id=id AND tweet_id<100000) as x GROUP BY term, lang ORDER BY probability DESC;
CREATE TABLE probabilities_wiki AS SELECT x.term, lang, CAST(count(*) AS float)/(SELECT freq FROM dictionaries WHERE dictionaries.term=x.term) AS probability FROM (select term, lang from dictionaries) as x GROUP BY term, lang ORDER BY probability DESC;
 
#psql -dclef -c "DROP TABLE IF EXISTS counting;CREATE TABLE counting (tweet_id BIGINT, lang CHARACTER VARYING(15), probsum FLOAT);"
for((i=0;i<70000000;i+=100000))
do
psql -dclef -c "INSERT INTO counting (tweet_id, lang, probsum) SELECT tweet_id, lang, sum(probability) FROM term, probabilities WHERE tweet_id>=$i AND tweet_id<($i+100000) AND term.term=probabilities.term GROUP BY tweet_id, lang;"
done

# Automatically choose a language (the one where words are the most frequent) for 100,000 tweets : 
DROP TABLE IF EXISTS auto_lang;CREATE TABLE auto_lang AS SELECT DISTINCT ON (tweet_id) * from counting WHERE tweet_id<100000 ORDER BY tweet_id ASC, probsum DESC ;
# How many correct identifications out of 100,000 tweets :
select count(*)*100/100000||'%' AS correct FROM (SELECT * FROM microblog where id<=100000) AS x, auto_lang WHERE tweet_id<=100000 AND id=tweet_id AND x.lang=auto_lang.lang;
# How many correct identifications out of 100,000 tweets (for each language) :
select x.lang, count(*)*100/(SELECT count(*) FROM microblog WHERE microblog.id<=100000 AND microblog.lang=x.lang) AS correct FROM (SELECT * FROM microblog where id<=100000) AS x, auto_lang WHERE tweet_id<=100000 AND id=tweet_id AND x.lang=auto_lang.lang GROUP BY x.lang ORDER BY correct DESC ;
# Language distribution according to locale :
select lang, CAST(count(*) AS FLOAT)*100/(SELECT count(*) FROM microblog WHERE microblog.id<=100000) AS "% tweets" FROM microblog WHERE id<=100000 GROUP BY lang ORDER BY "% tweets" DESC ;

# List of languages ranked by most used
psql -dclef -c"SELECT lang, count(id) FROM microblog GROUP BY lang ORDER BY count(id) DESC;"
# List of dictionnaries ranked by number of word occurences :
SELECT sum(freq), lang FROM dictionaries GROUP BY lang ORDER BY sum(freq) DESC;
# compare two languages on a specific tweet :
SELECT * FROM term, dictionaries as en, dictionaries as fr WHERE term.tweet_id=2 AND term.term=en.term AND term.term=fr.term AND fr.lang='fr' AND en.lang='en' ;

