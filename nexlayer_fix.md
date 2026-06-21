# Nexlayer working build fix

This file is the authoritative, pinned build solution for this repo. Nexlayer uses it verbatim on every run and will not override it. If a future build with this fix fails, Nexlayer appends/updates it rather than regenerating.

## CRITICAL BUILD CONSTRAINTS

1. **MEMOS_PORT=5230, MEMOS_ADDR=0.0.0.0, MEMOS_DATA=/var/opt/memos MUST all be set** — memos uses `viper.SetEnvPrefix("memos")` + `viper.AutomaticEnv()`, so env vars `MEMOS_PORT`, `MEMOS_ADDR`, and `MEMOS_DATA` map to the `port`, `addr`, and `data` config keys. MEMOS_ADDR=0.0.0.0 forces binding on all interfaces (not just 127.0.0.1).

2. **CGO_ENABLED=1 required** — memos uses go-sqlite3 which requires CGO. Build with `CGO_ENABLED=1`.

3. **sqlite-dev (build) and sqlite-libs (runtime) both required** — CGO compilation needs `sqlite-dev`; the final alpine image needs `sqlite-libs` to load the shared library at runtime.

4. **RUN mkdir -p /var/opt/memos required** — create the data directory in the image so SQLite can write its database file on first start.

5. **Do not change the port in nexlayer.yaml** — keep `servicePorts: [5230]` to match MEMOS_PORT.

## Fixed Dockerfile

```dockerfile
FROM mirror.gcr.io/library/golang:1.22-alpine AS builder
RUN apk add --no-cache gcc musl-dev sqlite-dev
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-w -s" -o /app/server ./cmd/memos

FROM mirror.gcr.io/library/alpine:3.20
RUN apk add --no-cache ca-certificates tini sqlite-libs && mkdir -p /var/opt/memos
COPY --from=builder /app/server /app/server
EXPOSE 5230
ENTRYPOINT ["/sbin/tini", "--", "/app/server"]
CMD ["--port", "5230", "--addr", "0.0.0.0", "--data", "/var/opt/memos"]
```

## Fixed nexlayer.yaml

```yaml
application:
  name: memos
  pods:
    - name: app
      image: "."
      path: /
      servicePorts:
        - 5230
      vars:
        MEMOS_PORT: "5230"
        MEMOS_ADDR: "0.0.0.0"
        MEMOS_DATA: "/var/opt/memos"
      volumes:
        - name: data
          mountPath: /var/opt/memos
          size: 5Gi
```
