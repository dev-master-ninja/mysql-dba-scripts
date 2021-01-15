/*
 * long_running_v2.sql
 * Purpose: Find long running queries 
 * Performance schema not always present, use v1
 * RK 2019
 */

/**  VERSION #2: With perf schema */       
    SELECT pl.id "Process ID",
           trx.trx_started "Started",
           esh.event_name 'Event',
           esh.sql_text 'Query'
      FROM information_schema.innodb_trx AS trx
INNER JOIN information_schema.processlist pl 
	    ON trx.trx_mysql_thread_id = pl.id
INNER JOIN performance_schema.threads th 
	    ON th.processlist_id = trx.trx_mysql_thread_id
INNER JOIN performance_schema.events_statements_history esh 
	    ON esh.thread_id = th.thread_id
     WHERE trx.trx_started < CURRENT_TIME - INTERVAL 59 SECOND
       AND pl.user <> 'system_user'
  ORDER BY esh.EVENT_ID;