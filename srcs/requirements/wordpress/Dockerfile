FROM alpine:3.17

WORKDIR /var/www/html

ARG WP_CLI_RELASE_URL="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"

# Install packages
#   - php81-phar: used for wp-cli installation
#   - php81-iconv: used for character encoding conversion
#   - php81-mbstring: (multi-byte string)  
#                   provides functions to handle multi-byte character encodings,
#                   which are used to represent characters that can't be represented with just one byte
RUN apk update; \
    apk add --no-cache \
                php81 \
                php81-common \
                php81-mysqli \
                php81-fpm \
                php81-phar \
                mariadb-client \
                dumb-init \
                php81-iconv \
                php81-mbstring

# Install WP cli
RUN wget -O /usr/local/bin/wp "${WP_CLI_RELASE_URL}"; \
    chmod +x /usr/local/bin/wp

# Copy script file
COPY ./tools/           /scripts/
RUN chmod +x /scripts/wordpress-entrypoint.sh

# Copy configuration file for php-fpm
COPY ./conf/www.conf    /etc/php81/php-fpm.d/www.conf

EXPOSE 9000

ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]
CMD ["/scripts/wordpress-entrypoint.sh"]
