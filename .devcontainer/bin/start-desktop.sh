#!/bin/bash
set -e

# Xvfb setup
export DISPLAY=:1
USER=student

USE_XVFB=false
USE_NOVNC=false
if [ "$USE_XVFB" = true ]; then
  # Start virtual X server
  Xvfb :1 -screen 0 1024x768x24 &
  sleep 1

  # Start XFCE session as the student user
  #su -s /bin/bash $USER -c "dbus-launch --exit-with-session xfce4-session > /tmp/xfce4.log 2>&1 &"
  dbus-launch --exit-with-session xfce4-session > /tmp/xfce4.log 2>&1 &
  sleep 1

  # Start x11vnc on display :1 without password (Codespaces access control expected)
  x11vnc -display :1 -nopw -forever -shared -rfbport 5901 > /tmp/x11vnc.log 2>&1 &
  sleep 1

  if [ "$USE_NOVNC" = true ]; then
    # Start noVNC proxy
    /opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 14500 > /tmp/novnc.log 2>&1 &
    echo "Desktop started. noVNC listening on port 14500."
  else
    # Alternative: start xpra shadowing the Xvfb display for HTML5 access
    #su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra shadow :1 --bind-tcp=0.0.0.0:14500 --html=on >/tmp/xpra-desktop.log 2>&1 &"
    env XDG_RUNTIME_DIR=/run/user/1000 xpra shadow :1 --bind-tcp=0.0.0.0:14500 --html=on >/tmp/xpra-desktop.log 2>&1 &
    echo "Desktop started. XPRA listening on port 14500."
    sleep 1
  fi
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
  #su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :1 --start-child=\"dbus-launch --exit-with-session startxfce4\" --bind-tcp=0.0.0.0:14500 --html=on --resize-display="1920x1080" --exit-with-children >/tmp/xpra-desktop.log 2>&1 &"
  env XDG_RUNTIME_DIR=/run/user/1000 xpra start :1 --start-child=\"dbus-launch --exit-with-session startxfce4\" --bind-tcp=0.0.0.0:14500 --html=on --resize-display="1920x1080" --exit-with-children >/tmp/xpra-desktop.log 2>&1 &
  #su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :1 --start-child=\"sh -c 'until /usr/bin/xrandr --current 2>/dev/null | grep -E \\\" connected .* [0-9]+x[0-9]+\\\" >/dev/null; do sleep 0.5; done; exec /usr/bin/dbus-launch --exit-with-session /usr/bin/startxfce4'\" --bind-tcp=0.0.0.0:14500 --html=on --resize-display=yes --exit-with-children >/tmp/xpra-desktop.log 2>&1 &"
  #su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :1 --start-child=\"/usr/local/bin/start-xfce4-wait.sh\" --bind-tcp=0.0.0.0:14500 --html=on --resize-display=yes --exit-with-children >/tmp/xpra-desktop.log 2>&1 &"
  sleep 1
fi

# Also start xpra per-app HTML5 sessions (so apps can be opened in separate tabs)
/usr/local/bin/start-xpra.sh

# Start landing page server (foregrounded by default script; background here)
/usr/local/bin/start-landing.sh >/tmp/landing.log 2>&1 &
