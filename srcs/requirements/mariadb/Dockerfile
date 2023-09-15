FROM alpine:3.17

WORKDIR /scripts

# Install Mysql
# Add our user and group for consistent IDs and change owrnerships
RUN addgroup -S mysql; \
    adduser -S -G mysql -h /var/lib/mysql mysql

# Install packages
RUN apk update; \
    apk add --no-cache mariadb mariadb-client dumb-init pwgen tzdata

# Timezone setting
RUN cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime;

# Copy script file and set Permission
COPY ./tools/ .
RUN chmod +x *.sh

# Copy configuration files
COPY ./conf/my.cnf                  /etc/my.cnf
COPY ./conf/my.cnf.d                /etc/my.cnf.d

EXPOSE 3306

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/scripts/mariadb-entrypoint.sh"]
