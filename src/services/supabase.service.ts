import { supabase } from '../lib/supabase';

// Simple type definitions directly from the database
interface Expert {
  id: string;
  auth_user_id: string;
  email: string;
  full_name: string;
  expertise: string[];
  hourly_rate: number;
  bio: string | null;
  verified: boolean;
  rating: number | null;
  total_reviews: number | null;
  profile_image_url: string | null;
  created_at: string;
  updated_at: string;
}

interface Appointment {
  id: string;
  expert_id: string;
  user_id: string | null;
  client_name: string;
  client_email: string;
  scheduled_for: string;
  start_time: string | null;
  end_time: string | null;
  status: 'requested' | 'confirmed' | 'completed' | 'cancelled' | 'pending';
  meeting_link: string | null;
  notes: string | null;
  feedback: string | null;
  rating: number | null;
  amount: number;
  created_at: string;
  updated_at: string;
}

interface Availability {
  id: string;
  expert_id: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
  is_available: boolean;
  created_at: string;
}

interface Message {
  id: string;
  appointment_id: string;
  sender_type: 'expert' | 'client';
  sender_name: string;
  content: string;
  created_at: string;
}

interface Earning {
  id: string;
  expert_id: string;
  appointment_id: string | null;
  amount: number;
  status: 'pending' | 'paid' | 'cancelled';
  payment_date: string | null;
  created_at: string;
}

/**
 * Authentication Services
 */
export const authService = {
  /**
   * Sign up a new expert
   */
  signUp: async (email: string, password: string, expertData: Omit<Expert, 'id' | 'auth_user_id' | 'created_at' | 'updated_at'>) => {
    // Create auth user
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
    });

    if (authError) throw authError;
    if (!authData.user) throw new Error('Failed to create user');

    // Create expert profile
    const { data: expertProfile, error: expertError } = await supabase
      .from('experts')
      .insert({
        ...expertData,
        auth_user_id: authData.user.id,
      } as any)
      .select()
      .single();

    if (expertError) throw expertError;

    return { user: authData.user, expert: expertProfile };
  },

  /**
   * Sign in an expert
   */
  signIn: async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;
    return data;
  },

  /**
   * Sign out
   */
  signOut: async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  /**
   * Get current session
   */
  getSession: async () => {
    const { data, error } = await supabase.auth.getSession();
    if (error) throw error;
    return data.session;
  },

  /**
   * Get current user
   */
  getCurrentUser: async () => {
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error) throw error;
    return user;
  },
};

/**
 * Expert Services
 */
