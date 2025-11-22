import { createClient } from '@supabase/supabase-js'

const isVite = typeof import.meta !== 'undefined' && !!import.meta.env
const SUPABASE_URL = isVite ? import.meta.env.VITE_SUPABASE_URL : process.env.SUPABASE_URL
const SUPABASE_ANON_KEY = isVite ? import.meta.env.VITE_SUPABASE_ANON_KEY : process.env.SUPABASE_ANON_KEY

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error('Missing Supabase credentials')
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: true, autoRefreshToken: true }
})
