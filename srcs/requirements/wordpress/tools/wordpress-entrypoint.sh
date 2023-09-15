#!/bin/sh

# --------------------------- FUNCTION DEFINITIONS --------------------------- #

# set system user and permissions
set_permissions() {
	if ! id www-data; then
		adduser -u 82 -D -S -G www-data www-data;
    fi
	chown -R www-data:www-data /var/www/html;
	chmod 755 /var/www/html;
}

# Set environment variables as default value 
# if variable is not defined and default value is not null.
# 	- args: "variable name" "default value1" "default value2"
set_env_var() {
	name="$1"
	shift
	eval "chosen_value=\${$name}"
	set -- "${chosen_value}" "$@"

	for candidate_value in "$@"; do
		if [ -n "${candidate_value}" ]; then
			chosen_value="${candidate_value}"
			break
		fi
	done

	echo "${name}: ${chosen_value}"
	export "$name=$chosen_value"
}

# Initialize environment variables
initialize_environment() {
	# DB related variables
	set_env_var WORDPRESS_DB_NAME "${MARIADB_DATABASE}" "${MYSQL_DATABASE}" "example_database"
	set_env_var WORDPRESS_DB_USER "${MARIADB_USER}" "${MYSQL_USER}" "example_user"
	set_env_var WORDPRESS_DB_PASSWORD "${MARIADB_PASSWORD}" "${MYSQL_PASSWORD}" "example_password"
	set_env_var WORDPRESS_DB_HOST "mariadb"
	set_env_var WORDPRESS_DB_PREFIX "wp_"

	# Website related variables
	set_env_var WORDPRESS_URL "13.124.216.218"
	set_env_var WORDPRESS_TITLE "so much fun!"

	# administrator account related variables
	set_env_var WORDPRESS_ADMIN_USER "god"
	set_env_var WORDPRESS_ADMIN_PASSWORD "god_password"
	set_env_var WORDPRESS_ADMIN_EMAIL "god@example.com"

	# regular user related variables
	set_env_var WORDPRESS_USER "normal"
	set_env_var WORDPRESS_USER_EMAIL "normal@example.com"
	set_env_var WORDPRESS_USER_PASSWORD "normal_password"
	set_env_var WORDPRESS_USER_ROLE "author"
}

# Install WP-Cli for wordpress website administration
install_wordpress_site() {
	# Install a wordpress website
	if [ ! -d "/var/www/html/wp-content" ]; then
		wp core download --locale=ko_KR --path=/var/www/html
		echo "Downloaded wordpress"
	fi
	# Write Config file(wp-config.php)
	if [ ! -f "/var/www/html/wp-config.php" ]; then
		wp core config \
			--dbname="${WORDPRESS_DB_NAME}" \
			--dbuser="${WORDPRESS_DB_USER}" \
			--dbpass="${WORDPRESS_DB_PASSWORD}" \
			--dbhost="${WORDPRESS_DB_HOST}" \
			--dbprefix="${WORDPRESS_DB_PREFIX}"
		echo "Generated wp-config.php file"
	fi
	# Last step to install wordpress
	if ! wp core is-installed; then
		wp core install \
			--url="${WORDPRESS_URL}" \
			--title="${WORDPRESS_TITLE}" \
			--admin_user="${WORDPRESS_ADMIN_USER}" \
			--admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
			--admin_email="${WORDPRESS_ADMIN_EMAIL}"
		echo "Installed wordpress completely"
	fi

	users_count=$(($(wp user list | wc -l) - 1))
	if [ $users_count -lt 2 ]; then
		wp user create \
			"${WORDPRESS_USER}" \
			"${WORDPRESS_USER_EMAIL}" \
			--user_pass="${WORDPRESS_USER_PASSWORD}" \
			--role="${WORDPRESS_USER_ROLE}"
		echo "Created user ${WORDPRESS_USER}"
	fi
}


# ------------------------------ MAIN EXECUTION ------------------------------ #

set -e  # Exit script in case of an error

set_permissions
initialize_environment
install_wordpress_site

exec php-fpm81 -F
