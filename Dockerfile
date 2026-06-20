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