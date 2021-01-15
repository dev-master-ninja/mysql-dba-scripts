/*
 * find_no_pk.sql
 * Purpose: find tables without a Primary Key
 * Excluding: Data Dictionary
 *
 * RK 2019
 */

select table_schema,
	   table_name
  from information_schema.columns
/*where table_schema = 'SCHEMA_NAME'*/
 where table_schema not in ('sys', 
                           'performance_schema', 
                           'information_schema', 
                           'mysql')
group by table_schema, table_name
having sum(if (column_key in ('PRI', 'UNI'), 1, 0)) = 0