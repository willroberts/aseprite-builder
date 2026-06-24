# aseprite-builder
This is a containerized builder for the free version of Aseprite, for Linux x86_64 systems.

Requirements: `podman`, `make`, and `bash`.

Usage: `make build`, then `./output/bin/aseprite` to run.

Builds latest `main` by default. Set `ASEPRITE_SHA` in environment to choose a specific version.

License: GPL3.
