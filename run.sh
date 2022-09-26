#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  DIR_1 : main folder'
    >&2 echo '  DIR_2 : main folder (docker tests)'
    >&2 echo '   N : case folder '
    >&2 echo '   X : d or i (dnav or inav) '
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )

DIR=$1
DOCKER_DIR=$2
N=$3
X=$4

# echo "=====Convert to NII (v1.1.0)====="
# $SCRIPT_DIR/0_convert_to_nii.sh $DIR $N $X 
# echo "=====Convert to NII (latest)====="
# $SCRIPT_DIR/0_convert_to_nii.sh $DOCKER_DIR $N $X 

echo "=====Register/Transform (v1.1.0)====="
$SCRIPT_DIR/1_register_mra2xnav.sh $DIR $N $X 
$SCRIPT_DIR/2_transform_image_mra2xnav.sh $DIR $N $X 

echo "=====Register/Transform (latest)====="
$SCRIPT_DIR/1b_register_docker.sh $DOCKER_DIR $N $X 