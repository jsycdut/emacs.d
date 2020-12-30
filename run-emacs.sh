#!/usr/bin/env bash

PLATFORM=$(uname)

if [[ "$PLATFORM" == "Linux" ]]; then
  nohup emacs -q --load init.el init.el &
elif [[ "$PLATFORM" == "Darwin" ]]; then
  /Applications/Emacs.app/Contents/MacOS/Emacs -q --load init.el init.el
else
  echo "Oh~ I don't know what your platform is, try to launch your emacs manually."
fi
