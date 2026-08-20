/*
  Replace with your own Supabase project values.
  Get them from: Supabase dashboard -> Project Settings -> API
  (Project URL, and the "anon public" key — never use the service_role key here)
*/
const SUPABASE_URL = "https://tdmqnlcndmkvmoazdosr.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRkbXFubGNuZG1rdm1vYXpkb3NyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyMjIyMDEsImV4cCI6MjEwMjc5ODIwMX0.ePpAq7mugGZiZ8QtltW1YmYZ2KuDokV9GPwI242GCgY";

/*
  Same VAPID public key you generated for the task-reminder function
  (run `npx web-push generate-vapid-keys`, use the "Public Key" here).
*/
const VAPID_PUBLIC_KEY = "BBgVatPJ8rgchxO9osmb7kBYH7WuiPOAPi3h97I-CdkoX1-uS7PUnxXWqZtzwYHwDi9l60UqNmEsC1gOIdRQ-6k";

const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
