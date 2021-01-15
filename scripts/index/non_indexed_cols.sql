/*
 * non_indexed_cols.sql
 * Purpose: find tables/columns with no index 
 *          which (probably) should be indexed
 * Excluding: Data Dictionary
 *
 * RK 2019
 */
    SELECT t.TABLE_SCHEMA,
           t.TABLE_NAME,
           c.COLUMN_NAME,
           IFNULL(kcu.CONSTRAINT_NAME, 'Not indexed') AS Indexed
      FROM information_schema.TABLES as t
INNER JOIN information_schema.COLUMNS as c
	    ON c.TABLE_SCHEMA = t.TABLE_SCHEMA
	   AND c.TABLE_NAME = t.TABLE_NAME
	   AND c.COLUMN_NAME LIKE '%id'
 LEFT JOIN information_schema.KEY_COLUMN_USAGE as kcu
   	    ON kcu.TABLE_SCHEMA = t.TABLE_SCHEMA
	   AND kcu.TABLE_NAME = t.TABLE_NAME
	   AND kcu.COLUMN_NAME = c.COLUMN_NAME
	   AND kcu.ORDINAL_POSITION = 1
     WHERE kcu.TABLE_SCHEMA IS NULL
       AND t.TABLE_SCHEMA NOT IN ('information_schema', 
                                  'performance_schema', 
                                  'mysql', 
                                  'sys')
ORDER BY TABLE_SCHEMA, TABLE_NAME                                  