#!/usr/bin/env bash

set -euo pipefail

if [[ "${ARKIME_CONT3XT:-false}" == "true" ]] || [[ "${ARKIME_PARLIAMENT:-false}" == "true" ]]; then
    # cont3xt/parliament require (header) authentication for every page, so any HTTP response means it's up
    [[ "${ARKIME_SSL:-true}" == "true" ]] && STATUS_PROTOCOL=https || STATUS_PROTOCOL=http
    [[ "${ARKIME_CONT3XT:-false}" == "true" ]] && STATUS_PORT=3218 || STATUS_PORT=8008
    [[ "$(curl --insecure --silent --output /dev/null --write-out '%{http_code}' "${STATUS_PROTOCOL}://localhost:${STATUS_PORT}/" || true)" != "000" ]]
elif [[ "${ARKIME_LIVE_CAPTURE:-false}" == "true" ]]; then
    supervisorctl status live-arkime >/dev/null 2>&1
elif [[ "${ARKIME_PCAP_PROCESSOR:-true}" == "true" ]] && [[ "${MALCOLM_PROFILE:-malcolm}" == "malcolm" ]]; then
    [[ "${ARKIME_SSL:-true}" == "true" ]] && STATUS_PROTOCOL=https || STATUS_PROTOCOL=http
    curl --insecure --silent --output /dev/null --fail "${STATUS_PROTOCOL}://localhost:${ARKIME_VIEWER_PORT:-8005}/_ns_/nstest.html"
else
    (( $(supervisorctl status 2>/dev/null | grep -cPv '(^INFO:|STARTING|RUNNING|EXITED|Not started$)') == 0 )) && exit 0 || exit 1
fi
