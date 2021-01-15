/*
 * db_index_usage.sql
 * Purpose: Find index usage statistics

 * You can make a decision based on the SEQ_IN_INDEX column data.

 * RK 2019
 */

SELECT TABLE_NAME,
       INDEX_NAME,
       SEQ_IN_INDEX,
       COLUMN_NAME,
       CARDINALITY,
       INDEX_TYPE,  
  FROM INFORMATION_SCHEMA.STATISTICS 

/* WHERE table_schema = 'database-name' */