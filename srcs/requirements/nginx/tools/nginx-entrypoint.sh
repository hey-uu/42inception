#!/bin/sh

# --------------------------- FUNCTION DEFINITIONS --------------------------- #

# Generate a self-signed certificate and key
generate_self_signed_ssl_certificate() {
	mkdir -p /etc/nginx/ssl;
	openssl req \
        -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=KR/L=Seoul/O=42Seoul/CN=hyeyukim.42.fr"
}

# ------------------------------ MAIN EXECUTION ------------------------------ #
set -e

generate_self_signed_ssl_certificate

exec nginx -g "daemon off;"