export const expertService = {
  /**
   * Get expert profile by auth user ID
   */
  getByAuthUserId: async (authUserId: string): Promise<Expert | null> => {
    const { data, error } = await supabase
      .from('experts')
      .select('*')
      .eq('auth_user_id', authUserId)
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  /**
   * Get expert profile by ID
   */
  getById: async (id: string): Promise<Expert | null> => {
    const { data, error } = await supabase
      .from('experts')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  },

  /**
   * Update expert profile
   */
  update: async (id: string, updates: any) => {
    const { data, error } = await supabase
      .from('experts')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  /**
   * Get all experts
   */
  getAll: async (): Promise<Expert[]> => {
    const { data, error } = await supabase
      .from('experts')
      .select('*')
      .eq('verified', true);

    if (error) throw error;
    return data || [];
  },
};

/**
 * Appointment Services
 */
export const appointmentService = {
  /**
   * Get appointments for an expert
   */
  getByExpertId: async (expertId: string): Promise<Appointment[]> => {
    const { data, error } = await supabase
      .from('appointments')
      .select('*')
      .eq('expert_id', expertId)
      .order('scheduled_for', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  /**
   * Get appointment by ID
   */
  getById: async (id: string): Promise<Appointment | null> => {
    const { data, error } = await supabase
      .from('appointments')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  },

  /**
   * Create new appointment
   */
  create: async (appointment: Omit<Appointment, 'id' | 'created_at' | 'updated_at'>) => {
    const { data, error } = await supabase
      .from('appointments')
      .insert(appointment as any)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  /**
   * Update appointment
   */
  update: async (id: string, updates: any) => {
    const { data, error } = await supabase
      .from('appointments')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  /**
   * Get appointment stats for expert
   */
  getStats: async (expertId: string) => {
    const { data, error } = await supabase
      .from('appointments')
      .select('status, amount')
      .eq('expert_id', expertId)
      .returns<Array<{ status: string; amount: number }>>();

    if (error) throw error;

    const stats = {
      total: data?.length || 0,
      confirmed: data?.filter((a: any) => a.status === 'confirmed').length || 0,
      completed: data?.filter((a: any) => a.status === 'completed').length || 0,
      pending: data?.filter((a: any) => a.status === 'requested' || a.status === 'pending').length || 0,
      cancelled: data?.filter((a: any) => a.status === 'cancelled').length || 0,
      totalRevenue: data?.reduce((sum: number, a: any) => sum + (a.amount || 0), 0) || 0,
    };

    return stats;
  },
};

/**
 * Availability Services
 */
export const availabilityService = {
  /**
   * Get availability for an expert
   */
  getByExpertId: async (expertId: string): Promise<Availability[]> => {
    const { data, error } = await supabase
      .from('availability')
      .select('*')
      .eq('expert_id', expertId)
      .order('day_of_week', { ascending: true });

    if (error) throw error;
    return data || [];
  },

  /**
   * Create availability slot
   */
  create: async (availability: Omit<Availability, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('availability')
      .insert(availability as any)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  /**
   * Update availability
   */
  update: async (id: string, updates: any) => {
    const { data, error } = await supabase
      .from('availability')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  /**
   * Delete availability
   */
  delete: async (id: string) => {
    const { error } = await supabase
      .from('availability')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },
};

/**
 * Message Services
 */
export const messageService = {
  /**
   * Get messages for an appointment
   */
  getByAppointmentId: async (appointmentId: string): Promise<Message[]> => {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('appointment_id', appointmentId)
      .order('created_at', { ascending: true });

    if (error) throw error;
    return data || [];
  },

  /**
   * Send a message
   */
  send: async (message: Omit<Message, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('messages')
      .insert(message as any)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  /**
   * Subscribe to new messages for an appointment
   */
  subscribe: (appointmentId: string, callback: (message: Message) => void) => {
    return supabase
      .channel(`messages:${appointmentId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `appointment_id=eq.${appointmentId}`,
        },
        (payload) => {
          callback(payload.new as Message);
        }
      )
      .subscribe();
  },
};

/**
 * Earnings Services
 */
export const earningsService = {
  /**
   * Get earnings for an expert
   */
  getByExpertId: async (expertId: string): Promise<Earning[]> => {
    const { data, error } = await supabase
      .from('earnings')
      .select('*')
      .eq('expert_id', expertId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  /**
   * Get earnings stats
   */
  getStats: async (expertId: string) => {
    const { data, error } = await supabase
      .from('earnings')
      .select('amount, status, payment_date')
      .eq('expert_id', expertId)
      .returns<Array<{ amount: number; status: string; payment_date: string | null }>>();

    if (error) throw error;

    const totalEarnings = data?.reduce((sum: number, e: any) => sum + (e.amount || 0), 0) || 0;
    const paidEarnings = data?.filter((e: any) => e.status === 'paid').reduce((sum: number, e: any) => sum + (e.amount || 0), 0) || 0;
    const pendingEarnings = data?.filter((e: any) => e.status === 'pending').reduce((sum: number, e: any) => sum + (e.amount || 0), 0) || 0;

    return {
      total: totalEarnings,
      paid: paidEarnings,
      pending: pendingEarnings,
      count: data?.length || 0,
    };
  },
};
