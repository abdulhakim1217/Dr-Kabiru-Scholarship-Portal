-- Enhanced Scholarship Management System Schema
-- This migration adds comprehensive features for the scholarship platform

-- Create enhanced application status enum
CREATE TYPE application_status AS ENUM (
  'draft',
  'submitted', 
  'under_review',
  'shortlisted',
  'interview_scheduled',
  'interview_completed',
  'approved',
  'rejected',
  'waitlisted'
);

-- Create education levels enum
CREATE TYPE education_level AS ENUM (
  'shs',
  'diploma', 
  'undergraduate',
  'postgraduate',
  'phd'
);

-- Create gender enum
CREATE TYPE gender_type AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');

-- Create enhanced user profiles table
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  full_name text NOT NULL,
  date_of_birth date,
  gender gender_type,
  nationality text DEFAULT 'Ghanaian',
  region text,
  district text,
  community_name text,
  phone text,
  alternative_phone text,
  passport_photo_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create enhanced scholarship applications table
DROP TABLE IF EXISTS public.scholarship_applications CASCADE;
CREATE TABLE public.scholarship_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  application_number text UNIQUE NOT NULL,
  
  -- Personal Information (can be null for anonymous applications)
  full_name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  date_of_birth date,
  gender gender_type,
  nationality text DEFAULT 'Ghanaian',
  region text,
  district text,
  community_name text NOT NULL,
  
  -- Academic Information
  institution_name text NOT NULL,
  program_course text NOT NULL,
  education_level education_level NOT NULL,
  year_semester text NOT NULL,
  gpa_cgpa decimal(3,2),
  
  -- Application Details
  essay_responses jsonb, -- Store multiple essay responses
  financial_need_description text,
  leadership_activities text,
  community_service text,
  career_goals text,
  
  -- Document URLs
  academic_transcript_url text,
  admission_letter_url text,
  national_id_url text,
  recommendation_letters_urls text[], -- Array for multiple letters
  supporting_documents_urls text[], -- Array for additional docs
  
  -- Application Status & Tracking
  status application_status DEFAULT 'draft',
  submission_date timestamp with time zone,
  last_status_change timestamp with time zone DEFAULT now(),
  status_history jsonb DEFAULT '[]'::jsonb,
  
  -- Review & Scoring
  reviewer_notes text,
  academic_score integer CHECK (academic_score >= 0 AND academic_score <= 100),
  financial_need_score integer CHECK (financial_need_score >= 0 AND financial_need_score <= 100),
  essay_score integer CHECK (essay_score >= 0 AND essay_score <= 100),
  leadership_score integer CHECK (leadership_score >= 0 AND leadership_score <= 100),
  total_score integer CHECK (total_score >= 0 AND total_score <= 400),
  
  -- Interview
  interview_scheduled_date timestamp with time zone,
  interview_notes text,
  interview_score integer CHECK (interview_score >= 0 AND interview_score <= 100),
  
  -- Metadata
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  
  -- Constraints
  CONSTRAINT valid_submission_date CHECK (
    (status = 'draft' AND submission_date IS NULL) OR 
    (status != 'draft' AND submission_date IS NOT NULL)
  )
);

-- Create scholarship configurations table
CREATE TABLE public.scholarship_configurations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  application_window_start timestamp with time zone NOT NULL,
  application_window_end timestamp with time zone NOT NULL,
  max_applications integer,
  eligibility_rules jsonb,
  required_documents text[],
  essay_questions jsonb,
  scoring_weights jsonb DEFAULT '{
    "academic": 25,
    "financial_need": 25, 
    "essay": 25,
    "leadership": 25
  }'::jsonb,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create reviewers table
CREATE TABLE public.reviewers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  full_name text NOT NULL,
  email text NOT NULL,
  expertise_areas text[],
  is_active boolean DEFAULT true,
  conflict_of_interest_declarations text[],
  created_at timestamp with time zone DEFAULT now()
);

