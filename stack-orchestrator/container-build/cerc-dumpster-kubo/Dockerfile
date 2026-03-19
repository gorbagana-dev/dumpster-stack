FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git make bash

WORKDIR /app
RUN git clone https://github.com/ipfs/kubo.git --depth=1 --branch=v0.33.2 .

# Add go-ds-s3 plugin compiled into the binary
# 1. Add to preload list so preload.sh generates the import
RUN echo -en "\ns3ds github.com/ipfs/go-ds-s3/plugin 0" >> plugin/loader/preload_list
# 2. Generate preload.go with the import
RUN bash plugin/loader/preload.sh > plugin/loader/preload.go
# 3. Now go get resolves the import and go mod tidy keeps it
RUN go get github.com/ipfs/go-ds-s3/plugin@latest
RUN go mod tidy
RUN make build

FROM alpine:latest

RUN apk add --no-cache ca-certificates jq

COPY --from=builder /app/cmd/ipfs/ipfs /usr/local/bin/ipfs
COPY scripts/start.sh /scripts/start.sh
RUN chmod +x /scripts/start.sh

ENV IPFS_PATH=/data/ipfs
ARG R2_IPFS_BUCKET=dumpster-ipfs
ARG R2_ACCOUNT_ID=52c20c98f552c6af17369284bd9a78b2

RUN ipfs init --profile=server \
    && ipfs config Addresses.API '/ip4/0.0.0.0/tcp/5001' \
    && ipfs config Addresses.Gateway '/ip4/0.0.0.0/tcp/8080' \
    && jq --arg endpoint "https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com" --arg bucket "$R2_IPFS_BUCKET" '.Datastore.Spec = {"mounts":[{"child":{"type":"s3ds","region":"auto","bucket":$bucket,"rootDirectory":"blocks","regionEndpoint":$endpoint,"accessKey":"","secretKey":"","workers":8},"mountpoint":"/blocks","prefix":"s3.datastore","type":"measure"},{"child":{"compression":"none","path":"datastore","type":"levelds"},"mountpoint":"/","prefix":"leveldb.datastore","type":"measure"}],"type":"mount"}' "$IPFS_PATH/config" > "$IPFS_PATH/config.tmp" \
    && mv "$IPFS_PATH/config.tmp" "$IPFS_PATH/config" \
    && jq -Sc '{type:.Datastore.Spec.type,mounts:[.Datastore.Spec.mounts[]|{mountpoint}+(.child|del(.regionEndpoint,.accessKey,.secretKey,.workers,.prefix,.compression)|if .type=="s3ds" then del(.type) else . end)]}' "$IPFS_PATH/config" > "$IPFS_PATH/datastore_spec"

EXPOSE 4001 5001 8080

HEALTHCHECK --interval=10s --timeout=5s --retries=10 --start-period=15s \
    CMD ipfs id || exit 1

CMD ["/scripts/start.sh"]
