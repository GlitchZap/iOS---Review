-- Expert Portal Database Schema
-- Run this SQL in your Supabase SQL Editor (https://supabase.com/dashboard/project/YOUR_PROJECT/sql)

-- Drop existing tables if they exist (in correct order due to foreign key constraints)
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS earnings CASCADE;
DROP TABLE IF EXISTS payouts CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS availability CASCADE;
DROP TABLE IF EXISTS experts CASCADE;

-- Create experts table
CREATE TABLE IF NOT EXISTS experts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  expertise TEXT[] NOT NULL DEFAULT '{}',
  hourly_rate DECIMAL(10,2) NOT NULL DEFAULT 0,
  bio TEXT,
  verified BOOLEAN NOT NULL DEFAULT false,
  rating DECIMAL(3,2) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  total_reviews INTEGER DEFAULT 0,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create availability table
CREATE TABLE IF NOT EXISTS availability (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  expert_id UUID REFERENCES experts(id) ON DELETE CASCADE NOT NULL,
  day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_available BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
  UNIQUE(expert_id, day_of_week, start_time, end_time)
);

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  expert_id UUID REFERENCES experts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID,
  client_name TEXT NOT NULL,
  client_email TEXT NOT NULL,
  scheduled_for TIMESTAMP WITH TIME ZONE NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE,
  end_time TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'confirmed', 'completed', 'cancelled', 'pending')),
  meeting_link TEXT,
  notes TEXT,
  feedback TEXT,
  rating DECIMAL(2,1) CHECK (rating >= 0 AND rating <= 5),
  amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create messages table for chat functionality
CREATE TABLE IF NOT EXISTS messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  appointment_id UUID REFERENCES appointments(id) ON DELETE CASCADE NOT NULL,
  sender_type TEXT NOT NULL CHECK (sender_type IN ('expert', 'client')),
  sender_name TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create payouts table for tracking payments
CREATE TABLE IF NOT EXISTS payouts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  expert_id UUID REFERENCES experts(id) ON DELETE CASCADE NOT NULL,
  appointment_id UUID REFERENCES appointments(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'cancelled')),
  payment_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create earnings table for tracking payments
CREATE TABLE IF NOT EXISTS earnings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  expert_id UUID REFERENCES experts(id) ON DELETE CASCADE NOT NULL,
  appointment_id UUID REFERENCES appointments(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'cancelled')),
  payment_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_experts_auth_user_id ON experts(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_experts_verified ON experts(verified);
CREATE INDEX IF NOT EXISTS idx_availability_expert_id ON availability(expert_id);
CREATE INDEX IF NOT EXISTS idx_appointments_expert_id ON appointments(expert_id);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_scheduled_for ON appointments(scheduled_for);
CREATE INDEX IF NOT EXISTS idx_messages_appointment_id ON messages(appointment_id);
CREATE INDEX IF NOT EXISTS idx_earnings_expert_id ON earnings(expert_id);
CREATE INDEX IF NOT EXISTS idx_payouts_expert_id ON payouts(expert_id);

-- Enable Row Level Security (RLS)
ALTER TABLE experts ENABLE ROW LEVEL SECURITY;
ALTER TABLE availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for experts table
CREATE POLICY "Experts can view their own profile" ON experts
  FOR SELECT USING (auth.uid() = auth_user_id);

CREATE POLICY "Experts can update their own profile" ON experts
  FOR UPDATE USING (auth.uid() = auth_user_id);

-- RLS Policies for availability table
CREATE POLICY "Experts can manage their own availability" ON availability
  FOR ALL USING (
    expert_id IN (SELECT id FROM experts WHERE auth_user_id = auth.uid())
  );

-- RLS Policies for appointments table
CREATE POLICY "Experts can view their own appointments" ON appointments
  FOR SELECT USING (
    expert_id IN (SELECT id FROM experts WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "Experts can update their own appointments" ON appointments
  FOR UPDATE USING (
    expert_id IN (SELECT id FROM experts WHERE auth_user_id = auth.uid())
  );

-- RLS Policies for messages table
CREATE POLICY "Users can view messages for their appointments" ON messages
  FOR SELECT USING (
    appointment_id IN (
      SELECT id FROM appointments 
      WHERE expert_id IN (SELECT id FROM experts WHERE auth_user_id = auth.uid())
    )
  );

CREATE POLICY "Users can create messages for their appointments" ON messages
  FOR INSERT WITH CHECK (
    appointment_id IN (
      SELECT id FROM appointments 
      WHERE expert_id IN (SELECT id FROM experts WHERE auth_user_id = auth.uid())
    )
  );

-- RLS Policies for earnings table
CREATE POLICY "Experts can view their own earnings" ON earnings
  FOR SELECT USING (
    expert_id IN (SELECT id FROM experts WHERE auth_user_id = auth.uid())
  );

-- RLS Policies for payouts table
CREATE POLICY "Experts can view their own payouts" ON payouts
  FOR SELECT USING (
    expert_id IN (SELECT id FROM experts WHERE auth_user_id = auth.uid())
  );

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at columns
CREATE TRIGGER update_experts_updated_at
  BEFORE UPDATE ON experts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at
  BEFORE UPDATE ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- To create a test user:
-- 1. Go to Supabase Dashboard > Authentication > Users
-- 2. Click "Add user" and create a user with email: admin1@gmail.com
-- 3. Copy the user's UUID
-- 4. Run this SQL with the actual UUID:
--
-- INSERT INTO experts (auth_user_id, email, full_name, expertise, hourly_rate, verified, bio)
-- VALUES (
--   'paste-uuid-here',
--   'admin1@gmail.com',
--   'Admin Expert',
--   ARRAY['Consulting', 'Technology', 'Business'],
--   150.00,
--   true,
--   'Expert consultant available for various services.'
-- );
--
-- 5. Then insert mock appointments:
-- 
-- INSERT INTO appointments (expert_id, client_name, client_email, scheduled_for, status, notes, amount)
-- VALUES 
--   ((SELECT id FROM experts LIMIT 1), 'Sarah Johnson', 'sarah.j@email.com', NOW() + INTERVAL '2 days', 'confirmed', 'Career coaching session', 150.00),
--   ((SELECT id FROM experts LIMIT 1), 'Michael Chen', 'michael.c@email.com', NOW() + INTERVAL '3 days', 'confirmed', 'Business strategy consultation', 200.00),
--   ((SELECT id FROM experts LIMIT 1), 'Emily Davis', 'emily.d@email.com', NOW() + INTERVAL '5 days', 'requested', 'Technical interview prep', 175.00),
--   ((SELECT id FROM experts LIMIT 1), 'James Wilson', 'james.w@email.com', NOW() - INTERVAL '2 days', 'completed', 'React development guidance', 150.00),
--   ((SELECT id FROM experts LIMIT 1), 'Lisa Anderson', 'lisa.a@email.com', NOW() - INTERVAL '5 days', 'completed', 'Product management advice', 180.00);
--
-- 6. Add some payouts for earnings display:
--
-- INSERT INTO payouts (expert_id, amount, status, payment_date)
-- VALUES 
--   ((SELECT id FROM experts LIMIT 1), 150.00, 'paid', NOW() - INTERVAL '3 days'),
--   ((SELECT id FROM experts LIMIT 1), 180.00, 'paid', NOW() - INTERVAL '6 days'),
--   ((SELECT id FROM experts LIMIT 1), 200.00, 'pending', NULL);
