#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '	BASE_DIR'
    >&2 echo '	SEG_NAME (PVeinsCroppedImage)'
    >&2 echo '	OUT_SDIR (where to save output)'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# CEMRG_DIR="/Users/jsolislemus/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
CEMRG_DIR="$HOME/dev/build/CEMRG2-U20.04/MITK-build/bin"
# MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

BASE_DIR=$1
SEG_NAME=$2
OUT_SDIR=$3
THRESHOLDS=$4

xnav=$(ls $BASE_DIR | grep dcm-LGE)

$CEMRG_DIR/MitkCemrgScarProjectionOptions -i $BASE_DIR/$xnav -seg $SEG_NAME -o $OUT_SDIR -m 0 -tv $THRESHOLDS -v
