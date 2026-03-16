FROM gorbagana-dev/dumpster-docs-base:local

COPY ./scripts/start.sh /scripts/
RUN chmod +x /scripts/start.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:3100/ >/dev/null || exit 1

CMD ["/scripts/start.sh"]
