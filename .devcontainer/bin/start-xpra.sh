#!/bin/bash
set -e

USER=student

# Start per-app xpra HTML5 sessions on distinct ports so each app can be opened
# in its own Chrome tab. Ports: 14500=terminal, 14501=jalview, 14502=beast

# Terminal
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :101 --bind-tcp=0.0.0.0:14501 --html=on --start-child=xfce4-terminal --exit-with-children >/tmp/xpra-term.log 2>&1 &"
sleep 0.5
# Jalview
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :102 --bind-tcp=0.0.0.0:14502 --html=on --start-child=/usr/local/bin/start-jalview.sh --exit-with-children >/tmp/xpra-jalview.log 2>&1 &"
sleep 0.5
# Firefox
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :103 --bind-tcp=0.0.0.0:14503 --html=on --start-child=/usr/local/bin/start-firefox.sh --exit-with-children >/tmp/xpra-firefox.log 2>&1 &"
sleep 0.5
# Figtree
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :104 --bind-tcp=0.0.0.0:14504 --html=on --start-child=/usr/local/bin/start-figtree.sh --exit-with-children >/tmp/xpra-figtree.log 2>&1 &"
sleep 0.5
# Tempest
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :105 --bind-tcp=0.0.0.0:14505 --html=on --start-child=/usr/local/bin/start-tempest.sh --exit-with-children >/tmp/xpra-tempest.log 2>&1 &"
sleep 0.5
# BEAUti
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :106 --bind-tcp=0.0.0.0:14506 --html=on --start-child=/usr/local/bin/start-beauti.sh --exit-with-children >/tmp/xpra-beauti.log 2>&1 &"
sleep 0.5
# Tracer
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :107 --bind-tcp=0.0.0.0:14507 --html=on --start-child=/usr/local/bin/start-tracer.sh --exit-with-children >/tmp/xpra-tracer.log 2>&1 &"
sleep 0.5
# TreeAnnotator
su - $USER -c "env XDG_RUNTIME_DIR=/run/user/1000 xpra start :108 --bind-tcp=0.0.0.0:14508 --html=on --start-child=/usr/local/bin/start-treeannotator.sh --exit-with-children >/tmp/xpra-treeannotator.log 2>&1 &"
sleep 0.5

echo "Xpra sessions started (HTML5): 14501=terminal,...,14508=treeannotator."
