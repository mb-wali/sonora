--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE de;
ALTER ROLE de WITH SUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md513c78e93243d730bdaa9290c57e88b1e';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md5bcfc52ee0d409ce403b9f97ff48f4724';






--
-- Database creation
--

CREATE DATABASE de WITH TEMPLATE = template0 OWNER = de;
CREATE DATABASE metadata WITH TEMPLATE = template0 OWNER = de;
CREATE DATABASE notifications WITH TEMPLATE = template0 OWNER = de;
CREATE DATABASE permissions WITH TEMPLATE = template0 OWNER = de;
REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


\connect de

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.23
-- Dumped by pg_dump version 9.6.23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: notification_types; Type: TYPE; Schema: public; Owner: de
--

CREATE TYPE public.notification_types AS ENUM (
    'apps',
    'tool_request',
    'team',
    'data',
    'analysis',
    'tools',
    'permanent_id_request'
);


ALTER TYPE public.notification_types OWNER TO de;

--
-- Name: app_category_hierarchy(uuid); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.app_category_hierarchy(uuid) RETURNS TABLE(parent_id uuid, id uuid, name character varying, description character varying, workspace_id uuid, is_public boolean, app_count bigint)
    LANGUAGE sql
    AS $_$
    WITH RECURSIVE subcategories AS
    (
            SELECT acg.parent_category_id AS parent_id, ac.id, ac.name,
                   ac.description, ac.workspace_id, ac.is_public,
                   app_count(ac.id) AS app_count
            FROM app_category_group acg
            RIGHT JOIN app_category_listing ac ON acg.child_category_id = ac.id
            WHERE ac.id = $1
        UNION ALL
            SELECT acg.parent_category_id AS parent_id, ac.id, ac.name,
                   ac.description, ac.workspace_id, ac.is_public,
                   app_count(ac.id) AS app_count
            FROM subcategories sc, app_category_group acg
            JOIN app_category_listing ac ON acg.child_category_id = ac.id
            WHERE acg.parent_category_id = sc.id
    )
    SELECT * FROM subcategories
$_$;


ALTER FUNCTION public.app_category_hierarchy(uuid) OWNER TO de;

--
-- Name: app_category_hierarchy(uuid, boolean); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.app_category_hierarchy(uuid, boolean) RETURNS TABLE(parent_id uuid, id uuid, name character varying, description character varying, workspace_id uuid, is_public boolean, app_count bigint)
    LANGUAGE sql
    AS $_$
    WITH RECURSIVE subcategories AS
    (
            SELECT acg.parent_category_id AS parent_id, ac.id, ac.name,
                   ac.description, ac.workspace_id, ac.is_public,
                   app_count(ac.id, $2) AS app_count
            FROM app_category_group acg
            RIGHT JOIN app_category_listing ac ON acg.child_category_id = ac.id
            WHERE ac.id = $1
        UNION ALL
            SELECT acg.parent_category_id AS parent_id, ac.id, ac.name,
                   ac.description, ac.workspace_id, ac.is_public,
                   app_count(ac.id, $2) AS app_count
            FROM subcategories sc, app_category_group acg
            JOIN app_category_listing ac ON acg.child_category_id = ac.id
            WHERE acg.parent_category_id = sc.id
    )
    SELECT * FROM subcategories
$_$;


ALTER FUNCTION public.app_category_hierarchy(uuid, boolean) OWNER TO de;

--
-- Name: app_category_hierarchy(uuid, boolean, anyarray); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.app_category_hierarchy(uuid, boolean, anyarray) RETURNS TABLE(parent_id uuid, id uuid, name character varying, description character varying, workspace_id uuid, is_public boolean, app_count bigint)
    LANGUAGE sql
    AS $_$
    WITH RECURSIVE subcategories AS
    (
            SELECT acg.parent_category_id AS parent_id, ac.id, ac.name,
                   ac.description, ac.workspace_id, ac.is_public,
                   app_count(ac.id, $2, $3) AS app_count
            FROM app_category_group acg
            RIGHT JOIN app_category_listing ac ON acg.child_category_id = ac.id
            WHERE ac.id = $1
        UNION ALL
            SELECT acg.parent_category_id AS parent_id, ac.id, ac.name,
                   ac.description, ac.workspace_id, ac.is_public,
                   app_count(ac.id, $2, $3) AS app_count
            FROM subcategories sc, app_category_group acg
            JOIN app_category_listing ac ON acg.child_category_id = ac.id
            WHERE acg.parent_category_id = sc.id
    )
    SELECT * FROM subcategories
$_$;


ALTER FUNCTION public.app_category_hierarchy(uuid, boolean, anyarray) OWNER TO de;

--
-- Name: app_category_hierarchy_ids(uuid); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.app_category_hierarchy_ids(uuid) RETURNS TABLE(id uuid)
    LANGUAGE sql
    AS $_$
    WITH RECURSIVE subcategories(parent_id) AS
    (
            SELECT acg.parent_category_id AS parent_id, ac.id
            FROM app_category_group acg
            RIGHT JOIN app_categories ac ON acg.child_category_id = ac.id
            WHERE ac.id = $1
        UNION ALL
            SELECT acg.parent_category_id AS parent_id, ac.id
            FROM subcategories sc, app_category_group acg
            JOIN app_categories ac ON acg.child_category_id = ac.id
            WHERE acg.parent_category_id = sc.id
    )
    SELECT id FROM subcategories
$_$;


ALTER FUNCTION public.app_category_hierarchy_ids(uuid) OWNER TO de;

--
-- Name: app_count(uuid); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.app_count(uuid) RETURNS bigint
    LANGUAGE sql
    AS $_$
    SELECT COUNT(DISTINCT a.id) FROM apps a
    JOIN app_category_app aca ON a.id = aca.app_id
    WHERE NOT a.deleted
    AND aca.app_category_id IN (SELECT * FROM app_category_hierarchy_ids($1))
$_$;


ALTER FUNCTION public.app_count(uuid) OWNER TO de;

--
-- Name: app_count(uuid, boolean); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.app_count(uuid, boolean) RETURNS bigint
    LANGUAGE sql
    AS $_$
    SELECT COUNT(DISTINCT a.id) FROM apps a
    JOIN app_category_app aca ON a.id = aca.app_id
    WHERE NOT a.deleted
    AND aca.app_category_id IN (SELECT * FROM app_category_hierarchy_ids($1))
    AND CASE
        WHEN $2 THEN TRUE
        ELSE NOT EXISTS (
            SELECT * FROM app_steps s
            JOIN tasks t ON t.id = s.task_id
            WHERE s.app_id = a.id
            AND t.external_app_id IS NOT NULL
        )
    END
$_$;


ALTER FUNCTION public.app_count(uuid, boolean) OWNER TO de;

--
-- Name: app_count(uuid, boolean, anyarray); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.app_count(uuid, boolean, anyarray) RETURNS bigint
    LANGUAGE sql
    AS $_$
    SELECT COUNT(DISTINCT a.id) FROM apps a
    JOIN app_category_app aca ON a.id = aca.app_id
    WHERE NOT a.deleted
    AND aca.app_category_id IN (SELECT * FROM app_category_hierarchy_ids($1))
    AND a.id = ANY ($3::uuid[])
    AND CASE
        WHEN $2 THEN TRUE
        ELSE NOT EXISTS (
            SELECT * FROM app_steps s
            JOIN tasks t ON t.id = s.task_id
            WHERE s.app_id = a.id
            AND t.external_app_id IS NOT NULL
        )
    END
$_$;


ALTER FUNCTION public.app_count(uuid, boolean, anyarray) OWNER TO de;

--
-- Name: first_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.first_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $1
$_$;


ALTER FUNCTION public.first_agg(anyelement, anyelement) OWNER TO de;

--
-- Name: last_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.last_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $2
$_$;


ALTER FUNCTION public.last_agg(anyelement, anyelement) OWNER TO de;

--
-- Name: first(anyelement); Type: AGGREGATE; Schema: public; Owner: de
--

CREATE AGGREGATE public.first(anyelement) (
    SFUNC = public.first_agg,
    STYPE = anyelement
);


ALTER AGGREGATE public.first(anyelement) OWNER TO de;

--
-- Name: last(anyelement); Type: AGGREGATE; Schema: public; Owner: de
--

CREATE AGGREGATE public.last(anyelement) (
    SFUNC = public.last_agg,
    STYPE = anyelement
);


ALTER AGGREGATE public.last(anyelement) OWNER TO de;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.access_tokens (
    webapp character varying(64) NOT NULL,
    user_id uuid NOT NULL,
    token bytea NOT NULL,
    expires_at timestamp without time zone,
    refresh_token bytea
);


ALTER TABLE public.access_tokens OWNER TO de;

--
-- Name: app_categories; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_categories (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(255),
    description text,
    workspace_id uuid NOT NULL
);


ALTER TABLE public.app_categories OWNER TO de;

--
-- Name: app_category_app; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_category_app (
    app_category_id uuid NOT NULL,
    app_id uuid NOT NULL
);


ALTER TABLE public.app_category_app OWNER TO de;

--
-- Name: app_category_group; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_category_group (
    parent_category_id uuid NOT NULL,
    child_category_id uuid NOT NULL,
    child_index integer NOT NULL
);


ALTER TABLE public.app_category_group OWNER TO de;

--
-- Name: workspace; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.workspace (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    root_category_id uuid,
    is_public boolean DEFAULT false,
    user_id uuid NOT NULL
);


ALTER TABLE public.workspace OWNER TO de;

--
-- Name: app_category_listing; Type: VIEW; Schema: public; Owner: de
--

CREATE VIEW public.app_category_listing AS
 SELECT c.id,
    c.name,
    c.description,
    c.workspace_id,
    w.is_public
   FROM (public.app_categories c
     LEFT JOIN public.workspace w ON ((c.workspace_id = w.id)));


ALTER TABLE public.app_category_listing OWNER TO de;