-- Create application assignments table (for reviewer assignments)
CREATE TABLE public.application_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id uuid REFERENCES public.scholarship_applications(id) ON DELETE CASCADE,
  reviewer_id uuid REFERENCES public.reviewers(id) ON DELETE CASCADE,
  assigned_date timestamp with time zone DEFAULT now(),
  review_completed_date timestamp with time zone,
  is_blind_review boolean DEFAULT false,
  UNIQUE(application_id, reviewer_id)
);

-- Create communications table
CREATE TABLE public.communications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id uuid REFERENCES public.scholarship_applications(id) ON DELETE CASCADE,
  sender_id uuid REFERENCES auth.users(id),
  recipient_id uuid REFERENCES auth.users(id),
  subject text NOT NULL,
  message text NOT NULL,
  is_read boolean DEFAULT false,
  communication_type text DEFAULT 'message', -- 'message', 'status_update', 'interview_invitation'
  created_at timestamp with time zone DEFAULT now()
);

-- Create audit logs table
CREATE TABLE public.audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  action text NOT NULL,
  table_name text,
  record_id uuid,
  old_values jsonb,
  new_values jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamp with time zone DEFAULT now()
);

-- Create notification preferences table
CREATE TABLE public.notification_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  email_notifications boolean DEFAULT true,
  sms_notifications boolean DEFAULT false,
  status_updates boolean DEFAULT true,
  interview_reminders boolean DEFAULT true,
  general_announcements boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

-- Update user_roles to include reviewer role
ALTER TYPE app_role ADD VALUE IF NOT EXISTS 'reviewer';

-- Create indexes for performance
CREATE INDEX idx_applications_status ON public.scholarship_applications(status);
CREATE INDEX idx_applications_user_id ON public.scholarship_applications(user_id);
CREATE INDEX idx_applications_submission_date ON public.scholarship_applications(submission_date);
CREATE INDEX idx_applications_community ON public.scholarship_applications(community_name);
CREATE INDEX idx_applications_institution ON public.scholarship_applications(institution_name);
CREATE INDEX idx_communications_application ON public.communications(application_id);
CREATE INDEX idx_communications_recipient ON public.communications(recipient_id);
CREATE INDEX idx_audit_logs_user_action ON public.audit_logs(user_id, action);

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scholarship_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scholarship_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviewers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- User Profiles
CREATE POLICY "Users can view own profile" ON public.user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all profiles" ON public.user_profiles
  FOR SELECT USING (public.has_role(auth.uid(), 'admin'));

-- Scholarship Applications
CREATE POLICY "Users can view own applications" ON public.scholarship_applications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own applications" ON public.scholarship_applications
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own draft applications" ON public.scholarship_applications
  FOR UPDATE USING (auth.uid() = user_id AND status = 'draft');

CREATE POLICY "Admins can view all applications" ON public.scholarship_applications
  FOR SELECT USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update applications" ON public.scholarship_applications
  FOR UPDATE USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Reviewers can view assigned applications" ON public.scholarship_applications
  FOR SELECT USING (
    public.has_role(auth.uid(), 'reviewer') AND 
    id IN (
      SELECT application_id FROM public.application_assignments 
      WHERE reviewer_id IN (
        SELECT id FROM public.reviewers WHERE user_id = auth.uid()
      )
    )
  );

-- Scholarship Configurations
CREATE POLICY "Anyone can view active configurations" ON public.scholarship_configurations
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage configurations" ON public.scholarship_configurations
  FOR ALL USING (public.has_role(auth.uid(), 'admin'));

-- Communications
CREATE POLICY "Users can view own communications" ON public.communications
  FOR SELECT USING (auth.uid() = recipient_id OR auth.uid() = sender_id);

CREATE POLICY "Users can send communications" ON public.communications
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Admins can view all communications" ON public.communications
  FOR ALL USING (public.has_role(auth.uid(), 'admin'));

-- Notification Preferences
CREATE POLICY "Users can manage own preferences" ON public.notification_preferences
  FOR ALL USING (auth.uid() = user_id);

-- Functions

-- Function to generate application number
CREATE OR REPLACE FUNCTION generate_application_number()
RETURNS text AS $$
DECLARE
  year_suffix text;
  sequence_num integer;
  app_number text;
