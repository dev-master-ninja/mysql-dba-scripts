/*
 * user_permissions.sql
 * Purpose: Several options to find user permissions on table
 *
 * RK 2019
 */

 SELECT grantee, 
        table_catalog, 
        table_schema, 
        privilege_type, 
        is_grantable
   FROM information_schema.schema_privileges;
/*
 Identical: SELECT * from information_schema.schema_privileges;
*/

SHOW GRANTS;

/**** PER DATABASE ****/
SELECT * from mysql.db;
SELECT * FROM mysql.tables_priv  /* WHERE db='name' */;
SELECT * FROM mysql.columns_priv /* WHERE db='name' */;
SELECT * FROM mysql.procs_priv   /* WHERE db='name' */;
