# Supabase Integration Guide

This guide explains how the Expert Portal is connected to Supabase.

## Setup

### 1. Environment Variables

Create a `.env.local` file in the root directory with your Supabase credentials:

```env
REACT_APP_SUPABASE_URL=https://rpxccrfbicwkoeenhfkm.supabase.co
REACT_APP_SUPABASE_ANON_KEY=your_anon_key_here
```

### 2. Database Schema

The application uses the following Supabase tables:

- **experts** - Expert profiles linked to auth.users
- **appointments** - Appointment bookings
- **availability** - Expert availability schedule
- **messages** - Chat messages between experts and clients
- **earnings** - Payment and earnings tracking
- **profiles** - User profiles
- **users** - Basic user information

## File Structure

```
src/
├── lib/
│   └── supabase.ts              # Supabase client initialization
├── types/
│   ├── database.ts              # TypeScript types for database schema
│   └── index.ts                 # Application types
├── services/
│   └── supabase.service.ts      # Database service functions
├── context/
│   ├── AuthContext.tsx          # Legacy auth (backend API)
│   └── SupabaseAuthContext.tsx  # New Supabase auth
```

## Usage

### Authentication

To use Supabase authentication, replace the import in `App.tsx`:

```typescript
// Old (backend API)
import { AuthProvider } from './context/AuthContext';

// New (Supabase)
import { AuthProvider } from './context/SupabaseAuthContext';
```

### Using Supabase Services

```typescript
import { 
  authService, 
  expertService, 
  appointmentService, 
  availabilityService,
  messageService,
  earningsService 
} from '../services/supabase.service';

// Example: Get expert appointments
const appointments = await appointmentService.getByExpertId(expertId);

// Example: Send a message
await messageService.send({
  appointment_id: appointmentId,
  sender_type: 'expert',
  sender_name: 'Expert Name',
  content: 'Hello!',
});

// Example: Subscribe to real-time messages
const subscription = messageService.subscribe(appointmentId, (message) => {
  console.log('New message:', message);
});
```

### Direct Supabase Client Usage

```typescript
import { supabase } from '../lib/supabase';

// Query data
const { data, error } = await supabase
  .from('experts')
  .select('*')
  .eq('verified', true);

// Insert data
const { data, error } = await supabase
  .from('appointments')
  .insert({ 
    expert_id: 'xxx',
    client_name: 'John Doe',
    // ... other fields
  });

// Real-time subscriptions
supabase
  .channel('appointments')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'appointments' },
    (payload) => console.log('New appointment!', payload)
  )
  .subscribe();
```

## Migration from Backend API to Supabase

### Current State
- Backend API (Express + MySQL) is still running
- Frontend uses custom auth with JWT tokens
- API endpoints in `src/services/api.ts`

### To Migrate to Supabase

1. **Update App.tsx** to use `SupabaseAuthContext`:
```typescript
import { AuthProvider } from './context/SupabaseAuthContext';
```

2. **Update Pages** to use Supabase services:
```typescript
// Instead of:
import { appointmentsAPI } from '../services/api';

// Use:
import { appointmentService } from '../services/supabase.service';
```

3. **Update Protected Routes** to check Supabase auth:
```typescript
const { user, loading } = useAuth(); // from SupabaseAuthContext
```

## Row Level Security (RLS)

Make sure to enable RLS policies in Supabase for security:

```sql
-- Example: Experts can only see their own data
CREATE POLICY "Experts can view own appointments"
  ON appointments FOR SELECT
  USING (auth.uid() = (
    SELECT auth_user_id FROM experts WHERE id = expert_id
  ));

-- Example: Experts can update their own profile
CREATE POLICY "Experts can update own profile"
  ON experts FOR UPDATE
  USING (auth.uid() = auth_user_id);
```

## Testing the Connection

1. Start the React app:
```bash
npm start
```

2. Open browser console and test:
```javascript
import { supabase } from './lib/supabase';

// Test connection
const { data, error } = await supabase.from('experts').select('count');
console.log('Connection test:', { data, error });
```

## Troubleshooting

### Environment Variables Not Loading
- Restart the development server after creating `.env.local`
- Ensure file is named exactly `.env.local` (not `.env.local.txt`)
- Variables must start with `REACT_APP_`

### CORS Errors
- Check Supabase project settings > API > CORS
- Add your local development URL (http://localhost:3000)

### Authentication Issues
- Verify email confirmation is disabled in Supabase (for development)
- Check Supabase Auth settings for email templates
- Ensure RLS policies allow the operation

## Features

### ✅ Implemented
- Supabase client initialization
- TypeScript database types
- Authentication service (sign up, sign in, sign out)
- Expert service (CRUD operations)
- Appointment service (CRUD + stats)
- Availability service (CRUD)
- Message service (CRUD + real-time subscriptions)
- Earnings service (CRUD + stats)

### 🔄 Dual Mode Support
The application currently supports both:
- **Backend API** (Express + MySQL) - Current production
- **Supabase** - New integration (ready to use)

You can switch between them by changing the AuthProvider import.

## Next Steps

1. Test Supabase authentication flow
2. Migrate pages one by one to use Supabase services
3. Add Row Level Security policies
4. Remove old backend API dependencies
5. Deploy to production with Supabase

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
