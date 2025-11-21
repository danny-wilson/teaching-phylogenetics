#!/bin/bash
set -e

USER=student
if ! id -u $USER >/dev/null 2>&1; then
  useradd -m -s /bin/bash $USER
fi

# Start per-app xpra HTML5 sessions on distinct ports so each app can be opened
# in its own Chrome tab. Ports: 14500=terminal, 14501=jalview, 14502=beast

su - $USER -c "xpra start :100 --bind-tcp=0.0.0.0:14500 --html=on --start-child=xfce4-terminal --exit-with-children >/tmp/xpra-term.log 2>&1 &"
sleep 0.5
su - $USER -c "xpra start :101 --bind-tcp=0.0.0.0:14501 --html=on --start-child=jalview --exit-with-children >/tmp/xpra-jalview.log 2>&1 &"
sleep 0.5
su - $USER -c "xpra start :102 --bind-tcp=0.0.0.0:14502 --html=on --start-child='/usr/bin/beast -java' --exit-with-children >/tmp/xpra-beast.log 2>&1 &"

echo "Xpra sessions started (HTML5): 14500=terminal,14501=jalview,14502=beast"
