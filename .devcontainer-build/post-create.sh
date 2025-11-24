#!/bin/sh
set -e
if [ ! -d /home/student/work/practical ]; then
  cp -r /workspaces/teaching-phylogenetics/practical /home/student/work/
fi
