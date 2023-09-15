#!/bin/sh

# Setup logging related configurations
configure_logging() {
	# Set default log directory if not defined
    MARIADB_LOG_DIR="${MARIADB_LOG_DIR:-"/var/log/mysql"}"	
	if [ "${MARIADB_LOG_DIR: -1}" = "/" ]; then 
		MARIADB_LOG_DIR="${MARIADB_LOG_DIR%/}"
	fi
	MARIADB_ENTRYPOINT_LOG_FILE="${MARIADB_ENTRYPOINT_LOG_FILE:-"entrypoint.log"}"
	MARIADB_ENTRYPOINT_LOG_FILE_PATH="${MARIADB_LOG_DIR}/${MARIADB_ENTRYPOINT_LOG_FILE}"
	
	export	MARIADB_LOG_DIR MARIADB_ENTRYPOINT_LOG_FILE MARIADB_ENTRYPOINT_LOG_FILE_PATH

	mkdir -p "${MARIADB_LOG_DIR}"
	chown -R mysql:mysql "${MARIADB_LOG_DIR}"
	touch "${MARIADB_ENTRYPOINT_LOG_FILE_PATH}"
}

# Log messages to the entrypoint log file
#	- args: "message"
entrypoint_log() {
	printf '%s [Entrypoint]: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %S')" "$@" \
									>> "${MARIADB_ENTRYPOINT_LOG_FILE_PATH}"
}
