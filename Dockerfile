# Non-root nginx image, listens on 8080
FROM nginxinc/nginx-unprivileged:1.27-alpine

LABEL org.opencontainers.image.title="codealpha-webserver" \
      org.opencontainers.image.description="CodeAlpha DevOps Task 4 - nginx web server in Docker"

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY html/ /usr/share/nginx/html/

EXPOSE 8080

# Container health: marks the container "unhealthy" if /healthz stops answering
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1
