#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '    BASE_DIR'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

DIR=$1

dNAV_DIR="$DIR/dNav"
iNAV_DIR="$DIR/iNav"

la="PVeinsCroppedImage.nii"
lareg="PVeinsCroppedImage.nii"
ddof="mra2dnav.dof"
idof="mra2inav.dof"

echo "INPUT   : $DIR/$la"
echo "DOF FILE: $ddof"
echo "OUTPUT  : $lareg"
$MIRTK_DIR/transform-image $DIR/$la $dNAV_DIR/$lareg -dofin $dNAV_DIR/$ddof -interp NN

echo "INPUT   : $DIR/$la"
echo "DOF FILE: $idof"
echo "OUTPUT  : $lareg"
$MIRTK_DIR/transform-image $DIR/$la $iNAV_DIR/$lareg -dofin $iNAV_DIR/$idof -interp NN