BEGIN
  year_suffix := EXTRACT(YEAR FROM now())::text;
  
  SELECT COALESCE(MAX(
    CAST(SUBSTRING(application_number FROM '[0-9]+$') AS integer)
  ), 0) + 1
  INTO sequence_num
  FROM public.scholarship_applications
  WHERE application_number LIKE 'SCH' || year_suffix || '%';
  
  app_number := 'SCH' || year_suffix || LPAD(sequence_num::text, 4, '0');
  
  RETURN app_number;
END;
$$ LANGUAGE plpgsql;

-- Function to update application status with history
CREATE OR REPLACE FUNCTION update_application_status(
  app_id uuid,
  new_status application_status,
  notes text DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  current_status application_status;
  status_entry jsonb;
BEGIN
  -- Get current status
  SELECT status INTO current_status
  FROM public.scholarship_applications
  WHERE id = app_id;
  
  -- Create status history entry
  status_entry := jsonb_build_object(
    'from_status', current_status,
    'to_status', new_status,
    'changed_at', now(),
    'changed_by', auth.uid(),
    'notes', notes
  );
  
  -- Update application
  UPDATE public.scholarship_applications
  SET 
    status = new_status,
    last_status_change = now(),
    status_history = status_history || status_entry
  WHERE id = app_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate total score
CREATE OR REPLACE FUNCTION calculate_total_score(app_id uuid)
RETURNS integer AS $$
DECLARE
  academic integer;
  financial integer;
  essay integer;
  leadership integer;
  interview integer;
  total integer;
BEGIN
  SELECT 
    COALESCE(academic_score, 0),
    COALESCE(financial_need_score, 0),
    COALESCE(essay_score, 0),
    COALESCE(leadership_score, 0),
    COALESCE(interview_score, 0)
  INTO academic, financial, essay, leadership, interview
  FROM public.scholarship_applications
  WHERE id = app_id;
  
  total := academic + financial + essay + leadership + interview;
  
  UPDATE public.scholarship_applications
  SET total_score = total
  WHERE id = app_id;
  
  RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate application number
CREATE OR REPLACE FUNCTION set_application_number()
RETURNS trigger AS $$
BEGIN
  IF NEW.application_number IS NULL THEN
    NEW.application_number := generate_application_number();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_application_number
  BEFORE INSERT ON public.scholarship_applications
  FOR EACH ROW
  EXECUTE FUNCTION set_application_number();

-- Trigger to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_applications_timestamp
  BEFORE UPDATE ON public.scholarship_applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_update_profiles_timestamp
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Insert default scholarship configuration
INSERT INTO public.scholarship_configurations (
  name,
  description,
  application_window_start,
  application_window_end,
  max_applications,
  eligibility_rules,
  required_documents,
  essay_questions
) VALUES (
  'Dr. Kairu Tiah Mahama MP Scholarship 2025',
  'Annual scholarship program for students from Walewale Constituency',
  '2025-01-01 00:00:00+00',
  '2025-12-31 23:59:59+00',
  1000,
  '{
    "min_gpa": 2.5,
    "eligible_regions": ["North East Region"],
    "eligible_communities": ["Walewale", "Wungu", "Nasia", "Kpasenkpe", "Gbintiri"],
    "education_levels": ["undergraduate", "postgraduate", "diploma"]
  }'::jsonb,
  ARRAY['academic_transcript', 'admission_letter', 'national_id', 'recommendation_letter'],
  '{
    "questions": [
      {
        "id": 1,
        "question": "Why do you deserve this scholarship? Describe your academic goals, financial situation, and how this scholarship will help you achieve your dreams.",
        "max_words": 500,
        "required": true
      },
      {
        "id": 2, 
        "question": "Describe your leadership experience and community service activities.",
        "max_words": 300,
        "required": true
      },
      {
        "id": 3,
        "question": "What are your career goals and how will you contribute to your community after graduation?",
        "max_words": 300,
        "required": true
      }
    ]
  }'::jsonb
);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;