# Nexlayer — memos

<!-- nexlayer:meta version=1 analyzed=2026-06-20T17:13:11Z repo=https://github.com/armondhonore/memos branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Memos is an open-source, self-hosted note-taking tool designed for quick capture and markdown-native content management.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Go | language | 1.26.2 | go.mod |
| SQLite | database | latest | Dockerfile, go.mod |
| Echo | framework | v5.1.0 | go.mod |
| gRPC | framework | v1.80.0 | go.mod |
| Alpine Linux | infra | 3.20 | Dockerfile |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- cmd/memos — Entry point for the server application
- internal/ — Core business logic and internal packages
- server/ — HTTP and gRPC server implementation
- store/ — Database persistence layer
- web/ — Frontend assets and templates
- proto/ — Protocol Buffer definitions for API
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- AWS S3 (for optional storage)
- OpenAI API (for AI features)
- Google GenAI (for AI features)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Go >= 1.26.2
- SQLite3

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
MEMOS_DB=sqlite
PORT=5230
```

### Steps

1. `go mod download` — Download Go dependencies
2. `go run cmd/memos/main.go` — Start the Memos server locally

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `PORT` | `"5230"` | plain |

### nexlayer.yaml

```yaml
application:
  name: memos
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/memos:19ee647c1a7"
      path: /
      servicePorts:
        - 5230
      vars:
        PORT: "5230"
```
<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| memos-app | mirror.gcr.io/library/golang:1.26-alpine | 5230 | web |
| memos-db | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |

### Deployment notes

- The application connects to the database using the Nexlayer pod address memos-db.pod:5432
- SQLite is supported but for pod-based deployments, a separate PostgreSQL pod is used to ensure data persistence and adherence to the one-service-per-pod rule
- Ensure necessary S3 credentials are provided via environment variables for object storage

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-20T18:33:22Z  
**Live URL:** https://relaxed-weasel-memos.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: memos
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/memos:19ee647c1a7"
      path: /
      servicePorts:
        - 5230
      vars:
        PORT: "5230"
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-20T18:25:47Z | analyzed | initial repo analysis |
| 2026-06-20T18:33:22Z | success | deployed https://relaxed-weasel-memos.cloud.nexlayer.ai |
<!-- nexlayer:end -->

