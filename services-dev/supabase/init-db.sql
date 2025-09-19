-- Supabase initialization script
-- This script sets up the basic Supabase database schema

-- Create auth schema for authentication
CREATE SCHEMA IF NOT EXISTS auth;

-- Create realtime schema for real-time subscriptions
CREATE SCHEMA IF NOT EXISTS _realtime;

-- Create storage schema for file storage
CREATE SCHEMA IF NOT EXISTS storage;

-- Create supabase_admin role first (required by Supabase images)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN
        CREATE ROLE supabase_admin SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS;
    END IF;
END
$$;

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pgjwt";

-- Set up auth schema tables (basic required tables)
SET search_path TO auth;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    instance_id uuid NULL,
    id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    aud character varying(255) NULL,
    role character varying(255) NULL,
    email character varying(255) NULL UNIQUE,
    encrypted_password character varying(255) NULL,
    email_confirmed_at timestamp with time zone NULL,
    invited_at timestamp with time zone NULL,
    confirmation_token character varying(255) NULL,
    confirmation_sent_at timestamp with time zone NULL,
    recovery_token character varying(255) NULL,
    recovery_sent_at timestamp with time zone NULL,
    email_change_token_new character varying(255) NULL,
    email_change character varying(255) NULL,
    email_change_sent_at timestamp with time zone NULL,
    last_sign_in_at timestamp with time zone NULL,
    raw_app_meta_data jsonb NULL,
    raw_user_meta_data jsonb NULL,
    is_super_admin boolean NULL,
    created_at timestamp with time zone NULL DEFAULT now(),
    updated_at timestamp with time zone NULL DEFAULT now(),
    phone character varying(15) NULL DEFAULT NULL,
    phone_confirmed_at timestamp with time zone NULL,
    phone_change character varying(15) NULL DEFAULT '',
    phone_change_token character varying(255) NULL DEFAULT '',
    phone_change_sent_at timestamp with time zone NULL,
    confirmed_at timestamp with time zone NULL DEFAULT now(),
    email_change_token_current character varying(255) NULL DEFAULT '',
    email_change_confirm_status smallint NULL DEFAULT 0,
    banned_until timestamp with time zone NULL,
    reauthentication_token character varying(255) NULL DEFAULT '',
    reauthentication_sent_at timestamp with time zone NULL,
    is_sso_user boolean NOT NULL DEFAULT false
);

-- Create anonymous user role
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN NOINHERIT;
    END IF;
END
$$;

-- Create authenticated user role
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN NOINHERIT;
    END IF;
END
$$;

-- Create service role
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
    END IF;
END
$$;

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;

-- Set up realtime schema
SET search_path TO _realtime;

-- Basic realtime table (simplified, will be setup by realtime service itself)
CREATE TABLE IF NOT EXISTS subscription (
    id bigserial PRIMARY KEY,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    claims jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc', now())
);

-- Switch back to public schema
SET search_path TO public;

-- Create a basic profiles table as an example
CREATE TABLE IF NOT EXISTS profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email text,
    display_name text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles table
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create function to get current user ID
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
    SELECT COALESCE(
        current_setting('request.jwt.claim.sub', true),
        (current_setting('request.jwt.claims', true)::jsonb ->> 'sub')
    )::uuid
$$;

-- Create function to get current user role
CREATE OR REPLACE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
    SELECT COALESCE(
        current_setting('request.jwt.claim.role', true),
        (current_setting('request.jwt.claims', true)::jsonb ->> 'role')
    )::text
$$;