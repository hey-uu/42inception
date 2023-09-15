#!/bin/sh

# Set environment variables. 
# 	- args: "variable name's suffix" "default value"
set_env_var() {
	mysql_var_name="MYSQL_$1"
	mariadb_var_name="MARIADB_$1"
	default_value="$2"

	eval "mariadb_var_value=\${$mariadb_var_name}"
    eval "mysql_var_value=\${$mysql_var_name}"
    value="${mariadb_var_value:-${mysql_var_value:-$default_value}}"
	
	entrypoint_log "${mariadb_var_name}: ${value}"
	export "$mysql_var_name=$value"
	export "$mariadb_var_name=$value"
}

# Escape string literals for SQL use
# 	- args: "literal"
escape_string_literal() {
	string_literal="$1"
	newline=$(printf '\n')
 	escaped=${string_literal//\\/\\\\}
	escaped="${escaped//$newline/\\n}"
	echo "${escaped//\'/\\\'}"
}

# Start a temporary MariaDB server
db_start_temp_server() {
	mariadbd-safe --user=mysql  --default-time-zone=SYSTEM &
	sleep 2
	entrypoint_log "Started temporary server."	
}

# Shutdown the temporary MariaDB server
db_shutdown_temp_server() {
	if [ "${_ROOT_PASSWORD_IS_SET}" = "false" ]; then
		mariadb-admin -uroot shutdown
	else
		mariadb-admin -uroot -p"${_ESCAPED_ROOT_PASSWORD}" shutdown
	fi
	entrypoint_log "Shutdowned temporary server."
}

# Stack queries to _QUERY_TMP_FILE
stack_query() {
	if [ -z "${_QUERY_TMP_FILE}" ]; then
		_QUERY_TMP_FILE="$(mktemp)"
	fi
	entrypoint_log "> query tmp file: ${_QUERY_TMP_FILE}"
	echo "$@" >> "${_QUERY_TMP_FILE}"
}

# Send collected queries to MariaDB
flush_query() {

	if [ -f "${_QUERY_TMP_FILE}" ]; then
        if [ "${_ROOT_PASSWORD_IS_SET}" = "false" ]; then
            mysql -uroot < "${_QUERY_TMP_FILE}"
        else
            mysql -uroot -p"${_ESCAPED_ROOT_PASSWORD}" < "${_QUERY_TMP_FILE}"
        fi
	fi
	rm -f "${_QUERY_TMP_FILE}"
	_QUERY_TMP_FILE=""
	entrypoint_log "Flushed SQL queries."
}
