#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '    DIR'
    >&2 echo '    N'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )

IMATOOLS_DIR="$HOME/dev/python/imatools/imatools"

CEMRG_DIR="$HOME/dev/build/FORK.CEMRG/MITK-build/bin"
MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
# CEMRG_DIR="/Users/jsolislemus/dev/build/FORK.JASL.CEMRG/MITK-build/bin" # macos
# MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS

DIR=$1
N=$2

CASE_DIR="$DIR/$N"
dNAV_DIR="$CASE_DIR/LGE_dNAV/OUTPUT"
iNAV_DIR="$CASE_DIR/LGE_iNAV/OUTPUT"

FIBROSIS_MSH="Normalised_IIR_MaxScar-single-voxel" # always the normalised
MNAME="Scalars_i_on_d"

python $IMATOOLS_DIR/project_scalars_on_mesh.py -sdir $dNAV_DIR -tdir $iNAV_DIR -smsh $FIBROSIS_MSH -tmsh $FIBROSIS_MSH -odir "$CASE_DIR" -omsh $MNAME -dt cell 


dNAV_MSH="LGE_dNAV/OUTPUT/Normalised_IIR_MaxScar-single-voxel"
iNAV_MSH=$MNAME
FNAME="$DIR/spatial_correspondence.csv"

if [ ! -f "$FNAME" ]; then
    echo "th_dnav, th_inav, fibrosis_d, fibrosis_i, jaccard, precision, recall, accuracy" > $FNAME 
fi

# Thresholds   :   MEAN    MEDIAN   TH_1      TH_2    TH_3
threshold_array=("1.1300" "1.1504" "1.1205" "1.265" "1.1367")
for ta in ${threshold_array[@]}; do 
    python $IMATOOLS_DIR/compare_fibrosis_overlap.py -d $CASE_DIR -imsh0 $dNAV_MSH -t0 1.2 -imsh1 $iNAV_MSH -t1 $ta -thio >> $FNAME 
done
