#!/bin/bash

set -u

usage() {
    cat <<'EOF'
Usage: app.sh <command> [arguments]

Commands:
  system-info              Display system information
  check-host <host>        Resolve and check connectivity to a host
  check-port <host> <port> Check TCP connectivity to host:port
  help                     Show this message

Exit codes:
  0  success
  1  operational failure (e.g. host cannot be resolved, port closed)
  2  invalid command or missing/invalid argument
EOF
}

cmd_system_info() {
    echo "====================== System Information ========================="
    echo "Hostname : $(hostname)"
    echo "User     : $(whoami)"
    echo "Date     : $(date '+%Y-%m-%d %H:%M:%S %Z')"
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "OS       : ${PRETTY_NAME:-unknown}"
    fi
    echo "Kernel   : $(uname -r)"
    return 0
}

cmd_check_host() {
    local host="${1:-}"

    if [[ -z "$host" ]]; then
        echo "Error: 'check-host' requires a host argument" >&2
        return 2
    fi

    local resolved
    resolved=$(getent hosts "$host" 2>/dev/null | awk '{print $1}' | head -n1)

    if [[ -z "$resolved" ]]; then
        echo "Resolution: FAILED to resolve '$host'" >&2
        return 1
    fi

    echo "Resolution: $host -> $resolved"
    if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
        echo "Ping      : reachable"
    else
        echo "Ping      : no reply (ICMP may be blocked)"
    fi
    return 0
}

cmd_check_port() {
    local host="${1:-}"
    local port="${2:-}"

    if [[ -z "$host" || -z "$port" ]]; then
        echo "Error: 'check-port' requires <host> <port>" >&2
        return 2


    if ! [[ "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
        echo "Error: port must be an integer between 1 and 65535, got '$port'" >&2
        return 2
    fi

    if timeout 2 bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null; then
        echo "Port $port on $host: open"
        return 0
    else
        echo "Port $port on $host: closed or unreachable" >&2
        return 1
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        echo "Error: no command given" >&2
        usage >&2
        return 2
    fi

    local command="$1"
    shift

    case "$command" in
        system-info)          cmd_system_info ;;
        check-host)           cmd_check_host "$@" ;;
        check-port)           cmd_check_port "$@" ;;
        help|-h|--help)       usage ;;
        *)
            echo "Error: unknown command '$command'" >&2
            usage >&2
            return 2
            ;;
    esac
}

main "$@"
exit $?
