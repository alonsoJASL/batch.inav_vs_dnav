#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  DIR'
    >&2 echo '  FNAME'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# CEMRG_DIR="/Users/jsolislemus/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
CEMRG_DIR="$HOME/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
# MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

BASE_DIR=$1
fname=$2


echo "Extract surface: $BASE_DIR/$fname"

$MIRTK_DIR/close-image $BASE_DIR/$fname $BASE_DIR/segmentation.s.nii -iterations 1 
$MIRTK_DIR/extract-surface $BASE_DIR/segmentation.s.nii $BASE_DIR/segmentation.vtk -isovalue 0.5 -blur 0
$MIRTK_DIR/smooth-surface $BASE_DIR/segmentation.vtk $BASE_DIR/segmentation.vtk -iterations 10 
