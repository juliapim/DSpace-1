--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE dspace;
ALTER ROLE dspace WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md560f94872869f54c7caa55c7c7c3760c5';






\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.3 (Debian 11.3-1.pgdg90+1)
-- Dumped by pg_dump version 11.3 (Debian 11.3-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.3 (Debian 11.3-1.pgdg90+1)
-- Dumped by pg_dump version 11.3 (Debian 11.3-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dspace; Type: DATABASE; Schema: -; Owner: dspace
--

CREATE DATABASE dspace WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE dspace OWNER TO dspace;

\connect dspace

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dspace; Type: DATABASE PROPERTIES; Schema: -; Owner: dspace
--

ALTER DATABASE dspace SET search_path TO '$user', 'public', 'extensions';


\connect dspace

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: dspace
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO dspace;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: getnextid(character varying); Type: FUNCTION; Schema: public; Owner: dspace
--

CREATE FUNCTION public.getnextid(character varying) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT CAST (nextval($1 || '_seq') AS INTEGER) AS RESULT;$_$;


ALTER FUNCTION public.getnextid(character varying) OWNER TO dspace;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bitstream; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.bitstream (
    bitstream_id integer,
    bitstream_format_id integer,
    checksum character varying(64),
    checksum_algorithm character varying(32),
    internal_id character varying(256),
    deleted boolean,
    store_number integer,
    sequence_id integer,
    size_bytes bigint,
    uuid uuid DEFAULT extensions.gen_random_uuid() NOT NULL
);


ALTER TABLE public.bitstream OWNER TO dspace;

--
-- Name: bitstreamformatregistry; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.bitstreamformatregistry (
    bitstream_format_id integer NOT NULL,
    mimetype character varying(256),
    short_description character varying(128),
    description text,
    support_level integer,
    internal boolean
);


ALTER TABLE public.bitstreamformatregistry OWNER TO dspace;

--
-- Name: bitstreamformatregistry_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.bitstreamformatregistry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bitstreamformatregistry_seq OWNER TO dspace;

--
-- Name: bundle; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.bundle (
    bundle_id integer,
    uuid uuid DEFAULT extensions.gen_random_uuid() NOT NULL,
    primary_bitstream_id uuid
);


ALTER TABLE public.bundle OWNER TO dspace;

--
-- Name: bundle2bitstream; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.bundle2bitstream (
    bitstream_order_legacy integer,
    bundle_id uuid NOT NULL,
    bitstream_id uuid NOT NULL,
    bitstream_order integer NOT NULL
);


ALTER TABLE public.bundle2bitstream OWNER TO dspace;

--
-- Name: checksum_history; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.checksum_history (
    check_id bigint NOT NULL,
    process_start_date timestamp without time zone,
    process_end_date timestamp without time zone,
    checksum_expected character varying,
    checksum_calculated character varying,
    result character varying,
    bitstream_id uuid
);


ALTER TABLE public.checksum_history OWNER TO dspace;

--
-- Name: checksum_history_check_id_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.checksum_history_check_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checksum_history_check_id_seq OWNER TO dspace;

--
-- Name: checksum_history_check_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dspace
--

ALTER SEQUENCE public.checksum_history_check_id_seq OWNED BY public.checksum_history.check_id;


--
-- Name: checksum_results; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.checksum_results (
    result_code character varying NOT NULL,
    result_description character varying
);


ALTER TABLE public.checksum_results OWNER TO dspace;

--
-- Name: collection; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.collection (
    collection_id integer,
    uuid uuid DEFAULT extensions.gen_random_uuid() NOT NULL,
    workflow_step_1 uuid,
    workflow_step_2 uuid,
    workflow_step_3 uuid,
    submitter uuid,
    template_item_id uuid,
    logo_bitstream_id uuid,
    admin uuid
);


ALTER TABLE public.collection OWNER TO dspace;

--
-- Name: collection2item; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.collection2item (
    collection_id uuid NOT NULL,
    item_id uuid NOT NULL
);


ALTER TABLE public.collection2item OWNER TO dspace;

--
-- Name: community; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.community (
    community_id integer,
    uuid uuid DEFAULT extensions.gen_random_uuid() NOT NULL,
    admin uuid,
    logo_bitstream_id uuid
);


ALTER TABLE public.community OWNER TO dspace;

--
-- Name: community2collection; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.community2collection (
    collection_id uuid NOT NULL,
    community_id uuid NOT NULL
);


ALTER TABLE public.community2collection OWNER TO dspace;

--
-- Name: community2community; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.community2community (
    parent_comm_id uuid NOT NULL,
    child_comm_id uuid NOT NULL
);


ALTER TABLE public.community2community OWNER TO dspace;

--
-- Name: doi; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.doi (
    doi_id integer NOT NULL,
    doi character varying(256),
    resource_type_id integer,
    resource_id integer,
    status integer,
    dspace_object uuid
);


ALTER TABLE public.doi OWNER TO dspace;

--
-- Name: doi_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.doi_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.doi_seq OWNER TO dspace;

--
-- Name: dspaceobject; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.dspaceobject (
    uuid uuid NOT NULL
);


ALTER TABLE public.dspaceobject OWNER TO dspace;

--
-- Name: eperson; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.eperson (
    eperson_id integer,
    email character varying(64),
    password character varying(128),
    can_log_in boolean,
    require_certificate boolean,
    self_registered boolean,
    last_active timestamp without time zone,
    sub_frequency integer,
    netid character varying(64),
    salt character varying(32),
    digest_algorithm character varying(16),
    uuid uuid DEFAULT extensions.gen_random_uuid() NOT NULL
);


ALTER TABLE public.eperson OWNER TO dspace;

--
-- Name: epersongroup; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.epersongroup (
    eperson_group_id integer,
    uuid uuid DEFAULT extensions.gen_random_uuid() NOT NULL,
    permanent boolean DEFAULT false,
    name character varying(250)
);


ALTER TABLE public.epersongroup OWNER TO dspace;

--
-- Name: epersongroup2eperson; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.epersongroup2eperson (
    eperson_group_id uuid NOT NULL,
    eperson_id uuid NOT NULL
);


ALTER TABLE public.epersongroup2eperson OWNER TO dspace;

--
-- Name: epersongroup2workspaceitem; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.epersongroup2workspaceitem (
    workspace_item_id integer NOT NULL,
    eperson_group_id uuid NOT NULL
);


ALTER TABLE public.epersongroup2workspaceitem OWNER TO dspace;

--
-- Name: fileextension; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.fileextension (
    file_extension_id integer NOT NULL,
    bitstream_format_id integer,
    extension character varying(16)
);


ALTER TABLE public.fileextension OWNER TO dspace;

--
-- Name: fileextension_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.fileextension_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fileextension_seq OWNER TO dspace;

--
-- Name: group2group; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.group2group (
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL
);


ALTER TABLE public.group2group OWNER TO dspace;

--
-- Name: group2groupcache; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.group2groupcache (
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL
);


ALTER TABLE public.group2groupcache OWNER TO dspace;

--
-- Name: handle; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.handle (
    handle_id integer NOT NULL,
    handle character varying(256),
    resource_type_id integer,
    resource_legacy_id integer,
    resource_id uuid
);


ALTER TABLE public.handle OWNER TO dspace;

--
-- Name: handle_id_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.handle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.handle_id_seq OWNER TO dspace;

--
-- Name: handle_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.handle_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.handle_seq OWNER TO dspace;

--
-- Name: harvested_collection; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.harvested_collection (
    harvest_type integer,
    oai_source character varying,
    oai_set_id character varying,
    harvest_message character varying,
    metadata_config_id character varying,
    harvest_status integer,
    harvest_start_time timestamp with time zone,
    last_harvested timestamp with time zone,
    id integer NOT NULL,
    collection_id uuid
);


ALTER TABLE public.harvested_collection OWNER TO dspace;

--
-- Name: harvested_collection_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.harvested_collection_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.harvested_collection_seq OWNER TO dspace;

--
-- Name: harvested_item; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.harvested_item (
    last_harvested timestamp with time zone,
    oai_id character varying,
    id integer NOT NULL,
    item_id uuid
);


ALTER TABLE public.harvested_item OWNER TO dspace;

--
-- Name: harvested_item_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.harvested_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.harvested_item_seq OWNER TO dspace;

--
-- Name: history_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.history_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.history_seq OWNER TO dspace;

--
-- Name: item; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.item (
    item_id integer,
    in_archive boolean,
    withdrawn boolean,
    last_modified timestamp with time zone,
    discoverable boolean,
    uuid uuid DEFAULT extensions.gen_random_uuid() NOT NULL,
    submitter_id uuid,
    owning_collection uuid
);


ALTER TABLE public.item OWNER TO dspace;

--
-- Name: item2bundle; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.item2bundle (
    bundle_id uuid NOT NULL,
    item_id uuid NOT NULL
);


ALTER TABLE public.item2bundle OWNER TO dspace;

--
-- Name: metadatafieldregistry_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.metadatafieldregistry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metadatafieldregistry_seq OWNER TO dspace;

--
-- Name: metadatafieldregistry; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.metadatafieldregistry (
    metadata_field_id integer DEFAULT nextval('public.metadatafieldregistry_seq'::regclass) NOT NULL,
    metadata_schema_id integer NOT NULL,
    element character varying(64),
    qualifier character varying(64),
    scope_note text
);


ALTER TABLE public.metadatafieldregistry OWNER TO dspace;

--
-- Name: metadataschemaregistry_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.metadataschemaregistry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metadataschemaregistry_seq OWNER TO dspace;

--
-- Name: metadataschemaregistry; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.metadataschemaregistry (
    metadata_schema_id integer DEFAULT nextval('public.metadataschemaregistry_seq'::regclass) NOT NULL,
    namespace character varying(256),
    short_id character varying(32)
);


ALTER TABLE public.metadataschemaregistry OWNER TO dspace;

--
-- Name: metadatavalue_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.metadatavalue_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metadatavalue_seq OWNER TO dspace;

--
-- Name: metadatavalue; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.metadatavalue (
    metadata_value_id integer DEFAULT nextval('public.metadatavalue_seq'::regclass) NOT NULL,
    metadata_field_id integer,
    text_value text,
    text_lang character varying(24),
    place integer,
    authority character varying(100),
    confidence integer DEFAULT '-1'::integer,
    dspace_object_id uuid
);


ALTER TABLE public.metadatavalue OWNER TO dspace;

--
-- Name: most_recent_checksum; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.most_recent_checksum (
    to_be_processed boolean NOT NULL,
    expected_checksum character varying NOT NULL,
    current_checksum character varying NOT NULL,
    last_process_start_date timestamp without time zone NOT NULL,
    last_process_end_date timestamp without time zone NOT NULL,
    checksum_algorithm character varying NOT NULL,
    matched_prev_checksum boolean NOT NULL,
    result character varying,
    bitstream_id uuid
);


ALTER TABLE public.most_recent_checksum OWNER TO dspace;

--
-- Name: registrationdata; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.registrationdata (
    registrationdata_id integer NOT NULL,
    email character varying(64),
    token character varying(48),
    expires timestamp without time zone
);


ALTER TABLE public.registrationdata OWNER TO dspace;

--
-- Name: registrationdata_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.registrationdata_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.registrationdata_seq OWNER TO dspace;

--
-- Name: requestitem; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.requestitem (
    requestitem_id integer NOT NULL,
    token character varying(48),
    allfiles boolean,
    request_email character varying(64),
    request_name character varying(64),
    request_date timestamp without time zone,
    accept_request boolean,
    decision_date timestamp without time zone,
    expires timestamp without time zone,
    request_message text,
    item_id uuid,
    bitstream_id uuid
);


ALTER TABLE public.requestitem OWNER TO dspace;

--
-- Name: requestitem_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.requestitem_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requestitem_seq OWNER TO dspace;

--
-- Name: resourcepolicy; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.resourcepolicy (
    policy_id integer NOT NULL,
    resource_type_id integer,
    resource_id integer,
    action_id integer,
    start_date date,
    end_date date,
    rpname character varying(30),
    rptype character varying(30),
    rpdescription text,
    eperson_id uuid,
    epersongroup_id uuid,
    dspace_object uuid
);


ALTER TABLE public.resourcepolicy OWNER TO dspace;

--
-- Name: resourcepolicy_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.resourcepolicy_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resourcepolicy_seq OWNER TO dspace;

--
-- Name: schema_version; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.schema_version OWNER TO dspace;

--
-- Name: site; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.site (
    uuid uuid NOT NULL
);


ALTER TABLE public.site OWNER TO dspace;

--
-- Name: subscription; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.subscription (
    subscription_id integer NOT NULL,
    eperson_id uuid,
    collection_id uuid
);


ALTER TABLE public.subscription OWNER TO dspace;

--
-- Name: subscription_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.subscription_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subscription_seq OWNER TO dspace;

--
-- Name: tasklistitem; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.tasklistitem (
    tasklist_id integer NOT NULL,
    workflow_id integer,
    eperson_id uuid
);


ALTER TABLE public.tasklistitem OWNER TO dspace;

--
-- Name: tasklistitem_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.tasklistitem_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tasklistitem_seq OWNER TO dspace;

--
-- Name: versionhistory; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.versionhistory (
    versionhistory_id integer NOT NULL
);


ALTER TABLE public.versionhistory OWNER TO dspace;

--
-- Name: versionhistory_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.versionhistory_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.versionhistory_seq OWNER TO dspace;

--
-- Name: versionitem; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.versionitem (
    versionitem_id integer NOT NULL,
    version_number integer,
    version_date timestamp without time zone,
    version_summary character varying(255),
    versionhistory_id integer,
    eperson_id uuid,
    item_id uuid
);


ALTER TABLE public.versionitem OWNER TO dspace;

--
-- Name: versionitem_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.versionitem_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.versionitem_seq OWNER TO dspace;

--
-- Name: webapp; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.webapp (
    webapp_id integer NOT NULL,
    appname character varying(32),
    url character varying,
    started timestamp without time zone,
    isui integer
);


ALTER TABLE public.webapp OWNER TO dspace;

--
-- Name: webapp_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.webapp_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.webapp_seq OWNER TO dspace;

--
-- Name: workflowitem; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.workflowitem (
    workflow_id integer NOT NULL,
    state integer,
    multiple_titles boolean,
    published_before boolean,
    multiple_files boolean,
    item_id uuid,
    collection_id uuid,
    owner uuid
);


ALTER TABLE public.workflowitem OWNER TO dspace;

--
-- Name: workflowitem_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.workflowitem_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workflowitem_seq OWNER TO dspace;

--
-- Name: workspaceitem; Type: TABLE; Schema: public; Owner: dspace
--

CREATE TABLE public.workspaceitem (
    workspace_item_id integer NOT NULL,
    multiple_titles boolean,
    published_before boolean,
    multiple_files boolean,
    stage_reached integer,
    page_reached integer,
    item_id uuid,
    collection_id uuid
);


ALTER TABLE public.workspaceitem OWNER TO dspace;

--
-- Name: workspaceitem_seq; Type: SEQUENCE; Schema: public; Owner: dspace
--

CREATE SEQUENCE public.workspaceitem_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workspaceitem_seq OWNER TO dspace;

--
-- Name: checksum_history check_id; Type: DEFAULT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.checksum_history ALTER COLUMN check_id SET DEFAULT nextval('public.checksum_history_check_id_seq'::regclass);


--
-- Data for Name: bitstream; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.bitstream (bitstream_id, bitstream_format_id, checksum, checksum_algorithm, internal_id, deleted, store_number, sequence_id, size_bytes, uuid) FROM stdin;
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	45607029293754608987108868907319527967	t	0	2	1748	8022f9f9-27a2-4557-b022-5052438765a0
\N	1	385781987949b409fa052fdf58d5638d	MD5	47591394740790572891033909030759029664	t	0	1	4396	79a3037d-4834-4a78-8314-f9f09d5f0760
\N	1	dca995f60834723d3b6e65639b4be1a2	MD5	98947114290180448767163563521022125006	t	0	3	7592	45703aed-6405-40ff-bbc9-2691f09ecca1
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	116584232166297765684707094643739948290	t	0	2	1748	68b0398f-9775-4752-a449-9699ed658837
\N	1	0d022789c197ff629092ba2b9023a647	MD5	138121618148967010138715291418723951456	t	0	1	891	90ae6c51-2e02-4690-8fd7-4ceda388b4cd
\N	16	fc7eb0009d0dad85be2bbcd0ef3a57ba	MD5	77586283828677306059638614851751703779	t	0	1	265465	d830ccea-6c47-4820-b5c8-9a2f6eed2442
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	154266413462657031115932910710908725030	t	0	2	1748	642b3906-8d79-4cf0-8a69-0dfb5b78c498
\N	18	4d7295b1cef69151ddea9ba4a18eae83	MD5	91467661968758075882525700691310613762	t	0	-1	7198	61630d7a-03a7-4d8d-9a6b-e4d6c8d15d1e
\N	18	ead7c1f9d01ffc83b45d345005984c13	MD5	66952276690167871909089141256835752770	t	0	1	190151	a62b5e6e-363a-494d-b5b6-a5938fd85a1a
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	23506478381771718134968768584295909435	t	0	2	1748	1d609521-1873-48d0-b196-e0ef8bd4b410
\N	18	90c80958622ba9026ee399527020e34b	MD5	7103229478529208524252549694049388912	t	0	-1	7041	c654bb2d-2f9d-4aaa-9189-cfe4ac179835
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	160658556952046500280032878235610220301	t	0	2	1748	2c9f9493-2010-464a-8127-c1fa74798b2d
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	1297708825603229506879746339600043184	t	0	1	1748	2b69a084-a274-48b1-9a20-7562e6d0c2b1
\N	16	4f8bfd095d7af4c381f61dcb9263aee0	MD5	75245365834806485380700389116414266178	t	0	1	68315	3f0c9692-e28a-47c4-847c-db9933027eb5
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	69350150022759452385265283000082832387	t	0	2	1748	ab2f42a0-461b-48d2-b505-f7a64fb11338
\N	16	6a3b7f2c44010dffae6d69aeb62b7cbf	MD5	132253840356855197064704545958371782123	f	0	-1	30257	64cfb38b-2553-4563-8e2c-9aa63eebea44
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	50175974139122953717458974432395813025	t	0	1	1748	6a415398-6c74-43e8-8bf1-85ef35320656
\N	16	f18659987b4f9a5e5d000fc3189a7000	MD5	24438194614014153863958031329534190238	f	0	-1	40730	eb53475d-d6ac-475d-80bb-ab2e75606cef
\N	1	385781987949b409fa052fdf58d5638d	MD5	115265637806749652516218744397840632777	t	0	1	4396	2b393f56-ad29-472c-a318-43d2470ebef9
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	20321851722343807689096177043612630537	t	0	1	1748	7be55ec8-e2f2-4a5d-9460-5819a9ce215a
\N	16	4f8bfd095d7af4c381f61dcb9263aee0	MD5	111989086965719399476760320775521059205	t	0	-1	68315	4c79e34c-ed0e-4fc6-8590-6c20a8b03394
\N	16	f18659987b4f9a5e5d000fc3189a7000	MD5	829451382223007085819032757147581105	t	0	-1	40730	1e106a1d-adf5-437e-a521-99a91256acf3
\N	18	f27bb9694e59c72ac3b5cc798ff2b701	MD5	119114935029632245998744045252308747230	t	0	-1	62090	59d8ac1a-7f6d-4add-a0ae-9fcd5446be31
\N	16	6a3b7f2c44010dffae6d69aeb62b7cbf	MD5	13097891779314996900789917523975796888	t	0	-1	30257	bde9434d-1770-426d-8f4a-c37912b563c5
\N	16	0abcde76452767fadc71068a1bf91ded	MD5	64823723588843255245143964752169291870	t	0	-1	63210	7ac7ddf7-2191-49db-b4b4-c9927ed12261
\N	16	a567283b4cefac075ff36b6e137d4c96	MD5	55416363877200396524988413710951232054	f	0	-1	268529	790958fc-6da3-4abb-ad03-858d1a1ec57c
\N	18	f27bb9694e59c72ac3b5cc798ff2b701	MD5	118741730328123718664419692270928028197	t	0	-1	62090	b0f4458a-cf9d-42ac-9d51-86fe3a87f5ef
\N	16	4f8bfd095d7af4c381f61dcb9263aee0	MD5	40668781705880103122006401842601017429	t	0	-1	68315	cf87f6f4-da12-4f06-b482-bbbf1f845fec
\N	16	4f8bfd095d7af4c381f61dcb9263aee0	MD5	99892242435417792640360367022424827160	f	0	-1	68315	f275e660-a45d-459e-8b15-5d36d2c6eba4
\N	16	0abcde76452767fadc71068a1bf91ded	MD5	90689827259029632874005305328688063013	f	0	-1	63210	50833f59-a4b8-4b6f-9f96-ed56acc489f8
\N	18	f27bb9694e59c72ac3b5cc798ff2b701	MD5	133920276517015817031347745108317730839	f	0	-1	62090	d18aee16-af5e-4da1-b3fe-490c916ba0ad
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	12962439281976449087536579015060537664	t	0	1	1748	71cffee1-a04e-454f-adbb-4d3270002774
\N	1	385781987949b409fa052fdf58d5638d	MD5	5092064146564826835473725570594739392	f	0	1	4396	ab3cb32c-7c21-461a-ae00-2a30e71b6e86
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	986126346369744523277913757317175367	f	0	2	1748	49109ddc-21ba-4ae0-9e78-1875ab3ec39a
\N	1	ebbf693e7109ddc7fe71a4bd796aa229	MD5	30917323416010240725567886378030500326	t	0	1	399	f31b479b-7597-46dd-835c-a514e2ccf306
\N	2	8a4605be74aa9ea9d79846c1fba20a33	MD5	166603535092730019572175850241055169342	t	0	2	1748	31702324-5623-44de-92de-a6e7e20da583
\.


--
-- Data for Name: bitstreamformatregistry; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.bitstreamformatregistry (bitstream_format_id, mimetype, short_description, description, support_level, internal) FROM stdin;
1	application/octet-stream	Unknown	Unknown data format	0	f
2	text/plain; charset=utf-8	License	Item-specific license agreed upon to submission	1	t
3	text/html; charset=utf-8	CC License	Item-specific Creative Commons license agreed upon to submission	1	t
4	application/pdf	Adobe PDF	Adobe Portable Document Format	1	f
5	text/xml	XML	Extensible Markup Language	1	f
6	text/plain	Text	Plain Text	1	f
7	text/html	HTML	Hypertext Markup Language	1	f
8	text/css	CSS	Cascading Style Sheets	1	f
9	application/msword	Microsoft Word	Microsoft Word	1	f
10	application/vnd.openxmlformats-officedocument.wordprocessingml.document	Microsoft Word XML	Microsoft Word XML	1	f
11	application/vnd.ms-powerpoint	Microsoft Powerpoint	Microsoft Powerpoint	1	f
12	application/vnd.openxmlformats-officedocument.presentationml.presentation	Microsoft Powerpoint XML	Microsoft Powerpoint XML	1	f
13	application/vnd.ms-excel	Microsoft Excel	Microsoft Excel	1	f
14	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	Microsoft Excel XML	Microsoft Excel XML	1	f
15	application/marc	MARC	Machine-Readable Cataloging records	1	f
16	image/jpeg	JPEG	Joint Photographic Experts Group/JPEG File Interchange Format (JFIF)	1	f
17	image/gif	GIF	Graphics Interchange Format	1	f
18	image/png	image/png	Portable Network Graphics	1	f
19	image/tiff	TIFF	Tag Image File Format	1	f
20	audio/x-aiff	AIFF	Audio Interchange File Format	1	f
21	audio/basic	audio/basic	Basic Audio	1	f
22	audio/x-wav	WAV	Broadcase Wave Format	1	f
23	video/mpeg	MPEG	Moving Picture Experts Group	1	f
24	text/richtext	RTF	Rich Text Format	1	f
25	application/vnd.visio	Microsoft Visio	Microsoft Visio	1	f
26	application/x-filemaker	FMP3	Filemaker Pro	1	f
27	image/x-ms-bmp	BMP	Microsoft Windows bitmap	1	f
28	application/x-photoshop	Photoshop	Photoshop	1	f
29	application/postscript	Postscript	Postscript Files	1	f
30	video/quicktime	Video Quicktime	Video Quicktime	1	f
31	audio/x-mpeg	MPEG Audio	MPEG Audio	1	f
32	application/vnd.ms-project	Microsoft Project	Microsoft Project	1	f
33	application/mathematica	Mathematica	Mathematica Notebook	1	f
34	application/x-latex	LateX	LaTeX document	1	f
35	application/x-tex	TeX	Tex/LateX document	1	f
36	application/x-dvi	TeX dvi	TeX dvi format	1	f
37	application/sgml	SGML	SGML application (RFC 1874)	1	f
38	application/wordperfect5.1	WordPerfect	WordPerfect 5.1 document	1	f
39	audio/x-pn-realaudio	RealAudio	RealAudio file	1	f
40	image/x-photo-cd	Photo CD	Kodak Photo CD image	1	f
41	application/vnd.oasis.opendocument.text	OpenDocument Text	OpenDocument Text	1	f
42	application/vnd.oasis.opendocument.text-template	OpenDocument Text Template	OpenDocument Text Template	1	f
43	application/vnd.oasis.opendocument.text-web	OpenDocument HTML Template	OpenDocument HTML Template	1	f
44	application/vnd.oasis.opendocument.text-master	OpenDocument Master Document	OpenDocument Master Document	1	f
45	application/vnd.oasis.opendocument.graphics	OpenDocument Drawing	OpenDocument Drawing	1	f
46	application/vnd.oasis.opendocument.graphics-template	OpenDocument Drawing Template	OpenDocument Drawing Template	1	f
47	application/vnd.oasis.opendocument.presentation	OpenDocument Presentation	OpenDocument Presentation	1	f
48	application/vnd.oasis.opendocument.presentation-template	OpenDocument Presentation Template	OpenDocument Presentation Template	1	f
49	application/vnd.oasis.opendocument.spreadsheet	OpenDocument Spreadsheet	OpenDocument Spreadsheet	1	f
50	application/vnd.oasis.opendocument.spreadsheet-template	OpenDocument Spreadsheet Template	OpenDocument Spreadsheet Template	1	f
51	application/vnd.oasis.opendocument.chart	OpenDocument Chart	OpenDocument Chart	1	f
52	application/vnd.oasis.opendocument.formula	OpenDocument Formula	OpenDocument Formula	1	f
53	application/vnd.oasis.opendocument.database	OpenDocument Database	OpenDocument Database	1	f
54	application/vnd.oasis.opendocument.image	OpenDocument Image	OpenDocument Image	1	f
55	application/vnd.openofficeorg.extension	OpenOffice.org extension	OpenOffice.org extension (since OOo 2.1)	1	f
56	application/vnd.sun.xml.writer	Writer 6.0 documents	Writer 6.0 documents	1	f
57	application/vnd.sun.xml.writer.template	Writer 6.0 templates	Writer 6.0 templates	1	f
58	application/vnd.sun.xml.calc	Calc 6.0 spreadsheets	Calc 6.0 spreadsheets	1	f
59	application/vnd.sun.xml.calc.template	Calc 6.0 templates	Calc 6.0 templates	1	f
60	application/vnd.sun.xml.draw	Draw 6.0 documents	Draw 6.0 documents	1	f
61	application/vnd.sun.xml.draw.template	Draw 6.0 templates	Draw 6.0 templates	1	f
62	application/vnd.sun.xml.impress	Impress 6.0 presentations	Impress 6.0 presentations	1	f
63	application/vnd.sun.xml.impress.template	Impress 6.0 templates	Impress 6.0 templates	1	f
64	application/vnd.sun.xml.writer.global	Writer 6.0 global documents	Writer 6.0 global documents	1	f
65	application/vnd.sun.xml.math	Math 6.0 documents	Math 6.0 documents	1	f
66	application/vnd.stardivision.writer	StarWriter 5.x documents	StarWriter 5.x documents	1	f
67	application/vnd.stardivision.writer-global	StarWriter 5.x global documents	StarWriter 5.x global documents	1	f
68	application/vnd.stardivision.calc	StarCalc 5.x spreadsheets	StarCalc 5.x spreadsheets	1	f
69	application/vnd.stardivision.draw	StarDraw 5.x documents	StarDraw 5.x documents	1	f
70	application/vnd.stardivision.impress	StarImpress 5.x presentations	StarImpress 5.x presentations	1	f
71	application/vnd.stardivision.impress-packed	StarImpress Packed 5.x files	StarImpress Packed 5.x files	1	f
72	application/vnd.stardivision.math	StarMath 5.x documents	StarMath 5.x documents	1	f
73	application/vnd.stardivision.chart	StarChart 5.x documents	StarChart 5.x documents	1	f
74	application/vnd.stardivision.mail	StarMail 5.x mail files	StarMail 5.x mail files	1	f
75	application/rdf+xml; charset=utf-8	RDF XML	RDF serialized in XML	1	f
76	application/epub+zip	EPUB	Electronic publishing	1	f
\.


--
-- Data for Name: bundle; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.bundle (bundle_id, uuid, primary_bitstream_id) FROM stdin;
\N	4ed605d6-72f2-4e09-afd2-8898aeca2a99	\N
\N	0bfdd997-b842-4660-ae00-e97decac5fd8	\N
\.


--
-- Data for Name: bundle2bitstream; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.bundle2bitstream (bitstream_order_legacy, bundle_id, bitstream_id, bitstream_order) FROM stdin;
\N	4ed605d6-72f2-4e09-afd2-8898aeca2a99	ab3cb32c-7c21-461a-ae00-2a30e71b6e86	0
\N	0bfdd997-b842-4660-ae00-e97decac5fd8	49109ddc-21ba-4ae0-9e78-1875ab3ec39a	0
\.


--
-- Data for Name: checksum_history; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.checksum_history (check_id, process_start_date, process_end_date, checksum_expected, checksum_calculated, result, bitstream_id) FROM stdin;
\.


--
-- Data for Name: checksum_results; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.checksum_results (result_code, result_description) FROM stdin;
INVALID_HISTORY	Install of the cheksum checking code do not consider this history as valid
BITSTREAM_NOT_FOUND	The bitstream could not be found
CHECKSUM_MATCH	Current checksum matched previous checksum
CHECKSUM_NO_MATCH	Current checksum does not match previous checksum
CHECKSUM_PREV_NOT_FOUND	Previous checksum was not found: no comparison possible
BITSTREAM_INFO_NOT_FOUND	Bitstream info not found
CHECKSUM_ALGORITHM_INVALID	Invalid checksum algorithm
BITSTREAM_NOT_PROCESSED	Bitstream marked to_be_processed=false
BITSTREAM_MARKED_DELETED	Bitstream marked deleted in bitstream table
\.


--
-- Data for Name: collection; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.collection (collection_id, uuid, workflow_step_1, workflow_step_2, workflow_step_3, submitter, template_item_id, logo_bitstream_id, admin) FROM stdin;
\N	2235ec98-c37a-4b8c-a23c-d638618949d3	41db32c9-81c5-401e-a3d8-b652c3f2cfcd	\N	\N	493173dd-0565-492c-89d6-a8027a0fbe7a	\N	\N	\N
\.


--
-- Data for Name: collection2item; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.collection2item (collection_id, item_id) FROM stdin;
2235ec98-c37a-4b8c-a23c-d638618949d3	994503bc-27f8-48e6-821c-608bcf12004d
\.


--
-- Data for Name: community; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.community (community_id, uuid, admin, logo_bitstream_id) FROM stdin;
\N	fc1cea15-cf7c-437c-9770-d6ff74ea63c4	\N	790958fc-6da3-4abb-ad03-858d1a1ec57c
\N	e3a1c713-cfd4-48c0-aa02-6899432858ef	\N	64cfb38b-2553-4563-8e2c-9aa63eebea44
\N	8aaa534f-9b53-4d88-97cf-621622e57034	\N	eb53475d-d6ac-475d-80bb-ab2e75606cef
\N	51bf9806-4bb4-4ee2-a9b8-8493e53bf3a5	\N	f275e660-a45d-459e-8b15-5d36d2c6eba4
\N	1a3d5676-d754-44a6-9fde-0969b7db7331	\N	50833f59-a4b8-4b6f-9f96-ed56acc489f8
\N	73a9d950-0f73-410f-887b-509a0f6d3711	\N	d18aee16-af5e-4da1-b3fe-490c916ba0ad
\.


--
-- Data for Name: community2collection; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.community2collection (collection_id, community_id) FROM stdin;
2235ec98-c37a-4b8c-a23c-d638618949d3	51bf9806-4bb4-4ee2-a9b8-8493e53bf3a5
\.


--
-- Data for Name: community2community; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.community2community (parent_comm_id, child_comm_id) FROM stdin;
fc1cea15-cf7c-437c-9770-d6ff74ea63c4	e3a1c713-cfd4-48c0-aa02-6899432858ef
fc1cea15-cf7c-437c-9770-d6ff74ea63c4	8aaa534f-9b53-4d88-97cf-621622e57034
fc1cea15-cf7c-437c-9770-d6ff74ea63c4	51bf9806-4bb4-4ee2-a9b8-8493e53bf3a5
fc1cea15-cf7c-437c-9770-d6ff74ea63c4	1a3d5676-d754-44a6-9fde-0969b7db7331
fc1cea15-cf7c-437c-9770-d6ff74ea63c4	73a9d950-0f73-410f-887b-509a0f6d3711
\.


--
-- Data for Name: doi; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.doi (doi_id, doi, resource_type_id, resource_id, status, dspace_object) FROM stdin;
\.


--
-- Data for Name: dspaceobject; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.dspaceobject (uuid) FROM stdin;
ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc
6cbcda86-f2a7-451e-87f6-c1cac29aacc5
653a2407-7e05-4e15-a02c-eaaeceb7bd4a
cfc2d1ca-fe02-4d84-b8e5-6617a0634da2
a62b5e6e-363a-494d-b5b6-a5938fd85a1a
1d609521-1873-48d0-b196-e0ef8bd4b410
c654bb2d-2f9d-4aaa-9189-cfe4ac179835
61630d7a-03a7-4d8d-9a6b-e4d6c8d15d1e
90ae6c51-2e02-4690-8fd7-4ceda388b4cd
68b0398f-9775-4752-a449-9699ed658837
9bdf3f48-794e-42ba-a545-ec43b7757fdc
77b39a80-d9ba-4fff-8536-66821a338c93
0e2856eb-e40c-4c0d-949d-946205182610
54f3f964-0f76-4cd5-9157-ce12d18a385a
45703aed-6405-40ff-bbc9-2691f09ecca1
d830ccea-6c47-4820-b5c8-9a2f6eed2442
642b3906-8d79-4cf0-8a69-0dfb5b78c498
59d8ac1a-7f6d-4add-a0ae-9fcd5446be31
a715933f-d3ee-4720-ab0f-94ad4d07cf69
efa436be-136d-4a59-8215-00f305bde265
4c79e34c-ed0e-4fc6-8590-6c20a8b03394
3f0c9692-e28a-47c4-847c-db9933027eb5
ab2f42a0-461b-48d2-b505-f7a64fb11338
2b69a084-a274-48b1-9a20-7562e6d0c2b1
bde9434d-1770-426d-8f4a-c37912b563c5
1e106a1d-adf5-437e-a521-99a91256acf3
7ac7ddf7-2191-49db-b4b4-c9927ed12261
044090f0-0386-40d0-ad8a-479044ab755a
79a3037d-4834-4a78-8314-f9f09d5f0760
2c9f9493-2010-464a-8127-c1fa74798b2d
6a415398-6c74-43e8-8bf1-85ef35320656
2b393f56-ad29-472c-a318-43d2470ebef9
8022f9f9-27a2-4557-b022-5052438765a0
7be55ec8-e2f2-4a5d-9460-5819a9ce215a
1f4792fa-f7a6-4594-abab-747440d431c8
fc1cea15-cf7c-437c-9770-d6ff74ea63c4
790958fc-6da3-4abb-ad03-858d1a1ec57c
b0f4458a-cf9d-42ac-9d51-86fe3a87f5ef
cf87f6f4-da12-4f06-b482-bbbf1f845fec
e3a1c713-cfd4-48c0-aa02-6899432858ef
64cfb38b-2553-4563-8e2c-9aa63eebea44
8aaa534f-9b53-4d88-97cf-621622e57034
eb53475d-d6ac-475d-80bb-ab2e75606cef
51bf9806-4bb4-4ee2-a9b8-8493e53bf3a5
f275e660-a45d-459e-8b15-5d36d2c6eba4
1a3d5676-d754-44a6-9fde-0969b7db7331
50833f59-a4b8-4b6f-9f96-ed56acc489f8
73a9d950-0f73-410f-887b-509a0f6d3711
d18aee16-af5e-4da1-b3fe-490c916ba0ad
2235ec98-c37a-4b8c-a23c-d638618949d3
493173dd-0565-492c-89d6-a8027a0fbe7a
41db32c9-81c5-401e-a3d8-b652c3f2cfcd
71cffee1-a04e-454f-adbb-4d3270002774
709b36d6-5abd-47ea-9c61-2d40ee89decc
e393c177-804c-49f6-bdb0-297b67d04e18
ec55252a-ca8a-4acb-bcbc-442c078f6afa
558d9a65-f84e-42e7-8c7a-f95a4bcbfaca
fbf442cb-fcca-46d7-be96-684f3c6bcbf3
6461d541-e6e1-4211-ada8-5c4ef5418f8b
a2560efd-c0b1-4102-9843-9236614e015a
b2880022-7908-4b9b-a561-fa3d23273094
a5bba320-ba2d-45d5-8362-113bc268939d
43dfbe58-add4-469d-bb5f-b8795ce635e4
2c6dd8b1-e3a3-445e-b15e-f5c2ac5f18f7
340ef935-927a-4bd1-9308-ba2758c9189f
994503bc-27f8-48e6-821c-608bcf12004d
4ed605d6-72f2-4e09-afd2-8898aeca2a99
ab3cb32c-7c21-461a-ae00-2a30e71b6e86
0bfdd997-b842-4660-ae00-e97decac5fd8
49109ddc-21ba-4ae0-9e78-1875ab3ec39a
dff2ef94-9442-45f3-ae49-9f94d7aa08aa
2029af4e-a628-4dae-942d-47421f2c3d8d
d710ce01-85be-4d7b-9676-00d1ca6449d9
f31b479b-7597-46dd-835c-a514e2ccf306
31702324-5623-44de-92de-a6e7e20da583
\.


--
-- Data for Name: eperson; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.eperson (eperson_id, email, password, can_log_in, require_certificate, self_registered, last_active, sub_frequency, netid, salt, digest_algorithm, uuid) FROM stdin;
\N	juliarpim@gmail.com	02f3d829efef99290da13c5c17262c86712832316f3f5ee41bd69cc0875c6c6c293f72b1cadfe055b0dd36f38c324507e282868cc9f9203d1c93e116abab4f3d	t	f	f	2020-12-17 10:13:01.885	\N	\N	a43588121983f79ec5a9621774f650a0	SHA-512	1f4792fa-f7a6-4594-abab-747440d431c8
\N	disscocommadmin@gmail.com	10496949f0eac272a1578e901182d53f37a6a01bb200b8daa7ba9f69569541efb91e5b4d0a5a478726e1b9f7f1760a7895dea9445cfcaba3b21554288b682367	t	f	f	2021-01-06 10:46:30.334	\N	\N	1810f496cd970f7bbf2f2c85bd4aff12	SHA-512	e393c177-804c-49f6-bdb0-297b67d04e18
\N	disscocolladmin@gmail.com	84439825a3cc7b7dff104cfa4a83f70839535dc7cbb3278e88e98eb3efc1db243111bf1d753fa88301ee81b04fa4d7e107542e2bf7325f08b7e36cb2bec83d83	t	f	f	2021-01-06 10:48:18.454	\N	\N	fddb026f80fa05741729ca7ed518397f	SHA-512	ec55252a-ca8a-4acb-bcbc-442c078f6afa
\N	julia_pim@yahoo.com.br	\N	f	f	f	\N	\N	\N	\N	\N	9bdf3f48-794e-42ba-a545-ec43b7757fdc
\N	newuser77b39a80-d9ba-4fff-8536-66821a338c93	\N	\N	f	f	\N	\N	\N	\N	\N	77b39a80-d9ba-4fff-8536-66821a338c93
\N	newuser0e2856eb-e40c-4c0d-949d-946205182610	\N	\N	f	f	\N	\N	\N	\N	\N	0e2856eb-e40c-4c0d-949d-946205182610
\N	newuser6461d541-e6e1-4211-ada8-5c4ef5418f8b	\N	\N	f	f	\N	\N	\N	\N	\N	6461d541-e6e1-4211-ada8-5c4ef5418f8b
\N	disscoadmin@gmail.com	a190203b3a9f7748079f8bd88353455cde0b3409197ff3860d9b6e566207b63fc6ac76bf10ebf63ca9ffbde957789ef0f6fbef7ee41745faa295b92be350aa7b	t	f	f	2021-01-07 10:35:52.373	\N	\N	0a97026e7658bd5a0f7325ff0d0393b4	SHA-512	fbf442cb-fcca-46d7-be96-684f3c6bcbf3
\N	disscosubmit@gmail.com	0cf3d7d7c5e4e33e909b8e03c7fab22df0485fd3cd5c9edf2a165bc32289f588ede8795e4f215a80c1438999192f84b901a0f3a1f02fbaef76cee85b65223df2	t	f	f	2021-01-05 10:42:17.055	\N	\N	8a81d804187ede4d8dc048316301ddeb	SHA-512	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca
\N	test@test.edu	2a9c39cd356d3e573fbfe37d0884c34f9a8519df12c9a8bc05de57fec9846787c0fa68d18fa08044ca19e41e359572842fa97b4d8251e112880722ae5aa560ee	t	f	f	2021-01-04 10:54:56.385	\N	\N	d767a3e86fb07fef2997ac018f7c8864	SHA-512	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2
\N	disscovisitor@gmail.com	92736b60ec34f616aa69b7f4ae6488558cd5634c669f12a98e2d904412f42407546304906cbc60b4ad7cc0b76fb8fb24fa588de18560258a6ddb99b2f53b6d6f	t	f	f	2021-01-06 10:18:16.907	\N	\N	e2e5ded5938fe00deea4de3305568c3d	SHA-512	a5bba320-ba2d-45d5-8362-113bc268939d
\.


--
-- Data for Name: epersongroup; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.epersongroup (eperson_group_id, uuid, permanent, name) FROM stdin;
\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	t	Anonymous
\N	6cbcda86-f2a7-451e-87f6-c1cac29aacc5	t	Administrator
\N	54f3f964-0f76-4cd5-9157-ce12d18a385a	f	Test Group
\N	a715933f-d3ee-4720-ab0f-94ad4d07cf69	f	COLLECTION_697ab4f5-541c-4ea0-bc45-4f28c10758fd_WORKFLOW_STEP_1
\N	efa436be-136d-4a59-8215-00f305bde265	f	COLLECTION_697ab4f5-541c-4ea0-bc45-4f28c10758fd_WORKFLOW_STEP_3
\N	044090f0-0386-40d0-ad8a-479044ab755a	f	COLLECTION_f4e46c87-1286-4310-a272-ec8afb163874_WORKFLOW_STEP_3
\N	493173dd-0565-492c-89d6-a8027a0fbe7a	f	COLLECTION_2235ec98-c37a-4b8c-a23c-d638618949d3_SUBMIT
\N	41db32c9-81c5-401e-a3d8-b652c3f2cfcd	f	COLLECTION_2235ec98-c37a-4b8c-a23c-d638618949d3_WORKFLOW_STEP_1
\N	a2560efd-c0b1-4102-9843-9236614e015a	f	DiSSCo - Communities Admin
\N	b2880022-7908-4b9b-a561-fa3d23273094	f	DiSSCo - Collection Admin
\N	43dfbe58-add4-469d-bb5f-b8795ce635e4	f	DiSSCo Submiter
\N	dff2ef94-9442-45f3-ae49-9f94d7aa08aa	f	COLLECTION_9b2ab729-d796-4c5e-8e45-1a9d93e73caa_WORKFLOW_STEP_1
\N	2029af4e-a628-4dae-942d-47421f2c3d8d	f	COLLECTION_9b2ab729-d796-4c5e-8e45-1a9d93e73caa_WORKFLOW_STEP_2
\N	d710ce01-85be-4d7b-9676-00d1ca6449d9	f	COLLECTION_9b2ab729-d796-4c5e-8e45-1a9d93e73caa_WORKFLOW_STEP_3
\.


--
-- Data for Name: epersongroup2eperson; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.epersongroup2eperson (eperson_group_id, eperson_id) FROM stdin;
54f3f964-0f76-4cd5-9157-ce12d18a385a	9bdf3f48-794e-42ba-a545-ec43b7757fdc
6cbcda86-f2a7-451e-87f6-c1cac29aacc5	1f4792fa-f7a6-4594-abab-747440d431c8
6cbcda86-f2a7-451e-87f6-c1cac29aacc5	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2
6cbcda86-f2a7-451e-87f6-c1cac29aacc5	fbf442cb-fcca-46d7-be96-684f3c6bcbf3
a2560efd-c0b1-4102-9843-9236614e015a	e393c177-804c-49f6-bdb0-297b67d04e18
b2880022-7908-4b9b-a561-fa3d23273094	ec55252a-ca8a-4acb-bcbc-442c078f6afa
b2880022-7908-4b9b-a561-fa3d23273094	e393c177-804c-49f6-bdb0-297b67d04e18
43dfbe58-add4-469d-bb5f-b8795ce635e4	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca
43dfbe58-add4-469d-bb5f-b8795ce635e4	9bdf3f48-794e-42ba-a545-ec43b7757fdc
43dfbe58-add4-469d-bb5f-b8795ce635e4	1f4792fa-f7a6-4594-abab-747440d431c8
\.


--
-- Data for Name: epersongroup2workspaceitem; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.epersongroup2workspaceitem (workspace_item_id, eperson_group_id) FROM stdin;
\.


--
-- Data for Name: fileextension; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.fileextension (file_extension_id, bitstream_format_id, extension) FROM stdin;
1	4	pdf
2	5	xml
3	6	txt
4	6	asc
5	7	htm
6	7	html
7	8	css
8	9	doc
9	10	docx
10	11	ppt
11	12	pptx
12	13	xls
13	14	xlsx
14	16	jpeg
15	16	jpg
16	17	gif
17	18	png
18	19	tiff
19	19	tif
20	20	aiff
21	20	aif
22	20	aifc
23	21	au
24	21	snd
25	22	wav
26	23	mpeg
27	23	mpg
28	23	mpe
29	24	rtf
30	25	vsd
31	26	fm
32	27	bmp
33	28	psd
34	28	pdd
35	29	ps
36	29	eps
37	29	ai
38	30	mov
39	30	qt
40	31	mpa
41	31	abs
42	31	mpega
43	32	mpp
44	32	mpx
45	32	mpd
46	33	ma
47	34	latex
48	35	tex
49	36	dvi
50	37	sgm
51	37	sgml
52	38	wpd
53	39	ra
54	39	ram
55	40	pcd
56	41	odt
57	42	ott
58	43	oth
59	44	odm
60	45	odg
61	46	otg
62	47	odp
63	48	otp
64	49	ods
65	50	ots
66	51	odc
67	52	odf
68	53	odb
69	54	odi
70	55	oxt
71	56	sxw
72	57	stw
73	58	sxc
74	59	stc
75	60	sxd
76	61	std
77	62	sxi
78	63	sti
79	64	sxg
80	65	sxm
81	66	sdw
82	67	sgl
83	68	sdc
84	69	sda
85	70	sdd
86	71	sdp
87	72	smf
88	73	sds
89	74	sdm
90	75	rdf
91	76	epub
\.


--
-- Data for Name: group2group; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.group2group (parent_id, child_id) FROM stdin;
\.


--
-- Data for Name: group2groupcache; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.group2groupcache (parent_id, child_id) FROM stdin;
\.


--
-- Data for Name: handle; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.handle (handle_id, handle, resource_type_id, resource_legacy_id, resource_id) FROM stdin;
1	123456789/0	5	\N	653a2407-7e05-4e15-a02c-eaaeceb7bd4a
7	123456789/6	2	\N	\N
8	123456789/7	2	\N	\N
6	123456789/5	3	\N	\N
5	123456789/4	4	\N	\N
4	123456789/3	2	\N	\N
3	123456789/2	3	\N	\N
2	123456789/1	4	\N	\N
10	123456789/9	3	\N	\N
16	123456789/15	2	\N	\N
15	123456789/14	2	\N	\N
13	123456789/12	3	\N	\N
14	123456789/13	3	\N	\N
22	123456789/21	4	\N	\N
28	123456789/27	2	\N	\N
32	123456789/31	2	\N	\N
27	123456789/26	2	\N	\N
20	123456789/19	4	\N	\N
23	123456789/22	4	\N	\N
21	123456789/20	4	\N	\N
24	123456789/23	3	\N	\N
25	123456789/24	3	\N	\N
26	123456789/25	3	\N	\N
29	123456789/28	3	\N	\N
33	123456789/32	2	\N	\N
30	123456789/29	3	\N	\N
31	123456789/30	3	\N	\N
12	123456789/11	4	\N	\N
11	123456789/10	4	\N	\N
18	123456789/17	4	\N	\N
9	123456789/8	4	\N	\N
17	123456789/16	4	\N	\N
19	123456789/18	4	\N	\N
34	123456789/33	4	\N	fc1cea15-cf7c-437c-9770-d6ff74ea63c4
35	123456789/34	4	\N	\N
36	123456789/35	4	\N	\N
37	123456789/36	4	\N	e3a1c713-cfd4-48c0-aa02-6899432858ef
70	123456789/69	4	\N	8aaa534f-9b53-4d88-97cf-621622e57034
71	123456789/70	4	\N	51bf9806-4bb4-4ee2-a9b8-8493e53bf3a5
72	123456789/71	4	\N	1a3d5676-d754-44a6-9fde-0969b7db7331
73	123456789/72	4	\N	73a9d950-0f73-410f-887b-509a0f6d3711
74	123456789/73	3	\N	2235ec98-c37a-4b8c-a23c-d638618949d3
75	123456789/74	2	\N	\N
76	123456789/75	2	\N	994503bc-27f8-48e6-821c-608bcf12004d
78	123456789/77	2	\N	\N
77	123456789/76	3	\N	\N
\.


--
-- Data for Name: harvested_collection; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.harvested_collection (harvest_type, oai_source, oai_set_id, harvest_message, metadata_config_id, harvest_status, harvest_start_time, last_harvested, id, collection_id) FROM stdin;
\.


--
-- Data for Name: harvested_item; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.harvested_item (last_harvested, oai_id, id, item_id) FROM stdin;
\.


--
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.item (item_id, in_archive, withdrawn, last_modified, discoverable, uuid, submitter_id, owning_collection) FROM stdin;
\N	f	f	2021-01-05 10:42:23.158+00	t	2c6dd8b1-e3a3-445e-b15e-f5c2ac5f18f7	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N
\N	f	f	2021-01-05 10:42:49.219+00	t	340ef935-927a-4bd1-9308-ba2758c9189f	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N
\N	f	f	2021-01-04 10:55:17.746+00	t	709b36d6-5abd-47ea-9c61-2d40ee89decc	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N
\N	t	f	2021-01-06 10:00:34.64+00	t	994503bc-27f8-48e6-821c-608bcf12004d	fbf442cb-fcca-46d7-be96-684f3c6bcbf3	2235ec98-c37a-4b8c-a23c-d638618949d3
\.


--
-- Data for Name: item2bundle; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.item2bundle (bundle_id, item_id) FROM stdin;
4ed605d6-72f2-4e09-afd2-8898aeca2a99	994503bc-27f8-48e6-821c-608bcf12004d
0bfdd997-b842-4660-ae00-e97decac5fd8	994503bc-27f8-48e6-821c-608bcf12004d
\.


--
-- Data for Name: metadatafieldregistry; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.metadatafieldregistry (metadata_field_id, metadata_schema_id, element, qualifier, scope_note) FROM stdin;
1	2	firstname	\N	\N
2	2	lastname	\N	\N
3	2	phone	\N	\N
4	2	language	\N	\N
5	1	provenance	\N	\N
6	1	rights	license	\N
7	1	contributor	\N	A person, organization, or service responsible for the content of the resource.  Catch-all for unspecified contributors.
8	1	contributor	advisor	Use primarily for thesis advisor.
9	1	contributor	author	\N
10	1	contributor	editor	\N
11	1	contributor	illustrator	\N
12	1	contributor	other	\N
13	1	coverage	spatial	Spatial characteristics of content.
14	1	coverage	temporal	Temporal characteristics of content.
15	1	creator	\N	Do not use; only for harvested metadata.
16	1	date	\N	Use qualified form if possible.
17	1	date	accessioned	Date DSpace takes possession of item.
18	1	date	available	Date or date range item became available to the public.
19	1	date	copyright	Date of copyright.
20	1	date	created	Date of creation or manufacture of intellectual content if different from date.issued.
21	1	date	issued	Date of publication or distribution.
22	1	date	submitted	Recommend for theses/dissertations.
23	1	identifier	\N	Catch-all for unambiguous identifiers not defined by\n    qualified form; use identifier.other for a known identifier common\n    to a local collection instead of unqualified form.
24	1	identifier	citation	Human-readable, standard bibliographic citation \n    of non-DSpace format of this item
25	1	identifier	govdoc	A government document number
26	1	identifier	isbn	International Standard Book Number
27	1	identifier	issn	International Standard Serial Number
28	1	identifier	sici	Serial Item and Contribution Identifier
29	1	identifier	ismn	International Standard Music Number
30	1	identifier	other	A known identifier type common to a local collection.
31	1	identifier	uri	Uniform Resource Identifier
32	1	description	\N	Catch-all for any description not defined by qualifiers.
33	1	description	abstract	Abstract or summary.
34	1	description	provenance	The history of custody of the item since its creation, including any changes successive custodians made to it.
35	1	description	sponsorship	Information about sponsoring agencies, individuals, or\n    contractual arrangements for the item.
36	1	description	statementofresponsibility	To preserve statement of responsibility from MARC records.
37	1	description	tableofcontents	A table of contents for a given item.
38	1	description	uri	Uniform Resource Identifier pointing to description of\n    this item.
39	1	format	\N	Catch-all for any format information not defined by qualifiers.
40	1	format	extent	Size or duration.
41	1	format	medium	Physical medium.
42	1	format	mimetype	Registered MIME type identifiers.
43	1	language	\N	Catch-all for non-ISO forms of the language of the\n    item, accommodating harvested values.
44	1	language	iso	Current ISO standard for language of intellectual content, including country codes (e.g. "en_US").
45	1	publisher	\N	Entity responsible for publication, distribution, or imprint.
46	1	relation	\N	Catch-all for references to other related items.
47	1	relation	isformatof	References additional physical form.
48	1	relation	ispartof	References physically or logically containing item.
49	1	relation	ispartofseries	Series name and number within that series, if available.
50	1	relation	haspart	References physically or logically contained item.
51	1	relation	isversionof	References earlier version.
52	1	relation	hasversion	References later version.
53	1	relation	isbasedon	References source.
54	1	relation	isreferencedby	Pointed to by referenced resource.
55	1	relation	requires	Referenced resource is required to support function,\n    delivery, or coherence of item.
56	1	relation	replaces	References preceeding item.
57	1	relation	isreplacedby	References succeeding item.
58	1	relation	uri	References Uniform Resource Identifier for related item.
59	1	rights	\N	Terms governing use and reproduction.
60	1	rights	uri	References terms governing use and reproduction.
61	1	source	\N	Do not use; only for harvested metadata.
62	1	source	uri	Do not use; only for harvested metadata.
63	1	subject	\N	Uncontrolled index term.
64	1	subject	classification	Catch-all for value from local classification system;\n    global classification systems will receive specific qualifier
65	1	subject	ddc	Dewey Decimal Classification Number
66	1	subject	lcc	Library of Congress Classification Number
67	1	subject	lcsh	Library of Congress Subject Headings
68	1	subject	mesh	MEdical Subject Headings
69	1	subject	other	Local controlled vocabulary; global vocabularies will receive specific qualifier.
70	1	title	\N	Title statement/title proper.
71	1	title	alternative	Varying (or substitute) form of title proper appearing in item,\n    e.g. abbreviation or translation
72	1	type	\N	Nature or genre of content.
73	3	abstract	\N	A summary of the resource.
74	3	accessRights	\N	Information about who can access the resource or an indication of its security status. May include information regarding access or restrictions based on privacy, security, or other policies.
75	3	accrualMethod	\N	The method by which items are added to a collection.
76	3	accrualPeriodicity	\N	The frequency with which items are added to a collection.
77	3	accrualPolicy	\N	The policy governing the addition of items to a collection.
78	3	alternative	\N	An alternative name for the resource.
79	3	audience	\N	A class of entity for whom the resource is intended or useful.
80	3	available	\N	Date (often a range) that the resource became or will become available.
81	3	bibliographicCitation	\N	Recommended practice is to include sufficient bibliographic detail to identify the resource as unambiguously as possible.
82	3	conformsTo	\N	An established standard to which the described resource conforms.
83	3	contributor	\N	An entity responsible for making contributions to the resource. Examples of a Contributor include a person, an organization, or a service.
84	3	coverage	\N	The spatial or temporal topic of the resource, the spatial applicability of the resource, or the jurisdiction under which the resource is relevant.
85	3	created	\N	Date of creation of the resource.
86	3	creator	\N	An entity primarily responsible for making the resource.
87	3	date	\N	A point or period of time associated with an event in the lifecycle of the resource.
88	3	dateAccepted	\N	Date of acceptance of the resource.
89	3	dateCopyrighted	\N	Date of copyright.
90	3	dateSubmitted	\N	Date of submission of the resource.
91	3	description	\N	An account of the resource.
92	3	educationLevel	\N	A class of entity, defined in terms of progression through an educational or training context, for which the described resource is intended.
93	3	extent	\N	The size or duration of the resource.
94	3	format	\N	The file format, physical medium, or dimensions of the resource.
95	3	hasFormat	\N	A related resource that is substantially the same as the pre-existing described resource, but in another format.
96	3	hasPart	\N	A related resource that is included either physically or logically in the described resource.
97	3	hasVersion	\N	A related resource that is a version, edition, or adaptation of the described resource.
98	3	identifier	\N	An unambiguous reference to the resource within a given context.
99	3	instructionalMethod	\N	A process, used to engender knowledge, attitudes and skills, that the described resource is designed to support.
100	3	isFormatOf	\N	A related resource that is substantially the same as the described resource, but in another format.
101	3	isPartOf	\N	A related resource in which the described resource is physically or logically included.
102	3	isReferencedBy	\N	A related resource that references, cites, or otherwise points to the described resource.
103	3	isReplacedBy	\N	A related resource that supplants, displaces, or supersedes the described resource.
104	3	isRequiredBy	\N	A related resource that requires the described resource to support its function, delivery, or coherence.
105	3	issued	\N	Date of formal issuance (e.g., publication) of the resource.
106	3	isVersionOf	\N	A related resource of which the described resource is a version, edition, or adaptation.
107	3	language	\N	A language of the resource.
108	3	license	\N	A legal document giving official permission to do something with the resource.
109	3	mediator	\N	An entity that mediates access to the resource and for whom the resource is intended or useful.
110	3	medium	\N	The material or physical carrier of the resource.
111	3	modified	\N	Date on which the resource was changed.
112	3	provenance	\N	A statement of any changes in ownership and custody of the resource since its creation that are significant for its authenticity, integrity, and interpretation.
113	3	publisher	\N	An entity responsible for making the resource available.
114	3	references	\N	A related resource that is referenced, cited, or otherwise pointed to by the described resource.
115	3	relation	\N	A related resource.
116	3	replaces	\N	A related resource that is supplanted, displaced, or superseded by the described resource.
117	3	requires	\N	A related resource that is required by the described resource to support its function, delivery, or coherence.
118	3	rights	\N	Information about rights held in and over the resource.
119	3	rightsHolder	\N	A person or organization owning or managing rights over the resource.
120	3	source	\N	A related resource from which the described resource is derived.
121	3	spatial	\N	Spatial characteristics of the resource.
122	3	subject	\N	The topic of the resource.
123	3	tableOfContents	\N	A list of subunits of the resource.
124	3	temporal	\N	Temporal characteristics of the resource.
125	3	title	\N	A name given to the resource.
126	3	type	\N	The nature or genre of the resource.
127	3	valid	\N	Date (often a range) of validity of a resource.
128	1	date	updated	The last time the item was updated via the SWORD interface
129	1	description	version	The Peer Reviewed status of an item
130	1	identifier	slug	a uri supplied via the sword slug header, as a suggested uri for the item
131	1	language	rfc3066	the rfc3066 form of the language for the item
132	1	rights	holder	The owner of the copyright
\.


--
-- Data for Name: metadataschemaregistry; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.metadataschemaregistry (metadata_schema_id, namespace, short_id) FROM stdin;
1	http://dublincore.org/documents/dcmi-terms/	dc
2	http://dspace.org/eperson	eperson
3	http://purl.org/dc/terms/	dcterms
4	http://dspace.org/namespace/local/	local
\.


--
-- Data for Name: metadatavalue; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.metadatavalue (metadata_value_id, metadata_field_id, text_value, text_lang, place, authority, confidence, dspace_object_id) FROM stdin;
1	2	user	\N	0	\N	-1	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2
2	1	admin	\N	0	\N	-1	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2
3	4	en	\N	0	\N	-1	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2
437	33	The primary vehicle through which DiSSCo will raise its overall readiness to favorably position itself for its construction and eventual operation. Construction preparedness will be achieved by developing a comprehensive Construction Masterplan that will be based on the thorough and complete integration of five critical implementation areas.	\N	0	\N	-1	51bf9806-4bb4-4ee2-a9b8-8493e53bf3a5
132	70	icedig-blok-version-small.png	\N	0	\N	-1	59d8ac1a-7f6d-4add-a0ae-9fcd5446be31
133	61	/dspace/upload/icedig-blok-version-small.png	\N	0	\N	-1	59d8ac1a-7f6d-4add-a0ae-9fcd5446be31
422	70	mobilise.jpg	\N	0	\N	-1	64cfb38b-2553-4563-8e2c-9aa63eebea44
423	61	/dspace/upload/mobilise.jpg	\N	0	\N	-1	64cfb38b-2553-4563-8e2c-9aa63eebea44
430	70	ENVRI-FAIR	\N	0	\N	-1	8aaa534f-9b53-4d88-97cf-621622e57034
431	33	The ENVRI community is a group of Environmental Research Infrastructures (ENVRI), projects, networks and other diverse stakeholders interested in environmental Research Infrastructure matters	\N	0	\N	-1	8aaa534f-9b53-4d88-97cf-621622e57034
44	70	londonhm.png	\N	0	\N	-1	61630d7a-03a7-4d8d-9a6b-e4d6c8d15d1e
45	61	/dspace/upload/londonhm.png	\N	0	\N	-1	61630d7a-03a7-4d8d-9a6b-e4d6c8d15d1e
20	70	Screenshot from 2020-11-23 11-40-53.png	\N	0	\N	-1	a62b5e6e-363a-494d-b5b6-a5938fd85a1a
21	61	/dspace/upload/Screenshot from 2020-11-23 11-40-53.png	\N	0	\N	-1	a62b5e6e-363a-494d-b5b6-a5938fd85a1a
22	32		\N	0	\N	-1	a62b5e6e-363a-494d-b5b6-a5938fd85a1a
443	33	SYNTHESYS+ is the final iteration of a programme which builds upon previous projects that ran continuously from February 2004 until August 2017. So far all iterations of the SYNTHESYS programme have developed collections infrastructure with international partners, via discrete work packages coordinated under deliverables of Access, Networking, and Joint Research Activities.	\N	0	\N	-1	1a3d5676-d754-44a6-9fde-0969b7db7331
141	70	logoprepare.jpg	\N	0	\N	-1	4c79e34c-ed0e-4fc6-8590-6c20a8b03394
142	61	/dspace/upload/logoprepare.jpg	\N	0	\N	-1	4c79e34c-ed0e-4fc6-8590-6c20a8b03394
270	32		\N	0	\N	-1	79a3037d-4834-4a78-8314-f9f09d5f0760
24	70	license.txt	\N	0	\N	-1	1d609521-1873-48d0-b196-e0ef8bd4b410
25	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	1d609521-1873-48d0-b196-e0ef8bd4b410
178	70	logoprepare.jpg	\N	0	\N	-1	3f0c9692-e28a-47c4-847c-db9933027eb5
179	61	/dspace/upload/logoprepare.jpg	\N	0	\N	-1	3f0c9692-e28a-47c4-847c-db9933027eb5
180	32		\N	0	\N	-1	3f0c9692-e28a-47c4-847c-db9933027eb5
118	70	nature.jpg	\N	0	\N	-1	d830ccea-6c47-4820-b5c8-9a2f6eed2442
119	61	/dspace/upload/nature.jpg	\N	0	\N	-1	d830ccea-6c47-4820-b5c8-9a2f6eed2442
120	32		\N	0	\N	-1	d830ccea-6c47-4820-b5c8-9a2f6eed2442
182	70	license.txt	\N	0	\N	-1	ab2f42a0-461b-48d2-b505-f7a64fb11338
183	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	ab2f42a0-461b-48d2-b505-f7a64fb11338
434	70	logoprepare.jpg	\N	0	\N	-1	f275e660-a45d-459e-8b15-5d36d2c6eba4
35	70	naturlogo.png	\N	0	\N	-1	c654bb2d-2f9d-4aaa-9189-cfe4ac179835
36	61	/dspace/upload/naturlogo.png	\N	0	\N	-1	c654bb2d-2f9d-4aaa-9189-cfe4ac179835
435	61	/dspace/upload/logoprepare.jpg	\N	0	\N	-1	f275e660-a45d-459e-8b15-5d36d2c6eba4
436	70	DiSSCo Prepare	\N	0	\N	-1	51bf9806-4bb4-4ee2-a9b8-8493e53bf3a5
440	70	synthesys-1.jpg	\N	0	\N	-1	50833f59-a4b8-4b6f-9f96-ed56acc489f8
122	70	license.txt	\N	0	\N	-1	642b3906-8d79-4cf0-8a69-0dfb5b78c498
123	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	642b3906-8d79-4cf0-8a69-0dfb5b78c498
441	61	/dspace/upload/synthesys-1.jpg	\N	0	\N	-1	50833f59-a4b8-4b6f-9f96-ed56acc489f8
442	70	SYNTHESYS+	\N	0	\N	-1	1a3d5676-d754-44a6-9fde-0969b7db7331
449	33	ICEDIG is the first step to help to help tackle the complex challenge of digitising natural science collections and providing access to collections data via DiSSCo. In support of DiSSCo, ICEDIG will devise the necessary plans and capacity enhancements to make the future Research Infrastructure for natural sciences collections operational.	\N	0	\N	-1	73a9d950-0f73-410f-887b-509a0f6d3711
446	70	icedig-blok-version-small.png	\N	0	\N	-1	d18aee16-af5e-4da1-b3fe-490c916ba0ad
218	70	envri.jpg	\N	0	\N	-1	1e106a1d-adf5-437e-a521-99a91256acf3
219	61	/dspace/upload/envri.jpg	\N	0	\N	-1	1e106a1d-adf5-437e-a521-99a91256acf3
447	61	/dspace/upload/icedig-blok-version-small.png	\N	0	\N	-1	d18aee16-af5e-4da1-b3fe-490c916ba0ad
212	70	mobilise.jpg	\N	0	\N	-1	bde9434d-1770-426d-8f4a-c37912b563c5
213	61	/dspace/upload/mobilise.jpg	\N	0	\N	-1	bde9434d-1770-426d-8f4a-c37912b563c5
448	70	ICEDIG	\N	0	\N	-1	73a9d950-0f73-410f-887b-509a0f6d3711
268	70	README.md	\N	0	\N	-1	79a3037d-4834-4a78-8314-f9f09d5f0760
66	32		\N	0	\N	-1	90ae6c51-2e02-4690-8fd7-4ceda388b4cd
269	61	/dspace/upload/README.md	\N	0	\N	-1	79a3037d-4834-4a78-8314-f9f09d5f0760
272	70	license.txt	\N	0	\N	-1	2c9f9493-2010-464a-8127-c1fa74798b2d
273	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	2c9f9493-2010-464a-8127-c1fa74798b2d
224	70	synthesys-1.jpg	\N	0	\N	-1	7ac7ddf7-2191-49db-b4b4-c9927ed12261
225	61	/dspace/upload/synthesys-1.jpg	\N	0	\N	-1	7ac7ddf7-2191-49db-b4b4-c9927ed12261
483	2	user	\N	0	\N	-1	fbf442cb-fcca-46d7-be96-684f3c6bcbf3
484	1	admin	\N	0	\N	-1	fbf442cb-fcca-46d7-be96-684f3c6bcbf3
485	4	en	\N	0	\N	-1	fbf442cb-fcca-46d7-be96-684f3c6bcbf3
76	1	julia	\N	0	\N	-1	9bdf3f48-794e-42ba-a545-ec43b7757fdc
77	2	reis	\N	0	\N	-1	9bdf3f48-794e-42ba-a545-ec43b7757fdc
78	4	en	\N	0	\N	-1	9bdf3f48-794e-42ba-a545-ec43b7757fdc
492	1	John	\N	0	\N	-1	a5bba320-ba2d-45d5-8362-113bc268939d
493	2	User	\N	0	\N	-1	a5bba320-ba2d-45d5-8362-113bc268939d
494	4	en	\N	0	\N	-1	a5bba320-ba2d-45d5-8362-113bc268939d
93	70	demo.iml	\N	0	\N	-1	45703aed-6405-40ff-bbc9-2691f09ecca1
94	61	/dspace/upload/demo.iml	\N	0	\N	-1	45703aed-6405-40ff-bbc9-2691f09ecca1
95	70	license.txt	\N	0	\N	-1	68b0398f-9775-4752-a449-9699ed658837
96	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	68b0398f-9775-4752-a449-9699ed658837
424	70	MOBILISE	\N	0	\N	-1	e3a1c713-cfd4-48c0-aa02-6899432858ef
326	70	README.md	\N	0	\N	-1	2b393f56-ad29-472c-a318-43d2470ebef9
327	61	/dspace/upload/README.md	\N	0	\N	-1	2b393f56-ad29-472c-a318-43d2470ebef9
425	33	MOBILISE will produce a comprehensive knowledge framework for establishing bio- and geodiversity data as a crosscutting topic for nature-related domains.	\N	0	\N	-1	e3a1c713-cfd4-48c0-aa02-6899432858ef
548	70	license.txt	\N	0	\N	-1	71cffee1-a04e-454f-adbb-4d3270002774
549	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	71cffee1-a04e-454f-adbb-4d3270002774
97	70	HELP.md	\N	0	\N	-1	90ae6c51-2e02-4690-8fd7-4ceda388b4cd
98	61	/dspace/upload/HELP.md	\N	0	\N	-1	90ae6c51-2e02-4690-8fd7-4ceda388b4cd
328	32		\N	0	\N	-1	2b393f56-ad29-472c-a318-43d2470ebef9
428	70	envri.jpg	\N	0	\N	-1	eb53475d-d6ac-475d-80bb-ab2e75606cef
429	61	/dspace/upload/envri.jpg	\N	0	\N	-1	eb53475d-d6ac-475d-80bb-ab2e75606cef
558	9	Pim Reis, Julia	\N	0	\N	-1	994503bc-27f8-48e6-821c-608bcf12004d
559	70	Testing privacy	en_US	0	\N	-1	994503bc-27f8-48e6-821c-608bcf12004d
561	70	ORIGINAL	\N	1	\N	-1	4ed605d6-72f2-4e09-afd2-8898aeca2a99
202	70	license.txt	\N	0	\N	-1	2b69a084-a274-48b1-9a20-7562e6d0c2b1
203	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	2b69a084-a274-48b1-9a20-7562e6d0c2b1
457	70	WP 1. User needs and socioeconomic impact	\N	0	\N	-1	2235ec98-c37a-4b8c-a23c-d638618949d3
458	33		\N	0	\N	-1	2235ec98-c37a-4b8c-a23c-d638618949d3
562	70	README.md	\N	0	\N	-1	ab3cb32c-7c21-461a-ae00-2a30e71b6e86
563	61	/dspace/upload/README.md	\N	0	\N	-1	ab3cb32c-7c21-461a-ae00-2a30e71b6e86
564	32		\N	0	\N	-1	ab3cb32c-7c21-461a-ae00-2a30e71b6e86
565	70	LICENSE	\N	1	\N	-1	0bfdd997-b842-4660-ae00-e97decac5fd8
566	70	license.txt	\N	0	\N	-1	49109ddc-21ba-4ae0-9e78-1875ab3ec39a
567	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	49109ddc-21ba-4ae0-9e78-1875ab3ec39a
568	34	Submitted by admin user (disscoadmin@gmail.com) on 2021-01-06T10:00:29Z\nNo. of bitstreams: 1\nREADME.md: 4396 bytes, checksum: 385781987949b409fa052fdf58d5638d (MD5)	en	0	\N	-1	994503bc-27f8-48e6-821c-608bcf12004d
284	70	license.txt	\N	0	\N	-1	6a415398-6c74-43e8-8bf1-85ef35320656
285	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	6a415398-6c74-43e8-8bf1-85ef35320656
569	31	http://localhost:8080/jspui/handle/123456789/75	\N	0	\N	-1	994503bc-27f8-48e6-821c-608bcf12004d
371	70	dissco-logo-high-res_0.jpg	\N	0	\N	-1	790958fc-6da3-4abb-ad03-858d1a1ec57c
372	61	/dspace/upload/dissco-logo-high-res_0.jpg	\N	0	\N	-1	790958fc-6da3-4abb-ad03-858d1a1ec57c
480	1	John	\N	0	\N	-1	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca
481	2	User	\N	0	\N	-1	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca
482	4	en	\N	0	\N	-1	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca
357	70	license.txt	\N	0	\N	-1	7be55ec8-e2f2-4a5d-9460-5819a9ce215a
358	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	7be55ec8-e2f2-4a5d-9460-5819a9ce215a
574	1	John	\N	0	\N	-1	ec55252a-ca8a-4acb-bcbc-442c078f6afa
575	2	User	\N	0	\N	-1	ec55252a-ca8a-4acb-bcbc-442c078f6afa
373	70	DiSSCo	\N	0	\N	-1	fc1cea15-cf7c-437c-9770-d6ff74ea63c4
374	33	The Distributed System of Scientific Collections is a new world-class Research Infrastructure (RI) for natural science collections. The DiSSCo RI works for the digital unification of all European natural science assets under common curation, access, policies and practices, and aims to ensure that the data is easily Findable, Accessible, Interoperable and Reusable (FAIR).	\N	0	\N	-1	fc1cea15-cf7c-437c-9770-d6ff74ea63c4
489	1	John	\N	0	\N	-1	e393c177-804c-49f6-bdb0-297b67d04e18
490	2	User	\N	0	\N	-1	e393c177-804c-49f6-bdb0-297b67d04e18
491	4	en	\N	0	\N	-1	e393c177-804c-49f6-bdb0-297b67d04e18
573	34	Made available in DSpace on 2021-01-06T10:00:29Z (GMT). No. of bitstreams: 1\nREADME.md: 4396 bytes, checksum: 385781987949b409fa052fdf58d5638d (MD5)\n  Previous issue date: 2021-02-09	en	1	\N	-1	994503bc-27f8-48e6-821c-608bcf12004d
570	17	2021-01-06T10:00:29Z	\N	0	\N	-1	994503bc-27f8-48e6-821c-608bcf12004d
571	18	2021-01-06T10:00:29Z	\N	0	\N	-1	994503bc-27f8-48e6-821c-608bcf12004d
572	21	2021-02-09	\N	0	\N	-1	994503bc-27f8-48e6-821c-608bcf12004d
576	3		\N	0	\N	-1	ec55252a-ca8a-4acb-bcbc-442c078f6afa
577	4	en	\N	0	\N	-1	ec55252a-ca8a-4acb-bcbc-442c078f6afa
332	70	license.txt	\N	0	\N	-1	8022f9f9-27a2-4557-b022-5052438765a0
333	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	8022f9f9-27a2-4557-b022-5052438765a0
354	2	user	\N	0	\N	-1	1f4792fa-f7a6-4594-abab-747440d431c8
377	70	icedig-blok-version-small.png	\N	0	\N	-1	b0f4458a-cf9d-42ac-9d51-86fe3a87f5ef
378	61	/dspace/upload/icedig-blok-version-small.png	\N	0	\N	-1	b0f4458a-cf9d-42ac-9d51-86fe3a87f5ef
355	1	admin	\N	0	\N	-1	1f4792fa-f7a6-4594-abab-747440d431c8
356	4	en	\N	0	\N	-1	1f4792fa-f7a6-4594-abab-747440d431c8
591	70	browse-result.csv	\N	0	\N	-1	f31b479b-7597-46dd-835c-a514e2ccf306
592	61	/dspace/upload/browse-result.csv	\N	0	\N	-1	f31b479b-7597-46dd-835c-a514e2ccf306
593	32		\N	0	\N	-1	f31b479b-7597-46dd-835c-a514e2ccf306
383	70	logoprepare.jpg	\N	0	\N	-1	cf87f6f4-da12-4f06-b482-bbbf1f845fec
384	61	/dspace/upload/logoprepare.jpg	\N	0	\N	-1	cf87f6f4-da12-4f06-b482-bbbf1f845fec
595	70	license.txt	\N	0	\N	-1	31702324-5623-44de-92de-a6e7e20da583
596	61	Written by org.dspace.content.LicenseUtils	\N	0	\N	-1	31702324-5623-44de-92de-a6e7e20da583
\.


--
-- Data for Name: most_recent_checksum; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.most_recent_checksum (to_be_processed, expected_checksum, current_checksum, last_process_start_date, last_process_end_date, checksum_algorithm, matched_prev_checksum, result, bitstream_id) FROM stdin;
\.


--
-- Data for Name: registrationdata; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.registrationdata (registrationdata_id, email, token, expires) FROM stdin;
1	julia_pim@yahoo.com.br	5fb1b1d8bda4b363ef590fa43150e7fc	\N
2	disscoprepare@gmail.com	f7a3fe74aede9dc97b5d52d7b32f8a80	\N
3	juliapimfn@gmail.com	8d1fc285d69623a3b542cabf6b6ce348	\N
\.


--
-- Data for Name: requestitem; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.requestitem (requestitem_id, token, allfiles, request_email, request_name, request_date, accept_request, decision_date, expires, request_message, item_id, bitstream_id) FROM stdin;
\.


--
-- Data for Name: resourcepolicy; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.resourcepolicy (policy_id, resource_type_id, resource_id, action_id, start_date, end_date, rpname, rptype, rpdescription, eperson_id, epersongroup_id, dspace_object) FROM stdin;
427	2	\N	0	\N	\N	\N	TYPE_SUBMISSION	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	709b36d6-5abd-47ea-9c61-2d40ee89decc
384	0	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	64cfb38b-2553-4563-8e2c-9aa63eebea44
428	2	\N	1	\N	\N	\N	TYPE_SUBMISSION	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	709b36d6-5abd-47ea-9c61-2d40ee89decc
385	0	\N	1	\N	\N	\N	\N	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	64cfb38b-2553-4563-8e2c-9aa63eebea44
351	4	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	e3a1c713-cfd4-48c0-aa02-6899432858ef
429	2	\N	3	\N	\N	\N	TYPE_SUBMISSION	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	709b36d6-5abd-47ea-9c61-2d40ee89decc
390	0	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	f275e660-a45d-459e-8b15-5d36d2c6eba4
391	0	\N	1	\N	\N	\N	\N	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	f275e660-a45d-459e-8b15-5d36d2c6eba4
389	4	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	51bf9806-4bb4-4ee2-a9b8-8493e53bf3a5
430	2	\N	4	\N	\N	\N	TYPE_SUBMISSION	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	709b36d6-5abd-47ea-9c61-2d40ee89decc
393	0	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	50833f59-a4b8-4b6f-9f96-ed56acc489f8
431	2	\N	2	\N	\N	\N	TYPE_SUBMISSION	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	709b36d6-5abd-47ea-9c61-2d40ee89decc
394	0	\N	1	\N	\N	\N	\N	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	50833f59-a4b8-4b6f-9f96-ed56acc489f8
392	4	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	1a3d5676-d754-44a6-9fde-0969b7db7331
432	3	\N	-1	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	2235ec98-c37a-4b8c-a23c-d638618949d3
399	3	\N	10	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	2235ec98-c37a-4b8c-a23c-d638618949d3
400	3	\N	9	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	2235ec98-c37a-4b8c-a23c-d638618949d3
448	2	\N	0	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	340ef935-927a-4bd1-9308-ba2758c9189f
401	3	\N	3	\N	\N	\N	\N	\N	\N	493173dd-0565-492c-89d6-a8027a0fbe7a	2235ec98-c37a-4b8c-a23c-d638618949d3
402	3	\N	5	\N	\N	\N	TYPE_WORKFLOW	\N	\N	41db32c9-81c5-401e-a3d8-b652c3f2cfcd	2235ec98-c37a-4b8c-a23c-d638618949d3
449	2	\N	1	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	340ef935-927a-4bd1-9308-ba2758c9189f
403	3	\N	3	\N	\N	\N	TYPE_WORKFLOW	\N	\N	41db32c9-81c5-401e-a3d8-b652c3f2cfcd	2235ec98-c37a-4b8c-a23c-d638618949d3
398	3	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	2235ec98-c37a-4b8c-a23c-d638618949d3
450	2	\N	3	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	340ef935-927a-4bd1-9308-ba2758c9189f
451	2	\N	4	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	340ef935-927a-4bd1-9308-ba2758c9189f
452	2	\N	2	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	340ef935-927a-4bd1-9308-ba2758c9189f
343	0	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	790958fc-6da3-4abb-ad03-858d1a1ec57c
344	0	\N	1	\N	\N	\N	\N	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	790958fc-6da3-4abb-ad03-858d1a1ec57c
342	4	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	fc1cea15-cf7c-437c-9770-d6ff74ea63c4
484	2	\N	0	\N	\N	\N	TYPE_INHERITED	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	994503bc-27f8-48e6-821c-608bcf12004d
485	1	\N	0	\N	\N	\N	TYPE_INHERITED	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	4ed605d6-72f2-4e09-afd2-8898aeca2a99
486	0	\N	0	\N	\N	\N	TYPE_INHERITED	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	ab3cb32c-7c21-461a-ae00-2a30e71b6e86
487	1	\N	0	\N	\N	\N	TYPE_INHERITED	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	0bfdd997-b842-4660-ae00-e97decac5fd8
488	0	\N	0	\N	\N	\N	TYPE_INHERITED	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	49109ddc-21ba-4ae0-9e78-1875ab3ec39a
433	3	\N	1	\N	\N	\N	\N	\N	\N	a2560efd-c0b1-4102-9843-9236614e015a	2235ec98-c37a-4b8c-a23c-d638618949d3
387	0	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	eb53475d-d6ac-475d-80bb-ab2e75606cef
434	3	\N	4	\N	\N	\N	\N	\N	\N	a2560efd-c0b1-4102-9843-9236614e015a	2235ec98-c37a-4b8c-a23c-d638618949d3
388	0	\N	1	\N	\N	\N	\N	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	eb53475d-d6ac-475d-80bb-ab2e75606cef
386	4	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	8aaa534f-9b53-4d88-97cf-621622e57034
396	0	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	d18aee16-af5e-4da1-b3fe-490c916ba0ad
397	0	\N	1	\N	\N	\N	\N	\N	cfc2d1ca-fe02-4d84-b8e5-6617a0634da2	\N	d18aee16-af5e-4da1-b3fe-490c916ba0ad
395	4	\N	0	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	73a9d950-0f73-410f-887b-509a0f6d3711
436	3	\N	1	\N	\N	\N	\N	\N	\N	b2880022-7908-4b9b-a561-fa3d23273094	2235ec98-c37a-4b8c-a23c-d638618949d3
437	3	\N	3	\N	\N	\N	\N	\N	\N	b2880022-7908-4b9b-a561-fa3d23273094	2235ec98-c37a-4b8c-a23c-d638618949d3
438	3	\N	4	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	2235ec98-c37a-4b8c-a23c-d638618949d3
439	3	\N	4	\N	\N	\N	\N	\N	\N	b2880022-7908-4b9b-a561-fa3d23273094	2235ec98-c37a-4b8c-a23c-d638618949d3
440	3	\N	-1	\N	\N	\N	\N	\N	\N	ad76cb3d-9a58-4de2-8bb1-ef42b0086bbc	2235ec98-c37a-4b8c-a23c-d638618949d3
441	3	\N	1	\N	\N	\N	\N	\N	\N	a2560efd-c0b1-4102-9843-9236614e015a	2235ec98-c37a-4b8c-a23c-d638618949d3
442	3	\N	3	\N	\N	\N	\N	\N	\N	43dfbe58-add4-469d-bb5f-b8795ce635e4	2235ec98-c37a-4b8c-a23c-d638618949d3
443	2	\N	0	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	2c6dd8b1-e3a3-445e-b15e-f5c2ac5f18f7
444	2	\N	1	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	2c6dd8b1-e3a3-445e-b15e-f5c2ac5f18f7
445	2	\N	3	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	2c6dd8b1-e3a3-445e-b15e-f5c2ac5f18f7
446	2	\N	4	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	2c6dd8b1-e3a3-445e-b15e-f5c2ac5f18f7
447	2	\N	2	\N	\N	\N	TYPE_SUBMISSION	\N	558d9a65-f84e-42e7-8c7a-f95a4bcbfaca	\N	2c6dd8b1-e3a3-445e-b15e-f5c2ac5f18f7
\.


--
-- Data for Name: schema_version; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.schema_version (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	<< Flyway Baseline >>	BASELINE	<< Flyway Baseline >>	\N	dspace	2020-11-06 10:24:57.10702	0	t
2	1.1	Initial DSpace 1.1 database schema	SQL	V1.1__Initial_DSpace_1.1_database_schema.sql	1147897299	dspace	2020-11-06 10:24:57.449527	289	t
3	1.2	Upgrade to DSpace 1.2 schema	SQL	V1.2__Upgrade_to_DSpace_1.2_schema.sql	903973515	dspace	2020-11-06 10:24:57.747344	45	t
4	1.3	Upgrade to DSpace 1.3 schema	SQL	V1.3__Upgrade_to_DSpace_1.3_schema.sql	-783235991	dspace	2020-11-06 10:24:57.803177	43	t
5	1.3.9	Drop constraint for DSpace 1 4 schema	JDBC	org.dspace.storage.rdbms.migration.V1_3_9__Drop_constraint_for_DSpace_1_4_schema	-1	dspace	2020-11-06 10:24:57.860235	3	t
6	1.4	Upgrade to DSpace 1.4 schema	SQL	V1.4__Upgrade_to_DSpace_1.4_schema.sql	-831219528	dspace	2020-11-06 10:24:57.879713	109	t
7	1.5	Upgrade to DSpace 1.5 schema	SQL	V1.5__Upgrade_to_DSpace_1.5_schema.sql	-1234304544	dspace	2020-11-06 10:24:58.013085	88	t
8	1.5.9	Drop constraint for DSpace 1 6 schema	JDBC	org.dspace.storage.rdbms.migration.V1_5_9__Drop_constraint_for_DSpace_1_6_schema	-1	dspace	2020-11-06 10:24:58.110383	4	t
9	1.6	Upgrade to DSpace 1.6 schema	SQL	V1.6__Upgrade_to_DSpace_1.6_schema.sql	-495469766	dspace	2020-11-06 10:24:58.11934	22	t
10	1.7	Upgrade to DSpace 1.7 schema	SQL	V1.7__Upgrade_to_DSpace_1.7_schema.sql	-589640641	dspace	2020-11-06 10:24:58.152375	4	t
11	1.8	Upgrade to DSpace 1.8 schema	SQL	V1.8__Upgrade_to_DSpace_1.8_schema.sql	-171791117	dspace	2020-11-06 10:24:58.162853	5	t
12	3.0	Upgrade to DSpace 3.x schema	SQL	V3.0__Upgrade_to_DSpace_3.x_schema.sql	-1098885663	dspace	2020-11-06 10:24:58.173004	12	t
13	4.0	Upgrade to DSpace 4.x schema	SQL	V4.0__Upgrade_to_DSpace_4.x_schema.sql	1191833374	dspace	2020-11-06 10:24:58.19161	15	t
14	4.9.2015.10.26	DS-2818 registry update	SQL	V4.9_2015.10.26__DS-2818_registry_update.sql	1675451156	dspace	2020-11-06 10:24:58.212603	20	t
15	5.0.2014.08.08	DS-1945 Helpdesk Request a Copy	SQL	V5.0_2014.08.08__DS-1945_Helpdesk_Request_a_Copy.sql	-1208221648	dspace	2020-11-06 10:24:58.239282	18	t
16	5.0.2014.09.25	DS 1582 Metadata For All Objects drop constraint	JDBC	org.dspace.storage.rdbms.migration.V5_0_2014_09_25__DS_1582_Metadata_For_All_Objects_drop_constraint	-1	dspace	2020-11-06 10:24:58.264026	5	t
17	5.0.2014.09.26	DS-1582 Metadata For All Objects	SQL	V5.0_2014.09.26__DS-1582_Metadata_For_All_Objects.sql	1509433410	dspace	2020-11-06 10:24:58.273602	66	t
18	5.6.2016.08.23	DS-3097	SQL	V5.6_2016.08.23__DS-3097.sql	410632858	dspace	2020-11-06 10:24:58.353216	6	t
19	5.7.2017.04.11	DS-3563 Index metadatavalue resource type id column	SQL	V5.7_2017.04.11__DS-3563_Index_metadatavalue_resource_type_id_column.sql	912059617	dspace	2020-11-06 10:24:58.371192	11	t
20	5.7.2017.05.05	DS 3431 Add Policies for BasicWorkflow	JDBC	org.dspace.storage.rdbms.migration.V5_7_2017_05_05__DS_3431_Add_Policies_for_BasicWorkflow	-1	dspace	2020-11-06 10:24:58.392058	85	t
21	6.0.2015.03.06	DS 2701 Dso Uuid Migration	JDBC	org.dspace.storage.rdbms.migration.V6_0_2015_03_06__DS_2701_Dso_Uuid_Migration	-1	dspace	2020-11-06 10:24:58.492696	36	t
22	6.0.2015.03.07	DS-2701 Hibernate migration	SQL	V6.0_2015.03.07__DS-2701_Hibernate_migration.sql	-542830952	dspace	2020-11-06 10:24:58.534564	476	t
23	6.0.2015.08.31	DS 2701 Hibernate Workflow Migration	JDBC	org.dspace.storage.rdbms.migration.V6_0_2015_08_31__DS_2701_Hibernate_Workflow_Migration	-1	dspace	2020-11-06 10:24:59.034695	40	t
24	6.0.2016.01.03	DS-3024	SQL	V6.0_2016.01.03__DS-3024.sql	95468273	dspace	2020-11-06 10:24:59.084534	7	t
25	6.0.2016.01.26	DS 2188 Remove DBMS Browse Tables	JDBC	org.dspace.storage.rdbms.migration.V6_0_2016_01_26__DS_2188_Remove_DBMS_Browse_Tables	-1	dspace	2020-11-06 10:24:59.100972	33	t
26	6.0.2016.02.25	DS-3004-slow-searching-as-admin	SQL	V6.0_2016.02.25__DS-3004-slow-searching-as-admin.sql	-1623115511	dspace	2020-11-06 10:24:59.157536	15	t
27	6.0.2016.04.01	DS-1955 Increase embargo reason	SQL	V6.0_2016.04.01__DS-1955_Increase_embargo_reason.sql	283892016	dspace	2020-11-06 10:24:59.189573	3	t
28	6.0.2016.04.04	DS-3086-OAI-Performance-fix	SQL	V6.0_2016.04.04__DS-3086-OAI-Performance-fix.sql	445863295	dspace	2020-11-06 10:24:59.203654	12	t
29	6.0.2016.04.14	DS-3125-fix-bundle-bitstream-delete-rights	SQL	V6.0_2016.04.14__DS-3125-fix-bundle-bitstream-delete-rights.sql	-699277527	dspace	2020-11-06 10:24:59.222777	7	t
30	6.0.2016.05.10	DS-3168-fix-requestitem item id column	SQL	V6.0_2016.05.10__DS-3168-fix-requestitem_item_id_column.sql	-1122969100	dspace	2020-11-06 10:24:59.234964	12	t
31	6.0.2016.07.21	DS-2775	SQL	V6.0_2016.07.21__DS-2775.sql	-126635374	dspace	2020-11-06 10:24:59.257027	13	t
32	6.0.2016.07.26	DS-3277 fix handle assignment	SQL	V6.0_2016.07.26__DS-3277_fix_handle_assignment.sql	-284088754	dspace	2020-11-06 10:24:59.282067	5	t
33	6.0.2016.08.23	DS-3097	SQL	V6.0_2016.08.23__DS-3097.sql	-1986377895	dspace	2020-11-06 10:24:59.296203	4	t
34	6.1.2017.01.03	DS 3431 Add Policies for BasicWorkflow	JDBC	org.dspace.storage.rdbms.migration.V6_1_2017_01_03__DS_3431_Add_Policies_for_BasicWorkflow	-1	dspace	2020-11-06 10:24:59.312538	67	t
\.


--
-- Data for Name: site; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.site (uuid) FROM stdin;
653a2407-7e05-4e15-a02c-eaaeceb7bd4a
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.subscription (subscription_id, eperson_id, collection_id) FROM stdin;
\.


--
-- Data for Name: tasklistitem; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.tasklistitem (tasklist_id, workflow_id, eperson_id) FROM stdin;
\.


--
-- Data for Name: versionhistory; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.versionhistory (versionhistory_id) FROM stdin;
\.


--
-- Data for Name: versionitem; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.versionitem (versionitem_id, version_number, version_date, version_summary, versionhistory_id, eperson_id, item_id) FROM stdin;
\.


--
-- Data for Name: webapp; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.webapp (webapp_id, appname, url, started, isui) FROM stdin;
1	REST	http://localhost:8080/xmlui	2020-11-06 10:24:56.578	0
2	OAI	http://localhost:8080/xmlui	2020-11-06 10:25:18.408	0
3	JSPUI	http://localhost:8080/xmlui	2020-11-06 10:26:13.357	1
4	XMLUI	http://localhost:8080/xmlui	2020-11-06 10:26:31.749	1
5	REST	http://localhost:8080/xmlui	2020-11-08 10:11:58.55	0
6	OAI	http://localhost:8080/xmlui	2020-11-08 10:12:25.439	0
7	JSPUI	http://localhost:8080/xmlui	2020-11-08 10:13:20.08	1
8	XMLUI	http://localhost:8080/xmlui	2020-11-08 10:13:37.028	1
9	REST	http://localhost:8080/xmlui	2020-11-08 11:56:47.928	0
10	OAI	http://localhost:8080/xmlui	2020-11-08 11:57:12.431	0
11	JSPUI	http://localhost:8080/xmlui	2020-11-08 11:58:13.32	1
12	XMLUI	http://localhost:8080/xmlui	2020-11-08 11:58:34.591	1
13	REST	http://localhost:8080/xmlui	2020-11-26 11:30:43.127	0
14	OAI	http://localhost:8080/xmlui	2020-11-26 11:30:52.719	0
15	JSPUI	http://localhost:8080/xmlui	2020-11-26 11:31:17.383	1
16	XMLUI	http://localhost:8080/xmlui	2020-11-26 11:31:26.785	1
17	REST	http://localhost:8080/xmlui	2020-11-26 11:45:15.141	0
18	OAI	http://localhost:8080/xmlui	2020-11-26 11:45:27.436	0
19	JSPUI	http://localhost:8080/xmlui	2020-11-26 11:45:59.204	1
20	XMLUI	http://localhost:8080/xmlui	2020-11-26 11:46:09.808	1
21	REST	http://localhost:8080/xmlui	2020-11-26 11:59:14.597	0
22	OAI	http://localhost:8080/xmlui	2020-11-26 11:59:25.423	0
23	JSPUI	http://localhost:8080/xmlui	2020-11-26 11:59:49.045	1
24	XMLUI	http://localhost:8080/xmlui	2020-11-26 11:59:57.798	1
25	REST	http://localhost:8080/xmlui	2020-11-26 12:12:49.965	0
26	OAI	http://localhost:8080/xmlui	2020-11-26 12:13:01.081	0
27	JSPUI	http://localhost:8080/xmlui	2020-11-26 12:13:27.252	1
28	XMLUI	http://localhost:8080/xmlui	2020-11-26 12:13:35.808	1
29	REST	http://localhost:8080/xmlui	2020-11-26 14:03:26.048	0
30	OAI	http://localhost:8080/xmlui	2020-11-26 14:03:35.323	0
31	JSPUI	http://localhost:8080/xmlui	2020-11-26 14:04:01.647	1
32	XMLUI	http://localhost:8080/xmlui	2020-11-26 14:04:10.773	1
33	REST	http://localhost:8080/xmlui	2020-11-27 09:45:14.25	0
34	OAI	http://localhost:8080/xmlui	2020-11-27 09:45:25.898	0
35	JSPUI	http://localhost:8080/xmlui	2020-11-27 09:45:54.941	1
36	XMLUI	http://localhost:8080/xmlui	2020-11-27 09:46:05.181	1
37	REST	http://localhost:8080/xmlui	2020-11-27 10:01:43.802	0
38	OAI	http://localhost:8080/xmlui	2020-11-27 10:01:56.253	0
39	JSPUI	http://localhost:8080/xmlui	2020-11-27 10:02:28.789	1
40	XMLUI	http://localhost:8080/xmlui	2020-11-27 10:02:38.753	1
41	REST	http://localhost:8080/xmlui	2020-11-27 11:54:41.693	0
42	OAI	http://localhost:8080/xmlui	2020-11-27 11:54:53.243	0
43	JSPUI	http://localhost:8080/xmlui	2020-11-27 11:55:24.76	1
44	XMLUI	http://localhost:8080/xmlui	2020-11-27 11:55:37.435	1
45	REST	http://localhost:8080/xmlui	2020-11-27 12:33:06.026	0
46	OAI	http://localhost:8080/xmlui	2020-11-27 12:33:18.262	0
47	JSPUI	http://localhost:8080/xmlui	2020-11-27 12:33:47.843	1
48	XMLUI	http://localhost:8080/xmlui	2020-11-27 12:33:58.169	1
49	REST	http://localhost:8080/xmlui	2020-11-27 12:41:39.664	0
50	OAI	http://localhost:8080/xmlui	2020-11-27 12:41:51.587	0
51	JSPUI	http://localhost:8080/xmlui	2020-11-27 12:42:21.165	1
52	XMLUI	http://localhost:8080/xmlui	2020-11-27 12:42:31.284	1
53	REST	http://localhost:8080/xmlui	2020-11-27 13:11:52.918	0
54	OAI	http://localhost:8080/xmlui	2020-11-27 13:12:03.44	0
55	JSPUI	http://localhost:8080/xmlui	2020-11-27 13:12:32.338	1
56	XMLUI	http://localhost:8080/xmlui	2020-11-27 13:12:42.229	1
57	REST	http://localhost:8080/xmlui	2020-12-01 09:27:44.424	0
58	OAI	http://localhost:8080/xmlui	2020-12-01 09:27:55.61	0
59	JSPUI	http://localhost:8080/xmlui	2020-12-01 09:28:23.589	1
60	XMLUI	http://localhost:8080/xmlui	2020-12-01 09:28:34.253	1
61	REST	http://localhost:8080/xmlui	2020-12-01 10:15:53.461	0
62	OAI	http://localhost:8080/xmlui	2020-12-01 10:16:03.171	0
63	JSPUI	http://localhost:8080/xmlui	2020-12-01 10:16:26.92	1
64	XMLUI	http://localhost:8080/xmlui	2020-12-01 10:16:35.838	1
65	REST	http://localhost:8080/xmlui	2020-12-01 10:32:21.458	0
66	OAI	http://localhost:8080/xmlui	2020-12-01 10:32:30.461	0
67	JSPUI	http://localhost:8080/xmlui	2020-12-01 10:32:54.598	1
68	XMLUI	http://localhost:8080/xmlui	2020-12-01 10:33:03.403	1
69	REST	http://localhost:8080/xmlui	2020-12-01 10:47:31.527	0
70	OAI	http://localhost:8080/xmlui	2020-12-01 10:47:41.363	0
71	JSPUI	http://localhost:8080/xmlui	2020-12-01 10:48:05.563	1
72	XMLUI	http://localhost:8080/xmlui	2020-12-01 10:48:12.973	1
73	REST	http://localhost:8080/xmlui	2020-12-01 13:14:18.883	0
74	OAI	http://localhost:8080/xmlui	2020-12-01 13:14:28.515	0
75	JSPUI	http://localhost:8080/xmlui	2020-12-01 13:14:53.42	1
76	XMLUI	http://localhost:8080/xmlui	2020-12-01 13:15:02.121	1
77	REST	http://localhost:8080/xmlui	2020-12-05 13:01:49.535	0
78	OAI	http://localhost:8080/xmlui	2020-12-05 13:01:58.728	0
79	JSPUI	http://localhost:8080/xmlui	2020-12-05 13:02:27.171	1
80	XMLUI	http://localhost:8080/xmlui	2020-12-05 13:02:37.644	1
81	REST	http://localhost:8080/xmlui	2020-12-05 14:20:20.543	0
82	OAI	http://localhost:8080/xmlui	2020-12-05 14:20:31.23	0
83	JSPUI	http://localhost:8080/xmlui	2020-12-05 14:20:56.269	1
84	XMLUI	http://localhost:8080/xmlui	2020-12-05 14:21:04.962	1
85	REST	http://localhost:8080/xmlui	2020-12-05 15:18:14.201	0
86	OAI	http://localhost:8080/xmlui	2020-12-05 15:18:23.026	0
87	JSPUI	http://localhost:8080/xmlui	2020-12-05 15:18:47.426	1
88	XMLUI	http://localhost:8080/xmlui	2020-12-05 15:18:56.301	1
89	REST	http://localhost:8080/xmlui	2020-12-05 15:37:18.334	0
90	OAI	http://localhost:8080/xmlui	2020-12-05 15:37:27.435	0
91	JSPUI	http://localhost:8080/xmlui	2020-12-05 15:37:51.149	1
92	XMLUI	http://localhost:8080/xmlui	2020-12-05 15:37:59.933	1
93	REST	http://localhost:8080/xmlui	2020-12-05 15:48:55.569	0
94	OAI	http://localhost:8080/xmlui	2020-12-05 15:49:04.606	0
95	JSPUI	http://localhost:8080/xmlui	2020-12-05 15:49:29.108	1
96	XMLUI	http://localhost:8080/xmlui	2020-12-05 15:49:38.212	1
97	REST	http://localhost:8080/xmlui	2020-12-05 15:56:23.739	0
98	OAI	http://localhost:8080/xmlui	2020-12-05 15:56:34.19	0
99	JSPUI	http://localhost:8080/xmlui	2020-12-05 15:56:59.724	1
100	XMLUI	http://localhost:8080/xmlui	2020-12-05 15:57:08.797	1
101	REST	http://localhost:8080/xmlui	2020-12-06 17:59:22.511	0
102	OAI	http://localhost:8080/xmlui	2020-12-06 17:59:33.253	0
103	JSPUI	http://localhost:8080/xmlui	2020-12-06 18:00:00.293	1
104	XMLUI	http://localhost:8080/xmlui	2020-12-06 18:00:09.461	1
105	REST	http://localhost:8080/xmlui	2020-12-07 10:44:48.558	0
106	OAI	http://localhost:8080/xmlui	2020-12-07 10:44:57.008	0
107	JSPUI	http://localhost:8080/xmlui	2020-12-07 10:45:20.605	1
108	XMLUI	http://localhost:8080/xmlui	2020-12-07 10:45:29.831	1
109	REST	http://localhost:8080/xmlui	2020-12-07 11:08:33.235	0
110	OAI	http://localhost:8080/xmlui	2020-12-07 11:08:41.944	0
111	JSPUI	http://localhost:8080/xmlui	2020-12-07 11:09:03.406	1
112	XMLUI	http://localhost:8080/xmlui	2020-12-07 11:09:11.057	1
113	REST	http://localhost:8080/xmlui	2020-12-07 11:52:47.213	0
114	OAI	http://localhost:8080/xmlui	2020-12-07 11:52:56.575	0
115	JSPUI	http://localhost:8080/xmlui	2020-12-07 11:53:19.026	1
116	XMLUI	http://localhost:8080/xmlui	2020-12-07 11:53:26.731	1
117	REST	http://localhost:8080/xmlui	2020-12-07 15:45:31.232	0
118	OAI	http://localhost:8080/xmlui	2020-12-07 15:45:41.75	0
119	JSPUI	http://localhost:8080/xmlui	2020-12-07 15:46:06.434	1
120	XMLUI	http://localhost:8080/xmlui	2020-12-07 15:46:15.873	1
121	REST	http://localhost:8080/xmlui	2020-12-07 15:56:21.774	0
122	OAI	http://localhost:8080/xmlui	2020-12-07 15:56:31.295	0
123	JSPUI	http://localhost:8080/xmlui	2020-12-07 15:56:55.749	1
124	XMLUI	http://localhost:8080/xmlui	2020-12-07 15:57:04.917	1
125	REST	http://localhost:8080/xmlui	2020-12-12 09:39:51.704	0
126	OAI	http://localhost:8080/xmlui	2020-12-12 09:40:03.992	0
127	JSPUI	http://localhost:8080/xmlui	2020-12-12 09:40:34.324	1
128	XMLUI	http://localhost:8080/xmlui	2020-12-12 09:40:44.847	1
129	REST	http://localhost:8080/xmlui	2020-12-12 09:57:21.242	0
130	OAI	http://localhost:8080/xmlui	2020-12-12 09:57:33.34	0
131	JSPUI	http://localhost:8080/xmlui	2020-12-12 09:58:03.616	1
132	XMLUI	http://localhost:8080/xmlui	2020-12-12 09:58:14.863	1
133	REST	http://localhost:8080/xmlui	2020-12-12 16:08:21.783	0
134	OAI	http://localhost:8080/xmlui	2020-12-12 16:08:33.692	0
135	JSPUI	http://localhost:8080/xmlui	2020-12-12 16:09:03.902	1
136	XMLUI	http://localhost:8080/xmlui	2020-12-12 16:09:14.786	1
137	REST	http://localhost:8080/xmlui	2020-12-14 08:21:29.682	0
138	OAI	http://localhost:8080/xmlui	2020-12-14 08:21:39.124	0
139	JSPUI	http://localhost:8080/xmlui	2020-12-14 08:22:04.34	1
140	XMLUI	http://localhost:8080/xmlui	2020-12-14 08:22:13.975	1
141	REST	http://localhost:8080/xmlui	2020-12-14 12:21:12.421	0
142	OAI	http://localhost:8080/xmlui	2020-12-14 12:21:20.519	0
143	JSPUI	http://localhost:8080/xmlui	2020-12-14 12:21:42.083	1
144	XMLUI	http://localhost:8080/xmlui	2020-12-14 12:21:52.056	1
145	REST	http://localhost:8080/xmlui	2020-12-14 12:34:59.828	0
146	OAI	http://localhost:8080/xmlui	2020-12-14 12:35:08.337	0
147	JSPUI	http://localhost:8080/xmlui	2020-12-14 12:35:30.204	1
148	XMLUI	http://localhost:8080/xmlui	2020-12-14 12:35:38.372	1
149	REST	http://localhost:8080/xmlui	2020-12-14 12:47:09.056	0
150	OAI	http://localhost:8080/xmlui	2020-12-14 12:47:17.841	0
151	JSPUI	http://localhost:8080/xmlui	2020-12-14 12:47:41.756	1
152	XMLUI	http://localhost:8080/xmlui	2020-12-14 12:47:51.012	1
153	REST	http://localhost:8080/xmlui	2020-12-15 13:16:47.827	0
154	OAI	http://localhost:8080/xmlui	2020-12-15 13:16:57.482	0
155	JSPUI	http://localhost:8080/xmlui	2020-12-15 13:17:25.059	1
156	XMLUI	http://localhost:8080/xmlui	2020-12-15 13:17:35.045	1
157	REST	http://localhost:8080/xmlui	2020-12-17 09:15:57.555	0
158	OAI	http://localhost:8080/xmlui	2020-12-17 09:16:10.979	0
159	JSPUI	http://localhost:8080/xmlui	2020-12-17 09:16:43.136	1
160	XMLUI	http://localhost:8080/xmlui	2020-12-17 09:16:54.847	1
161	REST	http://localhost:8080/xmlui	2020-12-17 09:50:08.222	0
162	OAI	http://localhost:8080/xmlui	2020-12-17 09:50:16.518	0
163	JSPUI	http://localhost:8080/xmlui	2020-12-17 09:50:38.751	1
164	XMLUI	http://localhost:8080/xmlui	2020-12-17 09:50:47.623	1
165	REST	http://localhost:8080/jspui	2020-12-17 11:30:35.105	0
166	OAI	http://localhost:8080/jspui	2020-12-17 11:30:43.078	0
167	JSPUI	http://localhost:8080/jspui	2020-12-17 11:31:03.138	1
168	XMLUI	http://localhost:8080/jspui	2020-12-17 11:31:10.396	1
169	REST	http://localhost:8080/jspui	2020-12-17 11:39:59.894	0
170	OAI	http://localhost:8080/jspui	2020-12-17 11:40:07.604	0
171	JSPUI	http://localhost:8080/jspui	2020-12-17 11:40:27.492	1
172	XMLUI	http://localhost:8080/jspui	2020-12-17 11:40:36.422	1
173	REST	http://localhost:8080/jspui	2020-12-28 09:49:59.571	0
174	OAI	http://localhost:8080/jspui	2020-12-28 09:50:07.642	0
175	JSPUI	http://localhost:8080/jspui	2020-12-28 09:50:28.95	1
176	XMLUI	http://localhost:8080/jspui	2020-12-28 09:50:36.69	1
177	REST	http://localhost:8080/jspui	2020-12-28 10:21:49.978	0
178	OAI	http://localhost:8080/jspui	2020-12-28 10:21:59.838	0
179	JSPUI	http://localhost:8080/jspui	2020-12-28 10:22:23.529	1
180	XMLUI	http://localhost:8080/jspui	2020-12-28 10:22:32.303	1
181	REST	http://localhost:8080/jspui	2020-12-28 11:45:26.178	0
182	OAI	http://localhost:8080/jspui	2020-12-28 11:45:36.174	0
183	JSPUI	http://localhost:8080/jspui	2020-12-28 11:46:00.378	1
184	XMLUI	http://localhost:8080/jspui	2020-12-28 11:46:09.148	1
185	REST	http://localhost:8080/jspui	2020-12-28 12:39:31.565	0
186	OAI	http://localhost:8080/jspui	2020-12-28 12:39:41.727	0
187	JSPUI	http://localhost:8080/jspui	2020-12-28 12:40:07.491	1
188	XMLUI	http://localhost:8080/jspui	2020-12-28 12:40:16.743	1
189	REST	http://localhost:8080/jspui	2020-12-28 12:57:41.935	0
190	OAI	http://localhost:8080/jspui	2020-12-28 12:57:53.935	0
191	JSPUI	http://localhost:8080/jspui	2020-12-28 12:58:23.087	1
192	XMLUI	http://localhost:8080/jspui	2020-12-28 12:58:34.029	1
193	REST	http://localhost:8080/jspui	2020-12-28 13:42:38.996	0
194	OAI	http://localhost:8080/jspui	2020-12-28 13:42:46.216	0
195	JSPUI	http://localhost:8080/jspui	2020-12-28 13:43:04.633	1
196	XMLUI	http://localhost:8080/jspui	2020-12-28 13:43:11.439	1
197	REST	http://localhost:8080/jspui	2020-12-28 13:55:52.483	0
198	OAI	http://localhost:8080/jspui	2020-12-28 13:56:02.086	0
199	JSPUI	http://localhost:8080/jspui	2020-12-28 13:56:26.312	1
200	XMLUI	http://localhost:8080/jspui	2020-12-28 13:56:35.306	1
201	REST	http://localhost:8080/jspui	2020-12-28 15:09:56.082	0
202	OAI	http://localhost:8080/jspui	2020-12-28 15:10:06.145	0
203	JSPUI	http://localhost:8080/jspui	2020-12-28 15:10:31.436	1
204	XMLUI	http://localhost:8080/jspui	2020-12-28 15:10:40.264	1
205	REST	http://localhost:8080/jspui	2020-12-28 15:19:39.366	0
206	OAI	http://localhost:8080/jspui	2020-12-28 15:19:49.447	0
207	JSPUI	http://localhost:8080/jspui	2020-12-28 15:20:13.101	1
208	XMLUI	http://localhost:8080/jspui	2020-12-28 15:20:21.855	1
209	REST	http://localhost:8080/jspui	2020-12-29 09:44:36.41	0
210	OAI	http://localhost:8080/jspui	2020-12-29 09:44:43.976	0
211	JSPUI	http://localhost:8080/jspui	2020-12-29 09:45:04.022	1
212	XMLUI	http://localhost:8080/jspui	2020-12-29 09:45:12.28	1
213	REST	http://localhost:8080/jspui	2020-12-30 08:38:16.336	0
214	OAI	http://localhost:8080/jspui	2020-12-30 08:38:25.325	0
215	JSPUI	http://localhost:8080/jspui	2020-12-30 08:38:47.932	1
216	XMLUI	http://localhost:8080/jspui	2020-12-30 08:38:57.55	1
217	REST	http://localhost:8080/jspui	2020-12-30 09:08:37.048	0
218	OAI	http://localhost:8080/jspui	2020-12-30 09:08:44.583	0
219	JSPUI	http://localhost:8080/jspui	2020-12-30 09:09:02.945	1
220	XMLUI	http://localhost:8080/jspui	2020-12-30 09:09:10.734	1
221	REST	http://localhost:8080/jspui	2021-01-02 14:29:10.503	0
222	OAI	http://localhost:8080/jspui	2021-01-02 14:29:20.929	0
223	JSPUI	http://localhost:8080/jspui	2021-01-02 14:29:48.003	1
224	XMLUI	http://localhost:8080/jspui	2021-01-02 14:29:56.775	1
225	REST	http://localhost:8080/jspui	2021-01-03 13:14:10.923	0
226	OAI	http://localhost:8080/jspui	2021-01-03 13:14:21.025	0
227	JSPUI	http://localhost:8080/jspui	2021-01-03 13:14:49.3	1
228	XMLUI	http://localhost:8080/jspui	2021-01-03 13:14:59.438	1
229	REST	http://localhost:8080/jspui	2021-01-03 15:44:35.108	0
230	OAI	http://localhost:8080/jspui	2021-01-03 15:44:43.584	0
231	JSPUI	http://localhost:8080/jspui	2021-01-03 15:45:07.786	1
232	XMLUI	http://localhost:8080/jspui	2021-01-03 15:45:16.175	1
233	REST	http://localhost:8080/jspui	2021-01-03 15:55:45.008	0
234	OAI	http://localhost:8080/jspui	2021-01-03 15:55:52.008	0
235	JSPUI	http://localhost:8080/jspui	2021-01-03 15:56:09.424	1
236	XMLUI	http://localhost:8080/jspui	2021-01-03 15:56:15.815	1
237	REST	http://localhost:8080/jspui	2021-01-03 16:11:19.741	0
238	OAI	http://localhost:8080/jspui	2021-01-03 16:11:26.668	0
239	JSPUI	http://localhost:8080/jspui	2021-01-03 16:11:44.882	1
240	XMLUI	http://localhost:8080/jspui	2021-01-03 16:11:51.579	1
241	REST	http://localhost:8080/jspui	2021-01-03 17:43:54.276	0
242	OAI	http://localhost:8080/jspui	2021-01-03 17:44:03.899	0
243	JSPUI	http://localhost:8080/jspui	2021-01-03 17:44:29.504	1
244	XMLUI	http://localhost:8080/jspui	2021-01-03 17:44:39.524	1
245	REST	http://localhost:8080/jspui	2021-01-04 08:18:45.653	0
246	OAI	http://localhost:8080/jspui	2021-01-04 08:18:55.004	0
247	JSPUI	http://localhost:8080/jspui	2021-01-04 08:19:19.656	1
248	XMLUI	http://localhost:8080/jspui	2021-01-04 08:19:28.929	1
249	REST	http://localhost:8080/jspui	2021-01-04 11:31:10.085	0
250	OAI	http://localhost:8080/jspui	2021-01-04 11:31:19.349	0
251	JSPUI	http://localhost:8080/jspui	2021-01-04 11:31:44.245	1
252	XMLUI	http://localhost:8080/jspui	2021-01-04 11:31:53.156	1
253	REST	http://localhost:8080/jspui	2021-01-04 11:51:23.892	0
254	OAI	http://localhost:8080/jspui	2021-01-04 11:51:32.881	0
255	JSPUI	http://localhost:8080/jspui	2021-01-04 11:51:57.14	1
256	XMLUI	http://localhost:8080/jspui	2021-01-04 11:52:06.16	1
257	REST	http://localhost:8080/jspui	2021-01-05 08:31:36.75	0
258	OAI	http://localhost:8080/jspui	2021-01-05 08:31:46.394	0
259	JSPUI	http://localhost:8080/jspui	2021-01-05 08:32:07.966	1
260	XMLUI	http://localhost:8080/jspui	2021-01-05 08:32:16.217	1
261	REST	http://localhost:8080/jspui	2021-01-05 09:31:21.828	0
262	OAI	http://localhost:8080/jspui	2021-01-05 09:31:33.122	0
263	JSPUI	http://localhost:8080/jspui	2021-01-05 09:32:02.596	1
264	XMLUI	http://localhost:8080/jspui	2021-01-05 09:32:13.788	1
265	REST	http://localhost:8080/jspui	2021-01-06 09:08:07.044	0
266	OAI	http://localhost:8080/jspui	2021-01-06 09:08:18.695	0
267	JSPUI	http://localhost:8080/jspui	2021-01-06 09:08:48.978	1
268	XMLUI	http://localhost:8080/jspui	2021-01-06 09:09:00.008	1
269	REST	http://localhost:8080/jspui	2021-01-06 09:28:06.141	0
270	OAI	http://localhost:8080/jspui	2021-01-06 09:28:14.803	0
271	JSPUI	http://localhost:8080/jspui	2021-01-06 09:28:37.806	1
272	XMLUI	http://localhost:8080/jspui	2021-01-06 09:28:46.295	1
273	REST	http://localhost:8080/jspui	2021-01-06 10:16:48.008	0
274	OAI	http://localhost:8080/jspui	2021-01-06 10:16:54.527	0
275	JSPUI	http://localhost:8080/jspui	2021-01-06 10:17:16.072	1
276	XMLUI	http://localhost:8080/jspui	2021-01-06 10:17:24.705	1
277	REST	http://localhost:8080/jspui	2021-01-06 13:30:20.846	0
278	OAI	http://localhost:8080/jspui	2021-01-06 13:30:41.772	0
279	JSPUI	http://localhost:8080/jspui	2021-01-06 13:31:38.624	1
280	XMLUI	http://localhost:8080/jspui	2021-01-06 13:31:59.326	1
310	REST	http://localhost:8080/jspui	2021-01-07 10:34:46.385	0
311	OAI	http://localhost:8080/jspui	2021-01-07 10:34:54.369	0
312	JSPUI	http://localhost:8080/jspui	2021-01-07 10:35:16.469	1
313	XMLUI	http://localhost:8080/jspui	2021-01-07 10:35:27.531	1
314	REST	http://localhost:8080/jspui	2021-01-07 11:09:29.913	0
315	OAI	http://localhost:8080/jspui	2021-01-07 11:09:37.8	0
316	JSPUI	http://localhost:8080/jspui	2021-01-07 11:09:58.331	1
317	XMLUI	http://localhost:8080/jspui	2021-01-07 11:10:05.96	1
\.


--
-- Data for Name: workflowitem; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.workflowitem (workflow_id, state, multiple_titles, published_before, multiple_files, item_id, collection_id, owner) FROM stdin;
\.


--
-- Data for Name: workspaceitem; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY public.workspaceitem (workspace_item_id, multiple_titles, published_before, multiple_files, stage_reached, page_reached, item_id, collection_id) FROM stdin;
17	t	t	t	2	1	709b36d6-5abd-47ea-9c61-2d40ee89decc	2235ec98-c37a-4b8c-a23c-d638618949d3
18	t	t	t	2	1	2c6dd8b1-e3a3-445e-b15e-f5c2ac5f18f7	2235ec98-c37a-4b8c-a23c-d638618949d3
19	t	t	t	2	1	340ef935-927a-4bd1-9308-ba2758c9189f	2235ec98-c37a-4b8c-a23c-d638618949d3
\.


--
-- Name: bitstreamformatregistry_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.bitstreamformatregistry_seq', 76, true);


--
-- Name: checksum_history_check_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.checksum_history_check_id_seq', 1, false);


--
-- Name: doi_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.doi_seq', 1, false);


--
-- Name: fileextension_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.fileextension_seq', 91, true);


--
-- Name: handle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.handle_id_seq', 78, true);


--
-- Name: handle_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.handle_seq', 77, true);


--
-- Name: harvested_collection_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.harvested_collection_seq', 1, false);


--
-- Name: harvested_item_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.harvested_item_seq', 1, false);


--
-- Name: history_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.history_seq', 1, false);


--
-- Name: metadatafieldregistry_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.metadatafieldregistry_seq', 132, true);


--
-- Name: metadataschemaregistry_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.metadataschemaregistry_seq', 4, true);


--
-- Name: metadatavalue_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.metadatavalue_seq', 602, true);


--
-- Name: registrationdata_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.registrationdata_seq', 3, true);


--
-- Name: requestitem_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.requestitem_seq', 1, false);


--
-- Name: resourcepolicy_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.resourcepolicy_seq', 529, true);


--
-- Name: subscription_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.subscription_seq', 1, true);


--
-- Name: tasklistitem_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.tasklistitem_seq', 1, false);


--
-- Name: versionhistory_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.versionhistory_seq', 1, false);


--
-- Name: versionitem_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.versionitem_seq', 1, false);


--
-- Name: webapp_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.webapp_seq', 317, true);


--
-- Name: workflowitem_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.workflowitem_seq', 12, true);


--
-- Name: workspaceitem_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('public.workspaceitem_seq', 22, true);


--
-- Name: bitstream bitstream_id_unique; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bitstream
    ADD CONSTRAINT bitstream_id_unique UNIQUE (uuid);


--
-- Name: bitstream bitstream_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bitstream
    ADD CONSTRAINT bitstream_pkey PRIMARY KEY (uuid);


--
-- Name: bitstream bitstream_uuid_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bitstream
    ADD CONSTRAINT bitstream_uuid_key UNIQUE (uuid);


--
-- Name: bitstreamformatregistry bitstreamformatregistry_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bitstreamformatregistry
    ADD CONSTRAINT bitstreamformatregistry_pkey PRIMARY KEY (bitstream_format_id);


--
-- Name: bitstreamformatregistry bitstreamformatregistry_short_description_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bitstreamformatregistry
    ADD CONSTRAINT bitstreamformatregistry_short_description_key UNIQUE (short_description);


--
-- Name: bundle2bitstream bundle2bitstream_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bundle2bitstream
    ADD CONSTRAINT bundle2bitstream_pkey PRIMARY KEY (bitstream_id, bundle_id, bitstream_order);


--
-- Name: bundle bundle_id_unique; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bundle
    ADD CONSTRAINT bundle_id_unique UNIQUE (uuid);


--
-- Name: bundle bundle_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bundle
    ADD CONSTRAINT bundle_pkey PRIMARY KEY (uuid);


--
-- Name: bundle bundle_uuid_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bundle
    ADD CONSTRAINT bundle_uuid_key UNIQUE (uuid);


--
-- Name: checksum_history checksum_history_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.checksum_history
    ADD CONSTRAINT checksum_history_pkey PRIMARY KEY (check_id);


--
-- Name: checksum_results checksum_results_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.checksum_results
    ADD CONSTRAINT checksum_results_pkey PRIMARY KEY (result_code);


--
-- Name: collection2item collection2item_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection2item
    ADD CONSTRAINT collection2item_pkey PRIMARY KEY (collection_id, item_id);


--
-- Name: collection collection_id_unique; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_id_unique UNIQUE (uuid);


--
-- Name: collection collection_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_pkey PRIMARY KEY (uuid);


--
-- Name: collection collection_uuid_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_uuid_key UNIQUE (uuid);


--
-- Name: community2collection community2collection_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community2collection
    ADD CONSTRAINT community2collection_pkey PRIMARY KEY (collection_id, community_id);


--
-- Name: community2community community2community_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community2community
    ADD CONSTRAINT community2community_pkey PRIMARY KEY (parent_comm_id, child_comm_id);


--
-- Name: community community_id_unique; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_id_unique UNIQUE (uuid);


--
-- Name: community community_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_pkey PRIMARY KEY (uuid);


--
-- Name: community community_uuid_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_uuid_key UNIQUE (uuid);


--
-- Name: doi doi_doi_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.doi
    ADD CONSTRAINT doi_doi_key UNIQUE (doi);


--
-- Name: doi doi_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.doi
    ADD CONSTRAINT doi_pkey PRIMARY KEY (doi_id);


--
-- Name: dspaceobject dspaceobject_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.dspaceobject
    ADD CONSTRAINT dspaceobject_pkey PRIMARY KEY (uuid);


--
-- Name: eperson eperson_email_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.eperson
    ADD CONSTRAINT eperson_email_key UNIQUE (email);


--
-- Name: eperson eperson_id_unique; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.eperson
    ADD CONSTRAINT eperson_id_unique UNIQUE (uuid);


--
-- Name: eperson eperson_netid_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.eperson
    ADD CONSTRAINT eperson_netid_key UNIQUE (netid);


--
-- Name: eperson eperson_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.eperson
    ADD CONSTRAINT eperson_pkey PRIMARY KEY (uuid);


--
-- Name: eperson eperson_uuid_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.eperson
    ADD CONSTRAINT eperson_uuid_key UNIQUE (uuid);


--
-- Name: epersongroup2eperson epersongroup2eperson_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup2eperson
    ADD CONSTRAINT epersongroup2eperson_pkey PRIMARY KEY (eperson_group_id, eperson_id);


--
-- Name: epersongroup2workspaceitem epersongroup2workspaceitem_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup2workspaceitem
    ADD CONSTRAINT epersongroup2workspaceitem_pkey PRIMARY KEY (workspace_item_id, eperson_group_id);


--
-- Name: epersongroup epersongroup_id_unique; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup
    ADD CONSTRAINT epersongroup_id_unique UNIQUE (uuid);


--
-- Name: epersongroup epersongroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup
    ADD CONSTRAINT epersongroup_pkey PRIMARY KEY (uuid);


--
-- Name: epersongroup epersongroup_uuid_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup
    ADD CONSTRAINT epersongroup_uuid_key UNIQUE (uuid);


--
-- Name: fileextension fileextension_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.fileextension
    ADD CONSTRAINT fileextension_pkey PRIMARY KEY (file_extension_id);


--
-- Name: group2group group2group_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.group2group
    ADD CONSTRAINT group2group_pkey PRIMARY KEY (parent_id, child_id);


--
-- Name: group2groupcache group2groupcache_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.group2groupcache
    ADD CONSTRAINT group2groupcache_pkey PRIMARY KEY (parent_id, child_id);


--
-- Name: handle handle_handle_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.handle
    ADD CONSTRAINT handle_handle_key UNIQUE (handle);


--
-- Name: handle handle_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.handle
    ADD CONSTRAINT handle_pkey PRIMARY KEY (handle_id);


--
-- Name: harvested_collection harvested_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.harvested_collection
    ADD CONSTRAINT harvested_collection_pkey PRIMARY KEY (id);


--
-- Name: harvested_item harvested_item_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.harvested_item
    ADD CONSTRAINT harvested_item_pkey PRIMARY KEY (id);


--
-- Name: item2bundle item2bundle_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item2bundle
    ADD CONSTRAINT item2bundle_pkey PRIMARY KEY (bundle_id, item_id);


--
-- Name: item item_id_unique; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_id_unique UNIQUE (uuid);


--
-- Name: item item_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pkey PRIMARY KEY (uuid);


--
-- Name: item item_uuid_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_uuid_key UNIQUE (uuid);


--
-- Name: metadatafieldregistry metadatafieldregistry_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.metadatafieldregistry
    ADD CONSTRAINT metadatafieldregistry_pkey PRIMARY KEY (metadata_field_id);


--
-- Name: metadataschemaregistry metadataschemaregistry_namespace_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.metadataschemaregistry
    ADD CONSTRAINT metadataschemaregistry_namespace_key UNIQUE (namespace);


--
-- Name: metadataschemaregistry metadataschemaregistry_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.metadataschemaregistry
    ADD CONSTRAINT metadataschemaregistry_pkey PRIMARY KEY (metadata_schema_id);


--
-- Name: metadatavalue metadatavalue_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.metadatavalue
    ADD CONSTRAINT metadatavalue_pkey PRIMARY KEY (metadata_value_id);


--
-- Name: registrationdata registrationdata_email_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.registrationdata
    ADD CONSTRAINT registrationdata_email_key UNIQUE (email);


--
-- Name: registrationdata registrationdata_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.registrationdata
    ADD CONSTRAINT registrationdata_pkey PRIMARY KEY (registrationdata_id);


--
-- Name: requestitem requestitem_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.requestitem
    ADD CONSTRAINT requestitem_pkey PRIMARY KEY (requestitem_id);


--
-- Name: requestitem requestitem_token_key; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.requestitem
    ADD CONSTRAINT requestitem_token_key UNIQUE (token);


--
-- Name: resourcepolicy resourcepolicy_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.resourcepolicy
    ADD CONSTRAINT resourcepolicy_pkey PRIMARY KEY (policy_id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: site site_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (uuid);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (subscription_id);


--
-- Name: tasklistitem tasklistitem_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.tasklistitem
    ADD CONSTRAINT tasklistitem_pkey PRIMARY KEY (tasklist_id);


--
-- Name: versionhistory versionhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.versionhistory
    ADD CONSTRAINT versionhistory_pkey PRIMARY KEY (versionhistory_id);


--
-- Name: versionitem versionitem_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.versionitem
    ADD CONSTRAINT versionitem_pkey PRIMARY KEY (versionitem_id);


--
-- Name: webapp webapp_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.webapp
    ADD CONSTRAINT webapp_pkey PRIMARY KEY (webapp_id);


--
-- Name: workflowitem workflowitem_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.workflowitem
    ADD CONSTRAINT workflowitem_pkey PRIMARY KEY (workflow_id);


--
-- Name: workspaceitem workspaceitem_pkey; Type: CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.workspaceitem
    ADD CONSTRAINT workspaceitem_pkey PRIMARY KEY (workspace_item_id);


--
-- Name: bit_bitstream_fk_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX bit_bitstream_fk_idx ON public.bitstream USING btree (bitstream_format_id);


--
-- Name: bitstream_id_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX bitstream_id_idx ON public.bitstream USING btree (bitstream_id);


--
-- Name: bundle2bitstream_bitstream; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX bundle2bitstream_bitstream ON public.bundle2bitstream USING btree (bitstream_id);


--
-- Name: bundle2bitstream_bundle; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX bundle2bitstream_bundle ON public.bundle2bitstream USING btree (bundle_id);


--
-- Name: bundle_id_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX bundle_id_idx ON public.bundle USING btree (bundle_id);


--
-- Name: bundle_primary; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX bundle_primary ON public.bundle USING btree (primary_bitstream_id);


--
-- Name: ch_result_fk_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX ch_result_fk_idx ON public.checksum_history USING btree (result);


--
-- Name: checksum_history_bitstream; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX checksum_history_bitstream ON public.checksum_history USING btree (bitstream_id);


--
-- Name: collecion2item_collection; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collecion2item_collection ON public.collection2item USING btree (collection_id);


--
-- Name: collecion2item_item; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collecion2item_item ON public.collection2item USING btree (item_id);


--
-- Name: collection_bitstream; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collection_bitstream ON public.collection USING btree (logo_bitstream_id);


--
-- Name: collection_id_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collection_id_idx ON public.collection USING btree (collection_id);


--
-- Name: collection_submitter; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collection_submitter ON public.collection USING btree (submitter);


--
-- Name: collection_template; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collection_template ON public.collection USING btree (template_item_id);


--
-- Name: collection_workflow1; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collection_workflow1 ON public.collection USING btree (workflow_step_1);


--
-- Name: collection_workflow2; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collection_workflow2 ON public.collection USING btree (workflow_step_2);


--
-- Name: collection_workflow3; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX collection_workflow3 ON public.collection USING btree (workflow_step_3);


--
-- Name: community2collection_collection; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX community2collection_collection ON public.community2collection USING btree (collection_id);


--
-- Name: community2collection_community; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX community2collection_community ON public.community2collection USING btree (community_id);


--
-- Name: community2community_child; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX community2community_child ON public.community2community USING btree (child_comm_id);


--
-- Name: community2community_parent; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX community2community_parent ON public.community2community USING btree (parent_comm_id);


--
-- Name: community_admin; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX community_admin ON public.community USING btree (admin);


--
-- Name: community_bitstream; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX community_bitstream ON public.community USING btree (logo_bitstream_id);


--
-- Name: community_id_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX community_id_idx ON public.community USING btree (community_id);


--
-- Name: doi_doi_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX doi_doi_idx ON public.doi USING btree (doi);


--
-- Name: doi_object; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX doi_object ON public.doi USING btree (dspace_object);


--
-- Name: doi_resource_id_and_type_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX doi_resource_id_and_type_idx ON public.doi USING btree (resource_id, resource_type_id);


--
-- Name: eperson_email_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX eperson_email_idx ON public.eperson USING btree (email);


--
-- Name: eperson_group_id_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX eperson_group_id_idx ON public.epersongroup USING btree (eperson_group_id);


--
-- Name: eperson_id_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX eperson_id_idx ON public.eperson USING btree (eperson_id);


--
-- Name: epersongroup2eperson_group; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX epersongroup2eperson_group ON public.epersongroup2eperson USING btree (eperson_group_id);


--
-- Name: epersongroup2eperson_person; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX epersongroup2eperson_person ON public.epersongroup2eperson USING btree (eperson_id);


--
-- Name: epersongroup2workspaceitem_group; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX epersongroup2workspaceitem_group ON public.epersongroup2workspaceitem USING btree (eperson_group_id);


--
-- Name: epersongroup_unique_idx_name; Type: INDEX; Schema: public; Owner: dspace
--

CREATE UNIQUE INDEX epersongroup_unique_idx_name ON public.epersongroup USING btree (name);


--
-- Name: epg2wi_workspace_fk_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX epg2wi_workspace_fk_idx ON public.epersongroup2workspaceitem USING btree (workspace_item_id);


--
-- Name: fe_bitstream_fk_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX fe_bitstream_fk_idx ON public.fileextension USING btree (bitstream_format_id);


--
-- Name: group2group_child; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX group2group_child ON public.group2group USING btree (child_id);


--
-- Name: group2group_parent; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX group2group_parent ON public.group2group USING btree (parent_id);


--
-- Name: group2groupcache_child; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX group2groupcache_child ON public.group2groupcache USING btree (child_id);


--
-- Name: group2groupcache_parent; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX group2groupcache_parent ON public.group2groupcache USING btree (parent_id);


--
-- Name: handle_handle_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX handle_handle_idx ON public.handle USING btree (handle);


--
-- Name: handle_object; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX handle_object ON public.handle USING btree (resource_id);


--
-- Name: handle_resource_id_and_type_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX handle_resource_id_and_type_idx ON public.handle USING btree (resource_legacy_id, resource_type_id);


--
-- Name: harvested_collection_collection; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX harvested_collection_collection ON public.harvested_collection USING btree (collection_id);


--
-- Name: harvested_item_item; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX harvested_item_item ON public.harvested_item USING btree (item_id);


--
-- Name: item2bundle_bundle; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX item2bundle_bundle ON public.item2bundle USING btree (bundle_id);


--
-- Name: item2bundle_item; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX item2bundle_item ON public.item2bundle USING btree (item_id);


--
-- Name: item_collection; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX item_collection ON public.item USING btree (owning_collection);


--
-- Name: item_id_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX item_id_idx ON public.item USING btree (item_id);


--
-- Name: item_submitter; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX item_submitter ON public.item USING btree (submitter_id);


--
-- Name: metadatafield_schema_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX metadatafield_schema_idx ON public.metadatafieldregistry USING btree (metadata_schema_id);


--
-- Name: metadatafieldregistry_idx_element_qualifier; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX metadatafieldregistry_idx_element_qualifier ON public.metadatafieldregistry USING btree (element, qualifier);


--
-- Name: metadataschemaregistry_unique_idx_short_id; Type: INDEX; Schema: public; Owner: dspace
--

CREATE UNIQUE INDEX metadataschemaregistry_unique_idx_short_id ON public.metadataschemaregistry USING btree (short_id);


--
-- Name: metadatavalue_field_fk_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX metadatavalue_field_fk_idx ON public.metadatavalue USING btree (metadata_field_id);


--
-- Name: metadatavalue_field_object; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX metadatavalue_field_object ON public.metadatavalue USING btree (metadata_field_id, dspace_object_id);


--
-- Name: metadatavalue_object; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX metadatavalue_object ON public.metadatavalue USING btree (dspace_object_id);


--
-- Name: most_recent_checksum_bitstream; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX most_recent_checksum_bitstream ON public.most_recent_checksum USING btree (bitstream_id);


--
-- Name: mrc_result_fk_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX mrc_result_fk_idx ON public.most_recent_checksum USING btree (result);


--
-- Name: requestitem_bitstream; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX requestitem_bitstream ON public.requestitem USING btree (bitstream_id);


--
-- Name: requestitem_item; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX requestitem_item ON public.requestitem USING btree (item_id);


--
-- Name: resourcepolicy_group; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX resourcepolicy_group ON public.resourcepolicy USING btree (epersongroup_id);


--
-- Name: resourcepolicy_idx_rptype; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX resourcepolicy_idx_rptype ON public.resourcepolicy USING btree (rptype);


--
-- Name: resourcepolicy_object; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX resourcepolicy_object ON public.resourcepolicy USING btree (dspace_object);


--
-- Name: resourcepolicy_person; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX resourcepolicy_person ON public.resourcepolicy USING btree (eperson_id);


--
-- Name: resourcepolicy_type_id_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX resourcepolicy_type_id_idx ON public.resourcepolicy USING btree (resource_type_id, resource_id);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX schema_version_s_idx ON public.schema_version USING btree (success);


--
-- Name: subscription_collection; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX subscription_collection ON public.subscription USING btree (collection_id);


--
-- Name: subscription_person; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX subscription_person ON public.subscription USING btree (eperson_id);


--
-- Name: tasklist_workflow_fk_idx; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX tasklist_workflow_fk_idx ON public.tasklistitem USING btree (workflow_id);


--
-- Name: versionitem_item; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX versionitem_item ON public.versionitem USING btree (item_id);


--
-- Name: versionitem_person; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX versionitem_person ON public.versionitem USING btree (eperson_id);


--
-- Name: workspaceitem_coll; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX workspaceitem_coll ON public.workspaceitem USING btree (collection_id);


--
-- Name: workspaceitem_item; Type: INDEX; Schema: public; Owner: dspace
--

CREATE INDEX workspaceitem_item ON public.workspaceitem USING btree (item_id);


--
-- Name: bitstream bitstream_bitstream_format_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bitstream
    ADD CONSTRAINT bitstream_bitstream_format_id_fkey FOREIGN KEY (bitstream_format_id) REFERENCES public.bitstreamformatregistry(bitstream_format_id);


--
-- Name: bitstream bitstream_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bitstream
    ADD CONSTRAINT bitstream_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.dspaceobject(uuid);


--
-- Name: bundle2bitstream bundle2bitstream_bitstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bundle2bitstream
    ADD CONSTRAINT bundle2bitstream_bitstream_id_fkey FOREIGN KEY (bitstream_id) REFERENCES public.bitstream(uuid);


--
-- Name: bundle2bitstream bundle2bitstream_bundle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bundle2bitstream
    ADD CONSTRAINT bundle2bitstream_bundle_id_fkey FOREIGN KEY (bundle_id) REFERENCES public.bundle(uuid);


--
-- Name: bundle bundle_primary_bitstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bundle
    ADD CONSTRAINT bundle_primary_bitstream_id_fkey FOREIGN KEY (primary_bitstream_id) REFERENCES public.bitstream(uuid);


--
-- Name: bundle bundle_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.bundle
    ADD CONSTRAINT bundle_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.dspaceobject(uuid);


--
-- Name: checksum_history checksum_history_bitstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.checksum_history
    ADD CONSTRAINT checksum_history_bitstream_id_fkey FOREIGN KEY (bitstream_id) REFERENCES public.bitstream(uuid);


--
-- Name: checksum_history checksum_history_result_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.checksum_history
    ADD CONSTRAINT checksum_history_result_fkey FOREIGN KEY (result) REFERENCES public.checksum_results(result_code);


--
-- Name: collection2item collection2item_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection2item
    ADD CONSTRAINT collection2item_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(uuid);


--
-- Name: collection2item collection2item_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection2item
    ADD CONSTRAINT collection2item_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(uuid);


--
-- Name: collection collection_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_admin_fkey FOREIGN KEY (admin) REFERENCES public.epersongroup(uuid);


--
-- Name: collection collection_submitter_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_submitter_fkey FOREIGN KEY (submitter) REFERENCES public.epersongroup(uuid);


--
-- Name: collection collection_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.dspaceobject(uuid);


--
-- Name: collection collection_workflow_step_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_workflow_step_1_fkey FOREIGN KEY (workflow_step_1) REFERENCES public.epersongroup(uuid);


--
-- Name: collection collection_workflow_step_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_workflow_step_2_fkey FOREIGN KEY (workflow_step_2) REFERENCES public.epersongroup(uuid);


--
-- Name: collection collection_workflow_step_3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_workflow_step_3_fkey FOREIGN KEY (workflow_step_3) REFERENCES public.epersongroup(uuid);


--
-- Name: community2collection community2collection_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community2collection
    ADD CONSTRAINT community2collection_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(uuid);


--
-- Name: community2collection community2collection_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community2collection
    ADD CONSTRAINT community2collection_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(uuid);


--
-- Name: community2community community2community_child_comm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community2community
    ADD CONSTRAINT community2community_child_comm_id_fkey FOREIGN KEY (child_comm_id) REFERENCES public.community(uuid);


--
-- Name: community2community community2community_parent_comm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community2community
    ADD CONSTRAINT community2community_parent_comm_id_fkey FOREIGN KEY (parent_comm_id) REFERENCES public.community(uuid);


--
-- Name: community community_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_admin_fkey FOREIGN KEY (admin) REFERENCES public.epersongroup(uuid);


--
-- Name: community community_logo_bitstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_logo_bitstream_id_fkey FOREIGN KEY (logo_bitstream_id) REFERENCES public.bitstream(uuid);


--
-- Name: community community_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.dspaceobject(uuid);


--
-- Name: doi doi_dspace_object_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.doi
    ADD CONSTRAINT doi_dspace_object_fkey FOREIGN KEY (dspace_object) REFERENCES public.dspaceobject(uuid);


--
-- Name: eperson eperson_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.eperson
    ADD CONSTRAINT eperson_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.dspaceobject(uuid);


--
-- Name: epersongroup2eperson epersongroup2eperson_eperson_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup2eperson
    ADD CONSTRAINT epersongroup2eperson_eperson_group_id_fkey FOREIGN KEY (eperson_group_id) REFERENCES public.epersongroup(uuid);


--
-- Name: epersongroup2eperson epersongroup2eperson_eperson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup2eperson
    ADD CONSTRAINT epersongroup2eperson_eperson_id_fkey FOREIGN KEY (eperson_id) REFERENCES public.eperson(uuid);


--
-- Name: epersongroup2workspaceitem epersongroup2workspaceitem_eperson_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup2workspaceitem
    ADD CONSTRAINT epersongroup2workspaceitem_eperson_group_id_fkey FOREIGN KEY (eperson_group_id) REFERENCES public.epersongroup(uuid);


--
-- Name: epersongroup2workspaceitem epersongroup2workspaceitem_workspace_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup2workspaceitem
    ADD CONSTRAINT epersongroup2workspaceitem_workspace_item_id_fkey FOREIGN KEY (workspace_item_id) REFERENCES public.workspaceitem(workspace_item_id);


--
-- Name: epersongroup epersongroup_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.epersongroup
    ADD CONSTRAINT epersongroup_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.dspaceobject(uuid);


--
-- Name: fileextension fileextension_bitstream_format_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.fileextension
    ADD CONSTRAINT fileextension_bitstream_format_id_fkey FOREIGN KEY (bitstream_format_id) REFERENCES public.bitstreamformatregistry(bitstream_format_id);


--
-- Name: group2group group2group_child_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.group2group
    ADD CONSTRAINT group2group_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.epersongroup(uuid);


--
-- Name: group2group group2group_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.group2group
    ADD CONSTRAINT group2group_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.epersongroup(uuid);


--
-- Name: group2groupcache group2groupcache_child_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.group2groupcache
    ADD CONSTRAINT group2groupcache_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.epersongroup(uuid);


--
-- Name: group2groupcache group2groupcache_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.group2groupcache
    ADD CONSTRAINT group2groupcache_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.epersongroup(uuid);


--
-- Name: handle handle_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.handle
    ADD CONSTRAINT handle_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.dspaceobject(uuid);


--
-- Name: harvested_collection harvested_collection_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.harvested_collection
    ADD CONSTRAINT harvested_collection_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(uuid);


--
-- Name: harvested_item harvested_item_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.harvested_item
    ADD CONSTRAINT harvested_item_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(uuid);


--
-- Name: item2bundle item2bundle_bundle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item2bundle
    ADD CONSTRAINT item2bundle_bundle_id_fkey FOREIGN KEY (bundle_id) REFERENCES public.bundle(uuid);


--
-- Name: item2bundle item2bundle_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item2bundle
    ADD CONSTRAINT item2bundle_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(uuid);


--
-- Name: item item_owning_collection_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_owning_collection_fkey FOREIGN KEY (owning_collection) REFERENCES public.collection(uuid);


--
-- Name: item item_submitter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_submitter_id_fkey FOREIGN KEY (submitter_id) REFERENCES public.eperson(uuid);


--
-- Name: item item_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.dspaceobject(uuid);


--
-- Name: metadatafieldregistry metadatafieldregistry_metadata_schema_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.metadatafieldregistry
    ADD CONSTRAINT metadatafieldregistry_metadata_schema_id_fkey FOREIGN KEY (metadata_schema_id) REFERENCES public.metadataschemaregistry(metadata_schema_id);


--
-- Name: metadatavalue metadatavalue_dspace_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.metadatavalue
    ADD CONSTRAINT metadatavalue_dspace_object_id_fkey FOREIGN KEY (dspace_object_id) REFERENCES public.dspaceobject(uuid) ON DELETE CASCADE;


--
-- Name: metadatavalue metadatavalue_metadata_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.metadatavalue
    ADD CONSTRAINT metadatavalue_metadata_field_id_fkey FOREIGN KEY (metadata_field_id) REFERENCES public.metadatafieldregistry(metadata_field_id);


--
-- Name: most_recent_checksum most_recent_checksum_bitstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.most_recent_checksum
    ADD CONSTRAINT most_recent_checksum_bitstream_id_fkey FOREIGN KEY (bitstream_id) REFERENCES public.bitstream(uuid);


--
-- Name: most_recent_checksum most_recent_checksum_result_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.most_recent_checksum
    ADD CONSTRAINT most_recent_checksum_result_fkey FOREIGN KEY (result) REFERENCES public.checksum_results(result_code);


--
-- Name: requestitem requestitem_bitstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.requestitem
    ADD CONSTRAINT requestitem_bitstream_id_fkey FOREIGN KEY (bitstream_id) REFERENCES public.bitstream(uuid);


--
-- Name: requestitem requestitem_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.requestitem
    ADD CONSTRAINT requestitem_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(uuid);


--
-- Name: resourcepolicy resourcepolicy_dspace_object_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.resourcepolicy
    ADD CONSTRAINT resourcepolicy_dspace_object_fkey FOREIGN KEY (dspace_object) REFERENCES public.dspaceobject(uuid) ON DELETE CASCADE;


--
-- Name: resourcepolicy resourcepolicy_eperson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.resourcepolicy
    ADD CONSTRAINT resourcepolicy_eperson_id_fkey FOREIGN KEY (eperson_id) REFERENCES public.eperson(uuid);


--
-- Name: resourcepolicy resourcepolicy_epersongroup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.resourcepolicy
    ADD CONSTRAINT resourcepolicy_epersongroup_id_fkey FOREIGN KEY (epersongroup_id) REFERENCES public.epersongroup(uuid);


--
-- Name: site site_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.dspaceobject(uuid);


--
-- Name: subscription subscription_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(uuid);


--
-- Name: subscription subscription_eperson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_eperson_id_fkey FOREIGN KEY (eperson_id) REFERENCES public.eperson(uuid);


--
-- Name: tasklistitem tasklistitem_eperson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.tasklistitem
    ADD CONSTRAINT tasklistitem_eperson_id_fkey FOREIGN KEY (eperson_id) REFERENCES public.eperson(uuid);


--
-- Name: tasklistitem tasklistitem_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.tasklistitem
    ADD CONSTRAINT tasklistitem_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflowitem(workflow_id);


--
-- Name: versionitem versionitem_eperson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.versionitem
    ADD CONSTRAINT versionitem_eperson_id_fkey FOREIGN KEY (eperson_id) REFERENCES public.eperson(uuid);


--
-- Name: versionitem versionitem_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.versionitem
    ADD CONSTRAINT versionitem_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(uuid);


--
-- Name: versionitem versionitem_versionhistory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.versionitem
    ADD CONSTRAINT versionitem_versionhistory_id_fkey FOREIGN KEY (versionhistory_id) REFERENCES public.versionhistory(versionhistory_id);


--
-- Name: workflowitem workflowitem_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.workflowitem
    ADD CONSTRAINT workflowitem_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(uuid);


--
-- Name: workflowitem workflowitem_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.workflowitem
    ADD CONSTRAINT workflowitem_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(uuid);


--
-- Name: workflowitem workflowitem_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.workflowitem
    ADD CONSTRAINT workflowitem_owner_fkey FOREIGN KEY (owner) REFERENCES public.eperson(uuid);


--
-- Name: workspaceitem workspaceitem_collection_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.workspaceitem
    ADD CONSTRAINT workspaceitem_collection_id_fk FOREIGN KEY (collection_id) REFERENCES public.collection(uuid);


--
-- Name: workspaceitem workspaceitem_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.workspaceitem
    ADD CONSTRAINT workspaceitem_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(uuid);


--
-- Name: workspaceitem workspaceitem_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dspace
--

ALTER TABLE ONLY public.workspaceitem
    ADD CONSTRAINT workspaceitem_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(uuid);


--
-- PostgreSQL database dump complete
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.3 (Debian 11.3-1.pgdg90+1)
-- Dumped by pg_dump version 11.3 (Debian 11.3-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

