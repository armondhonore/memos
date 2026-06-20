# Nexlayer working build fix

This file is the authoritative, pinned build solution for this repo. Nexlayer uses it verbatim on every run and will not override it. If a future build with this fix fails, Nexlayer appends/updates it rather than regenerating.

## CRITICAL BUILD CONSTRAINTS

1. **CMD must pass `--port 5230 --data /var/opt/memos`** — the memos binary defaults to port 8081, which does not match the exposed/routed port 5230. Without explicit CMD args, Nexlayer's health check probes port 5230 and gets no response (HTTP 503).

2. **CGO_ENABLED=1 required** — memos uses go-sqlite3 which requires CGO. Build with `CGO_ENABLED=1`.

3. **sqlite-dev (build) and sqlite-libs (runtime) both required** — CGO compilation needs `sqlite-dev`; the final alpine image needs `sqlite-libs` to load the shared library at runtime.

4. **Data volume at /var/opt/memos required** — the SQLite database (`memos_prod.db`) must persist across restarts. Without a volume the DB is lost on pod restart.

5. **Do not change the port in nexlayer.yaml** — keep `servicePorts: [5230]` to match the CMD.

## Fixed Dockerfile

```dockerfile
FROM mirror.gcr.io/library/golang:1.26-alpine AS builder
RUN apk add --no-cache gcc musl-dev sqlite-dev
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-w -s" -o /app/server ./cmd/memos

FROM mirror.gcr.io/library/alpine:3.20
RUN apk add --no-cache ca-certificates tini sqlite-libs
COPY --from=builder /app/server /app/server
EXPOSE 5230
ENTRYPOINT ["/sbin/tini", "--", "/app/server"]
CMD ["--port", "5230", "--data", "/var/opt/memos"]
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
        PORT: "5230"
      volumes:
        - name: data
          mountPath: /var/opt/memos
          size: 5Gi
```
