#!/bin/sh

# --------------------------- FUNCTION DEFINITIONS --------------------------- #
. ./logging.sh
. ./setup_database.sh

# ------------------------------ MAIN EXECUTION ------------------------------ #

set -e  # Exit script in case of an error

configure_logging
initialize_environment
define_internal_variables
initialize_data_directory
set_directory_owrnership
configure_database

exec mariadbd-safe --user=mysql --console
