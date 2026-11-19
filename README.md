# CodeAlpha_Docker_WebServer — Task 4: Web Server using Docker

An **nginx** web server packaged as a hardened Docker image with health checks, compose config, a smoke-test script and a lifecycle walkthrough.

## Task requirements → where they are met
| Requirement | Implementation |
|---|---|
| Containerization basics | `Dockerfile` (small Alpine, non-root nginx-unprivileged), `.dockerignore` |
| Deploy & manage a web server in containers | `docker-compose.yml` (`restart`, port map, log rotation) |
| Container lifecycle and commands | `scripts/lifecycle-demo.sh` (build → run → inspect → exec → stop → start → rm) |
| Monitor health & troubleshoot | `HEALTHCHECK` on `/healthz`, `/nginx_status`, `scripts/smoke-test.sh`, troubleshooting table below |
| Best practices | non-root user, `read_only` FS, `cap_drop: ALL`, `no-new-privileges`, pinned tag, log limits, no `server_tokens` |

## Prerequisites
Docker Engine 24+ (or Docker Desktop) with Compose v2 (`docker compose version`).

## Run (from this folder)
```bash
docker compose up -d --build        # build + start
docker compose ps                   # STATUS shows (healthy) after ~15 s
./scripts/smoke-test.sh             # 4 HTTP checks
open http://localhost:8080          # or browse manually
docker compose logs -f web          # follow logs
docker compose down                 # stop + remove
```
Plain Docker alternative: `docker build -t codealpha-webserver:1.0 .` then `docker run -d --name web -p 8080:8080 codealpha-webserver:1.0`.
Windows: use PowerShell for the docker commands; run `.sh` scripts in Git Bash or WSL.

## Monitoring
```bash
docker inspect --format '{{.State.Health.Status}}' codealpha-web   # starting | healthy | unhealthy
docker inspect --format '{{json .State.Health}}' codealpha-web     # last probe results
docker stats codealpha-web                                         # live CPU/RAM
docker exec codealpha-web wget -q -O - http://127.0.0.1:8080/nginx_status   # nginx connection counters
```

## Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| `port is already allocated` | Something else uses 8080 | change mapping to `"9090:8080"` or stop the other process |
| Status `unhealthy` | nginx crashed / config error | `docker logs codealpha-web`; test config: `docker run --rm codealpha-webserver:1.0 nginx -t` |
| Container exits immediately | Bad `default.conf` | same `nginx -t` command, fix the syntax, rebuild |
| `Permission denied` writing files | Root FS is read-only by design | write to `/tmp` (tmpfs) or add a named volume |
| Page shows old content | Image not rebuilt | `docker compose up -d --build` |
| `/nginx_status` returns 403 from browser | Intentional | use `docker exec` as shown above |

## Known limitations / future work
Static content only, plain HTTP (add TLS via a reverse proxy such as Traefik/Caddy), no CI job. Not executed in the authoring environment — see root `TESTING_REPORT.md`.
