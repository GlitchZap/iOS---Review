import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5001/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests if it exists
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth API
export const authAPI = {
  register: async (data: {
    email: string;
    password: string;
    full_name: string;
    phone?: string;
    bio?: string;
    expertise?: string;
    hourly_rate?: number;
  }) => {
    const response = await api.post('/auth/register', data);
    return response.data;
  },

  login: async (email: string, password: string) => {
    const response = await api.post('/auth/login', { email, password });
    return response.data;
  },

  getMe: async () => {
    const response = await api.get('/auth/me');
    return response.data;
  },

  updateProfile: async (data: {
    full_name: string;
    phone?: string;
    bio?: string;
    expertise?: string;
    hourly_rate?: number;
    experience_years?: number;
    education?: string;
    languages?: string;
    certificates?: string;
  }) => {
    const response = await api.put('/auth/profile', data);
    return response.data;
  },
};

// Appointments API
export const appointmentsAPI = {
  getAll: async (status?: string) => {
    const response = await api.get('/appointments', { params: { status } });
    return response.data;
  },

  getOne: async (id: number) => {
    const response = await api.get(`/appointments/${id}`);
    return response.data;
  },

  update: async (id: number, data: any) => {
    const response = await api.put(`/appointments/${id}`, data);
    return response.data;
  },

  getStats: async () => {
    const response = await api.get('/appointments/stats/dashboard');
    return response.data;
  },
};

// Availability API
export const availabilityAPI = {
  getAll: async () => {
    const response = await api.get('/availability');
    return response.data;
  },

  add: async (data: { day_of_week: number; start_time: string; end_time: string }) => {
    const response = await api.post('/availability', data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await api.delete(`/availability/${id}`);
    return response.data;
  },
};

// Messages API
export const messagesAPI = {
  getByAppointment: async (appointmentId: number) => {
    const response = await api.get(`/messages/${appointmentId}`);
    return response.data;
  },

  send: async (appointmentId: number, message: string) => {
    const response = await api.post('/messages', {
      appointment_id: appointmentId,
      message,
    });
    return response.data;
  },

  markAsRead: async (appointmentId: number) => {
    const response = await api.put(`/messages/read/${appointmentId}`);
    return response.data;
  },
};

// Earnings API
export const earningsAPI = {
  getSummary: async () => {
    const response = await api.get('/earnings');
    return response.data;
  },

  getPayouts: async () => {
    const response = await api.get('/earnings/payouts');
    return response.data;
  },

  requestPayout: async () => {
    const response = await api.post('/earnings/request-payout');
    return response.data;
  },
};

export default api;
