# DevOps Diagnostic Tool — GitHub Actions CI/CD

A Linux diagnostic application built in Bash with
automated linting, functional tests, Docker smoke
tests and GitHub Actions continuous integration.

Developed for DevOps Practical Assignment 3.

## Features

- Runtime Linux system information
- DNS resolution and hostname validation
- ICMP host connectivity diagnostics
- TCP port connectivity diagnostics
- Input validation with defined exit codes
- Automated Bash syntax validation
- Automated functional tests
- Docker image builds and smoke tests
- Docker Compose support
- GitHub Actions CI pipeline

No cloud deployment is required.

## Project structure

```text
.
├── app/
│   └── app.sh
├── scripts/
│   ├── lint.sh
│   └── build.sh
├── tests/
│   └── test.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── .gitignore
├── grade.sh
└── README.md
```

## Requirements

For local development:

- Linux
- Bash
- Standard Linux utilities
- procps, hostname, coreutils, awk, getent
- ping and timeout
- Git

For container testing:

- Docker Engine
- Docker Compose

An internet connection may be needed for the
initial Docker image build.

## Installation

```bash
git clone https://github.com/KayceeJayy/devops-assignment-3-github-actions-ci.git
cd devops-assignment-3-github-actions-ci
```

The scripts are committed with executable permissions.

## Application commands

Show usage:

```bash
./app/app.sh help
```

Display Linux system information:

```bash
./app/app.sh system-info
```

Resolve and check a host:

```bash
./app/app.sh check-host localhost
```

Check a TCP port:

```bash
./app/app.sh check-port localhost 80
```

Valid TCP ports are integers from 1 through 65535.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Operational or connectivity failure |
| 2 | Invalid input or command |

The check-host command reports DNS success even when
ICMP is blocked. In that case, the diagnostic output
identifies the ICMP restriction.

## Local validation

Run Bash lint checks:

```bash
./scripts/lint.sh
```

Run functional tests:

```bash
./tests/test.sh
```

The student suite includes 16 tests for help,
system information, command validation, host
validation, TCP port validation and exit codes.

## Docker

Build and smoke-test the image:

```bash
./scripts/build.sh
```

Run the image directly:

```bash
docker run --rm devops-tool:local help
docker run --rm devops-tool:local system-info
docker run --rm devops-tool:local check-host localhost
```

Run using Docker Compose:

```bash
docker compose config
docker compose run --rm devops system-info
```

The container runs as a non-root user.

## GitHub Actions

Workflow location:

`.github/workflows/ci.yml`

The workflow runs on:

- push
- pull_request

It contains three jobs in dependency order:

1. validate — runs scripts/lint.sh
2. test — depends on validate and runs tests/test.sh
3. docker — depends on test and runs scripts/build.sh

A failed validation prevents downstream jobs
from executing.

### CI failure and recovery demonstration

The instructor-required failure and recovery were
demonstrated on the `demo/ci-failure-recovery` branch.

A deliberate incorrect assertion was committed to
`tests/test.sh`, causing the automated test job to fail.
The assertion was then corrected and pushed again.

Evidence:

- [Successful initial main workflow](https://github.com/KayceeJayy/devops-assignment-3-github-actions-ci/actions/runs/44474426079)
- [Intentionally failed CI run](https://github.com/KayceeJayy/devops-assignment-3-github-actions-ci/actions/runs/44475102147)
- [Successful CI recovery run](https://github.com/KayceeJayy/devops-assignment-3-github-actions-ci/actions/runs/44475184670)

The failed run demonstrates the dependency behaviour:
validation succeeds, the test job fails, and the
downstream Docker job cannot proceed successfully.

After fixing the assertion, the recovery run passes
all three jobs: `validate`, `test`, and `docker`.

The final `main` branch contains the corrected test.


## Instructor grading

Run:

```bash
./grade.sh
```

The instructor grader checks required files,
executable permissions, Bash syntax, workflow
triggers, job dependencies, application behaviour,
linting, Docker and Git history.

A passing grade script does not automatically
guarantee full marks in manual assessment.

## Assumptions and limitations

- The application targets Linux.
- Diagnostic information is obtained at runtime.
- DNS and ICMP connectivity depend on local
  network and firewall policies.
- TCP connectivity confirms only that a
  connection can be established.
- The Docker container shares the host kernel.
- The tool does not deploy to a cloud platform.
- No credentials, tokens or keys are committed.
- The workflow uses GitHub-hosted Ubuntu runners.
