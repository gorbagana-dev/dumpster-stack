FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git make

WORKDIR /app
RUN git clone https://github.com/ipfs/kubo.git --depth=1 --branch=v0.33.2 .

# Add go-ds-s3 plugin compiled into the binary
RUN go get github.com/ipfs/go-ds-s3/plugin@latest
RUN echo -en "\ns3ds github.com/ipfs/go-ds-s3/plugin 0" >> plugin/loader/preload_list
RUN go mod tidy
RUN make build

FROM alpine:latest

RUN apk add --no-cache ca-certificates jq

COPY --from=builder /app/cmd/ipfs/ipfs /usr/local/bin/ipfs
COPY scripts/start.sh /scripts/start.sh
RUN chmod +x /scripts/start.sh

ENV IPFS_PATH=/data/ipfs

EXPOSE 4001 5001 8080

HEALTHCHECK --interval=10s --timeout=5s --retries=10 --start-period=15s \
    CMD ipfs id || exit 1

CMD ["/scripts/start.sh"]
