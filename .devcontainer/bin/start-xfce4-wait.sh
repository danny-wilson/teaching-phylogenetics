#!/bin/sh
USER="${USER:-$(id -un)}"
HOME="/home/$USER"
export USER HOME
export DISPLAY=":1"

# full-path binaries (avoid PATH issues when run via su)
XRANDR=/usr/bin/xrandr
DBUS_LAUNCH=/usr/bin/dbus-launch
STARTXFCE=/usr/bin/startxfce4
DISPL_CFG="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/displays.xml"

# wait up to 30s for a non-zero RANDR output (checks for "CONNECTED" with a numeric mode)
for i in $(seq 1 60); do
  if $XRANDR --current 2>/dev/null | grep -E ' connected .* [0-9]{2,}x[0-9]{2,}' >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

# clear old cached display layout that can place panels wrong
[ -f "$DISPL_CFG" ] && rm -f "$DISPL_CFG"

# finally start XFCE (replace this exec line if you prefer a log wrapper)
exec $DBUS_LAUNCH --exit-with-session $STARTXFCE
