#!/usr/bin/env bash

set -euo pipefail

# the run mode may have been given as a container argument rather than via ARKIME_RUN_MODE,
#   so prefer what docker_entrypoint.sh recorded at startup
RECORDED_RUN_MODE="$(head -n 1 /var/run/arkime/run_mode 2>/dev/null || true)"
ARKIME_RUN_MODE="${RECORDED_RUN_MODE:-${ARKIME_RUN_MODE:-arkime}}"

[[ "${ARKIME_SSL:-true}" == "true" ]] && STATUS_PROTOCOL=https || STATUS_PROTOCOL=http

# succeeds if anything at all is answering HTTP(S) on the port (authentication
#   may cause a 401/403, which still means the service is up)
function http_listening() {
    local HTTP_CODE
    HTTP_CODE="$(curl --insecure --silent --output /dev/null --max-time 10 --write-out '%{http_code}' "${STATUS_PROTOCOL}://localhost:${1}/" 2>/dev/null || true)"
    [[ -n "${HTTP_CODE}" ]] && [[ "${HTTP_CODE}" != "000" ]]
}

case "${ARKIME_RUN_MODE,,}" in
    disabled)
        # a Parliament/Cont3xt container whose component is disabled (see docker_entrypoint.sh)
        exit 0
        ;;
    parliament)
        supervisorctl status parliament >/dev/null 2>&1 && http_listening "${ARKIME_PARLIAMENT_PORT:-8008}"
        ;;
    cont3xt)
        supervisorctl status cont3xt >/dev/null 2>&1 && http_listening "${ARKIME_CONT3XT_PORT:-3218}"
        ;;
    *)
        if [[ "${ARKIME_LIVE_CAPTURE:-false}" == "true" ]]; then
            supervisorctl status live-arkime >/dev/null 2>&1
        elif [[ "${ARKIME_PCAP_PROCESSOR:-true}" == "true" ]] && [[ "${MALCOLM_PROFILE:-malcolm}" == "malcolm" ]]; then
            curl --insecure --silent --output /dev/null --fail "${STATUS_PROTOCOL}://localhost:${ARKIME_VIEWER_PORT:-8005}/_ns_/nstest.html"
        else
            (( $(supervisorctl status 2>/dev/null | grep -cPv '(^INFO:|STARTING|RUNNING|EXITED|Not started$)') == 0 )) && exit 0 || exit 1
        fi
        ;;
esac
