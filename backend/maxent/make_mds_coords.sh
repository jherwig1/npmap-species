#!/bin/sh

TOOL_DIR=/home/jherwig1/npmap-species/backend/maxent
RESULTS_DIR=maxent_results
NUM_SPECIES=$(wc -l filelist | cut -d' ' -f1)
NUM_THREADS=$1

$TOOL_DIR/ssi $NUM_SPECIES filelist $NUM_THREADS
ls $RESULTS_DIR | $TOOL_DIR/convert_matrix matrix.dat $NUM_SPECIES > matrix.csv
Rscript $TOOL_DIR/make_mds_coords.R
$TOOL_DIR/convert_coords mds_coords.txt $NUM_SPECIES > coords.txt
