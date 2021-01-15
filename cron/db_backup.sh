#!/bin/bash
######################
# Full MySQL database backup script
# Execute as root or with -u root -p...
#
DATE=`date +%Y%m`
DATETIME=`date +%Y%m%d-%H%M`
BACKUP_DIR="/data/backup/${DATE}"
BACKUP_FILE="${BACKUP_DIR}/backup-${DATETIME}.sql"
MYSQL_DUMP="/usr/bin/mysqldump"

if [[ ! -d ${BACKUP_DIR} ]]
then
   mkdir "${BACKUP_DIR}"
fi

${MYSQL_DUMP} --all-databases --single-transaction --quick > ${BACKUP_FILE}
                                                           