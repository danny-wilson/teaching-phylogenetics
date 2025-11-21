#!/bin/bash
# Exec Google Chrome stable binary
if [ -x "/usr/bin/google-chrome-stable" ]; then
  exec /usr/bin/google-chrome-stable "$@"
fi
if [ -x "/opt/google/chrome/google-chrome" ]; then
  exec /opt/google/chrome/google-chrome "$@"
fi
echo "google-chrome: binary not found" >&2
exit 127
