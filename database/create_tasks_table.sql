-- Create programming tasks table for Pokemon capture challenges
-- Run this in your Supabase SQL Editor

-- Drop existing columns if they exist
ALTER TABLE IF EXISTS public.programming_tasks 
DROP COLUMN IF EXISTS difficulty,
DROP COLUMN IF EXISTS points_reward;

CREATE TABLE IF NOT EXISTS public.programming_tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    starter_code TEXT,
    expected_output TEXT NOT NULL,
    test_cases JSONB, -- Store multiple test cases if needed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.programming_tasks ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view programming tasks" ON public.programming_tasks;
DROP POLICY IF EXISTS "Admins can manage tasks" ON public.programming_tasks;

-- Allow everyone to read tasks
CREATE POLICY "Anyone can view programming tasks" ON public.programming_tasks
    FOR SELECT USING (true);

-- Only admins can insert/update/delete tasks (adjust as needed)
CREATE POLICY "Admins can manage tasks" ON public.programming_tasks
    FOR ALL USING (auth.uid() IS NOT NULL);

-- Insert sample tasks from the worksheet
INSERT INTO public.programming_tasks (title, description, starter_code, expected_output)
VALUES 
(
    'Tuple Unpacking',
    'Create a tuple called month_abbrevs with Jan, Feb, Mar. Then create three variables first_month, second_month, third_month and unpack the tuple into them.',
    '# Create tuple and unpack it
month_abbrevs = (''Jan'', ''Feb'', ''Mar'')
# TODO: Unpack the tuple
',
    'Jan Feb Mar'
),
(
    'Tuple to Lowercase List',
    'Use list comprehension to convert all items in month_abbrevs tuple to lowercase. Store result in month_abbrevs_lower list.',
    'month_abbrevs = (''Jan'', ''Feb'', ''Mar'', ''Apr'')
# TODO: Convert to lowercase using list comprehension
month_abbrevs_lower = 
print(month_abbrevs_lower)',
    '[''jan'', ''feb'', ''mar'', ''apr'']'
),
(
    'Reverse Dictionary',
    'Write a function reverse_dict() that exchanges keys and values in a dictionary. Given zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}, return {''rat'': ''2020'', ''ox'':''2021'', ''tiger'':''2022'', ''rabbit'':''2023''}',
    'def reverse_dict(input_dict):
    # TODO: Implement dictionary reversal
    pass

zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}
result = reverse_dict(zodiacs)
print(result)',
    '{''rat'': ''2020'', ''ox'': ''2021'', ''tiger'': ''2022'', ''rabbit'': ''2023''}'
),
(
    'DNA to mRNA Transcription',
    'Define transcription(input_sequence, mapping_dict) that translates DNA to mRNA. Use mapping = {''A'':''U'',''T'':''A'',''G'':''C'',''C'':''G''}. For input "TCGTTCAGT", return "AGCAAGUCA".',
    'def transcription(input_sequence, mapping_dict):
    # TODO: Implement DNA to mRNA translation
    pass

input_seq = ''TCGTTCAGT''
mapping = {''A'':''U'',''T'':''A'',''G'':''C'',''C'':''G''}
result = transcription(input_seq, mapping)
print(result)',
    'AGCAAGUCA'
);

-- Drop old function versions to avoid conflicts
DROP FUNCTION IF EXISTS get_random_task(TEXT);
DROP FUNCTION IF EXISTS get_random_task();

-- Create a function to get a random task
CREATE FUNCTION get_random_task()
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    starter_code TEXT,
    expected_output TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        t.description,
        t.starter_code,
        t.expected_output
    FROM public.programming_tasks t
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
