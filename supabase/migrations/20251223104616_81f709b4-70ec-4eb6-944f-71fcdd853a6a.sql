-- Add new columns for application letter and nomination letter
ALTER TABLE public.scholarship_applications
ADD COLUMN application_letter_url TEXT,
ADD COLUMN nomination_letter_url TEXT;