#!/bin/bash
set -e

USER=student

# Start per-app xpra HTML5 sessions on distinct ports so each app can be opened
# in its own Chrome tab. Ports: 14500=terminal, 14501=jalview, 14502=beast

# Terminal emulator in its own xpra session (accessible via HTML5 client)
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :101 --bind-tcp=0.0.0.0:14501 --html=on --start-child=xfce4-terminal --exit-with-children >/tmp/xpra-term.log 2>&1 &"
sleep 0.5
# Jalview in its own xpra session (accessible via HTML5 client)
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :102 --bind-tcp=0.0.0.0:14502 --html=on --start-child=/usr/local/bin/start-beast.sh --exit-with-children >/tmp/xpra-beast.log 2>&1 &"
sleep 0.5
# Firefox in its own xpra session (accessible via HTML5 client)
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :103 --bind-tcp=0.0.0.0:14503 --html=on --start-child=/usr/local/bin/firefox --exit-with-children >/tmp/xpra-firefox.log 2>&1 &"
sleep 0.5

echo "Xpra sessions started (HTML5): 14501=terminal,14502=beast,14503=firefox."
