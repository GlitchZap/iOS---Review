import React, { createContext, useContext, useState, useEffect } from 'react';
import { authAPI } from '../services/api';

interface User {
  id: number;
  email: string;
  full_name: string;
  expertise?: string;
  hourly_rate?: number;
  rating?: number;
  bio?: string;
  phone?: string;
  experience_years?: number;
  education?: string;
  languages?: string;
  certificates?: any;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (data: {
    email: string;
    password: string;
    full_name: string;
    phone?: string;
    bio?: string;
    expertise?: string;
    hourly_rate?: number;
  }) => Promise<void>;
  signOut: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  // Check if user is logged in on mount
  useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          const response = await authAPI.getMe();
          setUser(response.expert);
        } catch (error) {
          console.error('Auth check failed:', error);
          localStorage.removeItem('token');
        }
      }
      setLoading(false);
    };

    checkAuth();
  }, []);

  const signIn = async (email: string, password: string) => {
    try {
      const response = await authAPI.login(email, password);
      
      if (!response.success) {
        throw new Error(response.message || 'Login failed');
      }

      // Save token
      localStorage.setItem('token', response.token);
      
      // Set user
      setUser(response.expert);
      
      console.log('✅ Login successful');
    } catch (error: any) {
      console.error('Login error:', error);
      throw new Error(error.response?.data?.message || error.message || 'Login failed');
    }
  };

  const signUp = async (data: {
    email: string;
    password: string;
    full_name: string;
    phone?: string;
    bio?: string;
    expertise?: string;
    hourly_rate?: number;
  }) => {
    try {
      const response = await authAPI.register(data);
      
      if (!response.success) {
        throw new Error(response.message || 'Registration failed');
      }

      // Save token
      localStorage.setItem('token', response.token);
      
      // Set user
      setUser(response.expert);
      
      console.log('✅ Registration successful');
    } catch (error: any) {
      console.error('Registration error:', error);
      throw new Error(error.response?.data?.message || error.message || 'Registration failed');
    }
  };

  const refreshUser = async () => {
    try {
      const response = await authAPI.getMe();
      setUser(response.expert);
    } catch (error) {
      console.error('Failed to refresh user:', error);
    }
  };

  const signOut = async () => {
    console.log('👋 Signing out...');
    localStorage.removeItem('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, loading, signIn, signUp, signOut, refreshUser }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};