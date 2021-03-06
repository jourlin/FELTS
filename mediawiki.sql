--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.7
-- Dumped by pg_dump version 9.6.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE frwiki; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE frwiki IS 'Extrait de :
frwiki-20180201-pages-articles-multistream.xml
avec xml2sql 
https://github.com/matthewfl/mediawiki-xml2sql';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE page (
    page_id integer NOT NULL,
    page_namespace integer NOT NULL,
    page_title character varying(255),
    page_restrictions pg_catalog.text,
    page_counter bigint,
    page_is_redirect smallint,
    page_is_new smallint,
    page_random real,
    page_touched character(14),
    page_latest integer,
    page_len integer
);


--
-- Name: TABLE page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE page IS 'import:
COPY page FROM ''/home/jourlin/Recherche/FELTS/data/page.txt'' ;

pour mediawiki 1.5 à 1.9
+-------------------+---------------------+------+-----+---------+----------------+
| Field             | Type                | Null | Key | Default | Extra          |
+-------------------+---------------------+------+-----+---------+----------------+
| page_id           | int(8) unsigned     | NO   | PRI | NULL    | AUTO_INCREMENT |
| page_namespace    | int(11)             | NO   | MUL | NULL    |                |
| page_title        | varchar(255) binary | NO   |     | NULL    |                |
| page_restrictions | tinyblob            | NO   |     | NULL    |                |
| page_counter      | bigint(20) unsigned | NO   |     | 0       |                |
| page_is_redirect  | tinyint(1) unsigned | NO   |     | 0       |                |
| page_is_new       | tinyint(1) unsigned | NO   |     | 0       |                |
| page_random       | real unsigned       | NO   | MUL | NULL    |                |
| page_touched      | char(14) binary     | NO   |     | NULL    |                |
| page_latest       | int(8) unsigned     | NO   |     | NULL    |                |
| page_len          | int(8) unsigned     | NO   | MUL | NULL    |                |
+-------------------+---------------------+------+-----+---------+----------------+

Indices';


--
-- Name: revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE revision (
    rev_id integer NOT NULL,
    rev_page integer,
    rev_text_id integer,
a    rev_comment pg_catalog.text,
    rev_user integer,
    rev_user_text character varying(255),
    rev_timestamp character(14),
    rev_minor_edit smallint,
    rev_deleted smallint
);


--
-- Name: TABLE revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE revision IS 'import with 
COPY revision FROM ''/home/jourlin/Recherche/FELTS/data/revision.txt'' ;';


--
-- Name: text; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE text (
    old_id integer NOT NULL,
    old_text pg_catalog.text,
    old_flags pg_catalog.text
);


--
-- Name: TABLE text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE text IS 'import with :
COPY text FROM ''/home/jourlin/Recherche/FELTS/data/text.txt'' ;
MediaWiki versions: 	1.5 – 1.9
+-----------+-----------------+------+-----+---------+----------------+
| Field     | Type            | Null | Key | Default | Extra          |
+-----------+-----------------+------+-----+---------+----------------+
| old_id    | int(8) unsigned | NO   | PRI | NULL    | AUTO_INCREMENT |
| old_text  | mediumblob      | NO   |     | NULL    |                |
| old_flags | tinyblob        | NO   |     | NULL    |                |
+-----------+-----------------+------+-----+---------+----------------+';


--
-- Name: page page_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY page
    ADD CONSTRAINT page_pkey PRIMARY KEY (page_id);


--
-- Name: revision revision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY revision
    ADD CONSTRAINT revision_pkey PRIMARY KEY (rev_id);


--
-- Name: text text_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text
    ADD CONSTRAINT text_pkey PRIMARY KEY (old_id);


--
-- PostgreSQL database dump complete
--

-- Table Terms contains the extration of source and destination of all internal links  (e.g. [[named entity (hypernym)|named entity]])
CREATE TABLE Terms AS SELECT * FROM (SELECT DISTINCT old_id, lower(rtrim(replace(regexp_split_to_table(link, E'[\\[\\]\\|\\(\\)\\]]'), 'Catégorie:',''))) as term  FROM (SELECT old_id, unnest(regexp_matches(line, '\[\[[^\]]*\]\]', 'g')) as link FROM 
   (SELECT old_id, regexp_split_to_table(old_text, E'\\n') as line FROM 
       (SELECT old_id, old_text FRSELECT page_title, term FROM (SELECT * FROM page WHERE page_title='Je_suis' LIMIT 10) as p, revision as r, terms as t
where p.page_id=r.rev_page AND r.rev_id=t.old_idOM text) as X) as Y) as Z 
 ORDER BY term ASC) as A WHERE term !=''
 
