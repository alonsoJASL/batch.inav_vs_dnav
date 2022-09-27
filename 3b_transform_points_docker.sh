#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
# MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

DIR=$1
N=$2
X=$3

LGE_DIR="$DIR/$N/LGE_"$X"NAV"
MRA_DIR="$DIR/$N/MRA"

cd $MRA_DIR 
cutters=$(ls prodCutter*.vtk)
cd $SCRIPT_DIR

dof="mra2"$X"nav.dof"
mv="prodMVI.vtk"
docker run --rm --volume="$DIR/$N":/data biomedia/mirtk:latest transform-points "MRA/$mv" LGE_"$X"NAV/$mv -dofin LGE_"$X"NAV/$dof

for c in ${cutters}; do 
    echo "INPUT   : $MRA_DIR/$c"
    echo "DOF FILE: $dof"

    docker run --rm --volume="$DIR/$N":/data biomedia/mirtk:latest transform-points "MRA/$c" LGE_"$X"NAV/$c -dofin LGE_"$X"NAV/$dof
done 
