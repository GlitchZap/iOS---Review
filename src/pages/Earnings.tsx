import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Payout } from '../types';
import { Card } from '../components/ui/Card';
import { format } from 'date-fns';

// Mock payouts data
const MOCK_PAYOUTS: Payout[] = [
  {
    id: '1',
    expert_id: 'mock-expert-1',
    amount: 150,
    status: 'paid',
    payment_date: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString()
  },
  {
    id: '2',
    expert_id: 'mock-expert-1',
    amount: 180,
    status: 'paid',
    payment_date: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000).toISOString(),
    created_at: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000).toISOString()
  },
  {
    id: '3',
    expert_id: 'mock-expert-1',
    amount: 200,
    status: 'pending',
    payment_date: undefined,
    created_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString()
  },
  {
    id: '4',
    expert_id: 'mock-expert-1',
    amount: 175,
    status: 'paid',
    payment_date: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
    created_at: new Date(Date.now() - 12 * 24 * 60 * 60 * 1000).toISOString()
  }
];

export const Earnings: React.FC = () => {
  const { user } = useAuth();
  const [payouts, setPayouts] = useState<Payout[]>([]);
  const [totalEarnings, setTotalEarnings] = useState(0);
  const [pendingEarnings, setPendingEarnings] = useState(0);

  useEffect(() => {
    if (user) {
      loadEarnings();
    }
  }, [user]);

  const loadEarnings = async () => {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 300));

    const data = MOCK_PAYOUTS;
    setPayouts(data);
    const paid = data.filter((p) => p.status === 'paid').reduce((sum, p) => sum + p.amount, 0);
    const pending = data.filter((p) => p.status === 'pending').reduce((sum, p) => sum + p.amount, 0);
    setTotalEarnings(paid);
    setPendingEarnings(pending);
  };

  return (
    <div className="container mx-auto px-6 py-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-4xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent mb-2">
          Earnings
        </h1>
        <p className="text-gray-600">Track your payouts and financial performance</p>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
        <Card className="relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-green-500 to-emerald-500" />
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-500 mb-2">Total Earnings</p>
              <h2 className="text-4xl font-bold text-gray-900">
                ${totalEarnings.toFixed(2)}
              </h2>
              <p className="text-sm text-green-600 font-medium mt-2 flex items-center">
                <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
                Paid out
              </p>
            </div>
            <div className="w-16 h-16 bg-gradient-to-br from-green-100 to-emerald-100 rounded-2xl flex items-center justify-center text-3xl">
              💰
            </div>
          </div>
        </Card>
        
        <Card className="relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-yellow-500 to-orange-500" />
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-500 mb-2">Pending</p>
              <h2 className="text-4xl font-bold text-gray-900">
                ${pendingEarnings.toFixed(2)}
              </h2>
              <p className="text-sm text-yellow-600 font-medium mt-2 flex items-center">
                <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Processing
              </p>
            </div>
            <div className="w-16 h-16 bg-gradient-to-br from-yellow-100 to-orange-100 rounded-2xl flex items-center justify-center text-3xl">
              ⏳
            </div>
          </div>
        </Card>
      </div>

      {/* Payout History */}
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Payout History</h2>
        <p className="text-gray-600">Complete transaction history</p>
      </div>
      
      <div className="space-y-4">
        {payouts.length === 0 ? (
          <div className="bg-white rounded-2xl p-12 text-center border border-gray-100">
            <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
            </div>
            <p className="text-gray-500 font-medium">No payouts yet</p>
          </div>
        ) : (
          payouts.map((payout) => (
            <Card key={payout.id}>
              <div className="flex justify-between items-center">
                <div className="flex items-center space-x-4">
                  <div className={`
                    w-12 h-12 rounded-2xl flex items-center justify-center text-2xl
                    ${payout.status === 'paid' 
                      ? 'bg-gradient-to-br from-green-100 to-emerald-100' 
                      : 'bg-gradient-to-br from-yellow-100 to-orange-100'}
                  `}>
                    {payout.status === 'paid' ? '✅' : '⏳'}
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-gray-900">
                      ${payout.amount.toFixed(2)}
                    </h3>
                    <p className="text-sm text-gray-500 flex items-center mt-1">
                      <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                      {format(new Date(payout.created_at), 'MMM dd, yyyy')}
                    </p>
                  </div>
                </div>
                <span className={`
                  px-4 py-2 rounded-full text-sm font-semibold border
                  ${payout.status === 'paid' 
                    ? 'bg-green-100 text-green-700 border-green-200' 
                    : 'bg-yellow-100 text-yellow-700 border-yellow-200'}
                  capitalize
                `}>
                  {payout.status}
                </span>
              </div>
            </Card>
          ))
        )}
      </div>
    </div>
  );
};