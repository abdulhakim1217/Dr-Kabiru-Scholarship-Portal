-- Essential Tables for Scholarship Portal
-- Copy and paste this into Supabase SQL Editor

-- Create user_roles table
CREATE TABLE IF NOT EXISTS public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'user', 'reviewer')),
  created_at timestamp with time zone DEFAULT now(),
  UNIQUE(user_id, role)
);

-- Create scholarship_applications table
CREATE TABLE IF NOT EXISTS public.scholarship_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_number text UNIQUE NOT NULL DEFAULT ('SCH' || EXTRACT(YEAR FROM now()) || LPAD((RANDOM() * 9999)::int::text, 4, '0')),
  
  -- Personal Information
  full_name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  community_name text NOT NULL,
  
  -- Academic Information
  university text NOT NULL,
  course text NOT NULL,
  year_of_study text NOT NULL,
  cgpa text NOT NULL,
  reason text NOT NULL,
  
  -- Document URLs
  transcript_url text,
  application_letter_url text,
  nomination_letter_url text,
  supporting_docs_url text,
  
  -- Status and tracking
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected')),
  submission_date timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create communities table
CREATE TABLE IF NOT EXISTS public.communities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  district text,
  region text DEFAULT 'North East Region',
  created_at timestamp with time zone DEFAULT now()
);

-- Insert sample communities
INSERT INTO public.communities (name, district) VALUES
  ('Walewale', 'West Mamprusi'),
  ('Wungu', 'West Mamprusi'),
  ('Nasia', 'West Mamprusi'),
  ('Kpasenkpe', 'West Mamprusi'),
  ('Gbintiri', 'West Mamprusi'),
  ('Kpandai', 'West Mamprusi'),
  ('Sakogu', 'West Mamprusi'),
  ('Yagaba', 'West Mamprusi'),
  ('Demon', 'West Mamprusi'),
  ('Kparigu', 'West Mamprusi')
ON CONFLICT (name) DO NOTHING;

-- Enable Row Level Security
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scholarship_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;

-- Create has_role function
CREATE OR REPLACE FUNCTION public.has_role(user_id uuid, role_name text)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_roles.user_id = $1 AND user_roles.role = $2
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS Policies for user_roles
CREATE POLICY "Users can view own roles" ON public.user_roles
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Admins can view all roles" ON public.user_roles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- RLS Policies for scholarship_applications
CREATE POLICY "Allow anonymous application submissions" ON public.scholarship_applications
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous read for admin" ON public.scholarship_applications
  FOR SELECT USING (true);

CREATE POLICY "Admins can update applications" ON public.scholarship_applications
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- RLS Policies for communities
CREATE POLICY "Allow public read access to communities" ON public.communities
  FOR SELECT USING (true);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;

GRANT SELECT, INSERT ON public.scholarship_applications TO anon;
GRANT SELECT, UPDATE ON public.scholarship_applications TO authenticated;
GRANT SELECT ON public.communities TO anon;
GRANT SELECT ON public.communities TO authenticated;
GRANT SELECT ON public.user_roles TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_role TO authenticated;

-- Create function to submit applications
CREATE OR REPLACE FUNCTION public.submit_application(
  p_full_name text,
  p_email text,
  p_phone text,
  p_community_name text,
  p_university text,
  p_course text,
  p_year_of_study text,
  p_cgpa text,
  p_reason text,
  p_transcript_url text DEFAULT NULL,
  p_application_letter_url text DEFAULT NULL,
  p_nomination_letter_url text DEFAULT NULL,
  p_supporting_docs_url text DEFAULT NULL
)
RETURNS uuid AS $$
DECLARE
  new_app_id uuid;
BEGIN
  INSERT INTO public.scholarship_applications (
    full_name,
    email,
    phone,
    community_name,
    university,
    course,
    year_of_study,
    cgpa,
    reason,
    transcript_url,
    application_letter_url,
    nomination_letter_url,
    supporting_docs_url,
    status,
    submission_date
  ) VALUES (
    p_full_name,
    p_email,
    p_phone,
    p_community_name,
    p_university,
    p_course,
    p_year_of_study,
    p_cgpa,
    p_reason,
    p_transcript_url,
    p_application_letter_url,
    p_nomination_letter_url,
    p_supporting_docs_url,
    'pending',
    now()
  ) RETURNING id INTO new_app_id;
  
  RETURN new_app_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION public.submit_application TO anon;