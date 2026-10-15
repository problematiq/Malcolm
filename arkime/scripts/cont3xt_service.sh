#!/bin/bash

# Copyright (c) 2026 Battelle Energy Alliance, LLC.  All rights reserved.

# cont3xt and parliament share the users database initialized by the arkime container
/usr/local/bin/arkime_db_wait.sh

while true; do
  if [[ "${ARKIME_CONT3XT:-false}" == "true" ]] && [[ -f $ARKIME_DIR/etc/cont3xt.ini ]]; then
    echo "Launch cont3xt..."
    pushd $ARKIME_DIR/cont3xt >/dev/null 2>&1
    $ARKIME_DIR/bin/node cont3xt.js --insecure -c $ARKIME_DIR/etc/cont3xt.ini
    popd >/dev/null 2>&1
  fi
  sleep 5
done
