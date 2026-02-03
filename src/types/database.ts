export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      appointments: {
        Row: {
          id: string
          expert_id: string
          user_id: string | null
          client_name: string
          client_email: string
          scheduled_for: string
          start_time: string | null
          end_time: string | null
          status: 'requested' | 'confirmed' | 'completed' | 'cancelled' | 'pending'
          meeting_link: string | null
          notes: string | null
          feedback: string | null
          rating: number | null
          amount: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          expert_id: string
          user_id?: string | null
          client_name: string
          client_email: string
          scheduled_for: string
          start_time?: string | null
          end_time?: string | null
          status?: 'requested' | 'confirmed' | 'completed' | 'cancelled' | 'pending'
          meeting_link?: string | null
          notes?: string | null
          feedback?: string | null
          rating?: number | null
          amount?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          expert_id?: string
          user_id?: string | null
          client_name?: string
          client_email?: string
          scheduled_for?: string
          start_time?: string | null
          end_time?: string | null
          status?: 'requested' | 'confirmed' | 'completed' | 'cancelled' | 'pending'
          meeting_link?: string | null
          notes?: string | null
          feedback?: string | null
          rating?: number | null
          amount?: number
          created_at?: string
          updated_at?: string
        }
      }
      availability: {
        Row: {
          id: string
          expert_id: string
          day_of_week: number
          start_time: string
          end_time: string
          is_available: boolean
          created_at: string
        }
        Insert: {
          id?: string
          expert_id: string
          day_of_week: number
          start_time: string
          end_time: string
          is_available?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          expert_id?: string
          day_of_week?: number
          start_time?: string
          end_time?: string
          is_available?: boolean
          created_at?: string
        }
      }
      experts: {
        Row: {
          id: string
          auth_user_id: string
          email: string
          full_name: string
          expertise: string[]
          hourly_rate: number
          bio: string | null
          verified: boolean
          rating: number | null
          total_reviews: number | null
          profile_image_url: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          auth_user_id: string
          email: string
          full_name: string
          expertise?: string[]
          hourly_rate?: number
          bio?: string | null
          verified?: boolean
          rating?: number | null
          total_reviews?: number | null
          profile_image_url?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          auth_user_id?: string
          email?: string
          full_name?: string
          expertise?: string[]
          hourly_rate?: number
          bio?: string | null
          verified?: boolean
          rating?: number | null
          total_reviews?: number | null
          profile_image_url?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      earnings: {
        Row: {
          id: string
          expert_id: string
          appointment_id: string | null
          amount: number
          status: 'pending' | 'paid' | 'cancelled'
          payment_date: string | null
          created_at: string
        }
        Insert: {
          id?: string
          expert_id: string
          appointment_id?: string | null
          amount: number
          status?: 'pending' | 'paid' | 'cancelled'
          payment_date?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          expert_id?: string
          appointment_id?: string | null
          amount?: number
          status?: 'pending' | 'paid' | 'cancelled'
          payment_date?: string | null
          created_at?: string
        }
      }
      messages: {
        Row: {
          id: string
          appointment_id: string
          sender_type: 'expert' | 'client'
          sender_name: string
          content: string
          created_at: string
        }
        Insert: {
          id?: string
          appointment_id: string
          sender_type: 'expert' | 'client'
          sender_name: string
          content: string
          created_at?: string
        }
        Update: {
          id?: string
          appointment_id?: string
          sender_type?: 'expert' | 'client'
          sender_name?: string
          content?: string
          created_at?: string
        }
      }
      profiles: {
        Row: {
          id: string
          email: string | null
          name: string | null
          phone_number: string | null
          has_completed_onboarding: boolean | null
          has_completed_screener: boolean | null
          screener_data: Json | null
          child_profiles: Json | null
          active_child_id: string | null
          created_at: string | null
          updated_at: string | null
          last_login_at: string | null
        }
        Insert: {
          id: string
          email?: string | null
          name?: string | null
          phone_number?: string | null
          has_completed_onboarding?: boolean | null
          has_completed_screener?: boolean | null
          screener_data?: Json | null
          child_profiles?: Json | null
          active_child_id?: string | null
          created_at?: string | null
          updated_at?: string | null
          last_login_at?: string | null
        }
        Update: {
          id?: string
          email?: string | null
          name?: string | null
          phone_number?: string | null
          has_completed_onboarding?: boolean | null
          has_completed_screener?: boolean | null
          screener_data?: Json | null
          child_profiles?: Json | null
          active_child_id?: string | null
          created_at?: string | null
          updated_at?: string | null
          last_login_at?: string | null
        }
      }
      users: {
        Row: {
          id: string
          name: string | null
          email: string | null
          location: string | null
          parenting_style: string | null
          created_at: string | null
        }
        Insert: {
          id: string
          name?: string | null
          email?: string | null
          location?: string | null
          parenting_style?: string | null
          created_at?: string | null
        }
        Update: {
          id?: string
          name?: string | null
          email?: string | null
          location?: string | null
          parenting_style?: string | null
          created_at?: string | null
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}
