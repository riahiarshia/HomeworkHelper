--
-- PostgreSQL database dump
--

\restrict Hlul0jho17hMOeoYtQfI8l8cK5oqSUccwlh1X0ORsnKvI3vfpGRZ3t5wOQgbgnZ

-- Dumped from database version 15.14
-- Dumped by pg_dump version 16.10 (Homebrew)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: reset_monthly_usage_on_renewal(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_monthly_usage_on_renewal(p_user_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO monthly_usage_summary (user_id, year, month, subscription_renewals_count)
    VALUES (
        p_user_id,
        EXTRACT(YEAR FROM CURRENT_DATE),
        EXTRACT(MONTH FROM CURRENT_DATE),
        1
    )
    ON CONFLICT (user_id, year, month)
    DO UPDATE SET
        subscription_renewals_count = monthly_usage_summary.subscription_renewals_count + 1,
        updated_at = CURRENT_TIMESTAMP;
    
    RAISE NOTICE 'Monthly usage tracking reset for user % in %-%', 
        p_user_id, 
        EXTRACT(YEAR FROM CURRENT_DATE), 
        EXTRACT(MONTH FROM CURRENT_DATE);
END;
$$;


--
-- Name: set_trial_dates(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_trial_dates() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.subscription_status = 'trial' AND NEW.subscription_end_date IS NULL THEN
        NEW.subscription_start_date = NOW();
        NEW.subscription_end_date = NOW() + INTERVAL '14 days';
        NEW.trial_started_at = NOW();
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: update_monthly_usage_summary(uuid, bigint, numeric, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_monthly_usage_summary(p_user_id uuid, p_tokens bigint, p_cost_usd numeric, p_api_calls integer DEFAULT 1) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO monthly_usage_summary (user_id, year, month, total_tokens, total_cost_usd, api_calls_count)
    VALUES (
        p_user_id,
        EXTRACT(YEAR FROM CURRENT_DATE),
        EXTRACT(MONTH FROM CURRENT_DATE),
        p_tokens,
        p_cost_usd,
        p_api_calls
    )
    ON CONFLICT (user_id, year, month)
    DO UPDATE SET
        total_tokens = monthly_usage_summary.total_tokens + p_tokens,
        total_cost_usd = monthly_usage_summary.total_cost_usd + p_cost_usd,
        api_calls_count = monthly_usage_summary.api_calls_count + p_api_calls,
        updated_at = CURRENT_TIMESTAMP;
END;
$$;


--
-- Name: update_trial_history_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_trial_history_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_user_entitlements_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_user_entitlements_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(255),
    auth_provider character varying(50),
    subscription_status character varying(50) DEFAULT 'trial'::character varying NOT NULL,
    subscription_start_date timestamp without time zone,
    subscription_end_date timestamp without time zone,
    trial_started_at timestamp without time zone DEFAULT now(),
    promo_code_used character varying(100),
    promo_activated_at timestamp without time zone,
    stripe_customer_id character varying(255),
    stripe_subscription_id character varying(255),
    is_active boolean DEFAULT true,
    is_banned boolean DEFAULT false,
    banned_reason text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    last_active_at timestamp without time zone,
    password_hash character varying(255),
    apple_user_id character varying(255),
    apple_original_transaction_id character varying(255),
    apple_product_id character varying(255),
    apple_environment character varying(50) DEFAULT 'Production'::character varying
);


--
-- Name: active_users; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.active_users AS
 SELECT users.user_id,
    users.email,
    users.username,
    users.subscription_status,
    users.subscription_end_date,
    EXTRACT(day FROM ((users.subscription_end_date)::timestamp with time zone - now())) AS days_remaining
   FROM public.users
  WHERE ((users.subscription_end_date > now()) AND (users.is_active = true) AND (users.is_banned = false));


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(50) DEFAULT 'admin'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    last_login timestamp without time zone
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


--
-- Name: user_api_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_api_usage (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    endpoint character varying(100) NOT NULL,
    model character varying(50) NOT NULL,
    prompt_tokens integer DEFAULT 0 NOT NULL,
    completion_tokens integer DEFAULT 0 NOT NULL,
    total_tokens integer DEFAULT 0 NOT NULL,
    cost_usd numeric(10,6) DEFAULT 0.000000 NOT NULL,
    problem_id character varying(255),
    session_id character varying(255),
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now(),
    device_id character varying(255)
);


--
-- Name: TABLE user_api_usage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_api_usage IS 'Tracks OpenAI API usage per user for cost management and analytics';


--
-- Name: COLUMN user_api_usage.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.id IS 'Primary key';


--
-- Name: COLUMN user_api_usage.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.user_id IS 'Foreign key to users table';


--
-- Name: COLUMN user_api_usage.endpoint; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.endpoint IS 'API endpoint used (analyze_homework, generate_hint, etc.)';


--
-- Name: COLUMN user_api_usage.model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.model IS 'OpenAI model used (gpt-4o, gpt-4o-mini, etc.)';


--
-- Name: COLUMN user_api_usage.prompt_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.prompt_tokens IS 'Number of tokens in the prompt';


--
-- Name: COLUMN user_api_usage.completion_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.completion_tokens IS 'Number of tokens in the completion';


--
-- Name: COLUMN user_api_usage.total_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.total_tokens IS 'Total tokens used (prompt + completion)';


--
-- Name: COLUMN user_api_usage.cost_usd; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.cost_usd IS 'Cost in USD based on OpenAI pricing';


--
-- Name: COLUMN user_api_usage.problem_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.problem_id IS 'Optional: Reference to homework problem';


--
-- Name: COLUMN user_api_usage.session_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.session_id IS 'Optional: Group related API calls';


--
-- Name: COLUMN user_api_usage.metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.metadata IS 'Additional metadata (JSON)';


--
-- Name: COLUMN user_api_usage.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_api_usage.created_at IS 'Timestamp of API call';


--
-- Name: daily_usage_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.daily_usage_summary AS
 SELECT date(uau.created_at) AS date,
    count(uau.id) AS api_calls,
    count(DISTINCT uau.user_id) AS unique_users,
    sum(uau.prompt_tokens) AS prompt_tokens,
    sum(uau.completion_tokens) AS completion_tokens,
    sum(uau.total_tokens) AS total_tokens,
    sum(uau.cost_usd) AS cost_usd
   FROM public.user_api_usage uau
  WHERE (uau.created_at >= (CURRENT_DATE - '90 days'::interval))
  GROUP BY (date(uau.created_at))
  ORDER BY (date(uau.created_at)) DESC;


--
-- Name: VIEW daily_usage_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.daily_usage_summary IS 'Daily usage statistics (last 90 days)';


--
-- Name: device_logins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_logins (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    device_id character varying(255) NOT NULL,
    login_time timestamp without time zone DEFAULT now(),
    ip_address inet,
    user_agent text,
    device_info jsonb,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE device_logins; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.device_logins IS 'Tracks all device login attempts for analytics and fraud detection';


--
-- Name: device_logins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.device_logins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device_logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.device_logins_id_seq OWNED BY public.device_logins.id;


--
-- Name: device_usage_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.device_usage_summary AS
 SELECT uau.device_id,
    count(uau.id) AS total_api_calls,
    count(DISTINCT uau.user_id) AS unique_users,
    sum(uau.prompt_tokens) AS total_prompt_tokens,
    sum(uau.completion_tokens) AS total_completion_tokens,
    sum(uau.total_tokens) AS total_tokens,
    sum(uau.cost_usd) AS total_cost_usd,
    max(uau.created_at) AS last_api_call,
    min(uau.created_at) AS first_api_call
   FROM public.user_api_usage uau
  WHERE (uau.device_id IS NOT NULL)
  GROUP BY uau.device_id
  ORDER BY (sum(uau.cost_usd)) DESC;


--
-- Name: VIEW device_usage_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.device_usage_summary IS 'Aggregated API usage per device';


--
-- Name: endpoint_usage_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.endpoint_usage_summary AS
 SELECT uau.endpoint,
    uau.model,
    count(uau.id) AS api_calls,
    sum(uau.prompt_tokens) AS prompt_tokens,
    sum(uau.completion_tokens) AS completion_tokens,
    sum(uau.total_tokens) AS total_tokens,
    sum(uau.cost_usd) AS cost_usd,
    avg(uau.total_tokens) AS avg_tokens_per_call,
    avg(uau.cost_usd) AS avg_cost_per_call
   FROM public.user_api_usage uau
  GROUP BY uau.endpoint, uau.model
  ORDER BY (sum(uau.cost_usd)) DESC;


--
-- Name: VIEW endpoint_usage_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.endpoint_usage_summary IS 'Usage statistics by endpoint and model';


--
-- Name: entitlements_ledger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entitlements_ledger (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id text NOT NULL,
    subscription_group_id text NOT NULL,
    original_transaction_id_hash text NOT NULL,
    ever_trial boolean DEFAULT false NOT NULL,
    status text NOT NULL,
    first_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT entitlements_ledger_status_check CHECK ((status = ANY (ARRAY['active'::text, 'expired'::text, 'canceled'::text])))
);


--
-- Name: expired_users; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.expired_users AS
 SELECT users.user_id,
    users.email,
    users.username,
    users.subscription_status,
    users.subscription_end_date,
    EXTRACT(day FROM (now() - (users.subscription_end_date)::timestamp with time zone)) AS days_expired
   FROM public.users
  WHERE (users.subscription_end_date < now());


--
-- Name: fraud_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fraud_flags (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    device_id character varying(255),
    reason text NOT NULL,
    severity character varying(20) DEFAULT 'low'::character varying,
    details jsonb,
    resolved boolean DEFAULT false,
    resolved_at timestamp without time zone,
    resolved_by character varying(255),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE fraud_flags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.fraud_flags IS 'Flags suspicious activity patterns for manual review';


--
-- Name: fraud_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fraud_flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fraud_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fraud_flags_id_seq OWNED BY public.fraud_flags.id;


--
-- Name: monthly_usage_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.monthly_usage_summary AS
 SELECT u.user_id,
    u.username,
    u.email,
    date_trunc('month'::text, uau.created_at) AS month,
    count(uau.id) AS api_calls,
    sum(uau.prompt_tokens) AS prompt_tokens,
    sum(uau.completion_tokens) AS completion_tokens,
    sum(uau.total_tokens) AS total_tokens,
    sum(uau.cost_usd) AS cost_usd
   FROM (public.users u
     LEFT JOIN public.user_api_usage uau ON (((u.user_id)::text = (uau.user_id)::text)))
  WHERE (uau.created_at >= date_trunc('month'::text, (now() - '1 year'::interval)))
  GROUP BY u.user_id, u.username, u.email, (date_trunc('month'::text, uau.created_at))
  ORDER BY (date_trunc('month'::text, uau.created_at)) DESC, (sum(uau.cost_usd)) DESC NULLS LAST;


--
-- Name: VIEW monthly_usage_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.monthly_usage_summary IS 'Monthly aggregated usage per user (last 12 months)';


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    used boolean DEFAULT false,
    used_at timestamp without time zone
);


--
-- Name: TABLE password_reset_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.password_reset_tokens IS 'Stores tokens for password reset functionality';


--
-- Name: COLUMN password_reset_tokens.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.id IS 'Primary key';


--
-- Name: COLUMN password_reset_tokens.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.user_id IS 'Foreign key to users table';


--
-- Name: COLUMN password_reset_tokens.token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.token IS 'Secure random token for password reset';


--
-- Name: COLUMN password_reset_tokens.expires_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.expires_at IS 'Token expiration time (1 hour from creation)';


--
-- Name: COLUMN password_reset_tokens.used; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.used IS 'Whether the token has been used';


--
-- Name: COLUMN password_reset_tokens.used_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.used_at IS 'When the token was used';


--
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.password_reset_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.password_reset_tokens_id_seq OWNED BY public.password_reset_tokens.id;


--
-- Name: promo_code_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.promo_code_stats AS
SELECT
    NULL::character varying(100) AS code,
    NULL::integer AS duration_days,
    NULL::integer AS uses_total,
    NULL::integer AS uses_remaining,
    NULL::boolean AS active,
    NULL::bigint AS actual_uses,
    NULL::timestamp without time zone AS created_at;


--
-- Name: promo_code_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promo_code_usage (
    id integer NOT NULL,
    promo_code_id integer,
    user_id character varying(255),
    activated_at timestamp without time zone DEFAULT now(),
    ip_address character varying(50)
);


--
-- Name: promo_code_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promo_code_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promo_code_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promo_code_usage_id_seq OWNED BY public.promo_code_usage.id;


--
-- Name: promo_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promo_codes (
    id integer NOT NULL,
    code character varying(100) NOT NULL,
    duration_days integer NOT NULL,
    uses_total integer DEFAULT '-1'::integer,
    uses_remaining integer,
    used_count integer DEFAULT 0,
    active boolean DEFAULT true,
    starts_at timestamp without time zone,
    expires_at timestamp without time zone,
    created_by character varying(255),
    description text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: promo_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promo_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promo_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promo_codes_id_seq OWNED BY public.promo_codes.id;


--
-- Name: subscription_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_history (
    id integer NOT NULL,
    user_id character varying(255),
    event_type character varying(50) NOT NULL,
    old_status character varying(50),
    new_status character varying(50),
    old_end_date timestamp without time zone,
    new_end_date timestamp without time zone,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: subscription_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscription_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscription_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscription_history_id_seq OWNED BY public.subscription_history.id;


--
-- Name: trial_usage_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trial_usage_history (
    id integer NOT NULL,
    original_transaction_id character varying(255) NOT NULL,
    user_id uuid,
    apple_product_id character varying(255),
    had_intro_offer boolean DEFAULT false,
    had_free_trial boolean DEFAULT false,
    trial_start_date timestamp without time zone,
    trial_end_date timestamp without time zone,
    apple_environment character varying(50),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE trial_usage_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.trial_usage_history IS 'Tracks which Apple original_transaction_ids have received trials. 
This table persists even when user accounts are deleted to prevent trial abuse.
The original_transaction_id is tied to the Apple ID, not our user account.
This is minimal, purpose-limited data retained only for fraud prevention (GDPR/CCPA compliant).';


--
-- Name: COLUMN trial_usage_history.original_transaction_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.trial_usage_history.original_transaction_id IS 'Apple''s stable identifier that persists across renewals and restores. 
Tied to the user''s Apple ID, not our app account.';


--
-- Name: COLUMN trial_usage_history.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.trial_usage_history.user_id IS 'Reference to our user account. Set to NULL when account is deleted for privacy.';


--
-- Name: COLUMN trial_usage_history.had_intro_offer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.trial_usage_history.had_intro_offer IS 'True if this transaction used any introductory offer (includes free trials and discounted periods).';


--
-- Name: COLUMN trial_usage_history.had_free_trial; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.trial_usage_history.had_free_trial IS 'True if this transaction specifically used a free trial period.';


--
-- Name: COLUMN trial_usage_history.apple_environment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.trial_usage_history.apple_environment IS 'Sandbox or Production - helps distinguish test vs real subscriptions.';


--
-- Name: trial_usage_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trial_usage_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trial_usage_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trial_usage_history_id_seq OWNED BY public.trial_usage_history.id;


--
-- Name: user_api_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_api_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_api_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_api_usage_id_seq OWNED BY public.user_api_usage.id;


--
-- Name: user_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_devices (
    user_id character varying(255) NOT NULL,
    device_id character varying(255) NOT NULL,
    device_name character varying(255),
    is_trusted boolean DEFAULT false,
    first_seen timestamp without time zone DEFAULT now(),
    last_seen timestamp without time zone DEFAULT now(),
    login_count integer DEFAULT 1
);


--
-- Name: TABLE user_devices; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_devices IS 'Stores user device preferences and trusted device status';


--
-- Name: user_entitlements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_entitlements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    product_id text NOT NULL,
    subscription_group_id text NOT NULL,
    original_transaction_id text,
    original_transaction_id_hash text,
    is_trial boolean DEFAULT false NOT NULL,
    status text NOT NULL,
    purchase_at timestamp with time zone,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_entitlements_status_check CHECK ((status = ANY (ARRAY['active'::text, 'expired'::text, 'canceled'::text])))
);


--
-- Name: TABLE user_entitlements; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_entitlements IS 'User-linked subscription entitlements. Contains PII and plain transaction IDs 
while user account exists. Deleted on account deletion (data mirrored to 
entitlements_ledger first).';


--
-- Name: COLUMN user_entitlements.original_transaction_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_entitlements.original_transaction_id IS 'Plain Apple original_transaction_id. Kept only while user exists. Deleted on 
account deletion after mirroring hash to entitlements_ledger.';


--
-- Name: COLUMN user_entitlements.original_transaction_id_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_entitlements.original_transaction_id_hash IS 'Hashed version of original_transaction_id. Used to link to entitlements_ledger 
and for de-identified lookups after account deletion.';


--
-- Name: user_usage_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.user_usage_summary AS
 SELECT u.user_id,
    u.username,
    u.email,
    count(uau.id) AS total_api_calls,
    sum(uau.prompt_tokens) AS total_prompt_tokens,
    sum(uau.completion_tokens) AS total_completion_tokens,
    sum(uau.total_tokens) AS total_tokens,
    sum(uau.cost_usd) AS total_cost_usd,
    max(uau.created_at) AS last_api_call,
    min(uau.created_at) AS first_api_call
   FROM (public.users u
     LEFT JOIN public.user_api_usage uau ON (((u.user_id)::text = (uau.user_id)::text)))
  GROUP BY u.user_id, u.username, u.email
  ORDER BY (sum(uau.cost_usd)) DESC NULLS LAST;


--
-- Name: VIEW user_usage_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.user_usage_summary IS 'Aggregated view of API usage per user';


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: device_logins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_logins ALTER COLUMN id SET DEFAULT nextval('public.device_logins_id_seq'::regclass);


--
-- Name: fraud_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fraud_flags ALTER COLUMN id SET DEFAULT nextval('public.fraud_flags_id_seq'::regclass);


--
-- Name: password_reset_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens ALTER COLUMN id SET DEFAULT nextval('public.password_reset_tokens_id_seq'::regclass);


--
-- Name: promo_code_usage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_code_usage ALTER COLUMN id SET DEFAULT nextval('public.promo_code_usage_id_seq'::regclass);


--
-- Name: promo_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_codes ALTER COLUMN id SET DEFAULT nextval('public.promo_codes_id_seq'::regclass);


--
-- Name: subscription_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_history ALTER COLUMN id SET DEFAULT nextval('public.subscription_history_id_seq'::regclass);


--
-- Name: trial_usage_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_usage_history ALTER COLUMN id SET DEFAULT nextval('public.trial_usage_history_id_seq'::regclass);


--
-- Name: user_api_usage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_api_usage ALTER COLUMN id SET DEFAULT nextval('public.user_api_usage_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: admin_users admin_users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_email_key UNIQUE (email);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_username_key UNIQUE (username);


--
-- Name: device_logins device_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_logins
    ADD CONSTRAINT device_logins_pkey PRIMARY KEY (id);


--
-- Name: entitlements_ledger entitlements_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entitlements_ledger
    ADD CONSTRAINT entitlements_ledger_pkey PRIMARY KEY (id);


--
-- Name: fraud_flags fraud_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fraud_flags
    ADD CONSTRAINT fraud_flags_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_token_key UNIQUE (token);


--
-- Name: promo_code_usage promo_code_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_code_usage
    ADD CONSTRAINT promo_code_usage_pkey PRIMARY KEY (id);


--
-- Name: promo_code_usage promo_code_usage_promo_code_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_code_usage
    ADD CONSTRAINT promo_code_usage_promo_code_id_user_id_key UNIQUE (promo_code_id, user_id);


--
-- Name: promo_codes promo_codes_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_code_key UNIQUE (code);


--
-- Name: promo_codes promo_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_pkey PRIMARY KEY (id);


--
-- Name: subscription_history subscription_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_history
    ADD CONSTRAINT subscription_history_pkey PRIMARY KEY (id);


--
-- Name: trial_usage_history trial_usage_history_original_transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_usage_history
    ADD CONSTRAINT trial_usage_history_original_transaction_id_key UNIQUE (original_transaction_id);


--
-- Name: trial_usage_history trial_usage_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_usage_history
    ADD CONSTRAINT trial_usage_history_pkey PRIMARY KEY (id);


--
-- Name: user_api_usage user_api_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_api_usage
    ADD CONSTRAINT user_api_usage_pkey PRIMARY KEY (id);


--
-- Name: user_devices user_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_pkey PRIMARY KEY (user_id, device_id);


--
-- Name: user_entitlements user_entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_entitlements
    ADD CONSTRAINT user_entitlements_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_id_key UNIQUE (user_id);


--
-- Name: ent_ledger_last_seen_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ent_ledger_last_seen_idx ON public.entitlements_ledger USING btree (last_seen_at);


--
-- Name: ent_ledger_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ent_ledger_status_idx ON public.entitlements_ledger USING btree (status);


--
-- Name: ent_ledger_txid_hash_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ent_ledger_txid_hash_idx ON public.entitlements_ledger USING btree (original_transaction_id_hash);


--
-- Name: idx_admin_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_email ON public.admin_users USING btree (email);


--
-- Name: idx_admin_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_username ON public.admin_users USING btree (username);


--
-- Name: idx_apple_original_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_apple_original_transaction_id ON public.users USING btree (apple_original_transaction_id);


--
-- Name: idx_apple_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_apple_product_id ON public.users USING btree (apple_product_id);


--
-- Name: idx_device_logins_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_device_logins_device_id ON public.device_logins USING btree (device_id);


--
-- Name: idx_device_logins_login_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_device_logins_login_time ON public.device_logins USING btree (login_time);


--
-- Name: idx_device_logins_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_device_logins_user_id ON public.device_logins USING btree (user_id);


--
-- Name: idx_fraud_flags_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fraud_flags_device_id ON public.fraud_flags USING btree (device_id);


--
-- Name: idx_fraud_flags_resolved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fraud_flags_resolved ON public.fraud_flags USING btree (resolved);


--
-- Name: idx_fraud_flags_severity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fraud_flags_severity ON public.fraud_flags USING btree (severity);


--
-- Name: idx_fraud_flags_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fraud_flags_user_id ON public.fraud_flags USING btree (user_id);


--
-- Name: idx_password_reset_tokens_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_expires_at ON public.password_reset_tokens USING btree (expires_at);


--
-- Name: idx_password_reset_tokens_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_token ON public.password_reset_tokens USING btree (token);


--
-- Name: idx_password_reset_tokens_used; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_used ON public.password_reset_tokens USING btree (used);


--
-- Name: idx_password_reset_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_user_id ON public.password_reset_tokens USING btree (user_id);


--
-- Name: idx_promo_codes_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_promo_codes_active ON public.promo_codes USING btree (active);


--
-- Name: idx_promo_codes_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_promo_codes_code ON public.promo_codes USING btree (code);


--
-- Name: idx_promo_codes_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_promo_codes_expires_at ON public.promo_codes USING btree (expires_at);


--
-- Name: idx_promo_usage_promo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_promo_usage_promo_id ON public.promo_code_usage USING btree (promo_code_id);


--
-- Name: idx_promo_usage_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_promo_usage_user_id ON public.promo_code_usage USING btree (user_id);


--
-- Name: idx_sub_history_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sub_history_created_at ON public.subscription_history USING btree (created_at);


--
-- Name: idx_sub_history_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sub_history_event_type ON public.subscription_history USING btree (event_type);


--
-- Name: idx_sub_history_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sub_history_user_id ON public.subscription_history USING btree (user_id);


--
-- Name: idx_trial_history_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trial_history_created_at ON public.trial_usage_history USING btree (created_at);


--
-- Name: idx_trial_history_original_transaction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trial_history_original_transaction ON public.trial_usage_history USING btree (original_transaction_id);


--
-- Name: idx_trial_history_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trial_history_user_id ON public.trial_usage_history USING btree (user_id);


--
-- Name: idx_user_api_usage_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_api_usage_created_at ON public.user_api_usage USING btree (created_at);


--
-- Name: idx_user_api_usage_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_api_usage_device_id ON public.user_api_usage USING btree (device_id);


--
-- Name: idx_user_api_usage_endpoint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_api_usage_endpoint ON public.user_api_usage USING btree (endpoint);


--
-- Name: idx_user_api_usage_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_api_usage_model ON public.user_api_usage USING btree (model);


--
-- Name: idx_user_api_usage_user_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_api_usage_user_date ON public.user_api_usage USING btree (user_id, created_at);


--
-- Name: idx_user_api_usage_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_api_usage_user_id ON public.user_api_usage USING btree (user_id);


--
-- Name: idx_user_devices_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_devices_device_id ON public.user_devices USING btree (device_id);


--
-- Name: idx_user_devices_trusted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_devices_trusted ON public.user_devices USING btree (is_trusted);


--
-- Name: idx_user_devices_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_devices_user_id ON public.user_devices USING btree (user_id);


--
-- Name: idx_users_apple_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_apple_user_id ON public.users USING btree (apple_user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_password_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_password_hash ON public.users USING btree (password_hash);


--
-- Name: idx_users_stripe_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_stripe_customer_id ON public.users USING btree (stripe_customer_id);


--
-- Name: idx_users_subscription_end_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_subscription_end_date ON public.users USING btree (subscription_end_date);


--
-- Name: idx_users_subscription_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_subscription_status ON public.users USING btree (subscription_status);


--
-- Name: idx_users_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_user_id ON public.users USING btree (user_id);


--
-- Name: user_entitlements_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_entitlements_status_idx ON public.user_entitlements USING btree (status);


--
-- Name: user_entitlements_txid_hash_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_entitlements_txid_hash_idx ON public.user_entitlements USING btree (original_transaction_id_hash);


--
-- Name: user_entitlements_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_entitlements_user_idx ON public.user_entitlements USING btree (user_id);


--
-- Name: promo_code_stats _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.promo_code_stats AS
 SELECT pc.code,
    pc.duration_days,
    pc.uses_total,
    pc.uses_remaining,
    pc.active,
    count(pcu.id) AS actual_uses,
    pc.created_at
   FROM (public.promo_codes pc
     LEFT JOIN public.promo_code_usage pcu ON ((pc.id = pcu.promo_code_id)))
  GROUP BY pc.id;


--
-- Name: users set_trial_on_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_trial_on_insert BEFORE INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_trial_dates();


--
-- Name: trial_usage_history trigger_update_trial_history_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_trial_history_timestamp BEFORE UPDATE ON public.trial_usage_history FOR EACH ROW EXECUTE FUNCTION public.update_trial_history_updated_at();


--
-- Name: user_entitlements trigger_update_user_entitlements_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_user_entitlements_timestamp BEFORE UPDATE ON public.user_entitlements FOR EACH ROW EXECUTE FUNCTION public.update_user_entitlements_updated_at();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: promo_code_usage promo_code_usage_promo_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_code_usage
    ADD CONSTRAINT promo_code_usage_promo_code_id_fkey FOREIGN KEY (promo_code_id) REFERENCES public.promo_codes(id) ON DELETE CASCADE;


--
-- Name: promo_code_usage promo_code_usage_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_code_usage
    ADD CONSTRAINT promo_code_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: subscription_history subscription_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_history
    ADD CONSTRAINT subscription_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Hlul0jho17hMOeoYtQfI8l8cK5oqSUccwlh1X0ORsnKvI3vfpGRZ3t5wOQgbgnZ

