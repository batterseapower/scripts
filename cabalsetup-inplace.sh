#!/bin/bash
#

setupfile=$1
setupfilebin="./${setupfile}.out"

prefix=~/Programming/Checkouts/ghc.$2
compiler="${prefix}/compiler/stage1/ghc-inplace"
packager="${prefix}/utils/ghc-pkg/ghc-pkg-inplace"

bindir="${prefix}/experiment/bin"
libdir="${prefix}/experiment/lib"
libexecdir="${prefix}/experiment/libexec"
datadir="${prefix}/experiment/data"

# I'm not totally certain these actually need to exist.. at least, the GHC build process doesn't bother to supply them
echo "Creating directory structure"
mkdir ${prefix}/experiment
mkdir $bindir
mkdir $libdir
mkdir $libexecdir
mkdir $datadir

echo "Building $setupfile"
$compiler --make $setupfile -o $setupfilebin

echo "Running Cabal"
$setupfilebin configure --with-compiler=$compiler --with-hc-pkg=$packager --prefix=$prefix --bindir=$bindir --libdir=$libdir --libexecdir=$libexecdir --datadir=$datadir
$setupfilebin build
sudo $setupfilebin install