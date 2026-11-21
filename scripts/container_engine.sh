# shellcheck shell=bash
# Shared container engine detection for the workshop scripts.
#
# Source this file, then call `container_engine_detect`. On success it sets
# CONTAINER_ENGINE (docker|podman) and COMPOSE_CMD (a bash array holding the
# compose command, e.g. `docker compose` or `podman-compose`).
#
# Override the choice with CONTAINER_ENGINE=docker|podman when both engines are
# installed and you want a specific one.

ce_installed() { command -v "$1" >/dev/null 2>&1; }

ce_daemon_ready() {
  case "$1" in
    docker) ce_installed docker && docker info >/dev/null 2>&1 ;;
    podman) ce_installed podman && podman info >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

# ce_podman_socket_running — true when the Podman API socket is up.
# `podman compose` usually delegates to docker-compose, which talks to that socket.
ce_podman_socket_running() {
  [ "$(podman info --format '{{.Host.RemoteSocket.Exists}}' 2>/dev/null)" = "true" ]
}

# ce_compose_available <engine> — sets COMPOSE_CMD when a compose command works.
ce_compose_available() {
  # shellcheck disable=SC2034  # COMPOSE_CMD is consumed by the scripts that source this file
  COMPOSE_CMD=()
  case "$1" in
    docker)
      if ce_installed docker && docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD=(docker compose)
        return 0
      fi
      ;;
    podman)
      if ce_installed podman && ce_podman_socket_running && podman compose version >/dev/null 2>&1; then
        COMPOSE_CMD=(podman compose)
        return 0
      fi
      if ce_installed podman-compose; then
        COMPOSE_CMD=(podman-compose)
        return 0
      fi
      if ce_installed podman && podman compose version >/dev/null 2>&1; then
        # No socket and no podman-compose: the provider may not need the API socket.
        COMPOSE_CMD=(podman compose)
        return 0
      fi
      ;;
  esac
  return 1
}

# container_engine_hint <engine> — prints the install/start hint for that engine.
container_engine_hint() {
  case "$1" in
    docker)
      echo "Docker: install Docker Desktop (macOS/Windows) or Docker Engine + the compose plugin (Linux); start the daemon and rerun."
      ;;
    podman)
      echo "Podman: on macOS/Windows run 'podman machine init --memory 8192 && podman machine start'; on Linux install podman plus podman-compose (or the docker-compose provider for 'podman compose')."
      ;;
  esac
}

# container_engine_detect — pick the engine and compose command.
# Returns 0 when a usable engine + compose pair was found, 1 otherwise.
container_engine_detect() {
  local requested="${CONTAINER_ENGINE:-}"
  local candidates=()
  local engine

  CONTAINER_ENGINE=""
  # shellcheck disable=SC2034  # both are consumed by the scripts that source this file
  COMPOSE_CMD=()

  case "$requested" in
    "") candidates=(docker podman) ;;
    docker | podman) candidates=("$requested") ;;
    *)
      echo "CONTAINER_ENGINE must be 'docker' or 'podman' (got: '$requested')" >&2
      return 1
      ;;
  esac

  for engine in "${candidates[@]}"; do
    if ! ce_daemon_ready "$engine"; then
      continue
    fi
    if ! ce_compose_available "$engine"; then
      continue
    fi
    CONTAINER_ENGINE="$engine"
    export CONTAINER_ENGINE
    return 0
  done

  return 1
}

# container_image_reference <container> — the image reference the container was
# created from. Docker exposes it as .Config.Image; podman as .ImageName.
container_image_reference() {
  local container="$1"
  local out=""

  if [ -n "${CONTAINER_ENGINE:-}" ]; then
    case "$CONTAINER_ENGINE" in
      docker) out="$(docker inspect --format='{{.Config.Image}}' "$container" 2>/dev/null || true)" ;;
      podman) out="$(podman inspect --format='{{.ImageName}}' "$container" 2>/dev/null || true)" ;;
    esac
  fi
  if [ -z "$out" ]; then
    # Cross-engine fallback so a Docker-created container still reports under podman and vice versa.
    out="$(docker inspect --format='{{.Config.Image}}' "$container" 2>/dev/null || true)"
  fi
  if [ -z "$out" ]; then
    out="$(podman inspect --format='{{.ImageName}}' "$container" 2>/dev/null || true)"
  fi
  printf '%s' "$out"
}

# container_image_id <container> — the image ID the container runs.
container_image_id() {
  local container="$1"
  if [ -n "${CONTAINER_ENGINE:-}" ]; then
    "$CONTAINER_ENGINE" inspect --format='{{.Image}}' "$container" 2>/dev/null || true
  fi
}
