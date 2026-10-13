#!/bin/sh
set -eu

mkdir -p "${CEZ_PROJECTS_DIR}" "${GOPATH}" "${NPM_CONFIG_PREFIX}" "${XDG_CACHE_HOME}" "${MISE_DATA_DIR}"
mise reshim

exec /usr/local/bin/node /usr/local/lib/node_modules/@open-mercato/cezar/dist/index.js serve \
    --bind-host "${CEZ_BIND_HOST:-0.0.0.0}" \
    --port "${CEZ_PORT:-4321}" \
    --no-open \
    "$@"
