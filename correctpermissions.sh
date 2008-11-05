#!/bin/bash
#

#chflags nouchg "$1"

chown mbolingbroke:staff "$1"

if [ -d "$1" ]
then
  # World readable, sticky bit
  chmod 755 "$1"
else
  # World readable
  chmod 644 "$1"
fi
