-- Seed data for local development
-- This file is run after migrations to populate the database with test data

-- Example: Create a profiles table (optional - remove if not needed)
-- CREATE TABLE IF NOT EXISTS public.profiles (
--   id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
--   username TEXT UNIQUE,
--   avatar_url TEXT,
--   created_at TIMESTAMPTZ DEFAULT NOW(),
--   updated_at TIMESTAMPTZ DEFAULT NOW()
-- );

-- Example: Enable Row Level Security
-- ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Example: Create RLS policies
-- CREATE POLICY "Users can view their own profile"
--   ON public.profiles
--   FOR SELECT
--   USING (auth.uid() = id);

-- Example: Insert test data
-- INSERT INTO public.profiles (id, username) VALUES
--   ('00000000-0000-0000-0000-000000000001', 'test_user_1'),
--   ('00000000-0000-0000-0000-000000000002', 'test_user_2')
-- ON CONFLICT (id) DO NOTHING;

-- Add your seed data below
