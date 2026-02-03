import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Appointment } from '../types';
import { StatsCard } from '../components/dashboard/StatsCard';
import { AppointmentCard } from '../components/dashboard/AppointmentCard';

// Mock data for frontend-only mode
const MOCK_APPOINTMENTS: Appointment[] = [
  {
    id: '1',
    expert_id: 'mock-expert-1',
    user_id: 'user-1',
    client_name: 'Sarah Johnson',
    client_email: 'sarah.j@email.com',
    scheduled_for: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
    status: 'confirmed',
    notes: 'Career coaching session',
    amount: 150,
    created_at: new Date().toISOString()
  },
  {
    id: '2',
    expert_id: 'mock-expert-1',
    user_id: 'user-2',
    client_name: 'Michael Chen',
    client_email: 'michael.c@email.com',
    scheduled_for: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
    status: 'confirmed',
    notes: 'Business strategy consultation',
    amount: 200,
    created_at: new Date().toISOString()
  },
  {
    id: '3',
    expert_id: 'mock-expert-1',
    user_id: 'user-3',
    client_name: 'Emily Davis',
    client_email: 'emily.d@email.com',
    scheduled_for: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString(),
    status: 'requested',
    notes: 'Technical interview prep',
    amount: 175,
    created_at: new Date().toISOString()
  }
];

export const Dashboard: React.FC = () => {
  const { user } = useAuth();
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [stats, setStats] = useState({
    upcoming: 0,
    completed: 0,
    earnings: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (user) {
      loadDashboardData();
    }
  }, [user]);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      setError('');

      // Simulate API delay
      await new Promise(resolve => setTimeout(resolve, 500));

      // Use mock data
      setAppointments(MOCK_APPOINTMENTS.filter(a => a.status === 'confirmed'));

      setStats({
        upcoming: MOCK_APPOINTMENTS.filter(a => a.status === 'confirmed').length,
        completed: 5,
        earnings: 3300,
      });

    } catch (err: any) {
      console.error('Dashboard error:', err);
      setError(err.message || 'Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto px-6 py-8">
        <div className="flex items-center justify-center h-64">
          <div className="flex items-center space-x-3">
            <svg className="animate-spin h-8 w-8 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <span className="text-gray-600 font-medium">Loading dashboard...</span>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="container mx-auto px-6 py-8">
        <div className="bg-red-50 border border-red-200 rounded-2xl p-6 animate-fade-in">
          <h3 className="text-lg font-semibold text-red-900 mb-2">Error Loading Dashboard</h3>
          <p className="text-red-700">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-6 py-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-4xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent mb-2">
          Dashboard
        </h1>
        <p className="text-gray-600">Welcome back! Here's what's happening today.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        <StatsCard title="Upcoming" value={stats.upcoming} icon="📅" />
        <StatsCard title="Completed" value={stats.completed} icon="✅" />
        <StatsCard
          title="Total Earnings"
          value={`$${stats.earnings.toFixed(2)}`}
          icon="💰"
        />
      </div>

      {/* Upcoming Appointments */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-gray-900">Upcoming Appointments</h2>
          <span className="text-sm text-gray-500 font-medium">{appointments.length} appointments</span>
        </div>
        <div className="space-y-4">
          {appointments.length === 0 ? (
            <div className="bg-white rounded-2xl p-12 text-center border border-gray-100">
              <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg className="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <p className="text-gray-500 font-medium">No upcoming appointments</p>
            </div>
          ) : (
            appointments.map((appointment) => (
              <AppointmentCard key={appointment.id} appointment={appointment} />
            ))
          )}
        </div>
      </div>
    </div>
  );
};
