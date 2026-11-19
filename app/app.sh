#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'HELP'
DevOps Diagnostic Tool

Usage:
  ./app/app.sh system-info
  ./app/app.sh check-host <host>
  ./app/app.sh check-port <host> <port>
  ./app/app.sh help

Exit codes:
  0 - Success
  1 - Operational failure
  2 - Invalid input
HELP
}

invalid() {
    printf 'ERROR: %s\n' "$1" >&2
    usage >&2
    exit 2
}

valid_host() {
    local host="$1"

    [[ "$host" =~ ^[a-zA-Z0-9:][a-zA-Z0-9._:-]*$ ]] &&
        (( ${#host} <= 253 ))
}

resolve_host() {
    local host="$1"
    local address=""

    address="$(
        getent ahosts "$host" 2>/dev/null |
            awk 'NR == 1 {print $1}'
    )" || true

    if [[ -z "$address" ]]; then
        address="$(
            getent hosts "$host" 2>/dev/null |
                awk 'NR == 1 {print $1}'
        )" || true
    fi

    if [[ -z "$address" ]]; then
        echo "ERROR: Unable to resolve host: $host" >&2
        return 1
    fi

    printf 'Resolved address: %s\n' "$address"
}

system_info() {
    local os

    if [[ -r /etc/os-release ]]; then
        os=$(
            . /etc/os-release
            printf '%s' "${PRETTY_NAME:-Linux}"
        )
    else
        os="$(uname -s)"
    fi

    echo "===== SYSTEM INFORMATION ====="
    printf 'Hostname: %s\n' "$(hostname)"
    local current_user
    if current_user="$(id -un 2>/dev/null)"; then
        :
    else
        current_user="$(id -u)"
    fi
    printf 'User: %s\n' "$current_user"
    printf 'Date/time: %s\n' "$(date -Is)"
    printf 'OS: %s\n' "$os"
    printf 'Kernel: %s\n' "$(uname -r)"
    printf 'Uptime: %s\n' "$(uptime -p)"
    printf 'CPUs: %s\n' "$(nproc)"

    echo
    echo "===== MEMORY ====="
    free -h
}

check_host() {
    local host="$1"

    valid_host "$host" ||
        invalid "Invalid hostname or IP address."

    echo "===== HOST CHECK ====="
    printf 'Target: %s\n' "$host"

    resolve_host "$host" || return 1

    if timeout 4 ping -n -c 1 -W 2 "$host" \
        >/dev/null 2>&1; then
        echo "ICMP connectivity: SUCCESS"
    else
        echo "ICMP connectivity: FAILED or blocked"
        echo "DNS resolution succeeded; ICMP may be restricted."
    fi

    return 0
}

check_port() {
    local host="$1"
    local input="$2"
    local port

    valid_host "$host" ||
        invalid "Invalid hostname or IP address."

    if [[ ! "$input" =~ ^0*([1-9][0-9]{0,4})$ ]]; then
        invalid "Port must be an integer from 1 to 65535."
    fi

    port="${BASH_REMATCH[1]}"

    if (( 10#$port > 65535 )); then
        invalid "Port must be between 1 and 65535."
    fi

    echo "===== TCP PORT CHECK ====="
    printf 'Host: %s\n' "$host"
    printf 'Port: %s\n' "$port"

    resolve_host "$host" || return 1

    if timeout 4 bash -c \
        'exec 3<>"/dev/tcp/$1/$2"' \
        _ "$host" "$port" >/dev/null 2>&1; then

        echo "TCP connectivity: SUCCESS"
        return 0
    fi

    echo "TCP connectivity: FAILED"
    return 1
}

(( $# >= 1 )) || invalid "Missing command."

COMMAND="$1"
shift

case "$COMMAND" in
    help)
        (( $# == 0 )) || invalid "Unexpected arguments."
        usage
        ;;
    system-info)
        (( $# == 0 )) || invalid "Unexpected arguments."
        system_info
        ;;
    check-host)
        (( $# == 1 )) || invalid "Expected one host."
        check_host "$1"
        ;;
    check-port)
        (( $# == 2 )) ||
            invalid "Expected host and port."
        check_port "$1" "$2"
        ;;
    *)
        invalid "Unknown command: $COMMAND"
        ;;
esac
