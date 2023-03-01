#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '    BASE_DIR'
    >&2 echo '    OUT'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib" # linux
MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

BASE_DIR=$1
output=$2

lge=$(ls $BASE_DIR | grep dcm-LGE)
mra=$(ls $BASE_DIR | grep dcm-MRA)

echo "MOVING (source): $mra"
echo "FIXED  (target): $lge"

# echo "$MIRTK_DIR/register $MRA_DIR/$mra  $LGE_DIR/$lge -dofout $LGE_DIR/mra2'$X'nav.dof -model Rigid -verbose 1"
$MIRTK_DIR/register "$BASE_DIR/$mra"  "$BASE_DIR/$lge" -dofout "$BASE_DIR/$output.dof" -model Rigid -verbose 1

echo "Saving to TXT file"
$MIRTK_DIR/info "$BASE_DIR/$output.dof" > "$BASE_DIR/$output.txt"
