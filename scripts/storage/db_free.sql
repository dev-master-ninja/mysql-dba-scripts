/*
 * db_free.sql
 * Purpose: find free space in database.
 * If lot's of free space exists, run the db_table_free script to find
 * out which tables are eating up disk space. 
 * RK 2019
 */
SELECT table_schema AS "Database",
       ROUND(sum( data_length + index_length ) / 1024 /1024,1) AS "Occupied Size in MB",
       ROUND(sum( data_free )/ 1024 / 1024,1) AS "Free Space in MB" 
  FROM information_schema.TABLES 
GROUP BY table_schema
ORDER BY `Free Space in MB` DESC

/*
WHERE table_schema NOT ('sys', 
                           'performance_schema', 
                           'information_schema', 
                           'mysql') 
 */