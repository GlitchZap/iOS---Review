export interface Expert {
  id: string;
  auth_user_id?:  string;
  name: string;
  specialization:  string;
  description?:  string;
  rating:  number;
  reviews_count:  number;
  image_url?:  string;
  experience_years?:  number;
  verified: boolean;
  email?: string;
  created_at: string;
}

export interface Appointment {
  id: string;
  expert_id: string;
  user_id: string;
  client_name?: string;
  client_email?: string;
  scheduled_for: string;
  status: 'requested' | 'confirmed' | 'completed' | 'cancelled';
  feedback?: string;
  rating?: number;
  notes?: string;
  amount?: number;
  created_at?: string;
}

export interface Message {
  id: string;
  appointment_id: string;
  sender_id: string;
  receiver_id: string;
  sender_role: 'expert' | 'parent';
  message: string;  // Your existing column name
  message_type?:  string;
  sent_at:  string;  // Your existing column name
}

export interface Availability {
  id: string;
  expert_id: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
  created_at: string;
}

export interface Payout {
  id: string;
  expert_id: string;
  amount: number;
  status: 'pending' | 'paid';
  payment_date?: string;
  created_at: string;
}