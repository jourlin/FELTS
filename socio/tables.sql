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
-- Name: Belongs; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Belongs" (
    document integer NOT NULL,
    category integer NOT NULL
);


ALTER TABLE public."Belongs" OWNER TO socio;

--
-- Name: Category; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Category" (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public."Category" OWNER TO socio;

--
-- Name: Category_id_seq; Type: SEQUENCE; Schema: public; Owner: socio
--

CREATE SEQUENCE "Category_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Category_id_seq" OWNER TO socio;

--
-- Name: Category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: socio
--

ALTER SEQUENCE "Category_id_seq" OWNED BY "Category".id;


--
-- Name: Content; Type: TABLE; Schema: public; Owner: hypolite; Tablespace: 
--

CREATE TABLE "Content" (
    doc integer NOT NULL,
    line integer NOT NULL,
    content text
);


ALTER TABLE public."Content" OWNER TO hypolite;

--
-- Name: Document; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Document" (
    id integer NOT NULL,
    interviewed integer,
    interviewer integer,
    date timestamp with time zone
);


ALTER TABLE public."Document" OWNER TO socio;

--
-- Name: Document_id_seq; Type: SEQUENCE; Schema: public; Owner: socio
--

CREATE SEQUENCE "Document_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Document_id_seq" OWNER TO socio;

--
-- Name: Document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: socio
--

ALTER SEQUENCE "Document_id_seq" OWNED BY "Document".id;


--
-- Name: Entities; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Entities" (
    id integer NOT NULL,
    line integer,
    "offset" integer,
    entity text NOT NULL
);


ALTER TABLE public."Entities" OWNER TO socio;

--
-- Name: Entities_line_seq; Type: SEQUENCE; Schema: public; Owner: socio
--

CREATE SEQUENCE "Entities_line_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Entities_line_seq" OWNER TO socio;

--
-- Name: Entities_line_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: socio
--

ALTER SEQUENCE "Entities_line_seq" OWNED BY "Entities".line;


--
-- Name: Person; Type: TABLE; Schema: public; Owner: socio; Tablespace: 
--

CREATE TABLE "Person" (
    id integer NOT NULL,
    "FirstName" character varying(255) NOT NULL,
    "MiddleName" character varying(255),
    "LastName" character varying(255) NOT NULL
);


ALTER TABLE public."Person" OWNER TO socio;

--
-- Name: Person_id_seq; Type: SEQUENCE; Schema: public; Owner: socio
--

CREATE SEQUENCE "Person_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Person_id_seq" OWNER TO socio;

--
-- Name: Person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: socio
--

ALTER SEQUENCE "Person_id_seq" OWNED BY "Person".id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: socio
--

ALTER TABLE "Category" ALTER COLUMN id SET DEFAULT nextval('"Category_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: socio
--

ALTER TABLE "Document" ALTER COLUMN id SET DEFAULT nextval('"Document_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: socio
--

ALTER TABLE "Person" ALTER COLUMN id SET DEFAULT nextval('"Person_id_seq"'::regclass);


--
-- Name: CatÃ©gorie_pkey; Type: CONSTRAINT; Schema: public; Owner: socio; Tablespace: 
--

ALTER TABLE ONLY "Category"
    ADD CONSTRAINT "CatÃ©gorie_pkey" PRIMARY KEY (id);


--
-- Name: Content_pkey; Type: CONSTRAINT; Schema: public; Owner: hypolite; Tablespace: 
--

ALTER TABLE ONLY "Content"
    ADD CONSTRAINT "Content_pkey" PRIMARY KEY (doc, line);


--
-- Name: Document_pkey; Type: CONSTRAINT; Schema: public; Owner: socio; Tablespace: 
--

ALTER TABLE ONLY "Document"
    ADD CONSTRAINT "Document_pkey" PRIMARY KEY (id);


--
-- Name: Individu_pkey; Type: CONSTRAINT; Schema: public; Owner: socio; Tablespace: 
--

ALTER TABLE ONLY "Person"
    ADD CONSTRAINT "Individu_pkey" PRIMARY KEY (id);


--
-- Name: Belongs_category_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Belongs"
    ADD CONSTRAINT "Belongs_category_fkey" FOREIGN KEY (category) REFERENCES "Category"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Belongs_document_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Belongs"
    ADD CONSTRAINT "Belongs_document_fkey" FOREIGN KEY (document) REFERENCES "Document"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Content_doc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hypolite
--

ALTER TABLE ONLY "Content"
    ADD CONSTRAINT "Content_doc_fkey" FOREIGN KEY (doc) REFERENCES "Document"(id);


--
-- Name: Document_interviewed_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Document"
    ADD CONSTRAINT "Document_interviewed_fkey" FOREIGN KEY (interviewed) REFERENCES "Person"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Document_interviewer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: socio
--

ALTER TABLE ONLY "Document"
    ADD CONSTRAINT "Document_interviewer_fkey" FOREIGN KEY (interviewer) REFERENCES "Person"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres91
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres91;
GRANT ALL ON SCHEMA public TO postgres91;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: Content; Type: ACL; Schema: public; Owner: hypolite
--

REVOKE ALL ON TABLE "Content" FROM PUBLIC;
REVOKE ALL ON TABLE "Content" FROM hypolite;
GRANT ALL ON TABLE "Content" TO hypolite;
GRANT ALL ON TABLE "Content" TO socio;


--
-- Name: Document; Type: ACL; Schema: public; Owner: socio
--

REVOKE ALL ON TABLE "Document" FROM PUBLIC;
REVOKE ALL ON TABLE "Document" FROM socio;
GRANT ALL ON TABLE "Document" TO socio;


--
-- Name: Person; Type: ACL; Schema: public; Owner: socio
--

REVOKE ALL ON TABLE "Person" FROM PUBLIC;
REVOKE ALL ON TABLE "Person" FROM socio;
GRANT ALL ON TABLE "Person" TO socio;


--
-- PostgreSQL database dump complete
--

