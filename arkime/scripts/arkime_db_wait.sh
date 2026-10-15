#!/bin/bash

# Copyright (c) 2026 Battelle Energy Alliance, LLC.  All rights reserved.

# Block until the OpenSearch/Elasticsearch document store is up and the Arkime
#   users index has been created (by initarkime.sh in the arkime container).
#   Used by processes (cont3xt, parliament) that share Arkime's users database
#   but do not initialize it themselves.

OPENSEARCH_URL=${OPENSEARCH_URL:-"https://opensearch:9200"}
OPENSEARCH_PRIMARY=${OPENSEARCH_PRIMARY:-"opensearch-local"}
OPENSEARCH_CREDS_CONFIG_FILE=${OPENSEARCH_CREDS_CONFIG_FILE:-"/var/local/curlrc/.opensearch.primary.curlrc"}
if [[ -r "$OPENSEARCH_CREDS_CONFIG_FILE" ]]; then
  CURL_CONFIG_PARAMS=(
    --config
    "$OPENSEARCH_CREDS_CONFIG_FILE"
    )
else
  CURL_CONFIG_PARAMS=()
fi

echo "Giving ${OPENSEARCH_PRIMARY} time to start..."
/usr/local/bin/opensearch_status.sh >/dev/null 2>&1 || true

echo "Waiting for Arkime database initialization..."
until (( $(curl "${CURL_CONFIG_PARAMS[@]}" -fs -XGET -H'Content-Type: application/json' "${OPENSEARCH_URL}/_cat/indices/arkime_users_v*" 2>/dev/null | wc -l) > 0 )); do
  sleep 10
done
echo "Arkime database is initialized!"
