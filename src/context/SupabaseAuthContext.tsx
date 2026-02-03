import React, { createContext, useContext, useState, useEffect } from 'react';
import { User as SupabaseUser } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import { authService, expertService } from '../services/supabase.service';
import { Database } from '../types/database';

type Expert = Database['public']['Tables']['experts']['Row'];

interface AuthContextType {
  user: SupabaseUser | null;
  expert: Expert | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (data: {
    email: string;
    password: string;
    full_name: string;
    expertise?: string[];
    hourly_rate?: number;
    bio?: string;
  }) => Promise<void>;
  signOut: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<SupabaseUser | null>(null);
  const [expert, setExpert] = useState<Expert | null>(null);
  const [loading, setLoading] = useState(true);

  // Load user and expert data
  const loadUserData = async (currentUser: SupabaseUser | null) => {
    if (currentUser) {
      try {
        const expertData = await expertService.getByAuthUserId(currentUser.id);
        setExpert(expertData);
      } catch (error) {
        console.error('Error loading expert data:', error);
      }
    } else {
      setExpert(null);
    }
  };

  // Check if user is logged in on mount
  useEffect(() => {
    const initAuth = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        setUser(session?.user ?? null);
        await loadUserData(session?.user ?? null);
      } catch (error) {
        console.error('Auth initialization error:', error);
      } finally {
        setLoading(false);
      }
    };

    initAuth();

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        console.log('Auth state changed:', event);
        setUser(session?.user ?? null);
        await loadUserData(session?.user ?? null);
        setLoading(false);
      }
    );

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const signIn = async (email: string, password: string) => {
    try {
      setLoading(true);
      const authData = await authService.signIn(email, password);
      
      if (!authData?.user) {
        throw new Error('Login failed');
      }

      // User state will be updated by onAuthStateChange
      console.log('✅ Login successful');
    } catch (error: any) {
      console.error('Login error:', error);
      throw new Error(error.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  const signUp = async (data: {
    email: string;
    password: string;
    full_name: string;
    expertise?: string[];
    hourly_rate?: number;
    bio?: string;
  }) => {
    try {
      setLoading(true);
      const { user: authUser, expert: expertData } = await authService.signUp(
        data.email,
        data.password,
        {
          email: data.email,
          full_name: data.full_name,
          expertise: data.expertise || [],
          hourly_rate: data.hourly_rate || 0,
          bio: data.bio || null,
          verified: false,
          rating: null,
          total_reviews: null,
          profile_image_url: null,
        }
      );

      // User state will be updated by onAuthStateChange
      console.log('✅ Registration successful');
    } catch (error: any) {
      console.error('Registration error:', error);
      throw new Error(error.message || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  const signOut = async () => {
    try {
      await authService.signOut();
      setUser(null);
      setExpert(null);
    } catch (error: any) {
      console.error('Sign out error:', error);
      throw error;
    }
  };

  const refreshUser = async () => {
    try {
      const currentUser = await authService.getCurrentUser();
      setUser(currentUser);
      await loadUserData(currentUser);
    } catch (error) {
      console.error('Error refreshing user:', error);
    }
  };

  const value = {
    user,
    expert,
    loading,
    signIn,
    signUp,
    signOut,
    refreshUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
