// databaseFunctions.ts — works in both Vite and Node
import { createClient } from '@supabase/supabase-js'
import 'dotenv/config'

// Determine runtime environment
const isVite = typeof import.meta !== 'undefined' && !!import.meta.env

// Use Vite env in browser, .env in Node
const SUPABASE_URL = isVite ? import.meta.env.VITE_SUPABASE_URL : process.env.SUPABASE_URL
const SUPABASE_ANON_KEY = isVite ? import.meta.env.VITE_SUPABASE_ANON_KEY : process.env.SUPABASE_ANON_KEY

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error('❌ Missing Supabase credentials: check VITE_ vars or .env file')
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: true, autoRefreshToken: true }
})


/*
Above code is used to make a seperate test for the database function. 

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL!,
  import.meta.env.VITE_SUPABASE_ANON_KEY!,
  { auth: { persistSession: true, autoRefreshToken: true } }
)
*/


// export async function extractTaskAnswer(taskID:string, userResult: string): Promise<string> {
// need to update this with pass the taskID for the database. 
export async function extractTaskAnswer(taskID:string, userResult: string): Promise<boolean> {
  // Current task ID is used the 
  // connect to database 
  // select SQL 
    
    // should we always auth the user?? 
    //const { data: { user }, error: userErr } = await supabase.auth.getUser()
    //if (userErr || !user) { console.error(userErr || 'No user') }

    //extract the taskresult. 
    // Select it from query 
    const { data: correctTaskData, error: correctTaskError } = await supabase.from('tasktable').select('correctkey').eq('id', taskID);

    //Extract from query. Save as string. 
    let correctTaskRes: string | null = null;
    if (correctTaskError) {
      console.error(correctTaskError);
    } else if (correctTaskData && correctTaskData.length > 0 && correctTaskData[0].correctkey !== undefined) {
      correctTaskRes = correctTaskData[0].correctkey;
      console.log('Result of query:', correctTaskRes)
    }
    
  
    
    /* returns this: 
        {
      data: Array<{ correctKey: string }>,
      error: any,
      status: number,
      statusText: string
    }*/ 

    //Compare bothe result. 

    var corectness = false; 

    if(correctTaskRes === userResult) {
      corectness = true
      } 



  return corectness 
}

// missing adding the time aspect 
// missing to do this fixing the uuid & updating 
export async function notifyDBAndGodot(userID:any, taskID:string, resBool:boolean) {

    if (resBool) {
      // clean editor ?? gives a string?? then reupdate the editor with a string? then the function should return a string too 

      // update the user record 

      //const { data: { user }, error: userErr } = await supabase.auth.getUser()
      //if (userErr || !user) { console.error(userErr || 'No user'); return }

      const finishTime = new Date().toISOString();
      const { error } = await supabase
        .from('donetable') 
        .upsert([{ userid: userID, taskid: taskID, finnishtime: finishTime }])

      if (error) console.error('DB upsert error:', error)
      
      
    }

    // send msg to GODOT 

}