--
-- Name: app_documentation; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_documentation (
    app_id uuid NOT NULL,
    value text,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    modified_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


ALTER TABLE public.app_documentation OWNER TO de;

--
-- Name: app_hierarchy_version; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_hierarchy_version (
    version character varying NOT NULL,
    applied_by uuid NOT NULL,
    applied timestamp without time zone DEFAULT now()
);


ALTER TABLE public.app_hierarchy_version OWNER TO de;

--
-- Name: app_steps; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_steps (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    app_id uuid NOT NULL,
    task_id uuid NOT NULL,
    step integer NOT NULL
);


ALTER TABLE public.app_steps OWNER TO de;

--
-- Name: apps; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.apps (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(255),
    description text,
    deleted boolean DEFAULT false NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    integration_data_id uuid NOT NULL,
    wiki_url character varying(1024),
    integration_date timestamp without time zone,
    edited_date timestamp without time zone
);


ALTER TABLE public.apps OWNER TO de;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tasks (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    job_type_id uuid NOT NULL,
    external_app_id character varying(255),
    name character varying(255) NOT NULL,
    description text,
    label character varying(255),
    tool_id uuid
);


ALTER TABLE public.tasks OWNER TO de;

--
-- Name: tool_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tool_types (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(50) NOT NULL,
    label character varying(128) NOT NULL,
    description text,
    hidden boolean DEFAULT false NOT NULL,
    notification_type public.notification_types NOT NULL
);


ALTER TABLE public.tool_types OWNER TO de;

--
-- Name: tools; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tools (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(255) NOT NULL,
    location character varying(255),
    tool_type_id uuid NOT NULL,
    description text,
    version character varying(255) NOT NULL,
    attribution text,
    integration_data_id uuid NOT NULL,
    container_images_id uuid,
    time_limit_seconds integer DEFAULT 0 NOT NULL,
    restricted boolean DEFAULT false NOT NULL,
    interactive boolean DEFAULT false NOT NULL,
    gpu_enabled boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tools OWNER TO de;

--
-- Name: app_job_types; Type: VIEW; Schema: public; Owner: de
--

CREATE VIEW public.app_job_types AS
 SELECT apps.id AS app_id,
    tt.name AS job_type,
    tt.hidden
   FROM ((((public.apps
     JOIN public.app_steps steps ON ((apps.id = steps.app_id)))
     JOIN public.tasks t ON ((steps.task_id = t.id)))
     JOIN public.tools tool ON ((t.tool_id = tool.id)))
     JOIN public.tool_types tt ON ((tool.tool_type_id = tt.id)));


ALTER TABLE public.app_job_types OWNER TO de;

--
-- Name: integration_data; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.integration_data (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    integrator_name character varying(255) NOT NULL,
    integrator_email character varying(255) NOT NULL,
    user_id uuid,
    CONSTRAINT integration_data_integrator_email_check CHECK (((integrator_email)::text ~ '\S'::text)),
    CONSTRAINT integration_data_integrator_name_check CHECK (((integrator_name)::text ~ '\S'::text))
);


ALTER TABLE public.integration_data OWNER TO de;

--
-- Name: ratings; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.ratings (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    user_id uuid NOT NULL,
    app_id uuid NOT NULL,
    rating integer NOT NULL,
    comment_id bigint
);


ALTER TABLE public.ratings OWNER TO de;

--
-- Name: users; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    username character varying(512) NOT NULL
);


ALTER TABLE public.users OWNER TO de;

--
-- Name: app_listing; Type: VIEW; Schema: public; Owner: de
--

CREATE VIEW public.app_listing AS
 SELECT apps.id,
    apps.name,
    lower((apps.name)::text) AS lower_case_name,
    apps.description,
    integration.integrator_name,
    integration.integrator_email,
    apps.integration_date,
    apps.edited_date,
    apps.wiki_url,
    ( SELECT (COALESCE(avg(ratings.rating), 0.0))::double precision AS "coalesce"
           FROM public.ratings
          WHERE (ratings.app_id = apps.id)) AS average_rating,
    ( SELECT count(ratings.rating) AS count
           FROM public.ratings
          WHERE (ratings.app_id = apps.id)) AS total_ratings,
    (EXISTS ( SELECT aca.app_category_id,
            aca.app_id,
            ac.id,
            ac.name,
            ac.description,
            ac.workspace_id,
            w.id,
            w.root_category_id,
            w.is_public,
            w.user_id
           FROM ((public.app_category_app aca
             JOIN public.app_categories ac ON ((aca.app_category_id = ac.id)))
             JOIN public.workspace w ON ((ac.workspace_id = w.id)))
          WHERE ((apps.id = aca.app_id) AND (w.is_public IS TRUE)))) AS is_public,
    count(steps.*) AS step_count,
    count(t.tool_id) AS tool_count,
    count(t.external_app_id) AS external_app_count,
    count(t.id) AS task_count,
    apps.deleted,
    apps.disabled,
        CASE
            WHEN (count(DISTINCT tt.name) = 0) THEN 'unknown'::text
            WHEN (count(DISTINCT tt.name) > 1) THEN 'mixed'::text
            ELSE max((tt.name)::text)
        END AS overall_job_type,
    integration.user_id AS integrator_id,
    u.username AS integrator_username,
    array_agg(tt.name) AS job_types
   FROM ((((((public.apps
     LEFT JOIN public.integration_data integration ON ((apps.integration_data_id = integration.id)))
     LEFT JOIN public.users u ON ((integration.user_id = u.id)))
     LEFT JOIN public.app_steps steps ON ((apps.id = steps.app_id)))
     LEFT JOIN public.tasks t ON ((steps.task_id = t.id)))
     LEFT JOIN public.tools tool ON ((t.tool_id = tool.id)))
     LEFT JOIN public.tool_types tt ON ((tool.tool_type_id = tt.id)))
  GROUP BY apps.id, apps.name, apps.description, integration.integrator_name, integration.integrator_email, integration.user_id, u.username, apps.integration_date, apps.edited_date, apps.wiki_url, apps.deleted, apps.disabled;


ALTER TABLE public.app_listing OWNER TO de;

--
-- Name: app_publication_request_status_codes; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_publication_request_status_codes (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    email_template character varying(64)
);


ALTER TABLE public.app_publication_request_status_codes OWNER TO de;

--
-- Name: app_publication_request_statuses; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_publication_request_statuses (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    app_publication_request_id uuid NOT NULL,
    app_publication_request_status_code_id uuid NOT NULL,
    date_assigned timestamp without time zone DEFAULT now() NOT NULL,
    updater_id uuid NOT NULL,
    comments text
);


ALTER TABLE public.app_publication_request_statuses OWNER TO de;

--
-- Name: app_publication_requests; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_publication_requests (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    requestor_id uuid NOT NULL,
    app_id uuid
);


ALTER TABLE public.app_publication_requests OWNER TO de;

--
-- Name: app_references; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.app_references (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    app_id uuid NOT NULL,
    reference_text text NOT NULL
);


ALTER TABLE public.app_references OWNER TO de;

--
-- Name: apps_htcondor_extra; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.apps_htcondor_extra (
    apps_id uuid NOT NULL,
    extra_requirements text NOT NULL
);


ALTER TABLE public.apps_htcondor_extra OWNER TO de;

--
-- Name: async_task_behavior; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.async_task_behavior (
    async_task_id uuid NOT NULL,
    behavior_type text NOT NULL,
    data json
);


ALTER TABLE public.async_task_behavior OWNER TO de;

--
-- Name: async_task_status; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.async_task_status (
    async_task_id uuid NOT NULL,
    status text NOT NULL,
    detail text,
    created_date timestamp without time zone NOT NULL
);


ALTER TABLE public.async_task_status OWNER TO de;

--
-- Name: async_tasks; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.async_tasks (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    type text NOT NULL,
    username text,
    data json,
    start_date timestamp without time zone,
    end_date timestamp without time zone
);


ALTER TABLE public.async_tasks OWNER TO de;

--
-- Name: authorization_requests; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.authorization_requests (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    state_info text NOT NULL
);


ALTER TABLE public.authorization_requests OWNER TO de;

--
-- Name: bags; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.bags (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    user_id uuid NOT NULL,
    contents json NOT NULL
);


ALTER TABLE public.bags OWNER TO de;

--
-- Name: container_devices; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.container_devices (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    container_settings_id uuid NOT NULL,
    host_path text NOT NULL,
    container_path text NOT NULL
);


ALTER TABLE public.container_devices OWNER TO de;

--
-- Name: container_images; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.container_images (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name text NOT NULL,
    tag text NOT NULL,
    url text,
    deprecated boolean DEFAULT false NOT NULL,
    osg_image_path text
);


ALTER TABLE public.container_images OWNER TO de;

--
-- Name: container_ports; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.container_ports (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    container_settings_id uuid NOT NULL,
    host_port integer,
    container_port integer NOT NULL,
    bind_to_host boolean DEFAULT false NOT NULL
);


ALTER TABLE public.container_ports OWNER TO de;

--
-- Name: container_settings; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.container_settings (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    tools_id uuid NOT NULL,
    interactive_apps_proxy_settings_id uuid,
    pids_limit integer,
    cpu_shares integer,
    memory_limit bigint,
    min_memory_limit bigint,
    min_cpu_cores numeric(6,3),
    max_cpu_cores numeric(6,3),
    min_disk_space bigint,
    network_mode text,
    working_directory text,
    name text,
    entrypoint text,
    skip_tmp_mount boolean DEFAULT false NOT NULL,
    uid integer
);


ALTER TABLE public.container_settings OWNER TO de;

--
-- Name: container_volumes; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.container_volumes (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    container_settings_id uuid NOT NULL,
    host_path text NOT NULL,
    container_path text NOT NULL
);


ALTER TABLE public.container_volumes OWNER TO de;

--
-- Name: container_volumes_from; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.container_volumes_from (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    data_containers_id uuid NOT NULL,
    container_settings_id uuid NOT NULL
);


ALTER TABLE public.container_volumes_from OWNER TO de;

--
-- Name: data_containers; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.data_containers (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name_prefix text NOT NULL,
    container_images_id uuid NOT NULL,
    read_only boolean DEFAULT true NOT NULL
);


ALTER TABLE public.data_containers OWNER TO de;

--
-- Name: data_formats; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.data_formats (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    label character varying(255),
    display_order integer DEFAULT 999
);


ALTER TABLE public.data_formats OWNER TO de;

--
-- Name: data_source; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.data_source (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(50) NOT NULL,
    label character varying(50) NOT NULL,
    description text NOT NULL,
    display_order bigint
);


ALTER TABLE public.data_source OWNER TO de;

--
-- Name: default_bags; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.default_bags (
    user_id uuid NOT NULL,
    bag_id uuid NOT NULL
);


ALTER TABLE public.default_bags OWNER TO de;

--
-- Name: default_instant_launches; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.default_instant_launches (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    version integer NOT NULL,
    instant_launches jsonb DEFAULT '{}'::jsonb NOT NULL,
    added_by uuid NOT NULL,
    added_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.default_instant_launches OWNER TO de;

--
-- Name: default_instant_launches_version_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.default_instant_launches_version_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.default_instant_launches_version_seq OWNER TO de;

--
-- Name: default_instant_launches_version_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: de
--

ALTER SEQUENCE public.default_instant_launches_version_seq OWNED BY public.default_instant_launches.version;


--
-- Name: docker_registries; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.docker_registries (
    name text NOT NULL,
    username text NOT NULL,
    password text NOT NULL
);


ALTER TABLE public.docker_registries OWNER TO de;

--
-- Name: file_parameters; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.file_parameters (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    parameter_id uuid,
    retain boolean DEFAULT false,
    is_implicit boolean DEFAULT false,
    repeat_option_flag boolean DEFAULT true,
    info_type uuid NOT NULL,
    data_format uuid NOT NULL,
    data_source_id uuid NOT NULL
);


ALTER TABLE public.file_parameters OWNER TO de;

--
-- Name: genome_reference; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.genome_reference (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(512) NOT NULL,
    path character varying(1024) NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    last_modified_by uuid NOT NULL,
    last_modified_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.genome_reference OWNER TO de;

--
-- Name: info_type; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.info_type (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    label character varying(255),
    description text,
    deprecated boolean DEFAULT false,
    display_order integer DEFAULT 999
);


ALTER TABLE public.info_type OWNER TO de;

--
-- Name: input_output_mapping; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.input_output_mapping (
    mapping_id uuid NOT NULL,
    input uuid,
    external_input character varying(255),
    output uuid,
    external_output character varying(255)
);


ALTER TABLE public.input_output_mapping OWNER TO de;

--
-- Name: instant_launches; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.instant_launches (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    quick_launch_id uuid NOT NULL,
    added_by uuid NOT NULL,
    added_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.instant_launches OWNER TO de;

--
-- Name: interactive_apps_proxy_settings; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.interactive_apps_proxy_settings (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    image text NOT NULL,
    name text NOT NULL,
    frontend_url text,
    cas_url text,
    cas_validate text,
    ssl_cert_path text,
    ssl_key_path text
);


ALTER TABLE public.interactive_apps_proxy_settings OWNER TO de;

--
-- Name: job_limits; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.job_limits (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    launcher text,
    concurrent_jobs integer NOT NULL
);


ALTER TABLE public.job_limits OWNER TO de;

--
-- Name: job_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.job_types (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(36) NOT NULL,
    system_id character varying(36) NOT NULL
);


ALTER TABLE public.job_types OWNER TO de;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.jobs (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    job_name character varying(255) NOT NULL,
    job_description text DEFAULT ''::text,
    app_name character varying(255),
    job_type_id uuid NOT NULL,
    app_id character varying(255),
    app_wiki_url text,
    app_description text,
    result_folder_path text,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    planned_end_date timestamp without time zone,
    status character varying(64) NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    notify boolean DEFAULT false NOT NULL,
    user_id uuid NOT NULL,
    subdomain character varying(32),
    submission json,
    parent_id uuid
);


ALTER TABLE public.jobs OWNER TO de;

--
-- Name: job_listings; Type: VIEW; Schema: public; Owner: de
--

CREATE VIEW public.job_listings AS
 SELECT j.id,
    j.job_name,
    j.app_name,
    j.start_date,
    j.end_date,
    j.status,
    j.deleted,
    j.notify,
    u.username,
    j.job_description,
    j.app_id,
    j.app_wiki_url,
    j.app_description,
    j.result_folder_path,
    j.submission,
    t.name AS job_type,
    j.parent_id,
    (EXISTS ( SELECT child.id,
            child.job_name,
            child.job_description,
            child.app_name,
            child.job_type_id,
            child.app_id,
            child.app_wiki_url,
            child.app_description,
            child.result_folder_path,
            child.start_date,
            child.end_date,
            child.planned_end_date,
            child.status,
            child.deleted,
            child.notify,
            child.user_id,
            child.subdomain,
            child.submission,
            child.parent_id
           FROM public.jobs child
          WHERE (child.parent_id = j.id))) AS is_batch,
    t.system_id,
    j.planned_end_date,
    j.user_id
   FROM ((public.jobs j
     JOIN public.users u ON ((j.user_id = u.id)))
     JOIN public.job_types t ON ((j.job_type_id = t.id)));


ALTER TABLE public.job_listings OWNER TO de;

--
-- Name: job_status_updates; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.job_status_updates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    external_id character varying(64) NOT NULL,
    message text NOT NULL,
    status text NOT NULL,
    sent_from inet NOT NULL,
    sent_from_hostname text NOT NULL,
    sent_on bigint NOT NULL,
    propagated boolean DEFAULT false NOT NULL,
    propagation_attempts bigint DEFAULT 0 NOT NULL,
    last_propagation_attempt bigint,
    created_date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.job_status_updates OWNER TO de;

--
-- Name: job_steps; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.job_steps (
    job_id uuid NOT NULL,
    step_number integer NOT NULL,
    external_id character varying(64),
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    status character varying(64) NOT NULL,
    job_type_id uuid NOT NULL,
    app_step_number integer NOT NULL
);


ALTER TABLE public.job_steps OWNER TO de;

--
-- Name: job_tickets; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.job_tickets (
    job_id uuid NOT NULL,
    ticket character varying(100) NOT NULL,
    irods_path text NOT NULL,
    deleted boolean DEFAULT false
);


ALTER TABLE public.job_tickets OWNER TO de;

--
-- Name: logins; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.logins (
    user_id uuid NOT NULL,
    ip_address character varying(15),
    user_agent text,
    login_time timestamp without time zone DEFAULT now() NOT NULL,
    logout_time timestamp without time zone
);


ALTER TABLE public.logins OWNER TO de;

--
-- Name: notif_statuses; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.notif_statuses (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    analysis_id uuid NOT NULL,
    external_id uuid NOT NULL,
    hour_warning_sent boolean DEFAULT false NOT NULL,
    day_warning_sent boolean DEFAULT false NOT NULL,
    kill_warning_sent boolean DEFAULT false NOT NULL,
    hour_warning_failure_count integer DEFAULT 0 NOT NULL,
    day_warning_failure_count integer DEFAULT 0 NOT NULL,
    kill_warning_failure_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.notif_statuses OWNER TO de;

--
-- Name: parameter_groups; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.parameter_groups (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    task_id uuid NOT NULL,
    name character varying(255),
    description text,
    label character varying(255) NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    is_visible boolean DEFAULT true
);


ALTER TABLE public.parameter_groups OWNER TO de;

--
-- Name: parameter_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.parameter_types (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    label character varying(255),
    deprecated boolean DEFAULT false,
    hidable boolean DEFAULT false,
    display_order integer DEFAULT 999,
    value_type_id uuid
);


ALTER TABLE public.parameter_types OWNER TO de;

--
-- Name: parameter_values; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.parameter_values (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    parameter_id uuid NOT NULL,
    parent_id uuid,
    is_default boolean DEFAULT false NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    name character varying(255),
    value character varying(255),
    description text,
    label text
);


ALTER TABLE public.parameter_values OWNER TO de;

--
-- Name: parameters; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.parameters (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    parameter_group_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    label text,
    is_visible boolean DEFAULT true,
    ordering integer DEFAULT 0,
    display_order integer DEFAULT 0 NOT NULL,
    parameter_type uuid NOT NULL,
    required boolean DEFAULT false,
    omit_if_blank boolean DEFAULT true
);


ALTER TABLE public.parameters OWNER TO de;

--
-- Name: quick_launch_favorites; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.quick_launch_favorites (
    id uuid NOT NULL,
    quick_launch_id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.quick_launch_favorites OWNER TO de;

--
-- Name: quick_launch_global_defaults; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.quick_launch_global_defaults (
    id uuid NOT NULL,
    app_id uuid NOT NULL,
    quick_launch_id uuid NOT NULL
);


ALTER TABLE public.quick_launch_global_defaults OWNER TO de;

--
-- Name: quick_launch_user_defaults; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.quick_launch_user_defaults (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    app_id uuid NOT NULL,
    quick_launch_id uuid NOT NULL
);


ALTER TABLE public.quick_launch_user_defaults OWNER TO de;

--
-- Name: quick_launches; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.quick_launches (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    creator uuid NOT NULL,
    submission_id uuid NOT NULL,
    app_id uuid NOT NULL,
    is_public boolean DEFAULT false NOT NULL
);


ALTER TABLE public.quick_launches OWNER TO de;

--
-- Name: rating_listing; Type: VIEW; Schema: public; Owner: de
--

CREATE VIEW public.rating_listing AS
 SELECT row_number() OVER (ORDER BY a.id, u.id) AS id,
    a.id AS app_id,
    u.id AS user_id,
    ur.comment_id,
    ur.rating AS user_rating
   FROM ((public.ratings ur
     JOIN public.users u ON ((ur.user_id = u.id)))
     JOIN public.apps a ON ((a.id = ur.app_id)));


ALTER TABLE public.rating_listing OWNER TO de;

--
-- Name: request_status_codes; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.request_status_codes (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    email_template text NOT NULL
);


ALTER TABLE public.request_status_codes OWNER TO de;

--
-- Name: request_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.request_types (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.request_types OWNER TO de;

--
-- Name: request_updates; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.request_updates (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    request_id uuid NOT NULL,
    request_status_code_id uuid NOT NULL,
    updating_user_id uuid NOT NULL,
    created_date timestamp without time zone DEFAULT now() NOT NULL,
    message text
);


ALTER TABLE public.request_updates OWNER TO de;

--
-- Name: requests; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.requests (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    request_type_id uuid NOT NULL,
    requesting_user_id uuid NOT NULL,
    details json NOT NULL
);


ALTER TABLE public.requests OWNER TO de;

--
-- Name: rule_subtype; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.rule_subtype (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(40) NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.rule_subtype OWNER TO de;

--
-- Name: rule_type; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.rule_type (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    label character varying(255),
    deprecated boolean DEFAULT false,
    display_order integer DEFAULT 999,
    rule_description_format character varying(255) DEFAULT ''::character varying,
    rule_subtype_id uuid NOT NULL
);


ALTER TABLE public.rule_type OWNER TO de;

--
-- Name: rule_type_value_type; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.rule_type_value_type (
    rule_type_id uuid NOT NULL,
    value_type_id uuid NOT NULL
);


ALTER TABLE public.rule_type_value_type OWNER TO de;

--
-- Name: session; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.session OWNER TO de;

--
-- Name: submissions; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.submissions (
    id uuid NOT NULL,
    submission json NOT NULL
);


ALTER TABLE public.submissions OWNER TO de;

--
-- Name: suggested_groups; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.suggested_groups (
    app_id uuid NOT NULL,
    app_category_id uuid NOT NULL
);


ALTER TABLE public.suggested_groups OWNER TO de;

--
-- Name: value_type; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.value_type (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(40) NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.value_type OWNER TO de;

--
-- Name: task_param_listing; Type: VIEW; Schema: public; Owner: de
--

CREATE VIEW public.task_param_listing AS
 SELECT t.id AS task_id,
    p.parameter_group_id,
    p.id,
    p.name,
    p.label,
    p.description,
    p.ordering,
    p.display_order,
    p.required,
    p.omit_if_blank,
    p.is_visible,
    pt.name AS parameter_type,
    vt.name AS value_type,
    f.retain,
    f.is_implicit,
    f.repeat_option_flag,
    it.name AS info_type,
    df.name AS data_format,
    ds.name AS data_source
   FROM ((((((((public.parameters p
     JOIN public.parameter_types pt ON ((pt.id = p.parameter_type)))
     JOIN public.value_type vt ON ((vt.id = pt.value_type_id)))
     LEFT JOIN public.file_parameters f ON ((f.parameter_id = p.id)))
     LEFT JOIN public.info_type it ON ((f.info_type = it.id)))
     LEFT JOIN public.data_formats df ON ((f.data_format = df.id)))
     LEFT JOIN public.data_source ds ON ((f.data_source_id = ds.id)))
     JOIN public.parameter_groups g ON ((g.id = p.parameter_group_id)))
     JOIN public.tasks t ON ((t.id = g.task_id)));


ALTER TABLE public.task_param_listing OWNER TO de;

--
-- Name: tool_architectures; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tool_architectures (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.tool_architectures OWNER TO de;

--
-- Name: tool_listing; Type: VIEW; Schema: public; Owner: de
--

CREATE VIEW public.tool_listing AS
 SELECT row_number() OVER (ORDER BY apps.id, steps.step) AS id,
    apps.id AS app_id,
    apps.is_public,
    steps.step AS execution_order,
    tool.id AS tool_id,
    tool.name,
    tool.description,
    tool.location,
    tt.name AS type,
    tt.hidden,
    tool.version,
    tool.attribution,
    tool.container_images_id
   FROM ((((public.app_listing apps
     JOIN public.app_steps steps ON ((apps.id = steps.app_id)))
     JOIN public.tasks t ON ((steps.task_id = t.id)))
     JOIN public.tools tool ON ((t.tool_id = tool.id)))
     JOIN public.tool_types tt ON ((tool.tool_type_id = tt.id)));


ALTER TABLE public.tool_listing OWNER TO de;

--
-- Name: tool_request_status_codes; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tool_request_status_codes (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    email_template character varying(64)
);


ALTER TABLE public.tool_request_status_codes OWNER TO de;

--
-- Name: tool_request_statuses; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tool_request_statuses (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    tool_request_id uuid NOT NULL,
    tool_request_status_code_id uuid NOT NULL,
    date_assigned timestamp without time zone DEFAULT now() NOT NULL,
    updater_id uuid NOT NULL,
    comments text
);


ALTER TABLE public.tool_request_statuses OWNER TO de;

--
-- Name: tool_requests; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tool_requests (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    requestor_id uuid NOT NULL,
    phone character varying(30),
    tool_name character varying(255) NOT NULL,
    description text NOT NULL,
    source_url text NOT NULL,
    doc_url text NOT NULL,
    version character varying(255) NOT NULL,
    attribution text NOT NULL,
    multithreaded boolean,
    tool_architecture_id uuid NOT NULL,
    test_data_path text NOT NULL,
    instructions text NOT NULL,
    additional_info text,
    additional_data_file text,
    tool_id uuid
);


ALTER TABLE public.tool_requests OWNER TO de;

--
-- Name: tool_test_data_files; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tool_test_data_files (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    filename character varying(1024) NOT NULL,
    input_file boolean DEFAULT true,
    tool_id uuid NOT NULL
);


ALTER TABLE public.tool_test_data_files OWNER TO de;

--
-- Name: tool_type_parameter_type; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tool_type_parameter_type (
    tool_type_id uuid NOT NULL,
    parameter_type_id uuid NOT NULL
);


ALTER TABLE public.tool_type_parameter_type OWNER TO de;

--
-- Name: tree_urls; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tree_urls (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    sha1 character varying(40) NOT NULL,
    tree_urls text NOT NULL
);


ALTER TABLE public.tree_urls OWNER TO de;

--
-- Name: user_instant_launches; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.user_instant_launches (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    version integer NOT NULL,
    user_id uuid NOT NULL,
    instant_launches jsonb DEFAULT '{}'::jsonb NOT NULL,
    added_by uuid NOT NULL,
    added_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_instant_launches OWNER TO de;

--
-- Name: user_instant_launches_version_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.user_instant_launches_version_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_instant_launches_version_seq OWNER TO de;

--
-- Name: user_instant_launches_version_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: de
--

ALTER SEQUENCE public.user_instant_launches_version_seq OWNED BY public.user_instant_launches.version;


--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.user_preferences (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    user_id uuid NOT NULL,
    preferences text NOT NULL
);


ALTER TABLE public.user_preferences OWNER TO de;

--
-- Name: user_saved_searches; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.user_saved_searches (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    user_id uuid NOT NULL,
    saved_searches text NOT NULL
);


ALTER TABLE public.user_saved_searches OWNER TO de;

--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.user_sessions (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    user_id uuid NOT NULL,
    session text NOT NULL
);


ALTER TABLE public.user_sessions OWNER TO de;

--
-- Name: validation_rule_argument_definitions; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.validation_rule_argument_definitions (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    rule_type_id uuid NOT NULL,
    argument_index integer NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    argument_type_id uuid NOT NULL
);


ALTER TABLE public.validation_rule_argument_definitions OWNER TO de;

--
-- Name: validation_rule_argument_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.validation_rule_argument_types (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.validation_rule_argument_types OWNER TO de;

--
-- Name: validation_rule_arguments; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.validation_rule_arguments (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    rule_id uuid NOT NULL,
    ordering integer DEFAULT 0,
    argument_value text
);


ALTER TABLE public.validation_rule_arguments OWNER TO de;

--
-- Name: validation_rules; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.validation_rules (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    parameter_id uuid NOT NULL,
    rule_type uuid NOT NULL
);


ALTER TABLE public.validation_rules OWNER TO de;

--
-- Name: version; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.version (
    version character varying(20) NOT NULL,
    applied timestamp without time zone DEFAULT now()
);


ALTER TABLE public.version OWNER TO de;

--
-- Name: vice_analyses; Type: VIEW; Schema: public; Owner: de
--

CREATE VIEW public.vice_analyses AS
 SELECT j.id,
    j.job_name,
    j.app_name,
    j.subdomain,
    j.start_date,
    j.end_date,
    j.status,
    u.id AS user_id,
    u.username,
    j.job_description,
    j.app_id,
    j.result_folder_path,
    j.planned_end_date,
    a.description AS app_description,
    a.edited_date AS app_edited_date,
    l.id AS tool_id,
    l.name AS tool_name,
    l.description AS tool_description,
    l.version AS tool_version,
    c.working_directory,
    c.entrypoint,
    c.uid,
    c.min_cpu_cores,
    c.max_cpu_cores,
    c.memory_limit,
    c.pids_limit,
    c.skip_tmp_mount,
    p.container_port,
    i.id AS image_id,
    i.name AS image_name,
    i.tag AS image_tag,
    i.url AS image_url,
    s.step
   FROM ((((((((public.jobs j
     JOIN public.users u ON ((j.user_id = u.id)))
     JOIN public.apps a ON (((j.app_id)::text = ((a.id)::character varying)::text)))
     JOIN public.app_steps s ON ((a.id = s.app_id)))
     JOIN public.tasks k ON ((s.task_id = k.id)))
     JOIN public.tools l ON ((k.tool_id = l.id)))
     JOIN public.container_settings c ON ((l.id = c.tools_id)))
     JOIN public.container_images i ON ((l.container_images_id = i.id)))
     JOIN public.container_ports p ON ((c.id = p.container_settings_id)))
  WHERE ((j.deleted = false) AND (l.interactive = true))
  ORDER BY s.step;


ALTER TABLE public.vice_analyses OWNER TO de;

--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.webhooks (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    user_id uuid NOT NULL,
    url text NOT NULL,
    type_id uuid NOT NULL
);


ALTER TABLE public.webhooks OWNER TO de;

--
-- Name: webhooks_subscription; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.webhooks_subscription (
    webhook_id uuid NOT NULL,
    topic_id uuid NOT NULL
);


ALTER TABLE public.webhooks_subscription OWNER TO de;

--
-- Name: webhooks_topic; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.webhooks_topic (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    topic character varying(1024) NOT NULL
);


ALTER TABLE public.webhooks_topic OWNER TO de;

--
-- Name: webhooks_type; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.webhooks_type (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    type character varying(1024) NOT NULL,
    template text NOT NULL
);


ALTER TABLE public.webhooks_type OWNER TO de;

--
-- Name: workflow_io_maps; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.workflow_io_maps (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    app_id uuid NOT NULL,
    target_step uuid NOT NULL,
    source_step uuid NOT NULL
);


ALTER TABLE public.workflow_io_maps OWNER TO de;

--
-- Name: default_instant_launches version; Type: DEFAULT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_instant_launches ALTER COLUMN version SET DEFAULT nextval('public.default_instant_launches_version_seq'::regclass);


--
-- Name: user_instant_launches version; Type: DEFAULT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_instant_launches ALTER COLUMN version SET DEFAULT nextval('public.user_instant_launches_version_seq'::regclass);


--
-- Data for Name: access_tokens; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.access_tokens (webapp, user_id, token, expires_at, refresh_token) FROM stdin;
\.


--
-- Data for Name: app_categories; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_categories (id, name, description, workspace_id) FROM stdin;
12c7a585-ec23-3352-e313-02e323112a7c	Public Apps		00000000-0000-0000-0000-000000000000
5401bd14-6c14-4470-aedd-57b47ea1b979	Beta		00000000-0000-0000-0000-000000000000
\.


--
-- Data for Name: app_category_app; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_category_app (app_category_id, app_id) FROM stdin;
5401bd14-6c14-4470-aedd-57b47ea1b979	67d15627-22c5-42bd-8daf-9af5deecceab
5401bd14-6c14-4470-aedd-57b47ea1b979	336bbfb3-7899-493a-b4a2-ed3bc353ead8
\.


--
-- Data for Name: app_category_group; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_category_group (parent_category_id, child_category_id, child_index) FROM stdin;
12c7a585-ec23-3352-e313-02e323112a7c	5401bd14-6c14-4470-aedd-57b47ea1b979	0
\.


--
-- Data for Name: app_documentation; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_documentation (app_id, value, created_on, modified_on, created_by, modified_by) FROM stdin;
\.


--
-- Data for Name: app_hierarchy_version; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_hierarchy_version (version, applied_by, applied) FROM stdin;
\.


--
-- Data for Name: app_publication_request_status_codes; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_publication_request_status_codes (id, name, description, email_template) FROM stdin;
1fb4295b-684e-4657-afab-6cc0912312b1	Submitted	The request has been submitted, but not acted upon by the support team.	\N
046c9445-9070-4ccd-a2e9-66ee23124ce8	Completion	The app has been made available for public use.	app_publication_completion
\.


--
-- Data for Name: app_publication_request_statuses; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_publication_request_statuses (id, app_publication_request_id, app_publication_request_status_code_id, date_assigned, updater_id, comments) FROM stdin;
\.


--
-- Data for Name: app_publication_requests; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_publication_requests (id, requestor_id, app_id) FROM stdin;
\.


--
-- Data for Name: app_references; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_references (id, app_id, reference_text) FROM stdin;
\.


--
-- Data for Name: app_steps; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.app_steps (id, app_id, task_id, step) FROM stdin;
ee78deb5-ebbb-4d9d-8dcf-8dfe457a7856	1e8f719b-0452-4d39-a2f3-8714793ee3e6	212c5980-9a56-417e-a8c6-394ac445ca4d	0
089a61a0-23d9-4021-9354-a8498ef3ff19	67d15627-22c5-42bd-8daf-9af5deecceab	1ac31629-231a-4090-b3b4-63ee078a0c37	0
b34736a8-aa68-4845-803d-c0d1942ccdff	336bbfb3-7899-493a-b4a2-ed3bc353ead8	66b59035-6036-46c3-a30a-ee3bd4af47b6	0
\.


--
-- Data for Name: apps; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.apps (id, name, description, deleted, disabled, integration_data_id, wiki_url, integration_date, edited_date) FROM stdin;
1e8f719b-0452-4d39-a2f3-8714793ee3e6	Url Import	A Go tool for DE URL imports	f	f	3c533526-2390-11ec-9fc1-0242ac110002		2021-10-02 16:51:30.802362	\N
67d15627-22c5-42bd-8daf-9af5deecceab	DE Word Count	Counts the number of words in a file	f	f	3c535984-2390-11ec-9fc1-0242ac110002		2021-10-02 16:51:30.802362	\N
336bbfb3-7899-493a-b4a2-ed3bc353ead8	Python 2.7	Runs an arbitrary Python script with a time limit of 4 hours, a 1GB RAM limit, a 10% cpu share, and no networking. Accepts a script and a data file as inputs.	f	f	3c535984-2390-11ec-9fc1-0242ac110002		2021-10-02 16:51:30.802362	\N
\.


--
-- Data for Name: apps_htcondor_extra; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.apps_htcondor_extra (apps_id, extra_requirements) FROM stdin;
\.


--
-- Data for Name: async_task_behavior; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.async_task_behavior (async_task_id, behavior_type, data) FROM stdin;
\.


--
-- Data for Name: async_task_status; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.async_task_status (async_task_id, status, detail, created_date) FROM stdin;
\.


--
-- Data for Name: async_tasks; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.async_tasks (id, type, username, data, start_date, end_date) FROM stdin;
\.


--
-- Data for Name: authorization_requests; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.authorization_requests (id, user_id, state_info) FROM stdin;
\.


--
-- Data for Name: bags; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.bags (id, user_id, contents) FROM stdin;
\.


--
-- Data for Name: container_devices; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.container_devices (id, container_settings_id, host_path, container_path) FROM stdin;
\.


--
-- Data for Name: container_images; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.container_images (id, name, tag, url, deprecated, osg_image_path) FROM stdin;
15959300-b972-4571-ace2-081af0909599	discoenv/url-import	latest	https://registry.hub.docker.com/u/discoenv/url-import/	f	\N
fc210a84-f7cd-4067-939c-a68ec3e3bd2b	docker.cyverse.org/backwards-compat	latest	https://registry.hub.docker.com/u/discoenv/backwards-compat	t	\N
bad7e301-4442-4e82-8cc4-8db681cae364	python	2.7	https://hub.docker.com/_/python/	f	\N
\.


--
-- Data for Name: container_ports; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.container_ports (id, container_settings_id, host_port, container_port, bind_to_host) FROM stdin;
\.


--
-- Data for Name: container_settings; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.container_settings (id, tools_id, interactive_apps_proxy_settings_id, pids_limit, cpu_shares, memory_limit, min_memory_limit, min_cpu_cores, max_cpu_cores, min_disk_space, network_mode, working_directory, name, entrypoint, skip_tmp_mount, uid) FROM stdin;
3c582770-2390-11ec-9fc1-0242ac110002	681251ef-ee59-4fe9-9436-dc8a23feb11a	\N	\N	\N	\N	\N	\N	\N	\N	bridge	\N	\N	\N	f	\N
3c5888aa-2390-11ec-9fc1-0242ac110002	85cf7a33-386b-46fe-87c7-8c9d59972624	\N	\N	\N	\N	\N	\N	\N	\N	none	\N	\N	wc	f	\N
3c5cc78a-2390-11ec-9fc1-0242ac110002	4e3b1710-0f15-491f-aca9-812335356fdb	\N	\N	102	1000000000	\N	\N	\N	\N	none	\N	\N	python	f	\N
\.


--
-- Data for Name: container_volumes; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.container_volumes (id, container_settings_id, host_path, container_path) FROM stdin;
\.


--
-- Data for Name: container_volumes_from; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.container_volumes_from (id, data_containers_id, container_settings_id) FROM stdin;
3c597080-2390-11ec-9fc1-0242ac110002	115584ad-7bc3-4601-89a2-85a4e5b5f6a4	3c5888aa-2390-11ec-9fc1-0242ac110002
\.


--
-- Data for Name: data_containers; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.data_containers (id, name_prefix, container_images_id, read_only) FROM stdin;
115584ad-7bc3-4601-89a2-85a4e5b5f6a4	wc-data	15959300-b972-4571-ace2-081af0909599	t
\.


--
-- Data for Name: data_formats; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.data_formats (id, name, label, display_order) FROM stdin;
9e2f6f6b-8c7c-42a6-b6ff-2cca8dfff342	ASN-0	Genbank ASN1	999
6c4d09b3-0108-4dd3-857a-8225e0645a0a	Barcode-0	FASTX toolkit barcode file	999
ab391836-9a4d-4ee3-89ba-9da9cdd28255	CSV-0	Comma-separated values	999
ebf3b544-fc03-4fdf-8c02-49cef60b0fd6	EMBL-0	EMBL multiple sequence alignment	999
fa6554cf-38c0-4f6e-993c-1bb080c637fa	FAI-0	Samtools Fasta Index (FAI)	999
18fdae69-750c-421e-b43b-5724455dac8b	FASTA-0	FASTA	999
6fedea87-6e73-490a-a4e3-3a337085402c	FASTQ-0	FASTQ (Sanger)	999
b0754d3f-417b-49b3-ae2b-75339c4c392a	FASTQ-Illumina-0	FASTQ (Illumina 1.3+)	999
06db90d6-422a-4df3-8da5-adb75bc58b65	FASTQ-Int-0	FASTQ-Integer sequence file	999
faddc788-fb75-434d-9820-721292adf3b6	FASTQ-Solexa-0	FASTQ (Solexa)	999
6ddd55c6-21c7-4e0a-b0ff-2ac1e24e9762	Genbank-0	Genbank	999
15f121d1-7885-46f4-b2a9-32af7ef5ddaa	PDB-3.2	Protein Data Bank (PDB)	999
a84da1b1-d515-44b8-8b01-afdd660e0b77	Pileup-0	Pileup	999
f3a3e9eb-e46f-49cc-a61c-24db6ee964c4	SAI-0.1.2	SAM index	999
13cc9a49-e3e9-4b36-9436-782323f686e0	SAM-0.1.2	SAM	999
8068b37a-0921-4f34-9272-e5fc93d8f64b	SBML-1.2	Systems Biology Markup Language (Level 1, Version 2)	999
8bc057ea-c33d-476f-82f4-61c960bee223	SBML-2.4.1	Systems Biology Markup Language (Level 2, Version 4, Release 1)	999
e79fd13b-b82e-431d-83b6-95b3dc16dcbe	SBML-3.1	Systems Biology Markup Language (Level 3, Version 1 Core)	999
1810a7af-094f-4470-8677-42e217ccef4e	TAB-0	Tab-delimited text	999
158e6939-61e2-4297-8049-42ad77b32e51	Text-0	Plain text	999
6f7eeec5-cee5-4562-8515-2795c2399328	VCF-3.3	Variant call format (VCF)	999
70e56c3c-50eb-41a7-a98c-165a9cd55ee7	VCF-4.0	Variant call format (VCF)	999
fa730ba6-f6fa-479e-abf4-e56f4d37d4e7	WIG-0	UCSC Wiggle	999
e806880b-383d-4ad6-a4ab-8cdd88810a33	Unspecified	Unspecified Data Format	1
\.


--
-- Data for Name: data_source; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.data_source (id, name, label, description, display_order) FROM stdin;
8d6b8247-f1e7-49db-9ffe-13ead7c1aed6	file	File	A regular file.	1
1eeecf26-367a-4038-8d19-93ea80741df2	stdout	Standard Output	Redirected standard output from a job.	2
bc4cf23f-18b9-4466-af54-9d40f0e2f6b5	stderr	Standard Error Output	Redirected error output from a job.	3
\.


--
-- Data for Name: default_bags; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.default_bags (user_id, bag_id) FROM stdin;
\.


--
-- Data for Name: default_instant_launches; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.default_instant_launches (id, version, instant_launches, added_by, added_on) FROM stdin;
\.


--
-- Name: default_instant_launches_version_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.default_instant_launches_version_seq', 1, false);


--
-- Data for Name: docker_registries; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.docker_registries (name, username, password) FROM stdin;
\.


--
-- Data for Name: file_parameters; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.file_parameters (id, parameter_id, retain, is_implicit, repeat_option_flag, info_type, data_format, data_source_id) FROM stdin;
75288de6-323d-44ca-befa-8e14dae109e4	1dd009b1-ce1e-4933-aba8-66314757288b	t	f	t	0900e992-3bbd-4f4b-8d2d-ed289ca4e4f1	e806880b-383d-4ad6-a4ab-8cdd88810a33	8d6b8247-f1e7-49db-9ffe-13ead7c1aed6
a350604d-48a0-4083-b6b3-425f3b1f7f51	13914010-89cd-406d-99c3-9c4ff8b023c3	t	f	t	0900e992-3bbd-4f4b-8d2d-ed289ca4e4f1	e806880b-383d-4ad6-a4ab-8cdd88810a33	8d6b8247-f1e7-49db-9ffe-13ead7c1aed6
78244fb8-d5bb-479b-b73e-a12c20dbb774	5e1339f0-e01a-4fa3-8546-f7f16af547bf	t	f	t	0900e992-3bbd-4f4b-8d2d-ed289ca4e4f1	e806880b-383d-4ad6-a4ab-8cdd88810a33	8d6b8247-f1e7-49db-9ffe-13ead7c1aed6
73ec6e74-d5e6-4977-b999-620b4e79ebda	41d1a467-17fa-4b25-ba5e-43c8cb88948b	t	f	t	0900e992-3bbd-4f4b-8d2d-ed289ca4e4f1	e806880b-383d-4ad6-a4ab-8cdd88810a33	8d6b8247-f1e7-49db-9ffe-13ead7c1aed6
\.


--
-- Data for Name: genome_reference; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.genome_reference (id, name, path, deleted, created_by, created_on, last_modified_by, last_modified_on) FROM stdin;
4bb9856a-43da-4f67-bdf9-f90916b4c11f	Arabidopsis lyrata (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Arabidopsis_lyrata.1.0/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
18027404-d09f-41bf-99a4-74197ce0e7bf	Rattus norvegicus [Rat] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Rattus_norvegicus.RGSC3.4/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
2b1154f3-6c10-4707-a5ea-50d6eb890582	Zea mays [Maize] (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Zea_mays.AGPv2/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
e38b6fae-2e4b-4217-8c1f-6badea3ff7fc	Canis familiaris [Dog] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Canis_familiaris.BROAD2/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
72facaa7-ba29-49ee-b184-42ba3c015ca4	Equus caballus [Horse] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Equus_caballus.EquCab2/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
e21e71f2-219f-4704-a8a6-9ab487a759a6	Oryza brachyantha (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Oryza_brachyantha.v1.4b/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
9875f6cc-0503-418b-b5cc-8cb8dd44d56d	Setaria italica [Foxtail millet] (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Setaria_italica.JGIv2.0/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
46f9d53d-36b6-4bd9-b4f2-ff952833103f	Oryza indica (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Oryza_indica.ASM465v1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
2d748e14-47f5-4a91-bc67-214787ad0843	Chlamydomonas reinhardtii (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Chlamydomonas_reinhardtii.v3.0/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
ef269f1a-e561-4f0c-92b7-3d9d8e7362f3	Drosophila melanogaster [Fruitfly] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Drosophila_melanogaster.BGDP5/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
8af62f2b-15fc-4f36-ae04-c6b801d98c1b	Vitis vinifera [Grape] (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Vitis_vinifera.IGPP_12x/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
2c967e76-9b8a-4a3b-aa30-2e7de3a0a952	Sorghum bicolor [Sorghum] (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Sorghum_bicolor.Sorbi1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
58a84f5e-3922-43dc-8414-e42b1513be78	Physcomitrella patens (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Physcomitrella_patens.AMS242v1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
c4dadc23-e0d2-481c-a3d1-1f5067e6528e	Gallus gallus [Chicken] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Gallus_gallus.WASHUC2/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
4fce9ee9-0471-436b-938d-2e1820a71e6c	Homo sapiens [Human] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Homo_sapiens.GRCh37/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
f772929d-0ba3-4432-8623-7a74bf2720aa	Meleagris gallopavo [Turkey] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Meleagris_gallopavo.UMD2/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
ba3d662f-0f71-45fa-83a3-7a80b9bb2b3f	Xenopus tropicalis [Xenopus] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Xenopus_tropicalis.JGI_4.2/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
41149e71-4328-4391-b1d2-25fdbdca5a54	Felis catus [Cat] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Felis_catus.CAT/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
bb5317ce-ad00-466b-8109-432c117c0781	Sus scrofa [Pig] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Sus_scrofa.Sscrofa10.2/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
eb059ac7-ee82-421a-bbc1-12f117366c4a	Danio rerio [Zebrafish] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Danio_rerio.Zv9/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
a55701bc-44e6-4661-bc3a-888ca1febaed	Pan troglodytes [Chimp] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Pan_troglodytes.CHIMP2.1.4/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
6149be1b-7aaa-43b4-84df-de2567ab9489	Mus musculus [Mouse] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Mus_musculus.NCBIM37/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
ca94864b-b5a3-49a7-9638-0d57715a301d	Brassica rapa (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Brassica_rapa.IVFCAASv1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
826f0934-69a5-401d-8b5f-36da33fc520e	Glycine max [Soybean] (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Glycine_max.V1.0/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
80aa0d1a-f32c-439a-940d-c9a6d629ed43	Populus trichocarpa [Poplar] (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Populus_trichocarpa.JGI2.0/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
756adb31-72f4-487f-ba95-c5bcca7b13b5	Caenorhabditis elegans [C. elegans] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Caenorhabditis_elegans.WBcel215/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
7f66a989-9bb6-42c4-9db3-0e316304c93e	Arabidopsis thaliana (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Arabidopsis_thaliana.TAIR10/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
999a1d22-d2d8-4845-b685-da6403e9016e	Cyanidioschyzon merolae (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Cyanidioschyzon_merolae.ASM9120v1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
8683bbe8-c577-42f8-8d9b-1bdd861122ae	Brachypodium distachyon (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Brachypodium_distachyon.1.0/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
e4785abc-f1e7-4d71-9ae6-bff4f2b4613b	Oreochromis niloticus [Tilapia] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Oreochromis_niloticus.Orenil1.0/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
72de2532-bdf6-46b3-bffa-6c4860d63813	Bos taurus [Cow] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Bos_taurus.UMD3.1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
f3197615-747d-44c6-bd5f-293cbde95bab	Gadus morhua [Cod] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Gadus_morhua.gadMor1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
bdc96014-9b89-4dbc-9376-bc4805d9c1dd	Selaginella moellendorffii (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Selaginella_moellendorffii.v1.0/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
1e1c62e5-bd56-4cfa-b3ab-aa6a1496d3e5	Solanum lycopersicum [Tomato] (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Solanum_lycopersicum.SL2.40/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
0876c503-9634-488b-9584-ac6c0d565b8d	Oryza sativa [Rice] (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Oryza_sativa.MSU6/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
ea2e3413-924e-4de3-b012-05d906dd5d4a	Caenorhabditis elegans [C. elegans] (Ensembl 66)	/data2/collections/genomeservices/0.2.1/Caenorhabditis_elegans.WS220/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
443befdd-c7ed-4b33-ac67-56a6748d7a48	Tursiops truncatus [Dolphin] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Tursiops_truncatus.turTru1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
70a34bd3-a7a4-4c7e-8ff5-36335b3f9b57	Saccharomyces cerevisiae [Yeast] (Ensembl 67)	/data2/collections/genomeservices/0.2.1/Saccharomyces_cerevisiae.EF4/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
7e5eff7b-35fa-4635-806c-06ef5ef50db4	Oryza glaberrima (Ensembl 14)	/data2/collections/genomeservices/0.2.1/Oryza_glaberrima.AGI1.1/de_support/	f	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362	00000000-0000-0000-0000-000000000000	2021-10-02 16:51:30.802362
\.


--
-- Data for Name: info_type; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.info_type (id, name, label, description, deprecated, display_order) FROM stdin;
212907c0-736e-4dbe-b6e7-5dc0431c275f	ReconcileTaxa	Reconciled Taxonomy Information	\N	f	999
0e3343e3-c59a-44c4-b5ee-d4501ec3a898	ReferenceGenome	Reference Sequence and Annotations	\N	f	999
57eb7fb6-bdc0-42aa-b494-0483f9347815	ReferenceSequence	Reference Sequence Only	\N	f	999
68246ddf-8b1b-44c0-827f-88945cad8227	ReferenceAnnotation	Reference Annotation Only	\N	f	999
97d8ccf7-7242-4038-942c-235f2291ab6c	ACEField	Reconciled Tree and Trait Information for CACE and DACE	\N	t	999
ca9adde4-ab94-4a40-8c2f-c0b814156298	ContrastField	Reconciled Tree and Trait Informaiton for Independent Contrast	\N	t	999
e819ff9a-7398-4df9-8191-0f5afbbe5ca3	ReferenceDummyGenes	Fake Reference Genome for the Cufflinks Post-Processing Step	\N	t	999
0900e992-3bbd-4f4b-8d2d-ed289ca4e4f1	File	Unspecified	\N	f	1
762e5a0a-afb2-420e-8456-f79c78a29051	SequenceAlignment	Sequence Alignment	\N	f	999
f65a8f23-3e46-4df4-80f9-387641c013a6	MultipleSequenceAlignment	Multiple Sequence Alignment	\N	f	999
4a56f043-c62f-4fe9-a11f-a9a7d18e370f	BarcodeFile	Barcode File	\N	f	999
dd178256-ce77-41b0-a785-7e955799a20d	ExpressionData	Expression Data	\N	f	999
13313a72-ea0a-49df-9105-af798165a482	GenomicAnnotation	Genomic Annotation	\N	f	999
d4089473-139e-4345-9ca9-addcfc4b887e	BiologicalModel	Biological Model	\N	f	999
1c59c759-9cd3-4036-b7b4-82e8da40d0c2	NucleotideOrPeptideSequence	Nucleotide or Peptide Sequence	\N	f	999
3b4fc426-290a-4f63-adb4-75a60a43b420	Structure	Structure	\N	f	999
a378ca30-28c9-4179-8381-ec098a89d12b	TraitFile	Trait File	\N	f	999
7bda7ef9-7b25-43da-93d3-a6c483fd24e4	TreeFile	Tree File	\N	f	999
f1a9ce39-b83d-4820-909e-583f76bc5ebe	VariantData	Variant Data	\N	f	999
f51baae3-4368-4814-bca0-78bad9906445	Archive	Archive	\N	f	999
57bd5ba7-c899-4d50-8676-a3cd56e68f8a	Binary	Binary	\N	f	999
3b07f544-86a6-459e-b46a-ba53e6a37f33	TabularData	Tabular Data	\N	f	999
d433bee7-bfde-4696-a2b8-eb2b92ac0e13	GraphFile	Graph File	\N	f	999
6270ab49-d6b6-4d8c-b15a-89657b4227a4	PlainText	Plain Text	\N	f	999
15696bc7-f712-43f3-9910-150b53272841	StructuredText	Structured Text	\N	f	999
d106c3f9-93b5-4146-aaf0-727a0e8d8a50	Image	Image	\N	f	999
\.


--
-- Data for Name: input_output_mapping; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.input_output_mapping (mapping_id, input, external_input, output, external_output) FROM stdin;
\.


--
-- Data for Name: instant_launches; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.instant_launches (id, quick_launch_id, added_by, added_on) FROM stdin;
\.


--
-- Data for Name: integration_data; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.integration_data (id, integrator_name, integrator_email, user_id) FROM stdin;
3c533526-2390-11ec-9fc1-0242ac110002	Internal DE Tools	support@iplantcollaborative.org	\N
3c535984-2390-11ec-9fc1-0242ac110002	Default DE Tools	support@iplantcollaborative.org	\N
\.


--
-- Data for Name: interactive_apps_proxy_settings; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.interactive_apps_proxy_settings (id, image, name, frontend_url, cas_url, cas_validate, ssl_cert_path, ssl_key_path) FROM stdin;
\.


--
-- Data for Name: job_limits; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.job_limits (id, launcher, concurrent_jobs) FROM stdin;
72dfef9a-f6b1-482e-b2a0-16194247be31	\N	8
\.


--
-- Data for Name: job_status_updates; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.job_status_updates (id, external_id, message, status, sent_from, sent_from_hostname, sent_on, propagated, propagation_attempts, last_propagation_attempt, created_date) FROM stdin;
\.


--
-- Data for Name: job_steps; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.job_steps (job_id, step_number, external_id, start_date, end_date, status, job_type_id, app_step_number) FROM stdin;
\.


--
-- Data for Name: job_tickets; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.job_tickets (job_id, ticket, irods_path, deleted) FROM stdin;
\.


--
-- Data for Name: job_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.job_types (id, name, system_id) FROM stdin;
ad069d9f-e38f-418c-84f6-21f620cade77	DE	de
61433582-a271-4154-b3c5-f4c1d91db2a4	Agave	agave
ead7467a-67c1-4087-90e1-f29ebf2ea084	Interactive	interactive
769ab85c-539c-4f08-a9e7-a565bce9b009	OSG	osg
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.jobs (id, job_name, job_description, app_name, job_type_id, app_id, app_wiki_url, app_description, result_folder_path, start_date, end_date, planned_end_date, status, deleted, notify, user_id, subdomain, submission, parent_id) FROM stdin;
\.


--
-- Data for Name: logins; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.logins (user_id, ip_address, user_agent, login_time, logout_time) FROM stdin;
\.


--
-- Data for Name: notif_statuses; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.notif_statuses (id, analysis_id, external_id, hour_warning_sent, day_warning_sent, kill_warning_sent, hour_warning_failure_count, day_warning_failure_count, kill_warning_failure_count) FROM stdin;
\.


--
-- Data for Name: parameter_groups; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.parameter_groups (id, task_id, name, description, label, display_order, is_visible) FROM stdin;
30345113-d3e5-406b-a4e8-170a685e7a8b	212c5980-9a56-417e-a8c6-394ac445ca4d	Parameters	URL upload parameters	Parameters	0	t
741711b0-0b95-4ac9-98b4-ca58225e76be	1ac31629-231a-4090-b3b4-63ee078a0c37	Parameters	Word count parameters	Parameters	0	t
f252f7b2-5c27-4a27-bbbb-f4f2f2acf407	66b59035-6036-46c3-a30a-ee3bd4af47b6	Parameters	Python 2.7 parameters	Parameters	0	t
\.


--
-- Data for Name: parameter_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.parameter_types (id, name, description, label, deprecated, hidable, display_order, value_type_id) FROM stdin;
2cf37b0d-5463-4aef-98a2-4db63d2f3dbc	ClipperSelector		\N	t	f	999	\N
bea4f078-6296-4511-834a-27b6bc3c88ab	Script		\N	t	f	999	\N
9935e153-5765-4c2e-a2bc-676f88b11267	Mode		\N	t	f	999	\N
553f6a79-329e-470b-b827-ebbf2d2811f1	BarcodeSelector		\N	t	f	999	\N
8d7dfb62-2ba4-4ad1-b38e-068318200d9b	TNRSFileSelector		\N	t	f	999	\N
c5b85c6b-381e-44f6-a568-186f1fe7f03d	Info	Informative static text	\N	f	f	999	0115898a-f81a-4598-b1a8-06e538f1d774
ffeca61a-f1b9-43ba-b6ff-fa77bb34f396	Text	A text box (no caption or number check)	\N	f	t	1	0115898a-f81a-4598-b1a8-06e538f1d774
d2340f11-d260-41b4-93fd-c1d695bf6fef	Number	A text box that checks for valid number input	\N	t	f	999	bcb81292-f01d-45b1-8598-3d6cd745d2e9
f22ca553-856b-4253-b0f3-514701ed4567	QuotedText	A text box that will add quotes for passing string to command line	\N	t	f	999	0115898a-f81a-4598-b1a8-06e538f1d774
206a93d6-bac4-4925-89fe-39c073e85c47	Flag	A checkbox for yes/no selection	\N	f	t	3	e8e05e6c-5002-48c0-9167-c9733f0a9716
babc3c29-39c2-47b5-8576-f3741f9ae329	Selection	A list for selecting a choice (can be text)	\N	t	f	999	0115898a-f81a-4598-b1a8-06e538f1d774
7c71012b-158d-44fd-bda1-a5fb4d43bfd8	ValueSelection	A list for selecting a value (numeric range)	\N	t	f	999	bcb81292-f01d-45b1-8598-3d6cd745d2e9
f03dd9ac-b586-4fe1-a75b-3e2967bd0207	MultiLineText	A multiline text box		f	t	2	0115898a-f81a-4598-b1a8-06e538f1d774
67bdfe81-361e-41fe-852a-35159e1e7bc5	XBasePairs	A text box with caption (x=user specified number)	\N	t	f	999	bcb81292-f01d-45b1-8598-3d6cd745d2e9
871aa217-2e6c-48e2-880a-ee7815e8f7f8	XBasePairsText	A text box with caption (x=user specified text)		t	f	999	0115898a-f81a-4598-b1a8-06e538f1d774
c00ed92f-5399-490c-a6e5-aad0e140d7fe	Input	Input file or folder	\N	t	f	999	94fe4f2b-42f9-4ee7-bc28-f64cc8daf691
f7007237-040d-4253-9323-caa4f71e9795	Output	Output file or folder	\N	f	t	999	65e1e927-a1ed-4e25-bc0c-74c155215973
a024716e-1f18-4af7-b59e-0745786d1b69	EnvironmentVariable	An environment variable that is set before running a job	\N	f	t	9	96de7b1e-fe29-468f-85c0-a9458ce66fb1
548a55c2-53fe-40a5-ad38-033f79c8c0ab	TreeSelection	A hierarchical list for selecting a choice	\N	f	f	10	0115898a-f81a-4598-b1a8-06e538f1d774
c389d80a-f94e-4904-b6ef-bd658a18fc8a	Integer	An integer value.	\N	f	t	4	bcb81292-f01d-45b1-8598-3d6cd745d2e9
01250db2-f8e9-4d9e-b82e-c4713da84068	Double	A real number value.	\N	f	t	5	bcb81292-f01d-45b1-8598-3d6cd745d2e9
c529c00a-8b6f-4b73-80da-c460c09722ed	TextSelection	A list for selecting a textual value.	\N	f	f	6	0115898a-f81a-4598-b1a8-06e538f1d774
0f4e0460-893b-4724-bc7c-d145575b9b73	IntegerSelection	A list for selecting an integer value.	\N	f	f	7	bcb81292-f01d-45b1-8598-3d6cd745d2e9
b8566277-c368-40e9-8b66-bc1c884cf69b	DoubleSelection	A list for selecting a real number value.	\N	f	f	8	bcb81292-f01d-45b1-8598-3d6cd745d2e9
3b3fad4c-691b-44a8-bf34-d406f9052239	FileInput	A control allowing for the selection of a single file.	\N	f	f	11	94fe4f2b-42f9-4ee7-bc28-f64cc8daf691
9633fd4c-5ffc-4471-b531-2ecaaa683e26	FolderInput	A control allowing for the selection of an entire folder.	\N	f	f	12	94fe4f2b-42f9-4ee7-bc28-f64cc8daf691
fd5c9d3e-663d-469c-9455-5ee59621bf0e	MultiFileSelector	A control allowing for the selection of multiple files.	\N	f	f	13	94fe4f2b-42f9-4ee7-bc28-f64cc8daf691
0e2e3be4-18a8-487b-bb27-c96a5a5a141f	FileOutput	A single output file.	\N	f	t	14	65e1e927-a1ed-4e25-bc0c-74c155215973
108011ca-1908-494e-b76f-83bb2ba696d7	FolderOutput	A collection of output files in a single folder.	\N	f	t	15	65e1e927-a1ed-4e25-bc0c-74c155215973
8ef87e50-460f-402a-b5c8-bfbb83211a54	MultiFileOutput	Multiple output files matched by a glob pattern.	\N	f	t	16	65e1e927-a1ed-4e25-bc0c-74c155215973
8f6c59d1-cb29-45fd-834e-a42770c3faa6	ReferenceGenome	A reference genome to use for alignments.	\N	f	t	17	94fe4f2b-42f9-4ee7-bc28-f64cc8daf691
d55c28bf-9f00-44a6-9ced-3db8a46b8b40	ReferenceSequence	A reference sequence file to use for alignments.	\N	f	t	18	94fe4f2b-42f9-4ee7-bc28-f64cc8daf691
b728413e-69eb-435e-a6f5-d00cb1f43daa	ReferenceAnnotation	A reference annotation file to use for alignments.	\N	f	t	19	94fe4f2b-42f9-4ee7-bc28-f64cc8daf691
8031799a-5c4a-46d6-a984-21230cf4a04a	FileFolderInput	An input that can accept either a file or a folder as an input.	\N	f	t	20	94fe4f2b-42f9-4ee7-bc28-f64cc8daf691
\.


--
-- Data for Name: parameter_values; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.parameter_values (id, parameter_id, parent_id, is_default, display_order, name, value, description, label) FROM stdin;
\.


--
-- Data for Name: parameters; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.parameters (id, parameter_group_id, name, description, label, is_visible, ordering, display_order, parameter_type, required, omit_if_blank) FROM stdin;
1dd009b1-ce1e-4933-aba8-66314757288b	30345113-d3e5-406b-a4e8-170a685e7a8b	-filename	The name of the uploaded file.	Output Filename	t	0	0	0e2e3be4-18a8-487b-bb27-c96a5a5a141f	t	t
a0d6a102-8623-47b9-a57f-224d6a71f28d	30345113-d3e5-406b-a4e8-170a685e7a8b	-url	The URL to retrieve the file from.	Source URL	t	1	1	ffeca61a-f1b9-43ba-b6ff-fa77bb34f396	t	t
13914010-89cd-406d-99c3-9c4ff8b023c3	741711b0-0b95-4ac9-98b4-ca58225e76be		The file to count words in.	Input Filename	t	0	0	3b3fad4c-691b-44a8-bf34-d406f9052239	t	t
5e1339f0-e01a-4fa3-8546-f7f16af547bf	f252f7b2-5c27-4a27-bbbb-f4f2f2acf407		The Python script to run	Script	t	0	0	3b3fad4c-691b-44a8-bf34-d406f9052239	t	t
41d1a467-17fa-4b25-ba5e-43c8cb88948b	f252f7b2-5c27-4a27-bbbb-f4f2f2acf407		The data file to process	Data file	t	1	1	3b3fad4c-691b-44a8-bf34-d406f9052239	t	t
\.


--
-- Data for Name: quick_launch_favorites; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.quick_launch_favorites (id, quick_launch_id, user_id) FROM stdin;
\.


--
-- Data for Name: quick_launch_global_defaults; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.quick_launch_global_defaults (id, app_id, quick_launch_id) FROM stdin;
\.


--
-- Data for Name: quick_launch_user_defaults; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.quick_launch_user_defaults (id, user_id, app_id, quick_launch_id) FROM stdin;
\.


--
-- Data for Name: quick_launches; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.quick_launches (id, name, description, creator, submission_id, app_id, is_public) FROM stdin;
\.


--
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.ratings (id, user_id, app_id, rating, comment_id) FROM stdin;
\.


--
-- Data for Name: request_status_codes; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.request_status_codes (id, name, display_name, email_template) FROM stdin;
dc983a80-5cd6-4c56-a9a6-7fbe8787fdd0	submitted	Submitted	request_submitted
74c25fd8-5cdf-4a3d-89a2-c55e88277c6a	in-progress	In Progress	request_in_progress
184029d3-7767-413e-82a0-4af68f2282b7	approved	Approved	request_complete
71c59a1b-f322-4114-9bbe-3aaa6c7c1942	rejected	Rejected	request_rejected
\.


--
-- Data for Name: request_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.request_types (id, name) FROM stdin;
\.


--
-- Data for Name: request_updates; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.request_updates (id, request_id, request_status_code_id, updating_user_id, created_date, message) FROM stdin;
\.


--
-- Data for Name: requests; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.requests (id, request_type_id, requesting_user_id, details) FROM stdin;
\.


--
-- Data for Name: rule_subtype; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.rule_subtype (id, name, description) FROM stdin;
b85de8e1-7ddd-4f65-ad94-e896b74dc133	Integer	A whole number
ce7c5ad2-5fca-4611-843f-791eee1f6e87	Double	A real number
6bf5e9db-86cb-4e6a-a579-0f3819e4fd68	String	Arbitrary text
\.


--
-- Data for Name: rule_type; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.rule_type (id, name, description, label, deprecated, display_order, rule_description_format, rule_subtype_id) FROM stdin;
07303d4b-3635-4934-93e6-b24de4f2725b	IntBelowField	Needs to be less than another associated parameter	\N	t	5	Value must be below: {FieldRef}.	b85de8e1-7ddd-4f65-ad94-e896b74dc133
2c3eec11-011a-4152-b27b-00d73deab7cf	IntAbove	Has a lower limit (integer)	\N	f	3	Value must be above: {Number}.	b85de8e1-7ddd-4f65-ad94-e896b74dc133
e04fb2c6-d5fd-47e4-ae89-a67390ccb67e	IntRange	Has a range of integers allowed	\N	f	1	Value must be between: {Number} and {Number}.	b85de8e1-7ddd-4f65-ad94-e896b74dc133
e1afc242-8962-4f0c-95be-5a6363cdd48b	IntAboveField	Needs to be greater than another associated parameter	\N	t	6	Value must be above: {FieldRef}.	b85de8e1-7ddd-4f65-ad94-e896b74dc133
0621f097-1b31-4457-812b-c8ca70bfbe14	MustContain	Must contain certain terms	\N	t	7	Value must contain: {List}.	b85de8e1-7ddd-4f65-ad94-e896b74dc133
58cd8b75-5598-4490-a9c9-a6d7a8cd09dd	DoubleRange	Has a range of values allowed (non-integer)	\N	f	2	Value must be between: {Number} and {Number}.	ce7c5ad2-5fca-4611-843f-791eee1f6e87
aebaaff6-3280-442d-b45e-6fd65e2d2c80	IntBelow	Has a higher limit (integer)	\N	f	4	Value must be below: {Number}.	b85de8e1-7ddd-4f65-ad94-e896b74dc133
87087b30-e7af-4b04-b08f-49baf5570466	DoubleAbove	Has a lower limit (double)	\N	f	8	Value must be above {Number}.	ce7c5ad2-5fca-4611-843f-791eee1f6e87
716a791b-47f3-4a53-9585-ed2f731a47f8	DoubleBelow	Has a higher limit (double)	\N	f	9	Value must be below {Number}.	ce7c5ad2-5fca-4611-843f-791eee1f6e87
4b4ee99b-2cf2-4ff8-8474-73fc6a1effa7	Regex	Matches a regular expression	\N	f	10	Value must match regular expression {String}	6bf5e9db-86cb-4e6a-a579-0f3819e4fd68
2d531048-a876-4b5d-8d21-54074910c721	CharacterLimit	Value must contain at most a maximum number of characters		f	11	Value must contain at most {Number} characters.	6bf5e9db-86cb-4e6a-a579-0f3819e4fd68
\.


--
-- Data for Name: rule_type_value_type; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.rule_type_value_type (rule_type_id, value_type_id) FROM stdin;
07303d4b-3635-4934-93e6-b24de4f2725b	bcb81292-f01d-45b1-8598-3d6cd745d2e9
2c3eec11-011a-4152-b27b-00d73deab7cf	bcb81292-f01d-45b1-8598-3d6cd745d2e9
e04fb2c6-d5fd-47e4-ae89-a67390ccb67e	bcb81292-f01d-45b1-8598-3d6cd745d2e9
e1afc242-8962-4f0c-95be-5a6363cdd48b	bcb81292-f01d-45b1-8598-3d6cd745d2e9
0621f097-1b31-4457-812b-c8ca70bfbe14	bcb81292-f01d-45b1-8598-3d6cd745d2e9
0621f097-1b31-4457-812b-c8ca70bfbe14	0115898a-f81a-4598-b1a8-06e538f1d774
0621f097-1b31-4457-812b-c8ca70bfbe14	96de7b1e-fe29-468f-85c0-a9458ce66fb1
58cd8b75-5598-4490-a9c9-a6d7a8cd09dd	bcb81292-f01d-45b1-8598-3d6cd745d2e9
aebaaff6-3280-442d-b45e-6fd65e2d2c80	bcb81292-f01d-45b1-8598-3d6cd745d2e9
87087b30-e7af-4b04-b08f-49baf5570466	bcb81292-f01d-45b1-8598-3d6cd745d2e9
716a791b-47f3-4a53-9585-ed2f731a47f8	bcb81292-f01d-45b1-8598-3d6cd745d2e9
4b4ee99b-2cf2-4ff8-8474-73fc6a1effa7	0115898a-f81a-4598-b1a8-06e538f1d774
4b4ee99b-2cf2-4ff8-8474-73fc6a1effa7	96de7b1e-fe29-468f-85c0-a9458ce66fb1
2d531048-a876-4b5d-8d21-54074910c721	96de7b1e-fe29-468f-85c0-a9458ce66fb1
2d531048-a876-4b5d-8d21-54074910c721	0115898a-f81a-4598-b1a8-06e538f1d774
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.session (sid, sess, expire) FROM stdin;
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.submissions (id, submission) FROM stdin;
\.


--
-- Data for Name: suggested_groups; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.suggested_groups (app_id, app_category_id) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tasks (id, job_type_id, external_app_id, name, description, label, tool_id) FROM stdin;
212c5980-9a56-417e-a8c6-394ac445ca4d	ad069d9f-e38f-418c-84f6-21f620cade77	\N	Curl Wrapper	curl wrapper for DE URL imports	Curl Wrapper	681251ef-ee59-4fe9-9436-dc8a23feb11a
1ac31629-231a-4090-b3b4-63ee078a0c37	ad069d9f-e38f-418c-84f6-21f620cade77	\N	DE Word Count	Counts the number of words in a file	DE Word Count	85cf7a33-386b-46fe-87c7-8c9d59972624
66b59035-6036-46c3-a30a-ee3bd4af47b6	ad069d9f-e38f-418c-84f6-21f620cade77	\N	Run a Python 2.7 script	Runs a Python 2.7 script against a data file	Run a Python 2.7 script	4e3b1710-0f15-491f-aca9-812335356fdb
\.


--
-- Data for Name: tool_architectures; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tool_architectures (id, name, description) FROM stdin;
a8220bba-63fe-4139-b6c3-5e22b43e8413	32-bit Generic	32-bit executables on an unspecified architecture.
ef254514-6d9f-4869-8fb8-a719262efca3	64-bit Generic	64-bit executables on an unspecified architecture.
44df2e72-36c0-4753-99f7-10af851bae8f	Others	Another specific architecture.
6af24f59-5de7-4e43-a000-b8059dc80b0a	Don't know	Used in cases where the user doesn't know the architecture.
\.


--
-- Data for Name: tool_request_status_codes; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tool_request_status_codes (id, name, description, email_template) FROM stdin;
1fb4295b-684e-4657-afab-6cc0912312b1	Submitted	The request has been submitted, but not acted upon by the support team.	tool_request_submitted
afbbcda8-49c3-47c0-9f28-de87cbfbcbd6	Pending	The support team is waiting for a response from the requesting user.	tool_request_pending
b15fd4b9-a8d3-48ec-bd29-b0aacb51d335	Evaluation	The support team is evaluating the tool for installation.	tool_request_evaluation
031d4f2c-3880-4483-88f8-e6c27c374340	Installation	The support team is installing the tool.	tool_request_installation
e4a0210c-663c-4943-bae9-7d2fa7063301	Validation	The support team is verifying that the installation was successful.	tool_request_validation
5ed94200-7565-45d8-b576-d7ff839e9993	Completion	The tool has been installed successfully.	tool_request_completion
461f24ee-5521-461a-8c20-c400d912fb2d	Failed	The tool could not be installed.	tool_request_failed
\.


--
-- Data for Name: tool_request_statuses; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tool_request_statuses (id, tool_request_id, tool_request_status_code_id, date_assigned, updater_id, comments) FROM stdin;
\.


--
-- Data for Name: tool_requests; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tool_requests (id, requestor_id, phone, tool_name, description, source_url, doc_url, version, attribution, multithreaded, tool_architecture_id, test_data_path, instructions, additional_info, additional_data_file, tool_id) FROM stdin;
\.


--
-- Data for Name: tool_test_data_files; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tool_test_data_files (id, filename, input_file, tool_id) FROM stdin;
\.


--
-- Data for Name: tool_type_parameter_type; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tool_type_parameter_type (tool_type_id, parameter_type_id) FROM stdin;
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	ffeca61a-f1b9-43ba-b6ff-fa77bb34f396
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	f03dd9ac-b586-4fe1-a75b-3e2967bd0207
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	206a93d6-bac4-4925-89fe-39c073e85c47
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	c389d80a-f94e-4904-b6ef-bd658a18fc8a
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	01250db2-f8e9-4d9e-b82e-c4713da84068
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	c529c00a-8b6f-4b73-80da-c460c09722ed
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	0f4e0460-893b-4724-bc7c-d145575b9b73
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	b8566277-c368-40e9-8b66-bc1c884cf69b
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	a024716e-1f18-4af7-b59e-0745786d1b69
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	548a55c2-53fe-40a5-ad38-033f79c8c0ab
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	3b3fad4c-691b-44a8-bf34-d406f9052239
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	9633fd4c-5ffc-4471-b531-2ecaaa683e26
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	fd5c9d3e-663d-469c-9455-5ee59621bf0e
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	0e2e3be4-18a8-487b-bb27-c96a5a5a141f
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	108011ca-1908-494e-b76f-83bb2ba696d7
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	8ef87e50-460f-402a-b5c8-bfbb83211a54
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	8f6c59d1-cb29-45fd-834e-a42770c3faa6
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	d55c28bf-9f00-44a6-9ced-3db8a46b8b40
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	b728413e-69eb-435e-a6f5-d00cb1f43daa
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	8031799a-5c4a-46d6-a984-21230cf4a04a
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	f7007237-040d-4253-9323-caa4f71e9795
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	c00ed92f-5399-490c-a6e5-aad0e140d7fe
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	871aa217-2e6c-48e2-880a-ee7815e8f7f8
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	67bdfe81-361e-41fe-852a-35159e1e7bc5
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	7c71012b-158d-44fd-bda1-a5fb4d43bfd8
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	babc3c29-39c2-47b5-8576-f3741f9ae329
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	f22ca553-856b-4253-b0f3-514701ed4567
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	d2340f11-d260-41b4-93fd-c1d695bf6fef
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	c5b85c6b-381e-44f6-a568-186f1fe7f03d
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	8d7dfb62-2ba4-4ad1-b38e-068318200d9b
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	553f6a79-329e-470b-b827-ebbf2d2811f1
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	9935e153-5765-4c2e-a2bc-676f88b11267
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	bea4f078-6296-4511-834a-27b6bc3c88ab
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	2cf37b0d-5463-4aef-98a2-4db63d2f3dbc
fa713bb8-2838-4b63-ab3a-265dbb1d719c	ffeca61a-f1b9-43ba-b6ff-fa77bb34f396
fa713bb8-2838-4b63-ab3a-265dbb1d719c	f03dd9ac-b586-4fe1-a75b-3e2967bd0207
fa713bb8-2838-4b63-ab3a-265dbb1d719c	206a93d6-bac4-4925-89fe-39c073e85c47
fa713bb8-2838-4b63-ab3a-265dbb1d719c	c389d80a-f94e-4904-b6ef-bd658a18fc8a
fa713bb8-2838-4b63-ab3a-265dbb1d719c	01250db2-f8e9-4d9e-b82e-c4713da84068
fa713bb8-2838-4b63-ab3a-265dbb1d719c	c529c00a-8b6f-4b73-80da-c460c09722ed
fa713bb8-2838-4b63-ab3a-265dbb1d719c	0f4e0460-893b-4724-bc7c-d145575b9b73
fa713bb8-2838-4b63-ab3a-265dbb1d719c	b8566277-c368-40e9-8b66-bc1c884cf69b
fa713bb8-2838-4b63-ab3a-265dbb1d719c	548a55c2-53fe-40a5-ad38-033f79c8c0ab
fa713bb8-2838-4b63-ab3a-265dbb1d719c	3b3fad4c-691b-44a8-bf34-d406f9052239
fa713bb8-2838-4b63-ab3a-265dbb1d719c	9633fd4c-5ffc-4471-b531-2ecaaa683e26
fa713bb8-2838-4b63-ab3a-265dbb1d719c	fd5c9d3e-663d-469c-9455-5ee59621bf0e
fa713bb8-2838-4b63-ab3a-265dbb1d719c	0e2e3be4-18a8-487b-bb27-c96a5a5a141f
fa713bb8-2838-4b63-ab3a-265dbb1d719c	108011ca-1908-494e-b76f-83bb2ba696d7
fa713bb8-2838-4b63-ab3a-265dbb1d719c	8ef87e50-460f-402a-b5c8-bfbb83211a54
fa713bb8-2838-4b63-ab3a-265dbb1d719c	8f6c59d1-cb29-45fd-834e-a42770c3faa6
fa713bb8-2838-4b63-ab3a-265dbb1d719c	d55c28bf-9f00-44a6-9ced-3db8a46b8b40
fa713bb8-2838-4b63-ab3a-265dbb1d719c	b728413e-69eb-435e-a6f5-d00cb1f43daa
fa713bb8-2838-4b63-ab3a-265dbb1d719c	8031799a-5c4a-46d6-a984-21230cf4a04a
fa713bb8-2838-4b63-ab3a-265dbb1d719c	f7007237-040d-4253-9323-caa4f71e9795
fa713bb8-2838-4b63-ab3a-265dbb1d719c	bea4f078-6296-4511-834a-27b6bc3c88ab
fa713bb8-2838-4b63-ab3a-265dbb1d719c	9935e153-5765-4c2e-a2bc-676f88b11267
fa713bb8-2838-4b63-ab3a-265dbb1d719c	553f6a79-329e-470b-b827-ebbf2d2811f1
fa713bb8-2838-4b63-ab3a-265dbb1d719c	8d7dfb62-2ba4-4ad1-b38e-068318200d9b
fa713bb8-2838-4b63-ab3a-265dbb1d719c	c5b85c6b-381e-44f6-a568-186f1fe7f03d
fa713bb8-2838-4b63-ab3a-265dbb1d719c	d2340f11-d260-41b4-93fd-c1d695bf6fef
fa713bb8-2838-4b63-ab3a-265dbb1d719c	f22ca553-856b-4253-b0f3-514701ed4567
fa713bb8-2838-4b63-ab3a-265dbb1d719c	babc3c29-39c2-47b5-8576-f3741f9ae329
fa713bb8-2838-4b63-ab3a-265dbb1d719c	7c71012b-158d-44fd-bda1-a5fb4d43bfd8
fa713bb8-2838-4b63-ab3a-265dbb1d719c	67bdfe81-361e-41fe-852a-35159e1e7bc5
fa713bb8-2838-4b63-ab3a-265dbb1d719c	871aa217-2e6c-48e2-880a-ee7815e8f7f8
fa713bb8-2838-4b63-ab3a-265dbb1d719c	c00ed92f-5399-490c-a6e5-aad0e140d7fe
fa713bb8-2838-4b63-ab3a-265dbb1d719c	2cf37b0d-5463-4aef-98a2-4db63d2f3dbc
01e14110-1420-4de0-8a70-b0dd420f6a84	ffeca61a-f1b9-43ba-b6ff-fa77bb34f396
01e14110-1420-4de0-8a70-b0dd420f6a84	f03dd9ac-b586-4fe1-a75b-3e2967bd0207
01e14110-1420-4de0-8a70-b0dd420f6a84	206a93d6-bac4-4925-89fe-39c073e85c47
01e14110-1420-4de0-8a70-b0dd420f6a84	c389d80a-f94e-4904-b6ef-bd658a18fc8a
01e14110-1420-4de0-8a70-b0dd420f6a84	01250db2-f8e9-4d9e-b82e-c4713da84068
01e14110-1420-4de0-8a70-b0dd420f6a84	c529c00a-8b6f-4b73-80da-c460c09722ed
01e14110-1420-4de0-8a70-b0dd420f6a84	0f4e0460-893b-4724-bc7c-d145575b9b73
01e14110-1420-4de0-8a70-b0dd420f6a84	b8566277-c368-40e9-8b66-bc1c884cf69b
01e14110-1420-4de0-8a70-b0dd420f6a84	a024716e-1f18-4af7-b59e-0745786d1b69
01e14110-1420-4de0-8a70-b0dd420f6a84	548a55c2-53fe-40a5-ad38-033f79c8c0ab
01e14110-1420-4de0-8a70-b0dd420f6a84	3b3fad4c-691b-44a8-bf34-d406f9052239
01e14110-1420-4de0-8a70-b0dd420f6a84	9633fd4c-5ffc-4471-b531-2ecaaa683e26
01e14110-1420-4de0-8a70-b0dd420f6a84	fd5c9d3e-663d-469c-9455-5ee59621bf0e
01e14110-1420-4de0-8a70-b0dd420f6a84	0e2e3be4-18a8-487b-bb27-c96a5a5a141f
01e14110-1420-4de0-8a70-b0dd420f6a84	108011ca-1908-494e-b76f-83bb2ba696d7
01e14110-1420-4de0-8a70-b0dd420f6a84	8ef87e50-460f-402a-b5c8-bfbb83211a54
01e14110-1420-4de0-8a70-b0dd420f6a84	8f6c59d1-cb29-45fd-834e-a42770c3faa6
01e14110-1420-4de0-8a70-b0dd420f6a84	d55c28bf-9f00-44a6-9ced-3db8a46b8b40
01e14110-1420-4de0-8a70-b0dd420f6a84	b728413e-69eb-435e-a6f5-d00cb1f43daa
01e14110-1420-4de0-8a70-b0dd420f6a84	8031799a-5c4a-46d6-a984-21230cf4a04a
01e14110-1420-4de0-8a70-b0dd420f6a84	f7007237-040d-4253-9323-caa4f71e9795
01e14110-1420-4de0-8a70-b0dd420f6a84	c00ed92f-5399-490c-a6e5-aad0e140d7fe
01e14110-1420-4de0-8a70-b0dd420f6a84	871aa217-2e6c-48e2-880a-ee7815e8f7f8
01e14110-1420-4de0-8a70-b0dd420f6a84	67bdfe81-361e-41fe-852a-35159e1e7bc5
01e14110-1420-4de0-8a70-b0dd420f6a84	7c71012b-158d-44fd-bda1-a5fb4d43bfd8
01e14110-1420-4de0-8a70-b0dd420f6a84	babc3c29-39c2-47b5-8576-f3741f9ae329
01e14110-1420-4de0-8a70-b0dd420f6a84	f22ca553-856b-4253-b0f3-514701ed4567
01e14110-1420-4de0-8a70-b0dd420f6a84	d2340f11-d260-41b4-93fd-c1d695bf6fef
01e14110-1420-4de0-8a70-b0dd420f6a84	c5b85c6b-381e-44f6-a568-186f1fe7f03d
01e14110-1420-4de0-8a70-b0dd420f6a84	8d7dfb62-2ba4-4ad1-b38e-068318200d9b
01e14110-1420-4de0-8a70-b0dd420f6a84	553f6a79-329e-470b-b827-ebbf2d2811f1
01e14110-1420-4de0-8a70-b0dd420f6a84	9935e153-5765-4c2e-a2bc-676f88b11267
01e14110-1420-4de0-8a70-b0dd420f6a84	bea4f078-6296-4511-834a-27b6bc3c88ab
01e14110-1420-4de0-8a70-b0dd420f6a84	2cf37b0d-5463-4aef-98a2-4db63d2f3dbc
\.


--
-- Data for Name: tool_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tool_types (id, name, label, description, hidden, notification_type) FROM stdin;
de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	executable	UA	Run at the University of Arizona	f	analysis
fa713bb8-2838-4b63-ab3a-265dbb1d719c	fAPI	TACC	Run at the Texas Advanced Computing Center	f	analysis
01e14110-1420-4de0-8a70-b0dd420f6a84	internal	Internal DE tools.	Tools used internally by the Discovery Environment.	t	data
4166b913-eafa-4731-881f-21c3751dffbb	interactive	Interactive DE tools.	Interactive tools used by the Discovery Environment.	f	analysis
7ec7063b-a96d-4ae5-9815-4548ba7d9c74	osg	OSG DE tools.	DE tools capable of running on the Open Science Grid.	f	analysis
\.


--
-- Data for Name: tools; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tools (id, name, location, tool_type_id, description, version, attribution, integration_data_id, container_images_id, time_limit_seconds, restricted, interactive, gpu_enabled) FROM stdin;
681251ef-ee59-4fe9-9436-dc8a23feb11a	urlimport		01e14110-1420-4de0-8a70-b0dd420f6a84	Go tool for DE URL imports	1.0.0	\N	3c533526-2390-11ec-9fc1-0242ac110002	15959300-b972-4571-ace2-081af0909599	0	f	f	f
85cf7a33-386b-46fe-87c7-8c9d59972624	wc		de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	Word Count	0.0.1	\N	3c535984-2390-11ec-9fc1-0242ac110002	15959300-b972-4571-ace2-081af0909599	0	f	f	f
4c7105ce-b900-405f-b067-cd3b152d3b4b	notreal	/not/real/	01e14110-1420-4de0-8a70-b0dd420f6a84	not a real tool	1.0.0	\N	3c533526-2390-11ec-9fc1-0242ac110002	fc210a84-f7cd-4067-939c-a68ec3e3bd2b	0	f	f	f
4e3b1710-0f15-491f-aca9-812335356fdb	python	/usr/local/bin	de1dbe6a-a2bb-4219-986b-d878c6a9e3e4	Python 2.7 with no networking, a 1GB RAM limit, and a 10% cpu share. Entrypoint is python.	1.0.0	\N	3c535984-2390-11ec-9fc1-0242ac110002	bad7e301-4442-4e82-8cc4-8db681cae364	14400	f	f	f
\.


--
-- Data for Name: tree_urls; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tree_urls (id, sha1, tree_urls) FROM stdin;
\.


--
-- Data for Name: user_instant_launches; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.user_instant_launches (id, version, user_id, instant_launches, added_by, added_on) FROM stdin;
\.


--
-- Name: user_instant_launches_version_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.user_instant_launches_version_seq', 1, false);


--
-- Data for Name: user_preferences; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.user_preferences (id, user_id, preferences) FROM stdin;
\.


--
-- Data for Name: user_saved_searches; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.user_saved_searches (id, user_id, saved_searches) FROM stdin;
\.


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.user_sessions (id, user_id, session) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.users (id, username) FROM stdin;
00000000-0000-0000-0000-000000000000	<public>
\.


--
-- Data for Name: validation_rule_argument_definitions; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.validation_rule_argument_definitions (id, rule_type_id, argument_index, name, description, argument_type_id) FROM stdin;
5f05b059-0e27-4854-8471-2161e740c9dd	07303d4b-3635-4934-93e6-b24de4f2725b	0	FieldRef	The other field to compare to this field.	485d6288-9bf8-4f62-89da-eca90b0ca68b
e4a26b96-6ca6-46b6-8897-f4475db4c3bd	2c3eec11-011a-4152-b27b-00d73deab7cf	0	LowerLimit	The lower limit of this field.	aabf8059-ae4f-454e-a791-434580530530
192b9618-6811-4922-b44c-13d10fdad781	e04fb2c6-d5fd-47e4-ae89-a67390ccb67e	0	LowerLimit	The lower limit of this field.	aabf8059-ae4f-454e-a791-434580530530
91faecde-1dca-4eb0-be2d-8a8bf23d0b84	e04fb2c6-d5fd-47e4-ae89-a67390ccb67e	1	UpperLimit	The upper limit of this field.	aabf8059-ae4f-454e-a791-434580530530
eb50537e-07c2-4f64-b5d7-15765954334e	e1afc242-8962-4f0c-95be-5a6363cdd48b	0	FieldRef	The other field to compare to this field.	485d6288-9bf8-4f62-89da-eca90b0ca68b
d038c593-0dd1-4403-b13a-e1d816d1a31d	0621f097-1b31-4457-812b-c8ca70bfbe14	0	List	The list of valid values for this field.	485d6288-9bf8-4f62-89da-eca90b0ca68b
b86c8c26-6123-462d-b47c-93540eb4cacb	58cd8b75-5598-4490-a9c9-a6d7a8cd09dd	0	LowerLimit	The lower limit of this field.	9049a4cd-3385-4a3d-8db2-a49ce69b091d
7bec62bb-9489-4acb-99c6-577f13e38063	58cd8b75-5598-4490-a9c9-a6d7a8cd09dd	1	UpperLimit	The upper limit of this field.	9049a4cd-3385-4a3d-8db2-a49ce69b091d
f981dd45-e99d-489c-bcd3-75aef05678fd	aebaaff6-3280-442d-b45e-6fd65e2d2c80	0	UpperLimit	The upper limit of this field.	aabf8059-ae4f-454e-a791-434580530530
626f0bcd-4675-42f4-9a4c-3af516902d70	87087b30-e7af-4b04-b08f-49baf5570466	0	LowerLimit	The lower limit of this field.	9049a4cd-3385-4a3d-8db2-a49ce69b091d
51d0682b-088f-4dc8-869d-15f564f3dbe3	716a791b-47f3-4a53-9585-ed2f731a47f8	0	UpperLimit	The upper limit of this field.	9049a4cd-3385-4a3d-8db2-a49ce69b091d
d36c49c9-4a10-41b2-a796-7453fd26cfb4	4b4ee99b-2cf2-4ff8-8474-73fc6a1effa7	0	Regex	The regular expression.	485d6288-9bf8-4f62-89da-eca90b0ca68b
7ce39813-e26a-479d-832c-755a024e41fa	2d531048-a876-4b5d-8d21-54074910c721	0	MaxLength	The maximum length of the field.	aabf8059-ae4f-454e-a791-434580530530
\.


--
-- Data for Name: validation_rule_argument_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.validation_rule_argument_types (id, name) FROM stdin;
485d6288-9bf8-4f62-89da-eca90b0ca68b	String
aabf8059-ae4f-454e-a791-434580530530	Integer
9049a4cd-3385-4a3d-8db2-a49ce69b091d	Double
\.


--
-- Data for Name: validation_rule_arguments; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.validation_rule_arguments (id, rule_id, ordering, argument_value) FROM stdin;
\.


--
-- Data for Name: validation_rules; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.validation_rules (id, parameter_id, rule_type) FROM stdin;
\.


--
-- Data for Name: value_type; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.value_type (id, name, description) FROM stdin;
0115898a-f81a-4598-b1a8-06e538f1d774	String	Arbitrary text
e8e05e6c-5002-48c0-9167-c9733f0a9716	Boolean	True or false value
bcb81292-f01d-45b1-8598-3d6cd745d2e9	Number	Numeric value
94fe4f2b-42f9-4ee7-bc28-f64cc8daf691	Input	Input file or folder
65e1e927-a1ed-4e25-bc0c-74c155215973	Output	Output file or folder
96de7b1e-fe29-468f-85c0-a9458ce66fb1	EnvironmentVariable	An environment variable that is set before running a job
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.version (version, applied) FROM stdin;
1.4.0:20120525.01	2021-10-02 16:51:30.802362
1.4.0:20120530.01	2021-10-02 16:51:30.802362
1.4.0:20120615.01	2021-10-02 16:51:30.802362
1.4.0:20120618.01	2021-10-02 16:51:30.802362
1.4.0:20120713.01	2021-10-02 16:51:30.802362
1.4.0:20120720.01	2021-10-02 16:51:30.802362
1.4.0:20120726.01	2021-10-02 16:51:30.802362
1.4.0:20120822.01	2021-10-02 16:51:30.802362
1.4.4:20120927.01	2021-10-02 16:51:30.802362
1.6.0:20121105.01	2021-10-02 16:51:30.802362
1.6.0:20121204.01	2021-10-02 16:51:30.802362
1.6.0:20121213.01	2021-10-02 16:51:30.802362
1.8.0:20130225.01	2021-10-02 16:51:30.802362
1.8.0:20130304.01	2021-10-02 16:51:30.802362
1.8.0:20130304.02	2021-10-02 16:51:30.802362
1.8.0:20130313.01	2021-10-02 16:51:30.802362
1.8.0:20130314.01	2021-10-02 16:51:30.802362
1.8.0:20130419.01	2021-10-02 16:51:30.802362
1.8.0:20130502.01	2021-10-02 16:51:30.802362
1.8.0:20130613.01	2021-10-02 16:51:30.802362
1.8.0:20130626.01	2021-10-02 16:51:30.802362
1.8.0:20130627.01	2021-10-02 16:51:30.802362
1.8.0:20130703.01	2021-10-02 16:51:30.802362
1.8.0:20130716.01	2021-10-02 16:51:30.802362
1.8.0:20130807.01	2021-10-02 16:51:30.802362
1.8.2:20130903.01	2021-10-02 16:51:30.802362
1.8.2:20130904.01	2021-10-02 16:51:30.802362
1.8.2:20130924.01	2021-10-02 16:51:30.802362
1.8.4:20131014.01	2021-10-02 16:51:30.802362
1.8.4:20131217.01	2021-10-02 16:51:30.802362
1.8.4:20140106.01	2021-10-02 16:51:30.802362
1.8.4:20140107.01	2021-10-02 16:51:30.802362
1.8.4:20140114.01	2021-10-02 16:51:30.802362
1.8.4:20140115.01	2021-10-02 16:51:30.802362
1.8.4:20140304.01	2021-10-02 16:51:30.802362
1.8.6:20140227.01	2021-10-02 16:51:30.802362
1.8.6:20140404.01	2021-10-02 16:51:30.802362
1.8.7:20140420.01	2021-10-02 16:51:30.802362
1.8.7:20140421.01	2021-10-02 16:51:30.802362
1.8.7:20140509.01	2021-10-02 16:51:30.802362
1.8.8:20140515.01	2021-10-02 16:51:30.802362
1.8.8:20140522.01	2021-10-02 16:51:30.802362
1.8.8:20140611.01	2021-10-02 16:51:30.802362
1.8.9:20140619.01	2021-10-02 16:51:30.802362
1.8.9:20140627.01	2021-10-02 16:51:30.802362
1.8.9:20140627.02	2021-10-02 16:51:30.802362
1.8.9:20140711.01	2021-10-02 16:51:30.802362
1.8.9:20140714.01	2021-10-02 16:51:30.802362
1.8.9:20140715.01	2021-10-02 16:51:30.802362
1.8.9:20140718.01	2021-10-02 16:51:30.802362
1.8.9:20140724.01	2021-10-02 16:51:30.802362
1.9.2:20140909.01	2021-10-02 16:51:30.802362
1.9.2:20141126.01	2021-10-02 16:51:30.802362
1.9.3:20140424.01	2021-10-02 16:51:30.802362
1.9.3:20140527.01	2021-10-02 16:51:30.802362
1.9.3:20141217.01	2021-10-02 16:51:30.802362
1.9.5:20150113.01	2021-10-02 16:51:30.802362
1.9.5:20150114.01	2021-10-02 16:51:30.802362
1.9.5:20150202.01	2021-10-02 16:51:30.802362
1.9.5:20150216.01	2021-10-02 16:51:30.802362
1.9.7:20150209.01	2021-10-02 16:51:30.802362
1.9.9:20150530.05	2021-10-02 16:51:30.802362
2.0.0:20150602.01	2021-10-02 16:51:30.802362
2.0.0:20150630.01	2021-10-02 16:51:30.802362
2.1.0:20150812.01	2021-10-02 16:51:30.802362
2.1.0:20150825.01	2021-10-02 16:51:30.802362
2.1.0:20150825.02	2021-10-02 16:51:30.802362
2.1.0:20150825.03	2021-10-02 16:51:30.802362
2.1.0:20150901.01	2021-10-02 16:51:30.802362
2.2.0:20151005.01	2021-10-02 16:51:30.802362
2.3.0:20151110.01	2021-10-02 16:51:30.802362
2.4.0:20160106.01	2021-10-02 16:51:30.802362
2.5.0:20160210.01	2021-10-02 16:51:30.802362
2.6.0:20160222.01	2021-10-02 16:51:30.802362
2.6.0:20160309.01	2021-10-02 16:51:30.802362
2.6.0:20160420.01	2021-10-02 16:51:30.802362
2.7.0:20160525.01	2021-10-02 16:51:30.802362
2.7.0:20160526.01	2021-10-02 16:51:30.802362
2.7.0:20160614.01	2021-10-02 16:51:30.802362
2.8.0:20160712.01	2021-10-02 16:51:30.802362
2.8.0:20160728.01	2021-10-02 16:51:30.802362
2.9.0:20161007.01	2021-10-02 16:51:30.802362
2.10.0:20161201.01	2021-10-02 16:51:30.802362
2.10.0:20161205.01	2021-10-02 16:51:30.802362
2.10.0:20161214.01	2021-10-02 16:51:30.802362
2.12.0:20170428.01	2021-10-02 16:51:30.802362
2.12.0:20170508.01	2021-10-02 16:51:30.802362
2.12.0:20170510.01	2021-10-02 16:51:30.802362
2.13.0:20170609.01	2021-10-02 16:51:30.802362
2.13.0:20170616.01	2021-10-02 16:51:30.802362
2.15.0:20170824.01	2021-10-02 16:51:30.802362
2.18.0:20171113.01	2021-10-02 16:51:30.802362
2.20.0:20180326.01	2021-10-02 16:51:30.802362
2.21.0:20180419.01	2021-10-02 16:51:30.802362
2.21.0:20180426.01	2021-10-02 16:51:30.802362
2.21.0:20180515.01	2021-10-02 16:51:30.802362
2.22.0:20180523.01	2021-10-02 16:51:30.802362
2.22.0:20180601.01	2021-10-02 16:51:30.802362
2.22.0:20180604.01	2021-10-02 16:51:30.802362
2.22.0:20180614.01	2021-10-02 16:51:30.802362
2.22.0:20180617.01	2021-10-02 16:51:30.802362
2.22.0:20180718.01	2021-10-02 16:51:30.802362
2.22.0:20180718.02	2021-10-02 16:51:30.802362
2.22.0:20180724.01	2021-10-02 16:51:30.802362
2.23.0:20180828.01	2021-10-02 16:51:30.802362
2.23.0:20181024.01	2021-10-02 16:51:30.802362
2.24.0:20181205.01	2021-10-02 16:51:30.802362
2.24.0:20190114.01	2021-10-02 16:51:30.802362
2.25.0:20190206.01	2021-10-02 16:51:30.802362
2.25.0:20190212.01	2021-10-02 16:51:30.802362
2.25.0:20190226.01	2021-10-02 16:51:30.802362
2.26.0:20190318.01	2021-10-02 16:51:30.802362
2.26.0:20190409.01	2021-10-02 16:51:30.802362
2.27.0:20190528.01	2021-10-02 16:51:30.802362
2.28.0:20190815.01	2021-10-02 16:51:30.802362
2.29.0:20190917.01	2021-10-02 16:51:30.802362
2.30.0:20191118.01	2021-10-02 16:51:30.802362
2.30.0:20191121.01	2021-10-02 16:51:30.802362
2.31.0:20191212.01	2021-10-02 16:51:30.802362
2.32.0:20200319.01	2021-10-02 16:51:30.802362
2.32.0:20200402.01	2021-10-02 16:51:30.802362
2.33.0:20200420.01	2021-10-02 16:51:30.802362
2.34.0:20200714.01	2021-10-02 16:51:30.802362
2.34.0:20200731.01	2021-10-02 16:51:30.802362
2.34.0:20200820.01	2021-10-02 16:51:30.802362
2.34.0:20200820.02	2021-10-02 16:51:30.802362
2.34.0:20200902.01	2021-10-02 16:51:30.802362
2.35.0:20201023.01	2021-10-02 16:51:30.802362
2.35.0:20201106.01	2021-10-02 16:51:30.802362
2.36.0:20210201.01	2021-10-02 16:51:30.802362
2.37.0:20210312.01	2021-10-02 16:51:30.802362
\.


--
-- Data for Name: webhooks; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.webhooks (id, user_id, url, type_id) FROM stdin;
\.


--
-- Data for Name: webhooks_subscription; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.webhooks_subscription (webhook_id, topic_id) FROM stdin;
\.


--
-- Data for Name: webhooks_topic; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.webhooks_topic (id, topic) FROM stdin;
3c5f8114-2390-11ec-9fc1-0242ac110002	data
3c5f942e-2390-11ec-9fc1-0242ac110002	apps
3c5fa266-2390-11ec-9fc1-0242ac110002	analysis
3c5fad7e-2390-11ec-9fc1-0242ac110002	permanent_id_request
3c5fba76-2390-11ec-9fc1-0242ac110002	team
3c5fc53e-2390-11ec-9fc1-0242ac110002	tool_request
\.


--
-- Data for Name: webhooks_type; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.webhooks_type (id, type, template) FROM stdin;
3c5f234a-2390-11ec-9fc1-0242ac110002	Slack	\n{\n\t"text": "{{.Msg}}. {{if .Completed}} <{{.Link}}|{{.LinkText}}> {{- end}}"\n}\n
3c5f365a-2390-11ec-9fc1-0242ac110002	Zapier	\n{\n  "id": "{{.ID}}",\n  "name": "{{.Name}}",\n  "text": "{{.Msg}}. {{if .Completed}} <{{.Link}}|{{.LinkText}}> {{- end}}"\n}\n
3c5f42a8-2390-11ec-9fc1-0242ac110002	Custom	
\.


--
-- Data for Name: workflow_io_maps; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.workflow_io_maps (id, app_id, target_step, source_step) FROM stdin;
\.


--
-- Data for Name: workspace; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.workspace (id, root_category_id, is_public, user_id) FROM stdin;
00000000-0000-0000-0000-000000000000	12c7a585-ec23-3352-e313-02e323112a7c	t	00000000-0000-0000-0000-000000000000
\.


--
-- Name: access_tokens access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (webapp, user_id);


--
-- Name: app_categories app_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_categories
    ADD CONSTRAINT app_categories_pkey PRIMARY KEY (id);


--
-- Name: app_category_app app_category_app_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_category_app
    ADD CONSTRAINT app_category_app_pkey PRIMARY KEY (app_category_id, app_id);


--
-- Name: app_category_group app_category_group_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_category_group
    ADD CONSTRAINT app_category_group_pkey PRIMARY KEY (parent_category_id, child_category_id);


--
-- Name: app_documentation app_documentation_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_documentation
    ADD CONSTRAINT app_documentation_pkey PRIMARY KEY (app_id);


--
-- Name: app_publication_request_status_codes app_publication_request_status_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_publication_request_status_codes
    ADD CONSTRAINT app_publication_request_status_codes_pkey PRIMARY KEY (id);


--
-- Name: app_publication_request_statuses app_publication_request_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_publication_request_statuses
    ADD CONSTRAINT app_publication_request_statuses_pkey PRIMARY KEY (id);


--
-- Name: app_publication_requests app_publication_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_publication_requests
    ADD CONSTRAINT app_publication_requests_pkey PRIMARY KEY (id);


--
-- Name: app_references app_references_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_references
    ADD CONSTRAINT app_references_pkey PRIMARY KEY (id);


--
-- Name: app_steps app_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_steps
    ADD CONSTRAINT app_steps_pkey PRIMARY KEY (id);


--
-- Name: apps_htcondor_extra apps_htcondor_extra_apps_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.apps_htcondor_extra
    ADD CONSTRAINT apps_htcondor_extra_apps_id_pkey PRIMARY KEY (apps_id);


--
-- Name: apps apps_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);


--
-- Name: async_task_behavior async_task_behavior_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.async_task_behavior
    ADD CONSTRAINT async_task_behavior_pkey PRIMARY KEY (async_task_id, behavior_type);


--
-- Name: async_task_status async_task_status_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.async_task_status
    ADD CONSTRAINT async_task_status_pkey PRIMARY KEY (async_task_id, status, created_date);


--
-- Name: async_tasks async_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.async_tasks
    ADD CONSTRAINT async_tasks_pkey PRIMARY KEY (id);


--
-- Name: authorization_requests authorization_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.authorization_requests
    ADD CONSTRAINT authorization_requests_pkey PRIMARY KEY (id);


--
-- Name: authorization_requests authorization_requests_user_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.authorization_requests
    ADD CONSTRAINT authorization_requests_user_id_key UNIQUE (user_id);


--
-- Name: bags bags_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.bags
    ADD CONSTRAINT bags_id_key UNIQUE (id);


--
-- Name: bags bags_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.bags
    ADD CONSTRAINT bags_pkey PRIMARY KEY (id);


--
-- Name: container_devices container_devices_container_settings_id_host_path_container_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_devices
    ADD CONSTRAINT container_devices_container_settings_id_host_path_container_key UNIQUE (container_settings_id, host_path, container_path);


--
-- Name: container_devices container_devices_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_devices
    ADD CONSTRAINT container_devices_id_key UNIQUE (id);


--
-- Name: container_devices container_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_devices
    ADD CONSTRAINT container_devices_pkey PRIMARY KEY (id);


--
-- Name: container_images container_images_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_images
    ADD CONSTRAINT container_images_id_key UNIQUE (id);


--
-- Name: container_images container_images_name_tag_osg_image_path_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_images
    ADD CONSTRAINT container_images_name_tag_osg_image_path_key UNIQUE (name, tag, osg_image_path);


--
-- Name: container_images container_images_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_images
    ADD CONSTRAINT container_images_pkey PRIMARY KEY (id);


--
-- Name: container_ports container_ports_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_ports
    ADD CONSTRAINT container_ports_id_key UNIQUE (id);


--
-- Name: container_ports container_ports_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_ports
    ADD CONSTRAINT container_ports_id_pkey PRIMARY KEY (id);


--
-- Name: container_settings container_settings_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_settings
    ADD CONSTRAINT container_settings_id_key UNIQUE (id);


--
-- Name: container_settings container_settings_interactive_apps_proxy_settings_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_settings
    ADD CONSTRAINT container_settings_interactive_apps_proxy_settings_id_key UNIQUE (interactive_apps_proxy_settings_id);


--
-- Name: container_settings container_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_settings
    ADD CONSTRAINT container_settings_pkey PRIMARY KEY (id);


--
-- Name: container_settings container_settings_tools_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_settings
    ADD CONSTRAINT container_settings_tools_id_key UNIQUE (tools_id);


--
-- Name: container_volumes container_volumes_container_settings_id_host_path_container_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_volumes
    ADD CONSTRAINT container_volumes_container_settings_id_host_path_container_key UNIQUE (container_settings_id, host_path, container_path);


--
-- Name: container_volumes_from container_volumes_from_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_volumes_from
    ADD CONSTRAINT container_volumes_from_id_key UNIQUE (id);


--
-- Name: container_volumes_from container_volumes_from_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_volumes_from
    ADD CONSTRAINT container_volumes_from_pkey PRIMARY KEY (id);


--
-- Name: container_volumes container_volumes_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_volumes
    ADD CONSTRAINT container_volumes_id_key UNIQUE (id);


--
-- Name: container_volumes container_volumes_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_volumes
    ADD CONSTRAINT container_volumes_pkey PRIMARY KEY (id);


--
-- Name: data_containers data_containers_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.data_containers
    ADD CONSTRAINT data_containers_id_key UNIQUE (id);


--
-- Name: data_containers data_containers_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.data_containers
    ADD CONSTRAINT data_containers_pkey PRIMARY KEY (id);


--
-- Name: data_containers data_containers_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.data_containers
    ADD CONSTRAINT data_containers_unique UNIQUE (container_images_id, name_prefix, read_only);


--
-- Name: data_formats data_formats_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.data_formats
    ADD CONSTRAINT data_formats_pkey PRIMARY KEY (id);


--
-- Name: data_source data_source_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.data_source
    ADD CONSTRAINT data_source_pkey PRIMARY KEY (id);


--
-- Name: data_source data_source_unique_name; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.data_source
    ADD CONSTRAINT data_source_unique_name UNIQUE (name);


--
-- Name: default_bags default_bags_bag_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_bags
    ADD CONSTRAINT default_bags_bag_id_key UNIQUE (bag_id);


--
-- Name: default_bags default_bags_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_bags
    ADD CONSTRAINT default_bags_pkey PRIMARY KEY (user_id, bag_id);


--
-- Name: default_bags default_bags_user_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_bags
    ADD CONSTRAINT default_bags_user_id_key UNIQUE (user_id);


--
-- Name: default_instant_launches default_instant_launches_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_instant_launches
    ADD CONSTRAINT default_instant_launches_id_key UNIQUE (id);


--
-- Name: default_instant_launches default_instant_launches_pky; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_instant_launches
    ADD CONSTRAINT default_instant_launches_pky PRIMARY KEY (id);


--
-- Name: default_instant_launches default_instant_launches_version_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_instant_launches
    ADD CONSTRAINT default_instant_launches_version_unique UNIQUE (version);


--
-- Name: docker_registries docker_registries_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.docker_registries
    ADD CONSTRAINT docker_registries_pkey PRIMARY KEY (name);


--
-- Name: file_parameters file_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.file_parameters
    ADD CONSTRAINT file_parameters_pkey PRIMARY KEY (id);


--
-- Name: genome_reference genome_ref_name_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.genome_reference
    ADD CONSTRAINT genome_ref_name_unique UNIQUE (name);


--
-- Name: genome_reference genome_ref_path_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.genome_reference
    ADD CONSTRAINT genome_ref_path_unique UNIQUE (path);


--
-- Name: genome_reference genome_reference_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.genome_reference
    ADD CONSTRAINT genome_reference_pkey PRIMARY KEY (id);


--
-- Name: info_type info_type_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.info_type
    ADD CONSTRAINT info_type_pkey PRIMARY KEY (id);


--
-- Name: instant_launches instant_launches_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.instant_launches
    ADD CONSTRAINT instant_launches_id_key UNIQUE (id);


--
-- Name: instant_launches instant_launches_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.instant_launches
    ADD CONSTRAINT instant_launches_pkey PRIMARY KEY (id);


--
-- Name: integration_data integration_data_name_email_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.integration_data
    ADD CONSTRAINT integration_data_name_email_unique UNIQUE (integrator_name, integrator_email);


--
-- Name: integration_data integration_data_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.integration_data
    ADD CONSTRAINT integration_data_pkey PRIMARY KEY (id);


--
-- Name: interactive_apps_proxy_settings interactive_apps_proxy_settings_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.interactive_apps_proxy_settings
    ADD CONSTRAINT interactive_apps_proxy_settings_id_key UNIQUE (id);


--
-- Name: interactive_apps_proxy_settings interactive_apps_proxy_settings_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.interactive_apps_proxy_settings
    ADD CONSTRAINT interactive_apps_proxy_settings_id_pkey PRIMARY KEY (id);


--
-- Name: job_limits job_limits_launcher_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_limits
    ADD CONSTRAINT job_limits_launcher_unique UNIQUE (launcher);


--
-- Name: job_limits job_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_limits
    ADD CONSTRAINT job_limits_pkey PRIMARY KEY (id);


--
-- Name: job_status_updates job_status_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_status_updates
    ADD CONSTRAINT job_status_updates_pkey PRIMARY KEY (id);


--
-- Name: job_steps job_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_steps
    ADD CONSTRAINT job_steps_pkey PRIMARY KEY (job_id, step_number);


--
-- Name: job_tickets job_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_tickets
    ADD CONSTRAINT job_tickets_pkey PRIMARY KEY (job_id, ticket);


--
-- Name: job_types job_types_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_types
    ADD CONSTRAINT job_types_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: notif_statuses notif_statuses_analysis_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.notif_statuses
    ADD CONSTRAINT notif_statuses_analysis_id_key UNIQUE (analysis_id);


--
-- Name: notif_statuses notif_statuses_external_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.notif_statuses
    ADD CONSTRAINT notif_statuses_external_id_key UNIQUE (external_id);


--
-- Name: notif_statuses notif_statuses_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.notif_statuses
    ADD CONSTRAINT notif_statuses_id_key UNIQUE (id);


--
-- Name: notif_statuses notif_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.notif_statuses
    ADD CONSTRAINT notif_statuses_pkey PRIMARY KEY (id);


--
-- Name: parameter_groups parameter_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameter_groups
    ADD CONSTRAINT parameter_groups_pkey PRIMARY KEY (id);


--
-- Name: parameter_types parameter_types_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameter_types
    ADD CONSTRAINT parameter_types_pkey PRIMARY KEY (id);


--
-- Name: parameter_values parameter_values_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameter_values
    ADD CONSTRAINT parameter_values_pkey PRIMARY KEY (id);


--
-- Name: parameters parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_pkey PRIMARY KEY (id);


--
-- Name: quick_launch_favorites quick_launch_favorites_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_favorites
    ADD CONSTRAINT quick_launch_favorites_id_pkey PRIMARY KEY (id);


--
-- Name: quick_launch_favorites quick_launch_favorites_user_id_quick_launches_id_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_favorites
    ADD CONSTRAINT quick_launch_favorites_user_id_quick_launches_id_unique UNIQUE (user_id, quick_launch_id);


--
-- Name: quick_launch_global_defaults quick_launch_global_defaults_app_id_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_global_defaults
    ADD CONSTRAINT quick_launch_global_defaults_app_id_unique UNIQUE (app_id);


--
-- Name: quick_launch_global_defaults quick_launch_global_defaults_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_global_defaults
    ADD CONSTRAINT quick_launch_global_defaults_id_pkey PRIMARY KEY (id);


--
-- Name: quick_launch_global_defaults quick_launch_global_defaults_quick_launch_id_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_global_defaults
    ADD CONSTRAINT quick_launch_global_defaults_quick_launch_id_unique UNIQUE (quick_launch_id);


--
-- Name: quick_launch_user_defaults quick_launch_user_defaults_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_user_defaults
    ADD CONSTRAINT quick_launch_user_defaults_id_pkey PRIMARY KEY (id);


--
-- Name: quick_launch_user_defaults quick_launch_user_defaults_user_id_app_id_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_user_defaults
    ADD CONSTRAINT quick_launch_user_defaults_user_id_app_id_unique UNIQUE (user_id, app_id);


--
-- Name: quick_launch_user_defaults quick_launch_user_defaults_user_id_quick_launch_id_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_user_defaults
    ADD CONSTRAINT quick_launch_user_defaults_user_id_quick_launch_id_unique UNIQUE (user_id, quick_launch_id);


--
-- Name: quick_launches quick_launches_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launches
    ADD CONSTRAINT quick_launches_id_pkey PRIMARY KEY (id);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: request_status_codes request_status_codes_display_name_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_status_codes
    ADD CONSTRAINT request_status_codes_display_name_unique UNIQUE (display_name);


--
-- Name: request_status_codes request_status_codes_name_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_status_codes
    ADD CONSTRAINT request_status_codes_name_unique UNIQUE (name);


--
-- Name: request_status_codes request_status_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_status_codes
    ADD CONSTRAINT request_status_codes_pkey PRIMARY KEY (id);


--
-- Name: request_types request_types_name_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_types
    ADD CONSTRAINT request_types_name_unique UNIQUE (name);


--
-- Name: request_types request_types_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_types
    ADD CONSTRAINT request_types_pkey PRIMARY KEY (id);


--
-- Name: request_updates request_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_updates
    ADD CONSTRAINT request_updates_pkey PRIMARY KEY (id);


--
-- Name: requests requests_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: rule_subtype rule_subtype_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.rule_subtype
    ADD CONSTRAINT rule_subtype_pkey PRIMARY KEY (id);


--
-- Name: rule_type rule_type_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.rule_type
    ADD CONSTRAINT rule_type_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: submissions submissions_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_id_pkey PRIMARY KEY (id);


--
-- Name: suggested_groups suggested_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.suggested_groups
    ADD CONSTRAINT suggested_groups_pkey PRIMARY KEY (app_id, app_category_id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: tool_architectures tool_architectures_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_architectures
    ADD CONSTRAINT tool_architectures_pkey PRIMARY KEY (id);


--
-- Name: tool_request_status_codes tool_request_status_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_request_status_codes
    ADD CONSTRAINT tool_request_status_codes_pkey PRIMARY KEY (id);


--
-- Name: tool_request_statuses tool_request_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_request_statuses
    ADD CONSTRAINT tool_request_statuses_pkey PRIMARY KEY (id);


--
-- Name: tool_requests tool_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_requests
    ADD CONSTRAINT tool_requests_pkey PRIMARY KEY (id);


--
-- Name: tool_test_data_files tool_test_data_files_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_test_data_files
    ADD CONSTRAINT tool_test_data_files_pkey PRIMARY KEY (id);


--
-- Name: tool_types tool_types_name_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_types
    ADD CONSTRAINT tool_types_name_key UNIQUE (name);


--
-- Name: tool_types tool_types_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_types
    ADD CONSTRAINT tool_types_pkey PRIMARY KEY (id);


--
-- Name: tools tools_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tools
    ADD CONSTRAINT tools_pkey PRIMARY KEY (id);


--
-- Name: tools tools_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tools
    ADD CONSTRAINT tools_unique UNIQUE (name, version);


--
-- Name: tree_urls tree_urls_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tree_urls
    ADD CONSTRAINT tree_urls_id_key UNIQUE (id);


--
-- Name: tree_urls tree_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tree_urls
    ADD CONSTRAINT tree_urls_pkey PRIMARY KEY (id);


--
-- Name: tree_urls tree_urls_sha1_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tree_urls
    ADD CONSTRAINT tree_urls_sha1_key UNIQUE (sha1);


--
-- Name: user_instant_launches user_instant_launches_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_instant_launches
    ADD CONSTRAINT user_instant_launches_id_key UNIQUE (id);


--
-- Name: user_instant_launches user_instant_launches_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_instant_launches
    ADD CONSTRAINT user_instant_launches_pkey PRIMARY KEY (id);


--
-- Name: user_instant_launches user_instant_launches_user_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_instant_launches
    ADD CONSTRAINT user_instant_launches_user_id_key UNIQUE (user_id);


--
-- Name: user_instant_launches user_instant_launches_user_id_version_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_instant_launches
    ADD CONSTRAINT user_instant_launches_user_id_version_unique UNIQUE (user_id, version);


--
-- Name: user_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (id);


--
-- Name: user_saved_searches user_saved_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_saved_searches
    ADD CONSTRAINT user_saved_searches_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users username_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT username_unique UNIQUE (username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: validation_rule_argument_definitions validation_rule_argument_definitions_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rule_argument_definitions
    ADD CONSTRAINT validation_rule_argument_definitions_id_pkey PRIMARY KEY (id);


--
-- Name: validation_rule_argument_types validation_rule_argument_types_id_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rule_argument_types
    ADD CONSTRAINT validation_rule_argument_types_id_pkey PRIMARY KEY (id);


--
-- Name: validation_rule_arguments validation_rule_arguments_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rule_arguments
    ADD CONSTRAINT validation_rule_arguments_pkey PRIMARY KEY (id);


--
-- Name: validation_rules validation_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rules
    ADD CONSTRAINT validation_rules_pkey PRIMARY KEY (id);


--
-- Name: value_type value_type_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.value_type
    ADD CONSTRAINT value_type_pkey PRIMARY KEY (id);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- Name: ratings votes_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT votes_unique UNIQUE (user_id, app_id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: webhooks_subscription webhooks_subscription_ukey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks_subscription
    ADD CONSTRAINT webhooks_subscription_ukey UNIQUE (webhook_id, topic_id);


--
-- Name: webhooks_topic webhooks_topic_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks_topic
    ADD CONSTRAINT webhooks_topic_pkey PRIMARY KEY (id);


--
-- Name: webhooks_type webhooks_type_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks_type
    ADD CONSTRAINT webhooks_type_pkey PRIMARY KEY (id);


--
-- Name: webhooks_type webhooks_type_ukey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks_type
    ADD CONSTRAINT webhooks_type_ukey UNIQUE (type);


--
-- Name: webhooks webhooks_ukey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_ukey UNIQUE (user_id, url);


--
-- Name: workflow_io_maps workflow_io_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.workflow_io_maps
    ADD CONSTRAINT workflow_io_maps_pkey PRIMARY KEY (id);


--
-- Name: workflow_io_maps workflow_io_maps_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.workflow_io_maps
    ADD CONSTRAINT workflow_io_maps_unique UNIQUE (app_id, target_step, source_step);


--
-- Name: workspace workspace_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_pkey PRIMARY KEY (id);


--
-- Name: app_hierarchy_version_applied; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX app_hierarchy_version_applied ON public.app_hierarchy_version USING btree (applied);


--
-- Name: app_publication_request_status_codes_name_index; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX app_publication_request_status_codes_name_index ON public.app_publication_request_status_codes USING btree (name);


--
-- Name: app_publication_request_statuses_app_publication_request_id_ind; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX app_publication_request_statuses_app_publication_request_id_ind ON public.app_publication_request_statuses USING btree (app_publication_request_id);


--
-- Name: app_publication_requests_app_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX app_publication_requests_app_id_index ON public.app_publication_requests USING btree (app_id);


--
-- Name: app_publication_requests_requestor_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX app_publication_requests_requestor_id_index ON public.app_publication_requests USING btree (requestor_id);


--
-- Name: app_steps_app_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX app_steps_app_id ON public.app_steps USING btree (app_id);


--
-- Name: app_steps_task_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX app_steps_task_id ON public.app_steps USING btree (task_id);


--
-- Name: async_task_behavior_behavior_type_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX async_task_behavior_behavior_type_index ON public.async_task_behavior USING btree (behavior_type);


--
-- Name: async_task_status_id_date_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX async_task_status_id_date_index ON public.async_task_status USING btree (async_task_id, created_date);


--
-- Name: async_tasks_end_date_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX async_tasks_end_date_index ON public.async_tasks USING btree (end_date);


--
-- Name: async_tasks_start_date_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX async_tasks_start_date_index ON public.async_tasks USING btree (start_date);


--
-- Name: async_tasks_type_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX async_tasks_type_index ON public.async_tasks USING btree (type);


--
-- Name: async_tasks_username_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX async_tasks_username_index ON public.async_tasks USING btree (username);


--
-- Name: input_output_mapping_unique_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX input_output_mapping_unique_idx ON public.input_output_mapping USING btree (mapping_id, input, external_input);


--
-- Name: job_status_updates_external_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX job_status_updates_external_id ON public.job_status_updates USING btree (external_id);


--
-- Name: job_status_updates_propagated; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX job_status_updates_propagated ON public.job_status_updates USING btree (propagated, propagation_attempts);


--
-- Name: job_status_updates_unpropagated_with_external_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX job_status_updates_unpropagated_with_external_id ON public.job_status_updates USING btree (propagated, propagation_attempts, external_id) WHERE (propagated = false);


--
-- Name: job_tickets_job_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX job_tickets_job_id_index ON public.job_tickets USING btree (job_id);


--
-- Name: jobs_app_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX jobs_app_id_index ON public.jobs USING btree (app_id);


--
-- Name: jobs_app_id_start_date; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX jobs_app_id_start_date ON public.jobs USING btree (app_id, start_date);


--
-- Name: jobs_end_date_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX jobs_end_date_index ON public.jobs USING btree (end_date);


--
-- Name: jobs_parent_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX jobs_parent_id_index ON public.jobs USING btree (parent_id);


--
-- Name: jobs_start_date_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX jobs_start_date_index ON public.jobs USING btree (start_date);


--
-- Name: jobs_status_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX jobs_status_index ON public.jobs USING btree (status);


--
-- Name: jobs_user_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX jobs_user_id_index ON public.jobs USING btree (user_id);


--
-- Name: parameter_values_parameter_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX parameter_values_parameter_id_idx ON public.parameter_values USING btree (parameter_id);


--
-- Name: parameter_values_parent_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX parameter_values_parent_id_idx ON public.parameter_values USING btree (parent_id);


--
-- Name: request_updates_request_id_created_date_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX request_updates_request_id_created_date_index ON public.request_updates USING btree (request_id, created_date);


--
-- Name: tool_architectures_name_index; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX tool_architectures_name_index ON public.tool_architectures USING btree (name);


--
-- Name: tool_request_status_codes_name_index; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX tool_request_status_codes_name_index ON public.tool_request_status_codes USING btree (name);


--
-- Name: tool_request_statuses_tool_request_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX tool_request_statuses_tool_request_id_index ON public.tool_request_statuses USING btree (tool_request_id);


--
-- Name: tool_requests_requestor_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX tool_requests_requestor_id_index ON public.tool_requests USING btree (requestor_id);


--
-- Name: tool_requests_tool_id_index; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX tool_requests_tool_id_index ON public.tool_requests USING btree (tool_id);


--
-- Name: tree_urls_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX tree_urls_id ON public.tree_urls USING btree (id);


--
-- Name: tree_urls_sha1; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX tree_urls_sha1 ON public.tree_urls USING btree (sha1);


--
-- Name: user_preferences_user_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX user_preferences_user_id_idx ON public.user_preferences USING btree (user_id);


--
-- Name: user_saved_searches_user_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX user_saved_searches_user_id_idx ON public.user_sessions USING btree (user_id);


--
-- Name: user_sessions_user_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX user_sessions_user_id_idx ON public.user_sessions USING btree (user_id);


--
-- Name: validation_rule_arguments_rule_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX validation_rule_arguments_rule_id_idx ON public.validation_rule_arguments USING btree (rule_id);


--
-- Name: validation_rules_parameters_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX validation_rules_parameters_id_idx ON public.validation_rules USING btree (parameter_id);


--
-- Name: workflow_io_maps_app_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX workflow_io_maps_app_id_idx ON public.workflow_io_maps USING btree (app_id);


--
-- Name: workflow_io_maps_source_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX workflow_io_maps_source_idx ON public.workflow_io_maps USING btree (source_step);


--
-- Name: workflow_io_maps_target_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX workflow_io_maps_target_idx ON public.workflow_io_maps USING btree (target_step);


--
-- Name: access_tokens access_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: app_categories app_categories_workspace_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_categories
    ADD CONSTRAINT app_categories_workspace_id_fk FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: app_category_app app_category_app_app_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_category_app
    ADD CONSTRAINT app_category_app_app_category_id_fkey FOREIGN KEY (app_category_id) REFERENCES public.app_categories(id) ON DELETE CASCADE;


--
-- Name: app_category_app app_category_app_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_category_app
    ADD CONSTRAINT app_category_app_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: app_category_group app_category_group_child_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_category_group
    ADD CONSTRAINT app_category_group_child_category_id_fkey FOREIGN KEY (child_category_id) REFERENCES public.app_categories(id) ON DELETE CASCADE;


--
-- Name: app_category_group app_category_group_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_category_group
    ADD CONSTRAINT app_category_group_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES public.app_categories(id) ON DELETE CASCADE;


--
-- Name: app_documentation app_documentation_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_documentation
    ADD CONSTRAINT app_documentation_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: app_documentation app_documentation_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_documentation
    ADD CONSTRAINT app_documentation_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: app_documentation app_documentation_modified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_documentation
    ADD CONSTRAINT app_documentation_modified_by_fkey FOREIGN KEY (modified_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: app_hierarchy_version app_hierarchy_version_applied_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_hierarchy_version
    ADD CONSTRAINT app_hierarchy_version_applied_by_fkey FOREIGN KEY (applied_by) REFERENCES public.users(id);


--
-- Name: apps app_integration_data_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.apps
    ADD CONSTRAINT app_integration_data_id_fk FOREIGN KEY (integration_data_id) REFERENCES public.integration_data(id);


--
-- Name: app_publication_request_statuses app_publication_request_statuses_app_publication_request_id_fke; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_publication_request_statuses
    ADD CONSTRAINT app_publication_request_statuses_app_publication_request_id_fke FOREIGN KEY (app_publication_request_id) REFERENCES public.app_publication_requests(id);


--
-- Name: app_publication_request_statuses app_publication_request_statuses_app_publication_request_status; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_publication_request_statuses
    ADD CONSTRAINT app_publication_request_statuses_app_publication_request_status FOREIGN KEY (app_publication_request_status_code_id) REFERENCES public.app_publication_request_status_codes(id);


--
-- Name: app_publication_requests app_publication_requests_requestor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_publication_requests
    ADD CONSTRAINT app_publication_requests_requestor_id_fkey FOREIGN KEY (requestor_id) REFERENCES public.users(id);


--
-- Name: app_references app_references_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_references
    ADD CONSTRAINT app_references_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: app_steps app_steps_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_steps
    ADD CONSTRAINT app_steps_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: app_steps app_steps_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.app_steps
    ADD CONSTRAINT app_steps_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: apps_htcondor_extra apps_htcondor_extra_apps_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.apps_htcondor_extra
    ADD CONSTRAINT apps_htcondor_extra_apps_id_fkey FOREIGN KEY (apps_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: async_task_behavior async_task_behavior_async_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.async_task_behavior
    ADD CONSTRAINT async_task_behavior_async_task_id_fkey FOREIGN KEY (async_task_id) REFERENCES public.async_tasks(id) ON DELETE CASCADE;


--
-- Name: async_task_status async_task_status_async_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.async_task_status
    ADD CONSTRAINT async_task_status_async_task_id_fkey FOREIGN KEY (async_task_id) REFERENCES public.async_tasks(id) ON DELETE CASCADE;


--
-- Name: authorization_requests authorization_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.authorization_requests
    ADD CONSTRAINT authorization_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bags bags_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.bags
    ADD CONSTRAINT bags_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: container_devices container_devices_container_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_devices
    ADD CONSTRAINT container_devices_container_settings_id_fkey FOREIGN KEY (container_settings_id) REFERENCES public.container_settings(id) ON DELETE CASCADE;


--
-- Name: container_ports container_ports_container_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_ports
    ADD CONSTRAINT container_ports_container_settings_id_fkey FOREIGN KEY (container_settings_id) REFERENCES public.container_settings(id) ON DELETE CASCADE;


--
-- Name: container_settings container_settings_interactive_apps_proxy_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_settings
    ADD CONSTRAINT container_settings_interactive_apps_proxy_settings_id_fkey FOREIGN KEY (interactive_apps_proxy_settings_id) REFERENCES public.interactive_apps_proxy_settings(id) ON DELETE CASCADE;


--
-- Name: container_settings container_settings_tools_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_settings
    ADD CONSTRAINT container_settings_tools_id_fkey FOREIGN KEY (tools_id) REFERENCES public.tools(id) ON DELETE CASCADE;


--
-- Name: container_volumes container_volumes_container_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_volumes
    ADD CONSTRAINT container_volumes_container_settings_id_fkey FOREIGN KEY (container_settings_id) REFERENCES public.container_settings(id) ON DELETE CASCADE;


--
-- Name: container_volumes_from container_volumes_from_container_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_volumes_from
    ADD CONSTRAINT container_volumes_from_container_settings_id_fkey FOREIGN KEY (container_settings_id) REFERENCES public.container_settings(id) ON DELETE CASCADE;


--
-- Name: container_volumes_from container_volumes_from_data_containers_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.container_volumes_from
    ADD CONSTRAINT container_volumes_from_data_containers_id_fkey FOREIGN KEY (data_containers_id) REFERENCES public.data_containers(id) ON DELETE CASCADE;


--
-- Name: data_containers data_containers_container_images_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.data_containers
    ADD CONSTRAINT data_containers_container_images_id_fkey FOREIGN KEY (container_images_id) REFERENCES public.container_images(id);


--
-- Name: default_bags default_bags_bag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_bags
    ADD CONSTRAINT default_bags_bag_id_fkey FOREIGN KEY (bag_id) REFERENCES public.bags(id) ON DELETE CASCADE;


--
-- Name: default_bags default_bags_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_bags
    ADD CONSTRAINT default_bags_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: default_instant_launches default_instant_launches_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.default_instant_launches
    ADD CONSTRAINT default_instant_launches_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: tools deployed_comp_integration_data_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tools
    ADD CONSTRAINT deployed_comp_integration_data_id_fk FOREIGN KEY (integration_data_id) REFERENCES public.integration_data(id);


--
-- Name: file_parameters file_parameters_data_format_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.file_parameters
    ADD CONSTRAINT file_parameters_data_format_fkey FOREIGN KEY (data_format) REFERENCES public.data_formats(id);


--
-- Name: file_parameters file_parameters_data_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.file_parameters
    ADD CONSTRAINT file_parameters_data_source_id_fkey FOREIGN KEY (data_source_id) REFERENCES public.data_source(id);


--
-- Name: file_parameters file_parameters_info_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.file_parameters
    ADD CONSTRAINT file_parameters_info_type_fkey FOREIGN KEY (info_type) REFERENCES public.info_type(id);


--
-- Name: file_parameters file_parameters_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.file_parameters
    ADD CONSTRAINT file_parameters_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(id) ON DELETE CASCADE;


--
-- Name: genome_reference genome_reference_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.genome_reference
    ADD CONSTRAINT genome_reference_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: genome_reference genome_reference_last_modified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.genome_reference
    ADD CONSTRAINT genome_reference_last_modified_by_fkey FOREIGN KEY (last_modified_by) REFERENCES public.users(id);


--
-- Name: input_output_mapping input_output_mapping_input_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.input_output_mapping
    ADD CONSTRAINT input_output_mapping_input_fkey FOREIGN KEY (input) REFERENCES public.parameters(id) ON DELETE CASCADE;


--
-- Name: input_output_mapping input_output_mapping_mapping_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.input_output_mapping
    ADD CONSTRAINT input_output_mapping_mapping_id_fk FOREIGN KEY (mapping_id) REFERENCES public.workflow_io_maps(id) ON DELETE CASCADE;


--
-- Name: input_output_mapping input_output_mapping_output_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.input_output_mapping
    ADD CONSTRAINT input_output_mapping_output_fkey FOREIGN KEY (output) REFERENCES public.parameters(id) ON DELETE CASCADE;


--
-- Name: instant_launches instant_launches_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.instant_launches
    ADD CONSTRAINT instant_launches_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: instant_launches instant_launches_quick_launch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.instant_launches
    ADD CONSTRAINT instant_launches_quick_launch_id_fkey FOREIGN KEY (quick_launch_id) REFERENCES public.quick_launches(id) ON DELETE CASCADE;


--
-- Name: integration_data integration_data_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.integration_data
    ADD CONSTRAINT integration_data_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: job_steps job_steps_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_steps
    ADD CONSTRAINT job_steps_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id);


--
-- Name: job_steps job_steps_job_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_steps
    ADD CONSTRAINT job_steps_job_type_id_fkey FOREIGN KEY (job_type_id) REFERENCES public.job_types(id);


--
-- Name: job_tickets job_tickets_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.job_tickets
    ADD CONSTRAINT job_tickets_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: jobs jobs_job_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_job_type_id_fkey FOREIGN KEY (job_type_id) REFERENCES public.job_types(id);


--
-- Name: jobs jobs_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.jobs(id);


--
-- Name: jobs jobs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: logins logins_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.logins
    ADD CONSTRAINT logins_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: parameter_groups parameter_groups_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameter_groups
    ADD CONSTRAINT parameter_groups_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: parameter_types parameter_types_value_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameter_types
    ADD CONSTRAINT parameter_types_value_type_fkey FOREIGN KEY (value_type_id) REFERENCES public.value_type(id);


--
-- Name: parameter_values parameter_values_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameter_values
    ADD CONSTRAINT parameter_values_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(id) ON DELETE CASCADE;


--
-- Name: parameter_values parameter_values_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameter_values
    ADD CONSTRAINT parameter_values_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parameter_values(id) ON DELETE CASCADE;


--
-- Name: parameters parameters_parameter_groups_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_parameter_groups_id_fkey FOREIGN KEY (parameter_group_id) REFERENCES public.parameter_groups(id) ON DELETE CASCADE;


--
-- Name: parameters parameters_parameter_types_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_parameter_types_fkey FOREIGN KEY (parameter_type) REFERENCES public.parameter_types(id);


--
-- Name: quick_launch_favorites quick_launch_favorites_quick_launch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_favorites
    ADD CONSTRAINT quick_launch_favorites_quick_launch_id_fkey FOREIGN KEY (quick_launch_id) REFERENCES public.quick_launches(id);


--
-- Name: quick_launch_favorites quick_launch_favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_favorites
    ADD CONSTRAINT quick_launch_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: quick_launch_global_defaults quick_launch_global_defaults_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_global_defaults
    ADD CONSTRAINT quick_launch_global_defaults_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id);


--
-- Name: quick_launch_global_defaults quick_launch_global_defaults_quick_launch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_global_defaults
    ADD CONSTRAINT quick_launch_global_defaults_quick_launch_id_fkey FOREIGN KEY (quick_launch_id) REFERENCES public.quick_launches(id);


--
-- Name: quick_launch_user_defaults quick_launch_user_defaults_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_user_defaults
    ADD CONSTRAINT quick_launch_user_defaults_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id);


--
-- Name: quick_launch_user_defaults quick_launch_user_defaults_quick_launch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_user_defaults
    ADD CONSTRAINT quick_launch_user_defaults_quick_launch_id_fkey FOREIGN KEY (quick_launch_id) REFERENCES public.quick_launches(id);


--
-- Name: quick_launch_user_defaults quick_launch_user_defaults_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launch_user_defaults
    ADD CONSTRAINT quick_launch_user_defaults_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: quick_launches quick_launches_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launches
    ADD CONSTRAINT quick_launches_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id);


--
-- Name: quick_launches quick_launches_creator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launches
    ADD CONSTRAINT quick_launches_creator_fkey FOREIGN KEY (creator) REFERENCES public.users(id);


--
-- Name: quick_launches quick_launches_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.quick_launches
    ADD CONSTRAINT quick_launches_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: ratings ratings_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: ratings ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: request_updates request_updates_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_updates
    ADD CONSTRAINT request_updates_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id) ON DELETE CASCADE;


--
-- Name: request_updates request_updates_request_status_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_updates
    ADD CONSTRAINT request_updates_request_status_code_id_fkey FOREIGN KEY (request_status_code_id) REFERENCES public.request_status_codes(id) ON DELETE CASCADE;


--
-- Name: request_updates request_updates_updating_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.request_updates
    ADD CONSTRAINT request_updates_updating_user_id_fkey FOREIGN KEY (updating_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: requests requests_request_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_request_type_id_fkey FOREIGN KEY (request_type_id) REFERENCES public.request_types(id) ON DELETE CASCADE;


--
-- Name: requests requests_requesting_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_requesting_user_id_fkey FOREIGN KEY (requesting_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rule_type rule_type_rule_subtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.rule_type
    ADD CONSTRAINT rule_type_rule_subtype_id_fkey FOREIGN KEY (rule_subtype_id) REFERENCES public.rule_subtype(id);


--
-- Name: rule_type_value_type rule_type_value_type_rule_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.rule_type_value_type
    ADD CONSTRAINT rule_type_value_type_rule_type_id_fkey FOREIGN KEY (rule_type_id) REFERENCES public.rule_type(id);


--
-- Name: rule_type_value_type rule_type_value_type_value_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.rule_type_value_type
    ADD CONSTRAINT rule_type_value_type_value_type_id_fkey FOREIGN KEY (value_type_id) REFERENCES public.value_type(id);


--
-- Name: suggested_groups suggested_groups_app_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.suggested_groups
    ADD CONSTRAINT suggested_groups_app_category_id_fkey FOREIGN KEY (app_category_id) REFERENCES public.app_categories(id) ON DELETE CASCADE;


--
-- Name: suggested_groups suggested_groups_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.suggested_groups
    ADD CONSTRAINT suggested_groups_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_job_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_job_type_id_fk FOREIGN KEY (job_type_id) REFERENCES public.job_types(id);


--
-- Name: tasks tasks_tool_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_tool_id_fk FOREIGN KEY (tool_id) REFERENCES public.tools(id);


--
-- Name: tool_request_statuses tool_request_statuses_tool_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_request_statuses
    ADD CONSTRAINT tool_request_statuses_tool_request_id_fkey FOREIGN KEY (tool_request_id) REFERENCES public.tool_requests(id) ON DELETE CASCADE;


--
-- Name: tool_request_statuses tool_request_statuses_tool_request_status_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_request_statuses
    ADD CONSTRAINT tool_request_statuses_tool_request_status_code_id_fkey FOREIGN KEY (tool_request_status_code_id) REFERENCES public.tool_request_status_codes(id);


--
-- Name: tool_request_statuses tool_request_statuses_updater_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_request_statuses
    ADD CONSTRAINT tool_request_statuses_updater_id_fkey FOREIGN KEY (updater_id) REFERENCES public.users(id);


--
-- Name: tool_requests tool_requests_requestor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_requests
    ADD CONSTRAINT tool_requests_requestor_id_fkey FOREIGN KEY (requestor_id) REFERENCES public.users(id);


--
-- Name: tool_requests tool_requests_tool_architecture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_requests
    ADD CONSTRAINT tool_requests_tool_architecture_id_fkey FOREIGN KEY (tool_architecture_id) REFERENCES public.tool_architectures(id);


--
-- Name: tool_requests tool_requests_tool_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_requests
    ADD CONSTRAINT tool_requests_tool_id_fkey FOREIGN KEY (tool_id) REFERENCES public.tools(id);


--
-- Name: tool_test_data_files tool_test_data_files_tool_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_test_data_files
    ADD CONSTRAINT tool_test_data_files_tool_id_fkey FOREIGN KEY (tool_id) REFERENCES public.tools(id) ON DELETE CASCADE;


--
-- Name: tool_type_parameter_type tool_type_parameter_type_parameter_types_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_type_parameter_type
    ADD CONSTRAINT tool_type_parameter_type_parameter_types_fkey FOREIGN KEY (parameter_type_id) REFERENCES public.parameter_types(id);


--
-- Name: tool_type_parameter_type tool_type_parameter_type_tool_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tool_type_parameter_type
    ADD CONSTRAINT tool_type_parameter_type_tool_type_id_fkey FOREIGN KEY (tool_type_id) REFERENCES public.tool_types(id);


--
-- Name: tools tools_container_image_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tools
    ADD CONSTRAINT tools_container_image_fkey FOREIGN KEY (container_images_id) REFERENCES public.container_images(id);


--
-- Name: tools tools_tool_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tools
    ADD CONSTRAINT tools_tool_type_id_fkey FOREIGN KEY (tool_type_id) REFERENCES public.tool_types(id);


--
-- Name: webhooks_subscription topic_id_topic_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks_subscription
    ADD CONSTRAINT topic_id_topic_fkey FOREIGN KEY (topic_id) REFERENCES public.webhooks_topic(id) ON DELETE CASCADE;


--
-- Name: user_instant_launches user_instant_launches_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_instant_launches
    ADD CONSTRAINT user_instant_launches_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: user_instant_launches user_instant_launches_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_instant_launches
    ADD CONSTRAINT user_instant_launches_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_preferences user_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_saved_searches user_saved_searches_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_saved_searches
    ADD CONSTRAINT user_saved_searches_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: validation_rule_argument_definitions validation_rule_argument_definitions_argument_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rule_argument_definitions
    ADD CONSTRAINT validation_rule_argument_definitions_argument_type_id_fkey FOREIGN KEY (argument_type_id) REFERENCES public.validation_rule_argument_types(id) ON DELETE CASCADE;


--
-- Name: validation_rule_argument_definitions validation_rule_argument_definitions_rule_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rule_argument_definitions
    ADD CONSTRAINT validation_rule_argument_definitions_rule_type_id_fkey FOREIGN KEY (rule_type_id) REFERENCES public.rule_type(id) ON DELETE CASCADE;


--
-- Name: validation_rule_arguments validation_rule_arguments_validation_rules_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rule_arguments
    ADD CONSTRAINT validation_rule_arguments_validation_rules_id_fkey FOREIGN KEY (rule_id) REFERENCES public.validation_rules(id) ON DELETE CASCADE;


--
-- Name: validation_rules validation_rules_parameters_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rules
    ADD CONSTRAINT validation_rules_parameters_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(id) ON DELETE CASCADE;


--
-- Name: validation_rules validation_rules_rule_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.validation_rules
    ADD CONSTRAINT validation_rules_rule_type_fkey FOREIGN KEY (rule_type) REFERENCES public.rule_type(id);


--
-- Name: webhooks_subscription webhook_id_topic_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks_subscription
    ADD CONSTRAINT webhook_id_topic_fkey FOREIGN KEY (webhook_id) REFERENCES public.webhooks(id) ON DELETE CASCADE;


--
-- Name: webhooks webhooks_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.webhooks_type(id);


--
-- Name: webhooks webhooks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: workflow_io_maps workflow_io_maps_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.workflow_io_maps
    ADD CONSTRAINT workflow_io_maps_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: workflow_io_maps workflow_io_maps_source_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.workflow_io_maps
    ADD CONSTRAINT workflow_io_maps_source_fkey FOREIGN KEY (source_step) REFERENCES public.app_steps(id) ON DELETE CASCADE;


--
-- Name: workflow_io_maps workflow_io_maps_target_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.workflow_io_maps
    ADD CONSTRAINT workflow_io_maps_target_fkey FOREIGN KEY (target_step) REFERENCES public.app_steps(id) ON DELETE CASCADE;


--
-- Name: workspace workspace_root_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_root_category_id_fkey FOREIGN KEY (root_category_id) REFERENCES public.app_categories(id) ON DELETE CASCADE;


--
-- Name: workspace workspace_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\connect metadata

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.23
-- Dumped by pg_dump version 9.6.23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: target_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.target_enum AS ENUM (
    'analysis',
    'app',
    'avu',
    'file',
    'folder',
    'user',
    'quick_launch',
    'instant_launch'
);


ALTER TYPE public.target_enum OWNER TO postgres;

--
-- Name: attribute_synonyms(uuid); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.attribute_synonyms(uuid) RETURNS TABLE(id uuid, name character varying, description character varying, required boolean, value_type_id uuid)
    LANGUAGE sql
    AS $_$
    WITH RECURSIVE synonyms(attribute_id, synonym_id) AS (
            SELECT attribute_id, synonym_id
            FROM attr_synonyms
        UNION
            SELECT s.attribute_id AS attribute_id,
                   s0.synonym_id AS synonym_id
            FROM attr_synonyms s, synonyms s0
            WHERE s0.attribute_id = s.synonym_id
    )
    SELECT a.id, a.name, a.description, a.required, a.value_type_id
    FROM (
            SELECT synonym_id AS id FROM synonyms
            WHERE attribute_id = $1
            AND synonym_id != $1
        UNION
            SELECT attribute_id AS id FROM synonyms
            WHERE synonym_id = $1
            AND synonym_id != $1
    ) AS s
    JOIN attributes a ON s.id = a.id
$_$;


ALTER FUNCTION public.attribute_synonyms(uuid) OWNER TO de;

--
-- Name: first_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.first_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $1
$_$;


ALTER FUNCTION public.first_agg(anyelement, anyelement) OWNER TO de;

--
-- Name: last_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.last_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $2
$_$;


ALTER FUNCTION public.last_agg(anyelement, anyelement) OWNER TO de;

--
-- Name: ontology_class_hierarchy(character varying, character varying); Type: FUNCTION; Schema: public; Owner: de
--

CREATE FUNCTION public.ontology_class_hierarchy(character varying, character varying) RETURNS TABLE(parent_iri character varying, iri character varying, label character varying)
    LANGUAGE sql
    AS $_$
    WITH RECURSIVE subclasses AS
    (
      (SELECT h.class_iri AS parent_iri, c.iri, c.label
       FROM ontology_classes c
         LEFT JOIN ontology_hierarchies h ON h.ontology_version = $1 AND
                                             h.subclass_iri = c.iri
       WHERE c.ontology_version = $1 AND
             c.iri = $2
       LIMIT 1)
      UNION
      (SELECT h.class_iri AS parent_iri, c.iri, c.label
       FROM subclasses sc, ontology_classes c
         JOIN ontology_hierarchies h ON h.subclass_iri = c.iri
       WHERE c.ontology_version = $1 AND
             h.ontology_version = $1 AND
             h.class_iri = sc.iri)
    )
    SELECT * FROM subclasses
$_$;


ALTER FUNCTION public.ontology_class_hierarchy(character varying, character varying) OWNER TO de;

--
-- Name: first(anyelement); Type: AGGREGATE; Schema: public; Owner: de
--

CREATE AGGREGATE public.first(anyelement) (
    SFUNC = public.first_agg,
    STYPE = anyelement
);


ALTER AGGREGATE public.first(anyelement) OWNER TO de;

--
-- Name: last(anyelement); Type: AGGREGATE; Schema: public; Owner: de
--

CREATE AGGREGATE public.last(anyelement) (
    SFUNC = public.last_agg,
    STYPE = anyelement
);


ALTER AGGREGATE public.last(anyelement) OWNER TO de;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attached_tags; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.attached_tags (
    target_id uuid NOT NULL,
    target_type public.target_enum NOT NULL,
    tag_id uuid NOT NULL,
    attacher_id character varying(512),
    attached_on timestamp without time zone DEFAULT now() NOT NULL,
    detacher_id character varying(512) DEFAULT NULL::character varying,
    detached_on timestamp without time zone
);


ALTER TABLE public.attached_tags OWNER TO de;

--
-- Name: attr_attrs; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.attr_attrs (
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL,
    display_order integer NOT NULL,
    CONSTRAINT attr_attrs_parent_different_from_child CHECK ((parent_id <> child_id))
);


ALTER TABLE public.attr_attrs OWNER TO de;

--
-- Name: attr_enum_values; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.attr_enum_values (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    attribute_id uuid NOT NULL,
    value text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    display_order integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.attr_enum_values OWNER TO de;

--
-- Name: attr_synonyms; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.attr_synonyms (
    attribute_id uuid NOT NULL,
    synonym_id uuid NOT NULL
);


ALTER TABLE public.attr_synonyms OWNER TO de;

--
-- Name: attributes; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.attributes (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    required boolean DEFAULT false NOT NULL,
    value_type_id uuid NOT NULL,
    settings json,
    created_by character varying(512) NOT NULL,
    modified_by character varying(512) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    modified_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.attributes OWNER TO de;

--
-- Name: avus; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.avus (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    attribute text,
    value text,
    unit text,
    target_id uuid NOT NULL,
    target_type public.target_enum NOT NULL,
    created_by character varying(512) NOT NULL,
    modified_by character varying(512) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    modified_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.avus OWNER TO de;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.comments (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    value text NOT NULL,
    post_time timestamp without time zone DEFAULT now() NOT NULL,
    retracted boolean DEFAULT false NOT NULL,
    retracted_by character varying(512) DEFAULT NULL::character varying,
    deleted boolean DEFAULT false NOT NULL,
    target_id uuid NOT NULL,
    target_type public.target_enum NOT NULL,
    owner_id character varying(512) NOT NULL
);


ALTER TABLE public.comments OWNER TO de;

--
-- Name: favorites; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.favorites (
    target_id uuid NOT NULL,
    target_type public.target_enum NOT NULL,
    owner_id character varying(512) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.favorites OWNER TO de;

--
-- Name: file_links; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.file_links (
    file_id uuid NOT NULL,
    target_id uuid NOT NULL,
    target_type public.target_enum NOT NULL,
    owner_id character varying(512) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.file_links OWNER TO de;

--
-- Name: ontologies; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.ontologies (
    version character varying NOT NULL,
    iri character varying,
    deleted boolean DEFAULT false NOT NULL,
    created_by character varying(512) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    xml text NOT NULL
);


ALTER TABLE public.ontologies OWNER TO de;

--
-- Name: ontology_classes; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.ontology_classes (
    ontology_version character varying NOT NULL,
    iri character varying NOT NULL,
    label character varying,
    description text
);


ALTER TABLE public.ontology_classes OWNER TO de;

--
-- Name: ontology_hierarchies; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.ontology_hierarchies (
    ontology_version character varying NOT NULL,
    class_iri character varying NOT NULL,
    subclass_iri character varying NOT NULL
);


ALTER TABLE public.ontology_hierarchies OWNER TO de;

--
-- Name: permanent_id_request_status_codes; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.permanent_id_request_status_codes (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.permanent_id_request_status_codes OWNER TO de;

--
-- Name: permanent_id_request_statuses; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.permanent_id_request_statuses (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    permanent_id_request uuid NOT NULL,
    permanent_id_request_status_code uuid NOT NULL,
    date_assigned timestamp without time zone DEFAULT now() NOT NULL,
    updated_by character varying(512) NOT NULL,
    comments text
);


ALTER TABLE public.permanent_id_request_statuses OWNER TO de;

--
-- Name: permanent_id_request_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.permanent_id_request_types (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    type character varying NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.permanent_id_request_types OWNER TO de;

--
-- Name: permanent_id_requests; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.permanent_id_requests (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    requested_by character varying(512) NOT NULL,
    type uuid,
    target_id uuid NOT NULL,
    target_type public.target_enum NOT NULL,
    original_path text,
    permanent_id text
);


ALTER TABLE public.permanent_id_requests OWNER TO de;

--
-- Name: ratings; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.ratings (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    rating integer NOT NULL,
    target_id uuid NOT NULL,
    target_type public.target_enum NOT NULL,
    owner_id character varying(512) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ratings OWNER TO de;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.tags (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    value character varying(255) NOT NULL,
    description text,
    public boolean DEFAULT false NOT NULL,
    owner_id character varying(512),
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    modified_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tags OWNER TO de;

--
-- Name: template_attrs; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.template_attrs (
    template_id uuid NOT NULL,
    attribute_id uuid NOT NULL,
    display_order integer NOT NULL
);


ALTER TABLE public.template_attrs OWNER TO de;

--
-- Name: templates; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.templates (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    description text,
    deleted boolean DEFAULT false NOT NULL,
    created_by character varying(512) NOT NULL,
    modified_by character varying(512) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    modified_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.templates OWNER TO de;

--
-- Name: value_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.value_types (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.value_types OWNER TO de;

--
-- Name: version; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.version (
    version character varying(20) NOT NULL,
    applied timestamp without time zone DEFAULT now()
);


ALTER TABLE public.version OWNER TO de;

--
-- Data for Name: attached_tags; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.attached_tags (target_id, target_type, tag_id, attacher_id, attached_on, detacher_id, detached_on) FROM stdin;
\.


--
-- Data for Name: attr_attrs; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.attr_attrs (parent_id, child_id, display_order) FROM stdin;
\.


--
-- Data for Name: attr_enum_values; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.attr_enum_values (id, attribute_id, value, is_default, display_order) FROM stdin;
\.


--
-- Data for Name: attr_synonyms; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.attr_synonyms (attribute_id, synonym_id) FROM stdin;
\.


--
-- Data for Name: attributes; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.attributes (id, name, description, required, value_type_id, settings, created_by, modified_by, created_on, modified_on) FROM stdin;
\.


--
-- Data for Name: avus; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.avus (id, attribute, value, unit, target_id, target_type, created_by, modified_by, created_on, modified_on) FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.comments (id, value, post_time, retracted, retracted_by, deleted, target_id, target_type, owner_id) FROM stdin;
\.


--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.favorites (target_id, target_type, owner_id, created_on) FROM stdin;
\.


--
-- Data for Name: file_links; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.file_links (file_id, target_id, target_type, owner_id, created_on) FROM stdin;
\.


--
-- Data for Name: ontologies; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.ontologies (version, iri, deleted, created_by, created_on, xml) FROM stdin;
\.


--
-- Data for Name: ontology_classes; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.ontology_classes (ontology_version, iri, label, description) FROM stdin;
\.


--
-- Data for Name: ontology_hierarchies; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.ontology_hierarchies (ontology_version, class_iri, subclass_iri) FROM stdin;
\.


--
-- Data for Name: permanent_id_request_status_codes; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.permanent_id_request_status_codes (id, name, description) FROM stdin;
439a0a9e-2390-11ec-aa26-0242ac110002	Submitted	The request has been submitted and data moved into iDC staging, but not acted upon by the curators.
439a13b8-2390-11ec-aa26-0242ac110002	Pending	The curators are waiting for a response from the requesting user.
439a14ee-2390-11ec-aa26-0242ac110002	Evaluation	The curators are evaluating the metadata and data structure.
439a15de-2390-11ec-aa26-0242ac110002	Approved	The curators have approved the data and metadata and have submitted it for a public ID.
439a16a6-2390-11ec-aa26-0242ac110002	Completion	The data has been successfully assigned a public ID and moved into the iDC main space.
439a176e-2390-11ec-aa26-0242ac110002	Failed	The data could not be submitted for a public ID.
\.


--
-- Data for Name: permanent_id_request_statuses; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.permanent_id_request_statuses (id, permanent_id_request, permanent_id_request_status_code, date_assigned, updated_by, comments) FROM stdin;
\.


--
-- Data for Name: permanent_id_request_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.permanent_id_request_types (id, type, description) FROM stdin;
439a7f2e-2390-11ec-aa26-0242ac110002	DOI	Data Object Identifier
439a89a6-2390-11ec-aa26-0242ac110002	ARK	Archival Resource Key
\.


--
-- Data for Name: permanent_id_requests; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.permanent_id_requests (id, requested_by, type, target_id, target_type, original_path, permanent_id) FROM stdin;
\.


--
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.ratings (id, rating, target_id, target_type, owner_id, created_on) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.tags (id, value, description, public, owner_id, created_on, modified_on) FROM stdin;
\.


--
-- Data for Name: template_attrs; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.template_attrs (template_id, attribute_id, display_order) FROM stdin;
\.


--
-- Data for Name: templates; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.templates (id, name, description, deleted, created_by, modified_by, created_on, modified_on) FROM stdin;
\.


--
-- Data for Name: value_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.value_types (id, name) FROM stdin;
4cb79d83-e694-4acf-aa60-ddadee087b24	Timestamp
8130ec25-2452-4ff0-b66a-d9d3a6350816	Boolean
29f9f4fd-594c-493d-9560-fe8851084870	Number
c6cb42cd-7c47-47a1-8704-f6582b510acf	Integer
c29b0b10-d660-4582-9eb7-40c4f1699dd6	String
127036ff-ef19-4665-a9a9-7a6878d9813a	Multiline Text
28a1f81a-8b4f-4940-bcd4-e39241bf15dc	URL/URI
b17ed53d-2b10-428f-b38a-c9dec3dc5127	Enum
aaf2ecdc-7d50-11e7-aa7d-f64e9b87c109	OLS Ontology Term
b5bf6e00-47b9-49d4-b842-c9ce8f1e4f81	UAT Ontology Term
449a4bf0-16c8-4e33-bef7-737d1c4e5cde	Grouping
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.version (version, applied) FROM stdin;
1.8.9:20140625.01	2021-10-02 16:51:45.135014
1.8.9:20140707.01	2021-10-02 16:51:45.135014
1.9.2:20140902.01	2021-10-02 16:51:45.135014
2.0.0:20150529.01	2021-10-02 16:51:45.135014
2.0.0:20150601.01	2021-10-02 16:51:45.135014
2.1.0:20150807.01	2021-10-02 16:51:45.135014
2.1.0:20150810.01	2021-10-02 16:51:45.135014
2.1.0:20150811.01	2021-10-02 16:51:45.135014
2.4.0:20151210.01	2021-10-02 16:51:45.135014
2.6.0:20160331.01	2021-10-02 16:51:45.135014
2.7.0:20160513.01	2021-10-02 16:51:45.135014
2.7.0:20160614.01	2021-10-02 16:51:45.135014
2.7.0:20160624.01	2021-10-02 16:51:45.135014
2.8.0:20160705.01	2021-10-02 16:51:45.135014
2.15.0:20170816.01	2021-10-02 16:51:45.135014
2.16.0:20170919.01	2021-10-02 16:51:45.135014
2.17.0:20171026.01	2021-10-02 16:51:45.135014
2.18.0:20171103.01	2021-10-02 16:51:45.135014
2.22.0:20180727.01	2021-10-02 16:51:45.135014
2.36.0:20210218.01	2021-10-02 16:51:45.135014
\.


--
-- Name: attr_enum_values attr_enum_values_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attr_enum_values
    ADD CONSTRAINT attr_enum_values_pkey PRIMARY KEY (id);


--
-- Name: attr_enum_values attr_enum_values_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attr_enum_values
    ADD CONSTRAINT attr_enum_values_unique UNIQUE (attribute_id, value);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id);


--
-- Name: avus avus_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.avus
    ADD CONSTRAINT avus_pkey PRIMARY KEY (id);


--
-- Name: avus avus_unique; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.avus
    ADD CONSTRAINT avus_unique UNIQUE (target_id, target_type, attribute, value, unit);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (owner_id, target_id);


--
-- Name: file_links file_links_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.file_links
    ADD CONSTRAINT file_links_pkey PRIMARY KEY (file_id, target_id, owner_id);


--
-- Name: ontologies ontologies_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ontologies
    ADD CONSTRAINT ontologies_pkey PRIMARY KEY (version);


--
-- Name: ontology_classes ontology_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ontology_classes
    ADD CONSTRAINT ontology_classes_pkey PRIMARY KEY (ontology_version, iri);


--
-- Name: ontology_hierarchies ontology_hierarchies_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ontology_hierarchies
    ADD CONSTRAINT ontology_hierarchies_pkey PRIMARY KEY (ontology_version, class_iri, subclass_iri);


--
-- Name: permanent_id_request_status_codes permanent_id_request_status_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permanent_id_request_status_codes
    ADD CONSTRAINT permanent_id_request_status_codes_pkey PRIMARY KEY (id);


--
-- Name: permanent_id_request_statuses permanent_id_request_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permanent_id_request_statuses
    ADD CONSTRAINT permanent_id_request_statuses_pkey PRIMARY KEY (id);


--
-- Name: permanent_id_request_types permanent_id_request_types_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permanent_id_request_types
    ADD CONSTRAINT permanent_id_request_types_pkey PRIMARY KEY (id);


--
-- Name: permanent_id_requests permanent_id_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permanent_id_requests
    ADD CONSTRAINT permanent_id_requests_pkey PRIMARY KEY (id);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags tags_unique_value_user; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_unique_value_user UNIQUE (value, owner_id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: value_types value_types_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.value_types
    ADD CONSTRAINT value_types_pkey PRIMARY KEY (id);


--
-- Name: value_types value_types_unique_name; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.value_types
    ADD CONSTRAINT value_types_unique_name UNIQUE (name);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- Name: attached_tags_tag_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX attached_tags_tag_id_idx ON public.attached_tags USING btree (tag_id);


--
-- Name: attached_tags_target_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX attached_tags_target_id_idx ON public.attached_tags USING btree (target_id);


--
-- Name: attr_attrs_child_id; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX attr_attrs_child_id ON public.attr_attrs USING btree (child_id);


--
-- Name: attr_attrs_parent_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX attr_attrs_parent_id ON public.attr_attrs USING btree (parent_id);


--
-- Name: attr_enum_values_attribute_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX attr_enum_values_attribute_id ON public.attr_enum_values USING btree (attribute_id);


--
-- Name: attr_synonyms_attribute_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX attr_synonyms_attribute_id ON public.attr_synonyms USING btree (attribute_id);


--
-- Name: attr_synonyms_synonym_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX attr_synonyms_synonym_id ON public.attr_synonyms USING btree (synonym_id);


--
-- Name: avus_avu_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX avus_avu_idx ON public.avus USING btree (attribute, value, unit);


--
-- Name: avus_target_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX avus_target_id_idx ON public.avus USING btree (target_id, target_type);


--
-- Name: comments_target_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX comments_target_id_idx ON public.comments USING btree (target_id);


--
-- Name: file_links_target_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX file_links_target_id_idx ON public.file_links USING btree (target_id);


--
-- Name: permanent_id_request_status_codes_name_unique; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX permanent_id_request_status_codes_name_unique ON public.permanent_id_request_status_codes USING btree (name);


--
-- Name: permanent_id_request_types_unique; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX permanent_id_request_types_unique ON public.permanent_id_request_types USING btree (type);


--
-- Name: permanent_id_requests_unique; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX permanent_id_requests_unique ON public.permanent_id_requests USING btree (target_id, type);


--
-- Name: ratings_owner_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX ratings_owner_id_idx ON public.ratings USING btree (owner_id);


--
-- Name: ratings_target_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX ratings_target_id_idx ON public.ratings USING btree (target_id);


--
-- Name: tags_owner_id_idx; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX tags_owner_id_idx ON public.tags USING btree (owner_id);


--
-- Name: template_attrs_attribute_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX template_attrs_attribute_id ON public.template_attrs USING btree (attribute_id);


--
-- Name: template_attrs_template_id; Type: INDEX; Schema: public; Owner: de
--

CREATE INDEX template_attrs_template_id ON public.template_attrs USING btree (template_id);


--
-- Name: attached_tags attached_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attached_tags
    ADD CONSTRAINT attached_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: attr_attrs attr_attrs_child_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attr_attrs
    ADD CONSTRAINT attr_attrs_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: attr_attrs attr_attrs_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attr_attrs
    ADD CONSTRAINT attr_attrs_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: attr_enum_values attr_enum_values_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attr_enum_values
    ADD CONSTRAINT attr_enum_values_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: attr_synonyms attr_synonyms_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attr_synonyms
    ADD CONSTRAINT attr_synonyms_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: attr_synonyms attr_synonyms_synonym_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attr_synonyms
    ADD CONSTRAINT attr_synonyms_synonym_id_fkey FOREIGN KEY (synonym_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: attributes attributes_value_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_value_type_id_fkey FOREIGN KEY (value_type_id) REFERENCES public.value_types(id);


--
-- Name: ontology_classes ontology_classes_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ontology_classes
    ADD CONSTRAINT ontology_classes_version_fkey FOREIGN KEY (ontology_version) REFERENCES public.ontologies(version) ON DELETE CASCADE;


--
-- Name: ontology_hierarchies ontology_hierarchies_class_iri_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ontology_hierarchies
    ADD CONSTRAINT ontology_hierarchies_class_iri_fkey FOREIGN KEY (ontology_version, class_iri) REFERENCES public.ontology_classes(ontology_version, iri) ON DELETE CASCADE;


--
-- Name: ontology_hierarchies ontology_hierarchies_subclass_iri_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ontology_hierarchies
    ADD CONSTRAINT ontology_hierarchies_subclass_iri_fkey FOREIGN KEY (ontology_version, subclass_iri) REFERENCES public.ontology_classes(ontology_version, iri) ON DELETE CASCADE;


--
-- Name: ontology_hierarchies ontology_hierarchies_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.ontology_hierarchies
    ADD CONSTRAINT ontology_hierarchies_version_fkey FOREIGN KEY (ontology_version) REFERENCES public.ontologies(version) ON DELETE CASCADE;


--
-- Name: permanent_id_request_statuses permanent_id_request_statuses_request_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permanent_id_request_statuses
    ADD CONSTRAINT permanent_id_request_statuses_request_fkey FOREIGN KEY (permanent_id_request) REFERENCES public.permanent_id_requests(id) ON DELETE CASCADE;


--
-- Name: permanent_id_request_statuses permanent_id_request_statuses_status_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permanent_id_request_statuses
    ADD CONSTRAINT permanent_id_request_statuses_status_code_fkey FOREIGN KEY (permanent_id_request_status_code) REFERENCES public.permanent_id_request_status_codes(id);


--
-- Name: permanent_id_requests permanent_id_requests_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permanent_id_requests
    ADD CONSTRAINT permanent_id_requests_type_fkey FOREIGN KEY (type) REFERENCES public.permanent_id_request_types(id);


--
-- Name: template_attrs template_attrs_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.template_attrs
    ADD CONSTRAINT template_attrs_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: template_attrs template_attrs_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.template_attrs
    ADD CONSTRAINT template_attrs_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.templates(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\connect notifications

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.23
-- Dumped by pg_dump version 9.6.23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: acknowledgment_state; Type: TYPE; Schema: public; Owner: de
--

CREATE TYPE public.acknowledgment_state AS ENUM (
    'unreceived',
    'received',
    'acknowledged',
    'dismissed'
);


ALTER TYPE public.acknowledgment_state OWNER TO de;

--
-- Name: analysis_execution_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.analysis_execution_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.analysis_execution_statuses_id_seq OWNER TO de;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: analysis_execution_statuses; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.analysis_execution_statuses (
    id bigint DEFAULT nextval('public.analysis_execution_statuses_id_seq'::regclass) NOT NULL,
    uuid uuid NOT NULL,
    status character varying(32) NOT NULL,
    date_modified timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.analysis_execution_statuses OWNER TO de;

--
-- Name: email_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.email_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.email_notifications_id_seq OWNER TO de;

--
-- Name: email_notification_messages; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.email_notification_messages (
    id bigint DEFAULT nextval('public.email_notifications_id_seq'::regclass) NOT NULL,
    notification_id bigint NOT NULL,
    template character varying(256) NOT NULL,
    address character varying(1024) NOT NULL,
    date_sent timestamp without time zone DEFAULT now() NOT NULL,
    payload text NOT NULL
);


ALTER TABLE public.email_notification_messages OWNER TO de;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO de;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.notifications (
    id bigint DEFAULT nextval('public.notifications_id_seq'::regclass) NOT NULL,
    uuid uuid NOT NULL,
    type character varying(32) NOT NULL,
    user_id bigint NOT NULL,
    subject text NOT NULL,
    seen boolean DEFAULT false NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    date_created timestamp without time zone DEFAULT now() NOT NULL,
    message text NOT NULL
);


ALTER TABLE public.notifications OWNER TO de;

--
-- Name: system_notification_acknowledgments; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.system_notification_acknowledgments (
    user_id bigint NOT NULL,
    system_notification_id bigint NOT NULL,
    state public.acknowledgment_state DEFAULT 'unreceived'::public.acknowledgment_state NOT NULL,
    date_acknowledged timestamp without time zone
);


ALTER TABLE public.system_notification_acknowledgments OWNER TO de;

--
-- Name: system_notification_types_id_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.system_notification_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_notification_types_id_seq OWNER TO de;

--
-- Name: system_notification_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.system_notification_types (
    id bigint DEFAULT nextval('public.system_notification_types_id_seq'::regclass) NOT NULL,
    name character varying(32)
);


ALTER TABLE public.system_notification_types OWNER TO de;

--
-- Name: system_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.system_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_notifications_id_seq OWNER TO de;

--
-- Name: system_notifications; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.system_notifications (
    id bigint DEFAULT nextval('public.system_notifications_id_seq'::regclass) NOT NULL,
    uuid uuid NOT NULL,
    system_notification_type_id bigint NOT NULL,
    date_created timestamp without time zone DEFAULT now() NOT NULL,
    activation_date timestamp without time zone DEFAULT now() NOT NULL,
    deactivation_date timestamp without time zone,
    dismissible boolean DEFAULT false NOT NULL,
    logins_disabled boolean DEFAULT false NOT NULL,
    message text
);


ALTER TABLE public.system_notifications OWNER TO de;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO de;

--
-- Name: users; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.users (
    id bigint DEFAULT nextval('public.users_id_seq'::regclass) NOT NULL,
    username character varying(512) NOT NULL
);


ALTER TABLE public.users OWNER TO de;

--
-- Name: version_id_seq; Type: SEQUENCE; Schema: public; Owner: de
--

CREATE SEQUENCE public.version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.version_id_seq OWNER TO de;

--
-- Name: version; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.version (
    id bigint DEFAULT nextval('public.version_id_seq'::regclass) NOT NULL,
    version character varying(20) NOT NULL,
    applied timestamp without time zone DEFAULT now()
);


ALTER TABLE public.version OWNER TO de;

--
-- Data for Name: analysis_execution_statuses; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.analysis_execution_statuses (id, uuid, status, date_modified) FROM stdin;
\.


--
-- Name: analysis_execution_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.analysis_execution_statuses_id_seq', 1, false);


--
-- Data for Name: email_notification_messages; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.email_notification_messages (id, notification_id, template, address, date_sent, payload) FROM stdin;
\.


--
-- Name: email_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.email_notifications_id_seq', 1, false);


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.notifications (id, uuid, type, user_id, subject, seen, deleted, date_created, message) FROM stdin;
\.


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Data for Name: system_notification_acknowledgments; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.system_notification_acknowledgments (user_id, system_notification_id, state, date_acknowledged) FROM stdin;
\.


--
-- Data for Name: system_notification_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.system_notification_types (id, name) FROM stdin;
1	announcement
2	maintenance
3	warning
\.


--
-- Name: system_notification_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.system_notification_types_id_seq', 3, true);


--
-- Data for Name: system_notifications; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.system_notifications (id, uuid, system_notification_type_id, date_created, activation_date, deactivation_date, dismissible, logins_disabled, message) FROM stdin;
\.


--
-- Name: system_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.system_notifications_id_seq', 1, false);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.users (id, username) FROM stdin;
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Data for Name: version; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.version (id, version, applied) FROM stdin;
1	1.8.0:20130110.01	2021-10-02 16:51:58.16061
2	1.8.0:20130204.01	2021-10-02 16:51:58.16061
3	1.8.0:20130516.01	2021-10-02 16:51:58.16061
\.


--
-- Name: version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: de
--

SELECT pg_catalog.setval('public.version_id_seq', 3, true);


--
-- Name: analysis_execution_statuses analysis_execution_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.analysis_execution_statuses
    ADD CONSTRAINT analysis_execution_statuses_pkey PRIMARY KEY (id);


--
-- Name: email_notification_messages email_notification_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.email_notification_messages
    ADD CONSTRAINT email_notification_messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: system_notification_acknowledgments system_notification_acknowledgments_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.system_notification_acknowledgments
    ADD CONSTRAINT system_notification_acknowledgments_pkey PRIMARY KEY (user_id, system_notification_id);


--
-- Name: system_notification_types system_notification_types_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.system_notification_types
    ADD CONSTRAINT system_notification_types_pkey PRIMARY KEY (id);


--
-- Name: system_notifications system_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.system_notifications
    ADD CONSTRAINT system_notifications_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (id);


--
-- Name: email_notification_messages email_notification_messages_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.email_notification_messages
    ADD CONSTRAINT email_notification_messages_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: system_notification_acknowledgments system_notification_acknowledgments_system_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.system_notification_acknowledgments
    ADD CONSTRAINT system_notification_acknowledgments_system_notification_id_fkey FOREIGN KEY (system_notification_id) REFERENCES public.system_notifications(id);


--
-- Name: system_notification_acknowledgments system_notification_acknowledgments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.system_notification_acknowledgments
    ADD CONSTRAINT system_notification_acknowledgments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: system_notifications system_notifications_system_notification_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.system_notifications
    ADD CONSTRAINT system_notifications_system_notification_type_id_fkey FOREIGN KEY (system_notification_type_id) REFERENCES public.system_notification_types(id);


--
-- PostgreSQL database dump complete
--

\connect permissions

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.23
-- Dumped by pg_dump version 9.6.23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: subject_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.subject_type_enum AS ENUM (
    'user',
    'group'
);


ALTER TYPE public.subject_type_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: permission_levels; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.permission_levels (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    precedence integer NOT NULL
);


ALTER TABLE public.permission_levels OWNER TO de;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.permissions (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    subject_id uuid NOT NULL,
    resource_id uuid NOT NULL,
    permission_level_id uuid NOT NULL
);


ALTER TABLE public.permissions OWNER TO de;

--
-- Name: resource_types; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.resource_types (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.resource_types OWNER TO de;

--
-- Name: resources; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.resources (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(64) NOT NULL,
    resource_type_id uuid NOT NULL
);


ALTER TABLE public.resources OWNER TO de;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.subjects (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    subject_id character varying(64) NOT NULL,
    subject_type public.subject_type_enum NOT NULL
);


ALTER TABLE public.subjects OWNER TO de;

--
-- Name: version; Type: TABLE; Schema: public; Owner: de
--

CREATE TABLE public.version (
    version character varying(20) NOT NULL,
    applied timestamp without time zone DEFAULT now()
);


ALTER TABLE public.version OWNER TO de;

--
-- Data for Name: permission_levels; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.permission_levels (id, name, description, precedence) FROM stdin;
536e12b2-2390-11ec-9940-0242ac110002	own	Implies that the user can assign permissions to, read, and modify a resource.	0
536e1e38-2390-11ec-9940-0242ac110002	write	Implies that the user can read and modify a resource.	1
536e1fbe-2390-11ec-9940-0242ac110002	admin	Implies that a user can read and make limited motifications to a resource.	2
536e20e0-2390-11ec-9940-0242ac110002	read	Implies that a user can read a resource.	3
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.permissions (id, subject_id, resource_id, permission_level_id) FROM stdin;
\.


--
-- Data for Name: resource_types; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.resource_types (id, name, description) FROM stdin;
53710382-2390-11ec-9940-0242ac110002	app	A Discovery Environment application.
5371130e-2390-11ec-9940-0242ac110002	analysis	The results of running a Discovery Environment application.
5371153e-2390-11ec-9940-0242ac110002	tool	A Discovery Environment tool run by an application.
\.


--
-- Data for Name: resources; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.resources (id, name, resource_type_id) FROM stdin;
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.subjects (id, subject_id, subject_type) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: public; Owner: de
--

COPY public.version (version, applied) FROM stdin;
2.8.0:20160725.01	2021-10-02 16:52:12.234739
2.11.0:20170308.01	2021-10-02 16:52:12.234739
\.


--
-- Name: permission_levels permission_levels_name_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permission_levels
    ADD CONSTRAINT permission_levels_name_key UNIQUE (name);


--
-- Name: permission_levels permission_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permission_levels
    ADD CONSTRAINT permission_levels_pkey PRIMARY KEY (id);


--
-- Name: permission_levels permission_levels_precedence_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permission_levels
    ADD CONSTRAINT permission_levels_precedence_key UNIQUE (precedence);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: resource_types resource_types_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.resource_types
    ADD CONSTRAINT resource_types_pkey PRIMARY KEY (id);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_subject_id_key; Type: CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_subject_id_key UNIQUE (subject_id);


--
-- Name: permissions_subject_resource_unique; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX permissions_subject_resource_unique ON public.permissions USING btree (subject_id, resource_id);


--
-- Name: resource_types_name_unique; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX resource_types_name_unique ON public.resource_types USING btree (lower(btrim(regexp_replace((name)::text, '\s+'::text, ' '::text, 'g'::text))));


--
-- Name: resources_name_unique; Type: INDEX; Schema: public; Owner: de
--

CREATE UNIQUE INDEX resources_name_unique ON public.resources USING btree (name, resource_type_id);


--
-- Name: permissions permissions_permission_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_permission_level_id_fkey FOREIGN KEY (permission_level_id) REFERENCES public.permission_levels(id);


--
-- Name: permissions permissions_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resources(id) ON DELETE CASCADE;


--
-- Name: permissions permissions_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: resources resources_resource_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: de
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_resource_type_id_fkey FOREIGN KEY (resource_type_id) REFERENCES public.resource_types(id);


--
-- PostgreSQL database dump complete
--

\connect postgres

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.23
-- Dumped by pg_dump version 9.6.23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

\connect template1

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.23
-- Dumped by pg_dump version 9.6.23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

