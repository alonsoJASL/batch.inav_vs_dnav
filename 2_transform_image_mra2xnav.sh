#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

DIR=$1
N=$2
X=$3

LGE_DIR="$DIR/$N/LGE_"$X"NAV"
MRA_DIR="$DIR/$N/MRA"

la="LA.nii"
lareg="LA-reg.nii"
dof="mra2"$X"nav.dof"

echo "INPUT   : $MRA_DIR/$la"
echo "DOF FILE: $dof"
echo "OUTPUT  : $lareg"

# echo "$MIRTK_DIR/transform-image $MRA/$la $LGE_DIR/$lareg -dofin $LGE_DIR/$xnav -interp NN "
$MIRTK_DIR/transform-image $MRA_DIR/$la $LGE_DIR/$lareg -dofin $LGE_DIR/$dof -interp NN

