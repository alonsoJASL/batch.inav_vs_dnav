#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  DIR'
    >&2 echo '    N'
    >&2 echo '    X'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib" # linux
# MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

DIR=$1
N=$2
X=$3

LGE_DIR="$DIR/$N/LGE_"$X"NAV"
MRA_DIR="$DIR/$N/MRA"

xnav=$(ls $LGE_DIR | grep dcm-)
mra=$(ls $MRA_DIR | grep dcm)

echo "MOVING (source): $mra"
echo "FIXED  (target): $xnav"

# echo "$MIRTK_DIR/register $MRA_DIR/$mra  $LGE_DIR/$xnav -dofout $LGE_DIR/mra2'$X'nav.dof -model Rigid -verbose 1"
$MIRTK_DIR/register "$MRA_DIR/$mra"  "$LGE_DIR/$xnav" -dofout "$LGE_DIR/mra2"$X"nav.dof" -model Rigid -verbose 1

