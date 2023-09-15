FROM alpine:3.17

ARG NGINX_RELEASE_URL="http://nginx.org/packages/alpine/v3.17/main"
ARG NGINX_SIGNING_KEY_URL="https://nginx.org/keys/nginx_signing.rsa.pub"

# Install essential packages
RUN set -e; \
    apk add --no-cache openssl curl ca-certificates dumb-init; \
    printf "@nginx ${NGINX_RELEASE_URL}\n" | tee -a /etc/apk/repositories; \
    curl -o /tmp/nginx_signing.rsa.pub "${NGINX_SIGNING_KEY_URL}"; \
    openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -noout >> /dev/null; \
    mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
    apk add --no-cache nginx@nginx;

# Copy script file
COPY ./tools/                    /scripts/
RUN chmod +x /scripts/nginx-entrypoint.sh

# Copy Nginx configuration files
COPY ./conf/conf.d/             /etc/nginx/conf.d/
COPY ./conf/nginx.conf          /etc/nginx.conf

# Documentation of exposed ports
EXPOSE 443

# Run nginx
ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]
CMD ["/scripts/nginx-entrypoint.sh"]
