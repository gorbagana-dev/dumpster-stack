FROM cerc/dumpster-backend-base:local

COPY ./scripts/start.sh /scripts/

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD nc -z localhost 3200 || exit 1

CMD ["/scripts/start.sh"]
