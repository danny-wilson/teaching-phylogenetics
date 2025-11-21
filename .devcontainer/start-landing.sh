#!/bin/bash
set -e

#!/bin/bash
set -e
# Serve the static landing page on port 14600 from /opt/landing
cd /opt/landing || exit 0
exec python3 -m http.server 14600
