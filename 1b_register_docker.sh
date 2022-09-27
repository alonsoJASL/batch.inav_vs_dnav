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

DIR=$1
N=$2
X=$3

LGE_DIR="$DIR/$N/LGE_"$X"NAV"
MRA_DIR="$DIR/$N/MRA"

xnav=$(ls $LGE_DIR | grep dcm-)
mra=$(ls $MRA_DIR | grep dcm)

echo "MOVING (source): $mra"
echo "FIXED  (target): $xnav"

# echo "Registering" # register fixed moving -dofout file.dof -model Rigid 
docker run --rm --volume=$DIR/$N:/data biomedia/mirtk:latest register LGE_"$X"NAV/$xnav MRA/$mra -dofout LGE_"$X"NAV/mra2"$X"nav.dof -model Rigid # docker 1
# docker run --rm --volume=$DIR/$N:/data biomedia/mirtk:latest register MRA/$mra LGE_"$X"NAV/$xnav -dofout LGE_"$X"NAV/mra2"$X"nav.dof -model Rigid # docker 2

# echo "Transform segmentation" # transform-image input output -dofin file.dof 
docker run --rm --volume=$DIR/$N:/data biomedia/mirtk:latest transform-image MRA/LA.nii LGE_"$X"NAV/LA-reg.nii  -dofin LGE_"$X"NAV/mra2"$X"nav.dof -interp NN 