-- Get all the terms related to a specified page_title :
SELECT page_title, term FROM (SELECT * FROM page WHERE page_title='My_page_title') as p, revision as r, terms as t
where p.page_id=r.rev_page AND r.rev_id=t.old_id

-- Get some manual categories :
select * FROM 
(SELECT DISTINCT substring(page_title from '_\((.*)\)') as category
FROM page 
WHERE position('_(' in page_title)!=0
) as cat WHERE category LIKE 'a%' LIMIT 10

-- Get Semi-Automatic categories search for pattern "est un [[" :
CREATE TABLE entity_cat AS SELECT translate(lower(p.page_title), '_', ' ') as entity, lower(substring(phrase from 'est (?:un|le|une|la) [^\[]*\[\[([^\|\]]*)')) as cat FROM  
   (
SELECT old_id, lower(substring(old_text from E'\'\'\'([^\.]*)')) as phrase 
    FROM text
 ) as A,
revision as r, 
page as p
WHERE 
substring(phrase from 'est (?:un|le|une|la) [^\[]*\[\[([^\|\]]*)') IS NOT NULL
AND 
p.page_id=r.rev_page
AND 
r.rev_text_id=A.old_id
--
-- Create semantic tree
 DROP TABLE IF EXISTS links;
CREATE TABLE links AS SELECT DISTINCT lower(translate(entity, '_', ' ')) as spe, lower(translate(cat, '_', ' ')) as gen FROM entity_cat;
ALTER TABLE links ADD Primary Key (spe, gen);

SELECT distinct l0.spe as "0", l1.spe as "1", l2.spe as "2", l3.spe as "3", l4.spe as "4", l5.spe as "5", l6.spe as "6", l7.spe as "7",  l7.gen as "8"

FROM links as l0, links as l1, links as l2, links as l3, links as l4, links as l5, links as l6, links as l7

WHERE

l0.gen=l1.spe AND l1.gen=l2.spe AND l2.gen=l3.spe AND l3.gen = l4.spe 
AND l4.gen=l5.spe AND l5.gen=l6.spe AND l6.gen=l7.spe 

AND l0.gen!=l0.spe
AND l1.gen!=l1.spe
AND l1.gen!=l0.spe
AND l2.gen!=l2.spe
AND l2.gen!=l1.spe
AND l2.gen!=l0.spe
AND l3.gen!=l3.spe
AND l3.gen!=l2.spe
AND l3.gen!=l1.spe
AND l3.gen!=l0.spe
AND l4.gen!=l4.spe
AND l4.gen!=l3.spe
AND l4.gen!=l2.spe
AND l4.gen!=l1.spe
AND l4.gen!=l0.spe
AND l5.gen!=l5.spe
AND l5.gen!=l4.spe
AND l5.gen!=l3.spe
AND l5.gen!=l2.spe
AND l5.gen!=l1.spe
AND l5.gen!=l0.spe
AND l6.gen!=l6.spe
AND l6.gen!=l5.spe
AND l6.gen!=l4.spe
AND l6.gen!=l3.spe
AND l6.gen!=l2.spe
AND l6.gen!=l1.spe
AND l6.gen!=l0.spe
AND l7.gen!=l7.spe
AND l7.gen!=l6.spe
AND l7.gen!=l5.spe
AND l7.gen!=l4.spe
AND l7.gen!=l3.spe
AND l7.gen!=l2.spe
AND l7.gen!=l1.spe
AND l7.gen!=l0.spe

-- Find Redirections 
 SELECT count(*) FROM text WHERE lower(old_text) LIKE '#redirect%'
-- SELECT DISTINCT old_text FROM page as p, revision as r, text as t
-- WHERE p.page_is_redirect=1
-- AND p.page_id=r.rev_page
-- AND r.rev_id=t.old_id
-- AND lower(old_text) NOT LIKE '#redirect%'
-- LIMIT 10

