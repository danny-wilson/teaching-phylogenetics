#!/bin/sh
# Entry point script to start the desktop environment in a Codespace
# If run in an interactive TTY, runs in foreground to allow Ctrl+C to stop
# If not, starts in background and keeps container alive
set -e

START=/usr/local/bin/start-desktop.sh
LOG=/tmp/start-desktop.log

# If stdout is a TTY, run in foreground so Ctrl+C works
if [ -t 1 ]; then
  echo "Interactive TTY detected — starting desktop in background and entering bash shell"
  # ensure start-desktop.sh execs a foreground server (or call the server directly)
  nohup "$START" > "$LOG" 2>&1 &
  /bin/bash
else
  echo "No TTY — starting desktop in background and keeping container alive"
  # start in background and capture logs
  nohup "$START" > "$LOG" 2>&1 &
  # keep PID1 alive so Codespaces doesn't kill the container
  exec tail -f /dev/null
fi
