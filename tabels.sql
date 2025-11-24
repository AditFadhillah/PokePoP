
--create user table: 
CREATE TABLE IF NOT EXISTS gameusers (
    username character varying NOT NULL UNIQUE PRIMARY KEY, 
    encrypted_password character varying NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
)
--create activity table:  //Tracking ussage time in ms 
CREATE TABLE IF NOT EXISTS activity_time (
    sessionid uuid DEFAULT gen_random_uuid() PRIMARY KEY UNIQUE,
    username character varying NOT NULL UNIQUE, 
    started_at timestamp with time zone,
    last_beat_at timestamp with time zone,
    ended_at timestamp with time zone,
    active_ms bigint NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    meta jsonb,
    CONSTRAINT fk_session_username FOREIGN KEY (username) REFERENCES public.gameusers(username),
)

--create task table:  
CREATE TABLE IF NOT EXISTS all_tasks (
    taskid uuid DEFAULT gen_random_uuid() PRIMARY KEY UNIQUE,
    taskname TEXT varying NOT NULL UNIQUE, --thinking of having example as 2.b or such or having a coding convestion like w49t3.b 
    task_group TEXT varying, -- thiking using the group id to exlude solved task but still in same group 
    task_description TEXT varying, -- Detalied task description for render in app 
    task_answer TEXT varying, -- The correct answer for this task , used for evaluation 
)

--create task_progress_tracking table:  // used for tracking what task, when, how fast user have solved certain tasks. 
CREATE TABLE IF NOT EXISTS task_progress_tracking (
    progressid uuid DEFAULT gen_random_uuid() PRIMARY KEY UNIQUE,
    username TEXT,
    taskid uuid, 
    solved_time_ms bigint NOT NULL DEFAULT 0, -- total time for user to solve this task in ms?
    solved_at timestamp with time zone NOT NULL DEFAULT now(), --date for the user solved the task 
    CONSTRAINT fk_progressid_username FOREIGN KEY (username) REFERENCES public.gameusers(username),
    CONSTRAINT fk_progressid_taskid FOREIGN KEY (taskid) REFERENCES public.all_tasks(taskid),
)

--create task_progress_tracking table:  // used for tracking what task, when, how fast user have solved certain tasks. 
CREATE TABLE IF NOT EXISTS task_progress_tracking (
    progressid uuid DEFAULT gen_random_uuid() PRIMARY KEY UNIQUE,
    username TEXT,
    taskid uuid, 
    solved_time_ms bigint NOT NULL DEFAULT 0, -- total time for user to solve this task in ms?
    solved_at timestamp with time zone NOT NULL DEFAULT now(), --date for the user solved the task 
    CONSTRAINT fk_progressid_username FOREIGN KEY (username) REFERENCES public.gameusers(username),
    CONSTRAINT fk_progressid_taskid FOREIGN KEY (taskid) REFERENCES public.all_tasks(taskid),
)

-- Create pokemon_inventory table // used for keep track what pokemons user has 
CREATE TABLE IF NOT EXISTS public.pokemon_inventory (
    ownership_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username UUID REFERENCES public.gameusers(username) ON DELETE CASCADE,
    pokemon_name TEXT NOT NULL,
    level INTEGER NOT NULL DEFAULT 1,
    points INTEGER NOT NULL DEFAULT 0,
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Add constraints
    CHECK (level > 0 AND level <= 100),
    CHECK (points >= 0)
);


-- Create achievements table 
create table achievements (
  id uuid primary key default gen_random_uuid(),

  code text not null unique,          -- e.g. 'FIRST_CAPTURE', 'CAPTURE_5'
  title text not null,                -- short name shown to the user
  description text,                   -- longer text shown to the user

  category text not null,             -- e.g. 'capture', 'login', 'duration', 'region'

  -- What metric this achievement is about
  metric text not null,               -- e.g. 'total_captures', 'login_streak_days', 'region_completed', 'active_minutes'

  -- Numerical threshold for the metric, e.g. 1, 5, 10, 60, 90, 120
  threshold integer not null,

  -- Optional extra info (like which region)
  region integer,                     -- null for non-region achievements

  created_at timestamptz not null default now()
);

-- Create user_achievements //  Which achievements a player has unlocked
create table user_achievements (
  id uuid primary key default gen_random_uuid(),

  username text not null,            -- or user_id / trainer_id
  achievement_id uuid not null references achievements(id) on delete cascade,

  unlocked_at timestamptz not null default now(),

  unique (username, achievement_id)  -- can't unlock the same thing twice
);

insert into achievements (code, title, description, category, metric, threshold)
values (
  'FIRST_CAPTURE',
  'First Capture',
  'Capture your very first monster.',
  'capture',
  'total_captures',
  1
);

insert into achievements (code, title, description, category, metric, threshold)
values
  ('LOGIN_STREAK_1', 'Login Streak I', 'Log in 1 day in a row.',  'login', 'login_streak_days', 1),
  ('LOGIN_STREAK_2', 'Login Streak II','Log in 2 days in a row.', 'login', 'login_streak_days', 2),
  ('LOGIN_STREAK_3', 'Login Streak III','Log in 3 days in a row.','login','login_streak_days', 3),
  ('LOGIN_STREAK_4', 'Login Streak IV','Log in 4 days in a row.','login','login_streak_days', 4),
  ('LOGIN_STREAK_5', 'Login Streak V','Log in 5 days in a row.','login','login_streak_days', 5);


insert into achievements (code, title, description, category, metric, threshold, region)
values
  ('REGION_1_COMPLETE', 'Region 1 Master', 'Capture all monsters in Region 1.', 'region', 'region_completed', 1, 1),
  ('REGION_2_COMPLETE', 'Region 2 Master', 'Capture all monsters in Region 2.', 'region', 'region_completed', 1, 2),
  ('REGION_3_COMPLETE', 'Region 3 Master', 'Capture all monsters in Region 3.', 'region', 'region_completed', 1, 3),
  ('REGION_4_COMPLETE', 'Region 4 Master', 'Capture all monsters in Region 4.', 'region', 'region_completed', 1, 4);

insert into achievements (code, title, description, category, metric, threshold)
values
  ('DURATION_60',  'Endurance I',  'Be active for 60 minutes total.',  'duration', 'active_minutes', 60),
  ('DURATION_90',  'Endurance II', 'Be active for 90 minutes total.',  'duration', 'active_minutes', 90),
  ('DURATION_120', 'Endurance III','Be active for 120 minutes total.', 'duration', 'active_minutes', 120);
  
-- need to ask how to crate achivement table? 
-- todo refine the tables 
-- connect them in code and push to get 
--   this means that all the other codes should be updated and aligned, the insert and select task tabels. 
--  make report as well .
-- look at the tasks 
-- ask if he has the absalon link now or ping daniel 

