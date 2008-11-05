#!/bin/bash
#

if [ -e "Setup.lhs" ] ; then
  filename="Setup.lhs"
elif [ -e "Setup.hs" ] ; then
  filename="Setup.hs" 
else
  echo "No Cabal setup file found!"
  exit 0
fi
  

runghc $filename configure
if [ $? -eq 0 ] ; then
  runghc $filename build
  if [ $? -eq 0 ] ; then
    sudo runghc $filename install
  fi
fi
