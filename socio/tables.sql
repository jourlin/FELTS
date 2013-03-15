--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Appartient; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Appartient" (
    entretien integer NOT NULL,
    categorie integer NOT NULL
);


ALTER TABLE public."Appartient" OWNER TO socio;

--
-- Name: Catégorie; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Catégorie" (
    id integer NOT NULL,
    nom character varying(255) NOT NULL
);


ALTER TABLE public."Catégorie" OWNER TO socio;

--
-- Name: Catégorie_id_seq; Type: SEQUENCE; Schema: public; Owner: socio
--

CREATE SEQUENCE "Catégorie_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Catégorie_id_seq" OWNER TO socio;

--
-- Name: Catégorie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: socio
--

ALTER SEQUENCE "Catégorie_id_seq" OWNED BY "Catégorie".id;


--
-- Name: Entities; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Entities" (
    id integer NOT NULL,
    number integer,
    entity text NOT NULL
);


ALTER TABLE public."Entities" OWNER TO socio;

--
-- Name: Entretien; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Entretien" (
    id integer NOT NULL,
    interviewed integer,
    interviewer integer,
    date timestamp with time zone,
    content text
);


ALTER TABLE public."Entretien" OWNER TO socio;

--
-- Name: Entretien_id_seq; Type: SEQUENCE; Schema: public; Owner: socio
--

CREATE SEQUENCE "Entretien_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Entretien_id_seq" OWNER TO socio;

--
-- Name: Entretien_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: socio
--

ALTER SEQUENCE "Entretien_id_seq" OWNED BY "Entretien".id;


--
-- Name: Individu; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Individu" (
    id integer NOT NULL,
    "FirstName" character varying(255) NOT NULL,
    "MiddleName" character varying(255),
    "LastName" character varying(255) NOT NULL
);


ALTER TABLE public."Individu" OWNER TO socio;

--
-- Name: Individu_id_seq; Type: SEQUENCE; Schema: public; Owner: socio
--

CREATE SEQUENCE "Individu_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Individu_id_seq" OWNER TO socio;

--
-- Name: Individu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: socio
--

ALTER SEQUENCE "Individu_id_seq" OWNED BY "Individu".id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: socio
--

ALTER TABLE "Catégorie" ALTER COLUMN id SET DEFAULT nextval('"Catégorie_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: socio
--

ALTER TABLE "Entretien" ALTER COLUMN id SET DEFAULT nextval('"Entretien_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: socio
--

ALTER TABLE "Individu" ALTER COLUMN id SET DEFAULT nextval('"Individu_id_seq"'::regclass);


--
-- Name: Appartient_entretien_categorie_key; Type: CONSTRAINT; Schema: public; Owner: socio; Tablespace: 
--

ALTER TABLE ONLY "Appartient"
    ADD CONSTRAINT "Appartient_entretien_categorie_key" UNIQUE (entretien, categorie);


--
-- Name: Catégorie_pkey; Type: CONSTRAINT; Schema: public; Owner: socio; Tablespace: 
--

ALTER TABLE ONLY "Catégorie"
    ADD CONSTRAINT "Catégorie_pkey" PRIMARY KEY (id);


--
-- Name: Entrentien_pkey; Type: CONSTRAINT; Schema: public; Owner: socio; Tablespace: 
--

ALTER TABLE ONLY "Entretien"
    ADD CONSTRAINT "Entrentien_pkey" PRIMARY KEY (id);


--
-- Name: Individu_pkey; Type: CONSTRAINT; Schema: public; Owner: socio; Tablespace: 
--

ALTER TABLE ONLY "Individu"
    ADD CONSTRAINT "Individu_pkey" PRIMARY KEY (id);


--
-- Name: Appartient_categorie_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Appartient"
    ADD CONSTRAINT "Appartient_categorie_fkey" FOREIGN KEY (categorie) REFERENCES "Catégorie"(id);


--
-- Name: Appartient_entretien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Appartient"
    ADD CONSTRAINT "Appartient_entretien_fkey" FOREIGN KEY (entretien) REFERENCES "Entretien"(id);


--
-- Name: Entities_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Entities"
    ADD CONSTRAINT "Entities_id_fkey" FOREIGN KEY (id) REFERENCES "Entretien"(id) ON DELETE CASCADE;


--
-- Name: Entrentien_interviewed_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Entretien"
    ADD CONSTRAINT "Entrentien_interviewed_fkey" FOREIGN KEY (interviewed) REFERENCES "Individu"(id);


--
-- Name: Entretien_interviewer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Entretien"
    ADD CONSTRAINT "Entretien_interviewer_fkey" FOREIGN KEY (interviewer) REFERENCES "Individu"(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres91
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres91;
GRANT ALL ON SCHEMA public TO postgres91;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO socio;


--
-- PostgreSQL database dump complete
--

