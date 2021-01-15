/*
 * long_running_v1.sql
 * Purpose: Find long running queries 
 *
 * RK 2019
 */

/**  VERSION #1: Without perf schema */
    SELECT trx.trx_id as "Transaction ID",
           trx.trx_started as "Started",
           trx.trx_mysql_thread_id as "Thread ID"
      FROM INFORMATION_SCHEMA.INNODB_TRX AS trx
INNER JOIN INFORMATION_SCHEMA.PROCESSLIST AS pl 
	    ON trx.trx_mysql_thread_id = pl.id
     WHERE trx.trx_started < CURRENT_TIMESTAMP - INTERVAL 59 SECOND
       AND pl.user <> 'system_user';

