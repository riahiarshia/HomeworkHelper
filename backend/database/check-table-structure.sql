-- Check the structure of monthly_usage_summary table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'monthly_usage_summary' 
ORDER BY ordinal_position;


