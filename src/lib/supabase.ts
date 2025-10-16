import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL!,
  import.meta.env.VITE_SUPABASE_ANON_KEY!,
  { auth: { persistSession: true, autoRefreshToken: true } }
)


// export const updateDB = print()

export const updateDB = () => {
  console.log('Database update function called')
} // REMOVE WHEN DONE WITH DB (MADE BY ADIT)