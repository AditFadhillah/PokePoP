// testDatabase.ts — run this to test Supabase functions in Node
// import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'
// import { extractTaskAnswer,notifyDBAndGodot } from '../databaseFunctions'  // fixed import path

// Load environment vars from .env
const SUPABASE_URL = process.env.SUPABASE_URL!
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY!

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error('❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file')
}

// Create the client manually (bypasses Vite)
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Patch Supabase auth for Node test environment
supabase.auth.getUser = async () => {
  console.log('🧩 Mocked getUser() for Node environment')
  return {
    data: {
      user: {
        id: 'node-test-user',
        app_metadata: {},
        user_metadata: {},
        aud: 'authenticated',
        created_at: new Date().toISOString(),
      }
    },
    error: null
  }
}



// ------------------ Test runner ------------------
async function main() {
  console.log('🔍 Testing database connection...')

  //small letters for table name 
  const { data, error } = await supabase.from('tasktable').select('*').limit(1)
  if (error) {
    console.error('❌ Database error:', error)
  } else {
    console.log('✅ Connection OK. Sample data:', data)
  }

  // console.log('\n🧠 Testing extractTaskAnswer...')
  // const result = await extractTaskAnswer('testTask1', 'testTaskKey1')
  // console.log('Result of extractTaskAnswer:', result)
  
  // const result2 = await notifyDBAndGodot((await supabase.auth.getUser()).data.user?.id,'testTask1', result)
  // console.log('Result2 of notifyDBAndGodot:', result2)
}

main().catch((err) => console.error('Unexpected error:', err))


// running command: 
//  npx tsx src/lib/testfiles/testDatabase.ts