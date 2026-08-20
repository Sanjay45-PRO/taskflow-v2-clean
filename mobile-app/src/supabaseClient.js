import 'react-native-url-polyfill/auto';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';

// Same project as the TaskFlow web dashboard — one shared database.
const SUPABASE_URL = 'https://tdmqnlcndmkvmoazdosr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRkbXFubGNuZG1rdm1vYXpkb3NyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyMjIyMDEsImV4cCI6MjEwMjc5ODIwMX0.ePpAq7mugGZiZ8QtltW1YmYZ2KuDokV9GPwI242GCgY';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { storage: AsyncStorage, autoRefreshToken: true, persistSession: true, detectSessionInUrl: false }
});
