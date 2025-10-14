#!/usr/bin/env bash
set -euo pipefail

LOG_PATH=${SSHX_LOG:-/tmp/sshx.log}

mkdir -p /run/sshd

if ! ls /etc/ssh/ssh_host_* >/dev/null 2>&1; then
  ssh-keygen -A
fi

if ! pgrep -x sshd >/dev/null 2>&1; then
  /usr/sbin/sshd
fi

if command -v sshx >/dev/null 2>&1 && ! pgrep -x sshx >/dev/null 2>&1; then
  nohup sshx >"${LOG_PATH}" 2>&1 < /dev/null &
fi

if [ "$#" -eq 0 ]; then
  set -- sleep infinity
fi

exec "$@"
