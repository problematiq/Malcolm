#!/bin/bash

# Copyright (c) 2026 Battelle Energy Alliance, LLC.  All rights reserved.

# cont3xt and parliament share the users database initialized by the arkime container
/usr/local/bin/arkime_db_wait.sh

while true; do
  if [[ "${ARKIME_PARLIAMENT:-false}" == "true" ]] && [[ -f $ARKIME_DIR/etc/parliament.ini ]]; then
    echo "Launch parliament..."
    pushd $ARKIME_DIR/parliament >/dev/null 2>&1
    $ARKIME_DIR/bin/node parliament.js --insecure -c $ARKIME_DIR/etc/parliament.ini
    popd >/dev/null 2>&1
  fi
  sleep 5
done
