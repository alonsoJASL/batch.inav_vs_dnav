#!/usr/bin/env bash
set -euo pipefail


SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
# CEMRG_DIR="/Users/jsolislemus/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
# CEMRG_DIR="$HOME/dev/build/FORK.JASL.CEMRG/MITK-build/bin"
CEMRG_DIR="$HOME/dev/build/CEMRG2-U20.04/MITK-build/bin"
# MIRTK_DIR="$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib"
# MIRTK_DIR="$HOME/dev/libraries/MLib" # macOS


X='d'
BASE_DIR="/media/jsl19/sandisk/09-dnav_vs_inav/carmaf/carmaf_cemrg"
# BASE_DIR="$HOME/syncdir/kcl_xnav_registration/"$X"NAV"
#BASE_DIR="/Volumes/sandisk/09-dnav_vs_inav/registration_issue/iNAV"

SEG_NAME_OLD="PVeinsCroppedImage.nii"
SEG_NAME_NEW="PVeinsCroppedImage_new.nii"
MVI_NAME="tx_prodMVI-by-mra2"$X"nav.vtk"

OUT_DIR_OLD="OUTPUT_OLD"
OUT_DIR_NEW="OUTPUT_NEW"


LS_BASE=$(ls -1 $BASE_DIR)
for n in ${LS_BASE}; do

    WORK_DIR="$BASE_DIR/$n/CEMRG/"$X"Nav"
    logfile=$($SCRIPT_DIR/create_logfile.sh "$WORK_DIR")
    echo "[folder]       $WORK_DIR" > $logfile

     echo "[NEW_PROCESS]" >> $logfile
     SEG_NAME="$SEG_NAME_NEW"
     OUT_SDIR="$OUT_DIR_NEW"

     echo "=====inputs=====" >> $logfile
     echo "[segmentation] $SEG_NAME" >> $logfile
     echo "[output_dir]   $OUT_SDIR" >> $logfile

     echo "====clip_MVI====" >> $logfile
     $SCRIPT_DIR/4b_create_external_clippers.sh $WORK_DIR $SEG_NAME $MVI_NAME

     echo "====scar_map====" >> $logfile
     $SCRIPT_DIR/5_calculate_scar_map.sh $WORK_DIR $SEG_NAME $OUT_SDIR


     echo "[OLD_PROCESS]" >> $logfile
     SEG_NAME="$SEG_NAME_OLD"
     OUT_SDIR="$OUT_DIR_OLD"

     echo "=====inputs=====" >> $logfile 
     echo "[segmentation] $SEG_NAME" >> $logfile
     echo "[output_dir]   $OUT_SDIR" >> $logfile

     echo "====clip_MVI====" >> $logfile
     $SCRIPT_DIR/4b_create_external_clippers.sh $WORK_DIR $SEG_NAME $MVI_NAME

     echo "====scar_map====" >> $logfile
     $SCRIPT_DIR/5_calculate_scar_map.sh $WORK_DIR $SEG_NAME $OUT_SDIR

done
