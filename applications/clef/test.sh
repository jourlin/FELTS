learn_from=0;
learn_to=100000;
test_from=100001;
test_to=200000;

# term frequencies in database :
psql -c "DROP TABLE IF EXISTS frequencies_mblog; CREATE table frequencies_mblog AS SELECT term, lang, count(*) as freq FROM term, microblog WHERE term.tweet_id=microblog.id GROUP BY term,lang ORDER BY count(*) DESC;"
# probability of language given a term :
psql -c "CREATE INDEX term_idx ON dictionaries USING hash (term);"

# Clean experiments
psql -c "DROP TABLE IF EXISTS probabilities_mblog ;DROP TABLE IF EXISTS probabilities_wiki ;DROP TABLE IF EXISTS counting_mblog;DROP TABLE IF EXISTS counting_wiki; DROP TABLE IF EXISTS auto_lang_mblog;DROP TABLE IF EXISTS auto_lang_wiki;DROP TABLE IF EXISTS freq_sum_wiki"
# Calculate word-level probabilities
psql -c "CREATE TABLE freq_sum_mblog AS SELECT term, sum(freq) FROM frequencies GROUP BY term;"
psql -c "CREATE TABLE probabilities_mblog AS SELECT x.term, x.lang, (CAST(freq AS FLOAT) / sum) AS probability FROM frequencies_mblog as x, freq_sum_mblog as f WHERE f.term=x.term  GROUP BY x.term, x.lang, x.freq, f.sum ORDER BY probability DESC;"
#psql -c "CREATE TABLE probabilities_mblog AS SELECT x.term, lang, CAST(count(*) AS float)/(SELECT freq FROM frequencies WHERE frequencies.term=x.term) AS probability FROM (select term, lang from term, microblog WHERE tweet_id=id) as x GROUP BY term, lang ORDER BY probability DESC;"
psql -c "CREATE TABLE freq_sum_wiki AS SELECT term, sum(freq) FROM dictionaries2 GROUP BY term;"
psql -c "CREATE TABLE probabilities_wiki AS SELECT x.term, x.lang, (CAST(freq AS FLOAT) / sum) AS probability FROM dictionaries2 as x, freq_sum_wiki as f WHERE f.term=x.term  GROUP BY x.term, x.lang, x.freq, f.sum ORDER BY probability DESC;"
# calculate message-level probabilities
psql -c "CREATE TABLE counting_mblog (tweet_id BIGINT, lang CHARACTER VARYING(15), probsum FLOAT);"
psql -c "INSERT INTO counting_mblog (tweet_id, lang, probsum) SELECT tweet_id, probabilities_mblog.lang, sum(probability) FROM term, probabilities_mblog, task1, microblog WHERE task1.id_original=microblog.id_original AND microblog.id=term.tweet_id AND term.term=probabilities_mblog.term GROUP BY tweet_id, probabilities_mblog.lang;"
psql -c "CREATE TABLE counting_wiki (tweet_id BIGINT, lang CHARACTER VARYING(15), probsum FLOAT);"
psql -c "INSERT INTO counting_wiki (tweet_id, lang, probsum) SELECT tweet_id, probabilities_wiki.lang, sum(probability) FROM term, probabilities_wiki, task1, microblog WHERE task1.id_original=microblog.id_original AND microblog.id=term.tweet_id AND term.term=probabilities_wiki.term GROUP BY tweet_id, probabilities_wiki.lang;"


# Automatically choose a language (the one where words are the most frequent) for 100,000 tweets : 
psql -c "CREATE TABLE auto_lang_mblog AS SELECT DISTINCT ON (tweet_id) tweet_id,counting_mblog.lang, probsum as scoreMB from counting_mblog, task1, microblog WHERE task1.id_original=microblog.id_original AND microblog.id=counting_mblog.tweet_id ORDER BY tweet_id ASC, probsum DESC ;"
psql -c "CREATE TABLE auto_lang_wiki AS SELECT DISTINCT ON (tweet_id) tweet_id,counting_wiki.lang,probsum as scorewiki from counting_wiki, task1, microblog WHERE task1.id_original=microblog.id_original AND microblog.id=counting_wiki.tweet_id ORDER BY tweet_id ASC, probsum DESC ;"
# Display  recognition statistics
psql -c "SELECT count(*)*100/1098.0 as all_identical FROM auto_lang_mblog, auto_lang_wiki, microblog WHERE auto_lang_mblog.tweet_id=auto_lang_wiki.tweet_id AND auto_lang_wiki.tweet_id=microblog.id AND auto_lang_wiki.lang=auto_lang_mblog.lang AND auto_lang_mblog.lang=microblog.lang; "
psql -c "SELECT count(*)*100/1098.0 as mblog_identical FROM auto_lang_mblog, microblog WHERE auto_lang_mblog.tweet_id=microblog.id AND auto_lang_mblog.lang=microblog.lang; "
psql -c "SELECT count(*)*100/1098.0 as wiki_identical FROM  auto_lang_wiki, microblog WHERE auto_lang_wiki.tweet_id=microblog.id AND auto_lang_wiki.lang=microblog.lang; "
psql -c "SELECT microblog.id_original, microblog.lang as locale, auto_lang_mblog.lang as mblog, scoreMB, auto_lang_wiki.lang as wiki, scoreWiki, content FROM auto_lang_mblog, auto_lang_wiki, microblog, task1 WHERE task1.id_original=microblog.id_original AND auto_lang_mblog.tweet_id=auto_lang_wiki.tweet_id AND auto_lang_wiki.tweet_id=microblog.id AND (auto_lang_wiki.lang!=auto_lang_mblog.lang OR auto_lang_mblog.lang!=microblog.lang OR auto_lang_wiki.lang!=microblog.lang) LIMIT 10; "
exit
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

# Test on Wikipedia unigram probabilities: 
  DELETE FROM counting WHERE 1=1;
 INSERT INTO counting (tweet_id, lang, probsum) SELECT tweet_id, lang, sum(probability) FROM term, probabilities_wiki WHERE tweet_id<100000 AND term.term=probabilities_wiki.term GROUP BY tweet_id, lang;
 DROP TABLE IF EXISTS auto_lang;CREATE TABLE auto_lang AS SELECT DISTINCT ON (tweet_id) * from counting WHERE tweet_id<100000 ORDER BY tweet_id ASC, probsum DESC ;
 select count(*)*100/100000||'%' AS correct FROM (SELECT * FROM microblog where id<=100000) AS x, auto_lang WHERE tweet_id<=100000 AND id=tweet_id AND x.lang=auto_lang.lang;
 select x.lang, count(*)*100/(SELECT count(*) FROM microblog WHERE microblog.id<=100000 AND microblog.lang=x.lang) AS correct FROM (SELECT * FROM microblog where id<=100000) AS x, auto_lang WHERE tweet_id<=100000 AND id=tweet_id AND x.lang=auto_lang.lang GROUP BY x.lang ORDER BY correct DESC ;
 SELECT lang, count(tweet_id) FROM auto_lang GROUP BY lang ORDER BY count(tweet_id) DESC;
