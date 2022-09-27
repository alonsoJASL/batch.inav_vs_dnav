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

$MIRTK_DIR/transform-points $MRA_DIR/$mv $LGE_DIR/$mv -dofin $LGE_DIR/$dof
for c in ${cutters}; do 
    echo "INPUT   : $MRA_DIR/$c"
    echo "DOF FILE: $dof"
    # echo "$MIRTK_DIR/transform-image $MRA/$c $LGE_DIR/$lareg -dofin $LGE_DIR/$xnav -interp NN "
    $MIRTK_DIR/transform-points $MRA_DIR/$c $LGE_DIR/$c -dofin $LGE_DIR/$dof
done 
