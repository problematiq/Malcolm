#!/bin/sh

# Copyright (c) 2026 Battelle Energy Alliance, LLC.  All rights reserved.

cd "${ARKIME_DIR:-/opt/arkime}"/etc

wget -nv --no-check-certificate --timeout=30 --tries=2 -O ipv4-address-space.csv_new https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv && \
  mv -f ipv4-address-space.csv_new ipv4-address-space.csv || \
  rm -f ipv4-address-space.csv_new

wget -nv --timeout=30 --tries=2 -O oui.txt_new https://www.wireshark.org/download/automated/data/manuf && \
  mv -f oui.txt_new oui.txt || \
  rm -f oui.txt_new

# MAXMIND_GEOIP_DB_UPDATE_ENABLED=false skips the MaxMind GeoIP database download (e.g., for
#   air-gapped deployments, or to keep the databases that were embedded at build time)
case "$(echo "${MAXMIND_GEOIP_DB_UPDATE_ENABLED:-true}" | tr '[:upper:]' '[:lower:]')" in
  false|no|off|0|f|n)
    echo "MaxMind GeoIP database update disabled (MAXMIND_GEOIP_DB_UPDATE_ENABLED=${MAXMIND_GEOIP_DB_UPDATE_ENABLED})"
    ;;
  *)
    /usr/local/bin/maxmind-mmdb-download.sh -o "$(pwd)"
    ;;
esac
