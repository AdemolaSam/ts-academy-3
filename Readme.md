# Assignment 3 — CI/CD with GitHub Actions

A Bash CLI (`app/app.sh`) validated, tested, and Docker-smoke-tested through a
GitHub Actions pipeline running locally-equivalent scripts. No cloud deployment.

## Files

- `app/app.sh` — CLI: `system-info`, `check-host <host>`, `check-port <host> <port>`, `help`
- `scripts/lint.sh` — checks required files exist and runs `bash -n` on every script
- `scripts/build.sh` — builds the Docker image and runs smoke tests against it
- `tests/test.sh` — 10 tests covering help, system-info, invalid commands, host/port validation
- `.github/workflows/ci.yml` — pipeline: `validate` -> `test` -> `docker`, using `needs:`
- `Dockerfile`, `compose.yaml`, `.dockerignore`

## Setup

```bash
git clone <this-repo-url>
cd assignment-3
chmod +x grade.sh app/*.sh scripts/*.sh tests/*.sh
```

## Usage

```bash
./app/app.sh help
./app/app.sh system-info
./app/app.sh check-host example.com
./app/app.sh check-port example.com 443
```

## Exit codes

| Code | Meaning                                              |
|------|-------------------------------------------------------|
| 0    | Success                                               |
| 1    | Operational failure (host unresolvable, port closed)  |
| 2    | Invalid command or missing/invalid argument           |

## Testing

```bash
./scripts/lint.sh     # file + syntax checks
./tests/test.sh       # 10 functional tests
./scripts/build.sh    # Docker build + smoke tests (requires Docker)
./grade.sh            # instructor grader
```

## CI pipeline

`.github/workflows/ci.yml` runs on every push and pull request, with three
jobs gated by `needs:`:

```
validate  ->  test  ->  docker
```

`validate` fails fast on a syntax error or missing file, so `test` and
`docker` never run in that case.

### CI failure demonstration

<!-- Fill in once you've done this on GitHub:
1. Branch: `ci-failure-demo`
2. Introduced <describe the break, e.g. a syntax error in app/app.sh>
3. Pushed — CI failed at the `<job name>` job: <link to failed run>
4. Fixed the issue, pushed again — CI passed: <link to passing run>
-->

## Assumptions

- `check-host` treats a failed ping as a warning, not a failure — only failed
  DNS resolution returns exit 1, since ICMP is often blocked independently of
  real reachability.
- Docker smoke tests (`scripts/build.sh`) are separate from the pure-Bash
  tests (`tests/test.sh`) so the test suite can run without Docker installed.
