#!/bin/sh

. utils.sh

# Load environment variables and configurations for MariaDB
initialize_environment() {
	# Load environment variables
	set_env_var DATABASE ""
	set_env_var USER ""
	set_env_var PASSWORD ""
	set_env_var ROOT_HOST "%"
	set_env_var ROOT_PASSWORD ""
	set_env_var RANDOM_ROOT_PASSWORD ""

	if [ "$MARIADB_RANDOM_ROOT_PASSWORD" = "true" ]; then
		MARIADB_ROOT_PASSWORD=$(pwgen --numerals --capitalize --symbols --remove-chars="'\\" -1 32)
		set_env_var ROOT_PASSWORD ""
		# entrypoint_log "MariaDB(MySQL) root Password: $MYSQL_ROOT_PASSWORD"
	fi
}

# Define internal variables
define_internal_variables() {
	# Set variables for internal use
	_ESCAPED_PASSWORD="$(escape_string_literal "${MARIADB_PASSWORD}")"
	_ESCAPED_ROOT_PASSWORD="$(escape_string_literal "${MARIADB_ROOT_PASSWORD}")"
	_QUERY_TMP_FILE=
	_ROOT_PASSWORD_IS_SET="false"
}

# Initialize the MariaDB data directory and system tables
initialize_data_directory() {
	if [ -d /var/lib/mysql/mysql ]; then
		entrypoint_log "MySQL directory already present."
	else
		mariadb-install-db \
					--user=mysql \
					--ldata=/var/lib/mysql \
					--skip-test-db \
					--skip-log-bin \
					> /dev/null
		entrypoint_log "Database directory initialized."
	fi
}

# Ensure correct ownership for the database directories to the mysql user
set_directory_owrnership() {
	mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
    chown -R mysql:mysql /var/lib/mysql
}

# General setup for the MariaDB database
configure_database() {
	db_start_temp_server

	_ROOT_PASSWORD_IS_SET="false"
	# Setting timezone
	entrypoint_log "Setting timezone"
	mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot mysql
	
	# Setting root user
	entrypoint_log "Setting root user"
	# stack_query "FLUSH PRIVILEGES ;"
	stack_query "GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '${_ESCAPED_ROOT_PASSWORD}' WITH GRANT OPTION ;"
	stack_query "GRANT ALL ON *.* TO 'root'@'${MARIADB_ROOT_HOST}' IDENTIFIED BY '${_ESCAPED_ROOT_PASSWORD}' WITH GRANT OPTION ;"
	stack_query "FLUSH PRIVILEGES ;"
	flush_query

	_ROOT_PASSWORD_IS_SET="true"
	# Setting database
	entrypoint_log "Setting database"
	if [ "$MARIADB_DATABASE" != "" ]; then
		entrypoint_log "Create MARIADB_DATABASE($MARIADB_DATABASE)"
		stack_query "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"
		stack_query "GRANT ALL ON \`${MARIADB_DATABASE}\`.* to '${MARIADB_USER}'@'%' IDENTIFIED BY '${_ESCAPED_PASSWORD}';"
		stack_query "FLUSH PRIVILEGES ;"
		flush_query
	fi

	db_shutdown_temp_server
}