/*
 * db_size.sql
 * Purpose: find the size of all databases within MySQL Instance
 *
 * RK 2019
 */

use mysql;

  SELECT table_schema AS "Database", 
         ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS "Size in MB" 
    FROM information_schema.tables 
GROUP BY table_schema 
ORDER BY `Size in MB` DESC;
