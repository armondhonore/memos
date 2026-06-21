# Nexlayer working build fix

This file is the authoritative, pinned build solution for this repo. Nexlayer uses it verbatim on every run and will not override it. If a future build with this fix fails, Nexlayer appends/updates it rather than regenerating.

## CRITICAL BUILD CONSTRAINTS

1. **Use pre-built image `neosmemo/memos:stable`** — do NOT build from source. The source build produces a binary that crashes due to SQLite initialization issues. The official image works correctly.

2. **MEMOS_PORT=5230 MUST be set** — memos uses `viper.SetEnvPrefix("memos")` so the env var must be `MEMOS_PORT` not `PORT`. Without this the server may use a different default port.

3. **MEMOS_ADDR=0.0.0.0 MUST be set** — forces binding on all interfaces so the Nexlayer proxy can reach it.

4. **MEMOS_DATA=/var/opt/memos** — data directory for the SQLite database.

5. **servicePorts: [5230]** — must match MEMOS_PORT.

## Fixed Dockerfile

```dockerfile
FROM neosmemo/memos:stable
```

## Fixed nexlayer.yaml

```yaml
application:
  name: memos
  pods:
    - name: app
      image: "neosmemo/memos:stable"
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
