#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '    DIR'
    >&2 echo '    N'
    >&2 echo '    X'
    >&2 echo '    Threshold (single, multiple, or sweep)'
    >&2 echo '    OUTPUT'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
CEMRG_DIR="$HOME/dev/build/FORK.CEMRG/MITK-build/bin"
MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
# CEMRG_DIR="/Users/jsolislemus/dev/build/FORK.JASL.CEMRG/MITK-build/bin" # macos
# MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

DIR=$1
N=$2
X=$3
TH=$4
outp=$5

LGE_DIR="$DIR/$N/LGE_"$X"NAV"
xnav=$(ls $LGE_DIR | grep dcm-LGE)

echo "$CEMRG_DIR/MitkCemrgScarProjectionOptions -i $LGE_DIR/$xnav -m 1 -svp --threshold-values $TH --output-subfolder OUTPUT_$outp -v"
$CEMRG_DIR/MitkCemrgScarProjectionOptions -i $LGE_DIR/$xnav -m 1 -svp --threshold-values $TH --output-subfolder OUTPUT_$outp -v
