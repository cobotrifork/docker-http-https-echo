FROM node:16-alpine AS build

LABEL \
    org.opencontainers.image.title="http-https-echo" \
    org.opencontainers.image.description="Docker image that echoes request data as JSON; listens on HTTP/S, with various extra features, useful for debugging." \
    org.opencontainers.image.url="https://github.com/mendhak/docker-http-https-echo" \
    org.opencontainers.image.documentation="https://github.com/mendhak/docker-http-https-echo/blob/master/README.md" \
    org.opencontainers.image.source="https://github.com/mendhak/docker-http-https-echo" \
    org.opencontainers.image.licenses="MIT"

WORKDIR /app
COPY . /app

RUN set -ex \
  # Build JS-Application
  && npm install --production \
  # Generate SSL-certificate (for HTTPS)
  && apk --no-cache add openssl \
  && sh generate-cert.sh \
  && apk del openssl \
  && rm -rf /var/cache/apk/* \
  # Delete unnecessary files
  && rm package* generate-cert.sh \
  # Correct User's file access
  && chown -R node:node /app \
  && chmod +r /app/privkey.pem

FROM node:16-alpine AS final
WORKDIR /app
COPY --from=build /app /app
ENV HTTP_PORT=8080 HTTPS_PORT=8443
EXPOSE $HTTP_PORT $HTTPS_PORT
USER 1000
CMD ["node", "./index.js"]
