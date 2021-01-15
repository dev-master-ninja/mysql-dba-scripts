/*
 * db_free.sql
 * Purpose: find free space in database.
 * Find big empty tables, run "OPTIMIZE TABLE table-name" to
 * free up space. 
 * RK 2019
 */

  SELECT table_schema AS "Schema",  
         table_Name AS "Table",
         ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS "table_size",
         ROUND(sum( data_free )/ 1024 / 1024,1) AS "free_space"
    FROM information_schema.tables 
   WHERE data_free is not NULL
/* AND table_schema = 'db_name' */
GROUP BY table_schema, table_name
ORDER BY `free_space` DESC