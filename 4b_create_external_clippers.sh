#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# CEMRG_DIR="/Users/jsolislemus/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
# CEMRG_DIR="$HOME/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
CEMRG_DIR="$HOME/dev/build/CEMRG2-U20.04/MITK-build/bin"
# MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

BASE_DIR=$1
SEG_NAME=$2
MVI_NAME=$3

$SCRIPT_DIR/extract_surf.sh $BASE_DIR $SEG_NAME
$CEMRG_DIR/MitkCemrgApplyExternalClippers -i $BASE_DIR/$SEG_NAME -mv -mvname $MVI_NAME -v 
