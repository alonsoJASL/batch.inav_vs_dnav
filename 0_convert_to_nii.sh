#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  DIR : main folder'
    >&2 echo '   N : case folder '
    >&2 echo '   X : d or i (dnav or inav) '
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# CEMRG_DIR="/Users/jsolislemus/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
CEMRG_DIR="$HOME/dev/build/FORK.JASL.CEMRG/MITK-build/bin"

DIR=$1
N=$2
X=$3

CASE="$DIR/$N/LGE_"$X"NAV"
DICOM="$CASE/patient"
echo $DICOM
docker run --rm --volume="$DICOM":/Data orodrazeghi/dicom-converter . --gantry --inconsistent

NIIs="$DICOM/NIIs"
xnav=$(ls $NIIs)

echo "$NIIs/$xnav"
$CEMRG_DIR/MitkCemrgResampleReorient -i "$NIIs/$xnav" -o "$CASE/dcm-LGE-"$xnav -rs -ro

echo "Finished"
