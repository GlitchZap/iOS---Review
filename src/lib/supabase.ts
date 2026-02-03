import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.REACT_APP_SUPABASE_URL!;
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY!;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables. Please check your .env.local file.');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

/**
 * Helper function to check if user is a verified expert
 */
export const isExpert = async (userId: string): Promise<boolean> => {
  console.log('🔍 Checking expert status for user:', userId);
  
  try {
    const { data, error } = await supabase
      .from('experts')
      .select('id, verified, auth_user_id')
      .eq('auth_user_id', userId)
      .maybeSingle();

    if (error) {
      console.error('❌ Expert check error:', error);
      return false;
    }
    
    if (!data) {
      console.warn('⚠️ No expert record found for user:', userId);
      return false;
    }
    
    console.log('✅ Expert check result:', { verified: data.verified, expertId: data.id });
    return data.verified === true;
  } catch (err) {
    console.error('❌ Unexpected error in isExpert:', err);
    return false;
  }
};

/**
 * Get expert ID from auth user ID
 */
export const getExpertId = async (authUserId: string): Promise<string | null> => {
  try {
    const { data, error } = await supabase
      .from('experts')
      .select('id')
      .eq('auth_user_id', authUserId)
      .maybeSingle();

    if (error) {
      console.error('Error getting expert ID:', error);
      return null;
    }

    return data?.id || null;
  } catch (err) {
    console.error('Unexpected error getting expert ID:', err);
    return null;
  }
};