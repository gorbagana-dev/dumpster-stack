FROM gorbagana-dev/dumpster-backend-base:local

COPY ./scripts/start.sh /scripts/
RUN chmod +x /scripts/start.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD nc -z localhost 3200 || exit 1

CMD ["/scripts/start.sh"]
