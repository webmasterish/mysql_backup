#!/bin/bash

# usage:
# - cli			: bash mysql_backup.sh or ./mysql_backup.sh
# - cron job: 0 2 * * * /path/to/mysql_backup.sh >/dev/null 2>&1

# ------------------------------------------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# ------------------------------------------------------------------------------

# config

if [ -n "$1" ]; then

	CONFIG_FILE=$1

elif [ -f "${SCRIPT_DIR}/mysql_backup.config" ]; then

	source "${SCRIPT_DIR}/mysql_backup.config"

fi

[ ! -r ${CONFIG_FILE} ] && echo "Unreadable config file '${CONFIG_FILE}'. Aborting." && exit 1

# ------------------------------------------------------------------------------

# check required vars

[ ! -n "${BACKUP_DIR}" ] && echo "BACKUP_DIR required. Aborting." && exit 1
[ ! -n "${MYSQL_USER}" ] && echo "MYSQL_USER required. Aborting." && exit 1
[ ! -n "${MYSQL_PASS}" ] && echo "MYSQL_PASS required. Aborting." && exit 1
[ ! -n "${MYSQL_HOST}" ] && echo "MYSQL_HOST required. Aborting." && exit 1

# ------------------------------------------------------------------------------

compress()
{

	[ -n "${COMPRESS}" ] || return

	# ----------------------------------------------------------------------------

	local _file="$1"

	if [ -f "${_file}" ]; then

		echo "compressing '${_file}'"

		bzip2 -fv "${_file}"

	fi

}
# compress()

# ------------------------------------------------------------------------------

# create backup directory if it doesn't exist

mkdir -p "${BACKUP_DIR}"

# ------------------------------------------------------------------------------

# date format for backup filename

DATE=`date +%Y-%m-%d_%H-%M-%S`

# ------------------------------------------------------------------------------

exclude_pattern="(Database|information_schema|performance_schema|mysql|sys|phpmyadmin)"

if [ -n "${SINGLE_BACKUP_FILE}" ]; then

	mysqldump_file="${BACKUP_DIR}/dbs_${DATE}.sql"

	echo "Backing up all DBs to a single file '${mysqldump_file}'"

	echo 'show databases;' | \
	mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --host="${MYSQL_HOST}" | \
	grep -Ev "${exclude_pattern}" | \
	xargs \
	mysqldump \
	--user="${MYSQL_USER}" \
	--password="${MYSQL_PASS}" \
	--host="${MYSQL_HOST}" \
	--databases > "${mysqldump_file}" && \
	compress "${mysqldump_file}"

else

	for DB in $(mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --host="${MYSQL_HOST}" -e 'SHOW DATABASES;' | grep -Ev "${exclude_pattern}"); do

		mysqldump_file="${BACKUP_DIR}/${DB}_${DATE}.sql"

		echo "Backing up '${DB}'"

		mysqldump \
		--user="${MYSQL_USER}" \
		--password="${MYSQL_PASS}" \
		--host="${MYSQL_HOST}" \
		--databases "${DB}" > "${mysqldump_file}" && \
		compress "${mysqldump_file}"

	done

fi

# ------------------------------------------------------------------------------

# remove backups older than n days

if [ -n "${DAYS_TO_KEEP}" ]; then

	find "${BACKUP_DIR}" -type f \( -name '*.sql' -o -name '*.sql.*' \) -mtime +${DAYS_TO_KEEP} -exec rm {} \;

fi
