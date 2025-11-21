#!/bin/bash
# Wrapper to exec the installed Firefox binary from /opt/firefox or /opt/firefox-dist
if [ -x "/opt/firefox/firefox" ]; then
  exec /opt/firefox/firefox "$@"
fi
if [ -x "/opt/firefox-dist/firefox" ]; then
  exec /opt/firefox-dist/firefox "$@"
fi
if [ -x "/usr/bin/firefox" ]; then
  exec /usr/bin/firefox "$@"
fi
echo "firefox: binary not found" >&2
exit 127
#!/bin/bash
# Try common firefox binary locations and exec the first one found
if [ -x "/usr/bin/firefox" ]; then
  exec /usr/bin/firefox "$@"
fi
if [ -x "/opt/firefox-dist/firefox" ]; then
  exec /opt/firefox-dist/firefox "$@"
fi
if [ -x "/opt/firefox/firefox" ]; then
  exec /opt/firefox/firefox "$@"
fi
echo "firefox: binary not found" >&2
exit 127
