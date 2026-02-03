import React, { useEffect, useState, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Message, Appointment } from '../types';
import { Card } from '../components/ui/Card';
import { messagesAPI, appointmentsAPI } from '../services/api';

type AppointmentRow = Appointment & { parent_name?: string; scheduled_at?: string };
type MessageRow = Message & { content?: string; created_at?: string; sender_type?: string; sender_name?: string };

export const Chat: React.FC = () => {
  const { appointmentId } = useParams<{ appointmentId: string }>();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [appointment, setAppointment] = useState<AppointmentRow | null>(null);
  const [messages, setMessages] = useState<MessageRow[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const pollIntervalRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (!appointmentId || !user) return;

    const fetchAppointment = async () => {
      try {
        setLoading(true);
        const response = await appointmentsAPI.getOne(appointmentId as any);
        if (response.success) {
          setAppointment(response.appointment);
        }
      } catch (err: any) {
        console.error('Failed to load appointment:', err);
        setError('Failed to load appointment details');
      } finally {
        setLoading(false);
      }
    };

    const fetchMessages = async () => {
      try {
        const response = await messagesAPI.getByAppointment(appointmentId as any);
        if (response.success) {
          setMessages(response.messages || []);
        }
      } catch (err: any) {
        console.error('Failed to load messages:', err);
      }
    };

    fetchAppointment();
    fetchMessages();
    
    // Poll for new messages every 5 seconds
    pollIntervalRef.current = setInterval(fetchMessages, 5000);
    
    return () => {
      if (pollIntervalRef.current) {
        clearInterval(pollIntervalRef.current);
      }
    };
  }, [appointmentId, user]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const getAppointmentName = (appt: AppointmentRow) =>
    appt.parent_name ?? appt.client_name ?? 'Client';

  const getAppointmentTime = (appt: AppointmentRow) =>
    appt.scheduled_at ?? appt.scheduled_for;

  const getMessageContent = (msg: MessageRow) =>
    msg.content ?? msg.message ?? '';

  const getMessageTime = (msg: MessageRow) =>
    msg.created_at ?? msg.sent_at;
  
  const isExpertMessage = (msg: MessageRow) =>
    msg.sender_role === 'expert' || msg.sender_type === 'expert';

  const sendMessage = async () => {
    if (!newMessage.trim() || sending) return;

    try {
      setSending(true);
      setError(null);
      
      const response = await messagesAPI.send(appointmentId as any, newMessage.trim());
      
      if (response.success) {
        // Add the new message to the list
        setMessages(prev => [...prev, response.data]);
        setNewMessage('');
      }
    } catch (err: any) {
      console.error('Failed to send message:', err);
      setError('Failed to send message. Please try again.');
    } finally {
      setSending(false);
    }
  };

  const handleFileAttachment = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Handle file upload logic here
      console.log('File selected:', file.name);
    }
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
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
            <span className="text-gray-600 font-medium">Loading chat...</span>
          </div>
        </div>
      </div>
    );
  }

  if (!appointment) {
    return (
      <div className="container mx-auto px-6 py-8">
        <div className="text-center">
          <h2 className="text-xl font-semibold text-gray-700">Appointment not found</h2>
          <button
            onClick={() => navigate('/appointments')}
            className="mt-4 text-blue-600 hover:underline"
          >
            Back to Appointments
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-6 py-8 max-w-4xl animate-fade-in">
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 mb-4 transition-colors"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          <span className="font-medium">Back to Appointments</span>
        </button>
        
        <div className="flex items-center space-x-4">
          <div className="w-14 h-14 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-bold text-xl">
            {getAppointmentName(appointment).charAt(0).toUpperCase()}
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900">{getAppointmentName(appointment)}</h2>
            <p className="text-gray-500 flex items-center mt-1">
              <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              {new Date(getAppointmentTime(appointment)).toLocaleString()}
            </p>
          </div>
        </div>
      </div>

      {/* Messages Card */}
      <Card className="h-[640px] flex flex-col bg-white/80 backdrop-blur-sm border border-gray-100 shadow-2xl rounded-3xl">
        {/* Error Message */}
        {error && (
          <div className="m-4 p-3 bg-red-50 border border-red-200 rounded-xl text-red-600 text-sm">
            {error}
          </div>
        )}
        
        {/* Messages Container */}
        <div className="flex-1 overflow-y-auto p-5 space-y-5 scrollbar-thin scrollbar-thumb-gray-300">
          {messages.length === 0 ? (
            <div className="flex items-center justify-center h-full">
              <div className="text-center text-gray-500">
                <svg className="w-16 h-16 mx-auto mb-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
                <p className="font-medium">No messages yet</p>
                <p className="text-sm mt-1">Start the conversation!</p>
              </div>
            </div>
          ) : (
            messages.map((message) => {
              const timestamp = getMessageTime(message);
              const isExpert = isExpertMessage(message);
              
              return (
                <div
                  key={message.id}
                  className={`flex items-end ${isExpert ? 'justify-end' : 'justify-start'} animate-fade-in`}
                >
                  <div className={`flex items-end space-x-3 max-w-[78%] ${isExpert ? 'flex-row-reverse' : ''}`}>
                    <div className="shrink-0">
                      <div className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center text-sm font-semibold text-gray-700 shadow-sm">
                        {isExpert ? 'E' : getAppointmentName(appointment).charAt(0).toUpperCase()}
                      </div>
                    </div>
                    <div>
                      <div
                        className={isExpert
                          ? 'px-5 py-3 shadow-sm leading-relaxed text-sm bg-gradient-to-r from-blue-500 to-sky-500 text-white rounded-bl-2xl rounded-tl-2xl rounded-tr-xl'
                          : 'px-5 py-3 shadow-sm leading-relaxed text-sm bg-white text-gray-900 border border-gray-200 rounded-br-2xl rounded-tr-2xl rounded-tl-xl'
                        }
                      >
                        <p className="whitespace-pre-wrap">{getMessageContent(message)}</p>
                      </div>
                      <p className={`text-xs text-gray-400 mt-1 ${isExpert ? 'text-right' : 'text-left'}`}>
                        {timestamp ? new Date(timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })
          )}
          
          <div ref={messagesEndRef} />
        </div>

        {/* Input Area */}
        <div className="border-t border-gray-100 p-4 bg-transparent rounded-b-3xl">
          <div className="flex items-center gap-3">
            <input
              ref={fileInputRef}
              type="file"
              onChange={handleFileChange}
              className="hidden"
              accept="image/*,.pdf,.doc,.docx"
            />
            
            <button 
              onClick={handleFileAttachment}
              className="p-2 rounded-full hover:bg-gray-100 transition-colors"
              title="Attach file"
            >
              <svg className="w-5 h-5 text-gray-500" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13" />
              </svg>
            </button>

            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && !sending && sendMessage()}
              placeholder="Share a note, link, or file..."
              className="flex-1 px-4 py-3 rounded-full border border-gray-200 focus:border-sky-400 focus:ring-2 focus:ring-sky-400/20 transition-all outline-none bg-white"
              disabled={sending}
            />

            <button 
              type="button" 
              onClick={sendMessage}
              disabled={!newMessage.trim() || sending}
              className="rounded-full bg-gradient-to-r from-blue-600 to-purple-600 text-white p-3 shadow-md hover:opacity-95 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              title="Send message"
            >
              {sending ? (
                <svg className="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
              ) : (
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" d="M22 2L11 13" />
                  <path strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" d="M22 2l-7 20-4-9-9-4 20-7z" />
                </svg>
              )}
            </button>
          </div>
        </div>
      </Card>
    </div>
  );
};
