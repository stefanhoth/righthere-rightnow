#!/usr/bin/env bash
#
# Pair and connect to an Android device over wireless debugging, using a QR
# code drawn in this terminal.
#
# On the phone: Settings -> Developer options -> Wireless debugging
#               -> Pair device with QR code
#
# Derived from https://github.com/profdayat, rewritten to:
#   - draw the pairing password from /dev/urandom instead of bash's $RANDOM
#   - find the connect port over mDNS instead of port-scanning the device
#   - leave the running adb server alone
#   - verify success by looking at `adb devices`, not by trusting exit codes
#   - keep the password off stdout
#
# Compatible with bash 3.2 (the macOS system bash).

set -uo pipefail

readonly PASSWORD_LENGTH=21
timeout_seconds=120
show_password=0

usage() {
    cat <<'USAGE'
Usage: adb-qr-connect.sh [options]

Options:
  -t, --timeout SECONDS   How long to wait for the phone to scan (default: 120)
      --show-password     Print the pairing password as text as well as the QR
  -h, --help              This message

Requires: adb, qrencode  (brew install qrencode)
USAGE
}

while [ $# -gt 0 ]; do
    case "$1" in
        -t|--timeout)
            [ $# -ge 2 ] || { echo "--timeout needs a value" >&2; exit 2; }
            timeout_seconds="$2"; shift 2 ;;
        --show-password) show_password=1; shift ;;
        -h|--help)       usage; exit 0 ;;
        *)               echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

case "$timeout_seconds" in
    ''|*[!0-9]*) echo "--timeout wants a whole number of seconds" >&2; exit 2 ;;
esac

require() {
    command -v "$1" >/dev/null 2>&1 && return 0
    echo "Missing required command: $1" >&2
    [ -n "${2:-}" ] && echo "  $2" >&2
    exit 1
}

require adb "Install Android platform-tools and put adb on your PATH."
require qrencode "brew install qrencode"

# 21 characters from /dev/urandom. Bash's $RANDOM carries about 32 bits of
# internal state no matter how many characters you draw from it, so a long
# password built that way is weaker than its length suggests.
random_token() {
    LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$1"
}

# Prints "host:port" for the first advertised service of the given type, or
# nothing. The third column of `adb mdns services` is the address; splitting on
# the last colon keeps IPv6 literals intact.
find_service() {
    local service_type="$1" address host port
    address=$(adb mdns services 2>/dev/null | awk -v t="$service_type" '$0 ~ t {print $NF; exit}')
    [ -n "$address" ] || return 1

    host="${address%:*}"
    port="${address##*:}"
    [ -n "$host" ] && [ -n "$port" ] || return 1

    case "$host" in
        *:*) host="[$host]" ;;   # IPv6 literal
    esac
    printf '%s:%s\n' "$host" "$port"
}

# Polls for a service until it appears or the timeout expires.
await_service() {
    local service_type="$1" deadline_label="$2" found
    local started=$SECONDS

    while [ $((SECONDS - started)) -lt "$timeout_seconds" ]; do
        found=$(find_service "$service_type") && {
            # Status goes to stderr; stdout carries only the address, because
            # the caller captures this function's stdout.
            printf '\r%-70s\n' "Found $deadline_label at $found" >&2
            printf '%s\n' "$found"
            return 0
        }
        printf '\r  waiting for %s ... %ds' "$deadline_label" "$((SECONDS - started))" >&2
        sleep 1
    done

    printf '\r%-70s\n' "Timed out after ${timeout_seconds}s waiting for $deadline_label" >&2
    return 1
}

name="ADB_WIFI_$(random_token 20)"
password="$(random_token "$PASSWORD_LENGTH")"

if [ "${#password}" -ne "$PASSWORD_LENGTH" ]; then
    echo "Could not generate a password of the expected length." >&2
    exit 1
fi

echo "Android wireless debugging pairing"
echo "On the phone: Developer options -> Wireless debugging -> Pair device with QR code"
echo

# The phone reads this off your screen. Anyone else who can see your screen --
# a screen share, a photo, a person behind you -- can pair too, until the
# pairing window closes.
qrencode -t ANSIUTF8 "WIFI:T:ADB;S:${name};P:${password};;"

if [ "$show_password" -eq 1 ]; then
    echo "Service:  $name"
    echo "Password: $password"
    echo
fi

pairing_address=$(await_service '_adb-tls-pairing._tcp' 'pairing service') || exit 1

echo "Pairing ..."
pair_output=$(adb pair "$pairing_address" "$password" 2>&1)
pair_status=$?
password=""

if [ $pair_status -ne 0 ] || ! printf '%s' "$pair_output" | grep -qi 'successfully paired'; then
    echo "Pairing failed: $pair_output" >&2
    exit 1
fi
echo "Paired."

# The device advertises its connect port over mDNS once pairing succeeds.
# There is no need to scan 20,000 ports to find it, and on a monitored network
# that scan is the kind of thing that generates a security ticket about you.
connect_address=$(await_service '_adb-tls-connect._tcp' 'connect service') || exit 1

echo "Connecting ..."
connect_output=$(adb connect "$connect_address" 2>&1)
echo "$connect_output"

# `adb connect` exits 0 even when it prints "failed to connect", so ask the
# server what it actually has.
if adb devices | grep -q "^${connect_address}[[:space:]]"; then
    echo "Connected to $connect_address"
    exit 0
fi

echo "Not connected. adb said: $connect_output" >&2
exit 1
