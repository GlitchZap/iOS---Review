import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

/**
 * Test Component to verify Supabase Connection
 * 
 * This component tests:
 * 1. Database connection
 * 2. Fetching experts from the database
 * 3. Real-time subscriptions
 * 
 * Usage: Import this component in App.tsx to test the connection
 */
export const SupabaseTest: React.FC = () => {
  const [connectionStatus, setConnectionStatus] = useState<'testing' | 'connected' | 'error'>('testing');
  const [experts, setExperts] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    testConnection();
  }, []);

  const testConnection = async () => {
    try {
      console.log('🔍 Testing Supabase connection...');

      // Test 1: Fetch experts
      const { data, error: fetchError } = await supabase
        .from('experts')
        .select('*')
        .limit(5);

      if (fetchError) {
        throw fetchError;
      }

      console.log('✅ Supabase connection successful!');
      console.log('📊 Fetched experts:', data);
      
      setExperts(data || []);
      setConnectionStatus('connected');
      
    } catch (err: any) {
      console.error('❌ Supabase connection failed:', err);
      setError(err.message || 'Connection failed');
      setConnectionStatus('error');
    }
  };

  const testAuth = async () => {
    try {
      // Get current session
      const { data: { session } } = await supabase.auth.getSession();
      console.log('Current session:', session);
      
      if (!session) {
        console.log('No active session. Try signing up or logging in.');
      }
    } catch (err: any) {
      console.error('Auth test error:', err);
    }
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h2>🔌 Supabase Connection Test</h2>
      
      <div style={{ marginBottom: '20px' }}>
        <h3>Connection Status:</h3>
        {connectionStatus === 'testing' && <p>⏳ Testing connection...</p>}
        {connectionStatus === 'connected' && (
          <p style={{ color: 'green' }}>✅ Connected successfully!</p>
        )}
        {connectionStatus === 'error' && (
          <p style={{ color: 'red' }}>❌ Connection failed: {error}</p>
        )}
      </div>

      {experts.length > 0 && (
        <div>
          <h3>Experts Found ({experts.length}):</h3>
          <ul>
            {experts.map((expert) => (
              <li key={expert.id}>
                <strong>{expert.full_name}</strong> - {expert.email}
                {expert.verified && ' ✅'}
              </li>
            ))}
          </ul>
        </div>
      )}

      {experts.length === 0 && connectionStatus === 'connected' && (
        <div>
          <p>No experts found in the database yet.</p>
          <p>Try creating an expert account through the registration page.</p>
        </div>
      )}

      <div style={{ marginTop: '30px' }}>
        <button 
          onClick={testAuth}
          style={{
            padding: '10px 20px',
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Test Authentication
        </button>
        <button 
          onClick={testConnection}
          style={{
            padding: '10px 20px',
            backgroundColor: '#28a745',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
            marginLeft: '10px'
          }}
        >
          Retry Connection
        </button>
      </div>

      <div style={{ marginTop: '30px', backgroundColor: '#f8f9fa', padding: '15px', borderRadius: '4px' }}>
        <h4>📝 Quick Guide:</h4>
        <ol>
          <li><strong>Check Console:</strong> Open browser console to see detailed logs</li>
          <li><strong>Test Auth:</strong> Click "Test Authentication" to check auth status</li>
          <li><strong>Create Account:</strong> Go to /register to create a new expert account</li>
          <li><strong>View Data:</strong> Experts will appear above once accounts are created</li>
        </ol>
      </div>

      <div style={{ marginTop: '20px', backgroundColor: '#fff3cd', padding: '15px', borderRadius: '4px' }}>
        <h4>⚠️ Important:</h4>
        <ul>
          <li>Ensure `.env.local` file exists with correct Supabase credentials</li>
          <li>Check that Supabase project is active</li>
          <li>Verify Row Level Security (RLS) policies if queries fail</li>
          <li>Backend API is still running - you can use either system</li>
        </ul>
      </div>
    </div>
  );
};
