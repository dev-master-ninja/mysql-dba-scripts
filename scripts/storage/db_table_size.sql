/*
 * db_table_size.sql
 * Purpose: find the size of all tables within specified/all dbs.
 *
 * RK 2019
 */
SELECT table_schema as "Schema", 
       table_name AS "Table",
       ROUND(((data_length + index_length) / 1024 / 1024), 2) AS SizeInMB
FROM information_schema.TABLES
/*
WHERE table_schema = <ENTER SCHEMA/DATABASE>,
*/
ORDER BY table_schema, table_name;
