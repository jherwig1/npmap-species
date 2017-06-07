#!/bin/sh

# do_run.sh
#
# This is the 'meta-script' for producing other scripts to run the workflow.
# It produces:
#   preprocess.sh - creates species input files for cross-validation
#   maxent.sh - sets up and runs maxent via eden
#   postprocess.sh - post-processing and aggregation of maxent results
#   visit.sh - sets up  and runs visit via eden to generate new pngs of sdms

RUN_DIR=$(pwd)

#------------------------------------------------------------------------
# Configuration settings--SET APPROPRIATE PATHS HERE FOR YOUR ENVIRONMENT
TOOL_DIR=/mnt/data/jherwig1/npmap-species/backend/maxent
MAXENT_JAR=$TOOL_DIR/maxent.jar
CONFIG_FILE=/mnt/data/jherwig1/npmap-species/twincreekscode/maxent_config/config_one.txt
CV_NUM_FOLDS=$(head $CONFIG_FILE -n 1)
CV=true
COUNTS_FILE=/mnt/data/jherwig1/npmap-species/atbirecords/ATBI_counts.txt
RECORDS_DIR=/mnt/data/jherwig1/npmap-species/atbirecords/ATBI_files
ENV_DIR=/mnt/data/jherwig1/npmap-species/environmentallayers/mxe
ENV_PICK=all
GDAL_BIN=/home/jherwig1/gdal/bin
GEOTIFF_DIR=$RUN_DIR/geotiffs
#------------------------------------------------------------------------

if test $CV_NUM_FOLDS -gt 20 || test $CV_NUM_FOLDS -lt 2; then
   echo 'num_folds must be an integer in [2-20]'
   exit 1
fi

# clean up previous run's output
rm -rf eden*

# make pre-process script
echo "#!/bin/sh
export RUN_DIR=$RUN_DIR
export TOOL_DIR=$TOOL_DIR
export CONFIG_FILE=$CONFIG_FILE
export COUNTS_FILE=$COUNTS_FILE
export RECORDS_DIR=$RECORDS_DIR
export CV_NUM_FOLDS=$CV_NUM_FOLDS

" > preprocess.sh

if test $CV = false; then
   echo "echo 'Running separate_species.sh'" >> preprocess.sh
   echo "$TOOL_DIR/separate_species.sh > counts.txt" >> preprocess.sh

else
   #echo "echo 'Running separate.py'" >> preprocess.sh
   #echo "python $TOOL_DIR/separate.py $RECORDS_FILE" >> preprocess.sh
   echo "echo 'Running setup_eden_folds.sh'" >> preprocess.sh
   echo "$TOOL_DIR/setup_eden_folds.sh" >> preprocess.sh
   echo "chmod u+x $TOOL_DIR/eden_folds/commands.sh" >> preprocess.sh
   echo "echo 'Running eden job in eden_folds/'" >> preprocess.sh
   echo "eden_folds/commands.sh" >> preprocess.sh
fi

chmod u+x preprocess.sh

# make maxent script
echo "#!/bin/sh
export RUN_DIR=$RUN_DIR
export TOOL_DIR=$TOOL_DIR
export CONFIG_FILE=$CONFIG_FILE
export COUNTS_FILE=$COUNTS_FILE
export MAXENT_JAR=$MAXENT_JAR
export ENV_DIR=$ENV_DIR
export CV_NUM_FOLDS=$CV_NUM_FOLDS

" > maxent.sh

if test $CV = false; then
   echo "echo 'Running setup_eden_maxent.sh'" >> maxent.sh
   echo "$TOOL_DIR/setup_eden_maxent.sh" >> maxent.sh

else
   echo "echo 'Running setup_eden_maxent_cv.sh'" >> maxent.sh
   echo "$TOOL_DIR/setup_eden_maxent_cv.sh" >> maxent.sh
   
fi
echo "chmod u+x $TOOL_DIR/eden_maxent/commands.sh" >> maxent.sh
echo "echo 'Running eden job in eden_maxent/'" >> maxent.sh
echo "eden_maxent/commands.sh" >> maxent.sh
chmod u+x maxent.sh


# make postprocess script if doing cross validation
if test $CV = true; then
   
    echo "#!/bin/sh
export RUN_DIR=$RUN_DIR
export TOOL_DIR=$TOOL_DIR
export CONFIG_FILE=$CONFIG_FILE
export COUNTS_FILE=$COUNTS_FILE
export MAXENT_JAR=$MAXENT_JAR
export ENV_DIR=$ENV_DIR
export GDAL_BIN=$GDAL_BIN
export GEOTIFF_DIR=$GEOTIFF_DIR
export CV_NUM_FOLDS=$CV_NUM_FOLDS

" > postprocess.sh

    echo "echo 'Running setup_eden_aggregate.sh'" >> postprocess.sh
    echo "$TOOL_DIR/setup_eden_aggregate.sh" >> postprocess.sh
    echo "chmod u+x $TOOL_DIR/eden_aggregate/commands.sh" >> postprocess.sh
    echo "echo 'Running eden job in eden_aggregate/'" >> postprocess.sh
    echo "eden_aggregate/commands.sh" >> postprocess.sh

    chmod u+x postprocess.sh
fi

# make visit script
echo "#!/bin/sh
export RUN_DIR=$RUN_DIR
export TOOL_DIR=$TOOL_DIR
export CONFIG_FILE=$CONFIG_FILE
export ACCOUNT=$ACCOUNT

" > visit.sh
if test $CV = true; then
   #echo "echo 'Running make_filelist.sh'" >> visit.sh
   #echo "$TOOL_DIR/make_filelist.sh > filelist" >> visit.sh
   echo "echo 'Running setup_eden_visit.sh'" >> visit.sh
   echo "$TOOL_DIR/setup_eden_visit.sh" >> visit.sh
   echo "echo -n '#PBS -W depend=afterok:' >> eden_visit/header.pbs" >> visit.sh
   echo "cat $JOBID_FILE | grep nics.utk.edu >> eden_visit/header.pbs" >> visit.sh
   echo "cat eden_visit/footer.pbs >> eden_visit/header.pbs" >> visit.sh
   
   echo "echo 'Running eden job in eden_visit/'" >> visit.sh
   echo "eden eden_visit > $JOBID_FILE" >> visit.sh
fi
chmod u+x visit.sh
