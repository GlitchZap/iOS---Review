import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Appointment } from '../types';
import { AppointmentCard } from '../components/dashboard/AppointmentCard';
import { appointmentsAPI } from '../services/api';

export const Appointments: React.FC = () => {
  const { user } = useAuth();
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [filter, setFilter] = useState<'all' | 'upcoming' | 'completed'>('all');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (user) {
      loadAppointments();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user, filter]);

  const loadAppointments = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Get filter status for API
      let status: string | undefined;
      if (filter === 'upcoming') {
        status = 'confirmed';
      } else if (filter === 'completed') {
        status = 'completed';
      }
      
      const response = await appointmentsAPI.getAll(status);
      
      if (response.success) {
        let filtered = response.appointments || [];
        
        // Additional client-side filtering for upcoming
        if (filter === 'upcoming') {
          filtered = filtered.filter((a: Appointment) => 
            new Date(a.scheduled_for) > new Date()
          );
        }
        
        setAppointments(filtered);
      }
    } catch (err: any) {
      console.error('Failed to load appointments:', err);
      setError('Failed to load appointments. Please try again.');
      setAppointments([]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container mx-auto px-6 py-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-4xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent mb-2">
          Appointments
        </h1>
        <p className="text-gray-600">Manage your upcoming and past appointments</p>
      </div>

      {/* Filter Tabs */}
      <div className="flex space-x-2 mb-8 bg-white rounded-2xl p-2 w-fit shadow-md border border-gray-100">
        {[{ value: 'all', label: 'All', icon: '📋' }, 
          { value: 'upcoming', label: 'Upcoming', icon: '⏰' }, 
          { value: 'completed', label: 'Completed', icon: '✅' }].map((tab) => (
          <button
            key={tab.value}
            onClick={() => setFilter(tab.value as any)}
            className={`
              px-6 py-3 rounded-xl font-semibold text-sm transition-all duration-300
              ${filter === tab.value 
                ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg shadow-blue-500/30' 
                : 'text-gray-600 hover:bg-gray-50'}
            `}
          >
            <span className="mr-2">{tab.icon}</span>
            {tab.label}
          </button>
        ))}
      </div>

      {/* Error State */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-2xl p-6 mb-6">
          <div className="flex items-center">
            <svg className="w-6 h-6 text-red-500 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <p className="text-red-700">{error}</p>
            <button 
              onClick={loadAppointments}
              className="ml-auto px-4 py-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 transition-colors"
            >
              Retry
            </button>
          </div>
        </div>
      )}

      {/* Appointments List */}
      <div className="space-y-4">
        {loading ? (
          <div className="bg-white rounded-2xl p-12 text-center border border-gray-100">
            <div className="w-12 h-12 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto mb-4"></div>
            <p className="text-gray-500 font-medium">Loading appointments...</p>
          </div>
        ) : appointments.length === 0 ? (
          <div className="bg-white rounded-2xl p-12 text-center border border-gray-100">
            <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            </div>
            <p className="text-gray-500 font-medium">No appointments found</p>
            <p className="text-gray-400 text-sm mt-2">When users schedule sessions with you, they'll appear here</p>
          </div>
        ) : (
          appointments.map((appointment) => (
            <AppointmentCard key={appointment.id} appointment={appointment} />
          ))
        )}
      </div>
    </div>
  );
};
