#!/bin/bash
set -e

USER=student
if ! id -u $USER >/dev/null 2>&1; then
  useradd -m -s /bin/bash $USER
fi

# Ensure XDG runtime dir exists for the student (some apps expect it)
mkdir -p /run/user/1000
chown $USER:$USER /run/user/1000
chmod 700 /run/user/1000

# # Xvfb + .Xauthority setup
export DISPLAY=:1
export XAUTHORITY=/home/$USER/.Xauthority

# Ensure Xauthority exists and is owned correctly
if [ ! -f "$XAUTHORITY" ]; then
  touch "$XAUTHORITY"
  chown $USER:$USER "$XAUTHORITY"
fi

USE_XVFB=false
if [ "$USE_XVFB" = true ]; then
  # Start virtual X server
  Xvfb :1 -screen 0 1024x768x24 &
  sleep 1

  # Start XFCE session as the student user
  su -s /bin/bash $USER -c "dbus-launch --exit-with-session xfce4-session > /tmp/xfce4.log 2>&1 &"
  sleep 1

  # Start x11vnc on display :1 without password (Codespaces access control expected)
  x11vnc -display :1 -nopw -forever -shared -rfbport 5901 > /tmp/x11vnc.log 2>&1 &
  sleep 1

  # Redundant: also start xpra shadowing the Xvfb display for HTML5 access
  su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra shadow :1 --bind-tcp=0.0.0.0:14500 --html=on >/tmp/xpra-desktop.log 2>&1 &"
  sleep 1
else
  #xpra start :1 \
  #  --start-child="dbus-launch --exit-with-session startxfce4" \
  #  --bind-tcp=0.0.0.0:14500 \
  #  --html=on \
  #  --resize-display=yes \
  #  --exit-with-children \
  #  --auth=sha1 \
  #  --daemon=yes \
  #  --log-file=/tmp/xpra-desktop.log
  su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :1 --start-child=\"dbus-launch --exit-with-session startxfce4\" --bind-tcp=0.0.0.0:14500 --html=on --resize-display=yes --exit-with-children >/tmp/xpra-desktop.log 2>&1 &"
  sleep 1
fi

# Start noVNC proxy
#/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 > /tmp/novnc.log 2>&1 &
#echo "Desktop started. noVNC listening on port 6080."

# Also start xpra per-app HTML5 sessions (so apps can be opened in separate tabs)
/usr/local/bin/start-xpra.sh

# Start landing page server (foregrounded by default script; background here)
/usr/local/bin/start-landing.sh >/tmp/landing.log 2>&1 &
