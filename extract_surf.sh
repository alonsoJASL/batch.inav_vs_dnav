#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# CEMRG_DIR="/Users/jsolislemus/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
CEMRG_DIR="$HOME/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
# MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

DIR=$1
N=$2
X=$3
fname=$4

LGE_DIR="$DIR/$N/LGE_"$X"NAV"

echo "Extract surface: $LGE_DIR/$fname"

$MIRTK_DIR/close-image $LGE_DIR/$fname $LGE_DIR/segmentation.s.nii -iterations 1 
$MIRTK_DIR/extract-surface $LGE_DIR/segmentation.s.nii $LGE_DIR/segmentation.vtk -isovalue 0.5 -blur 0
$MIRTK_DIR/smooth-surface $LGE_DIR/segmentation.vtk $LGE_DIR/segmentation.vtk -iterations 10 
