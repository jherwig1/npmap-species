#!/bin/sh

# This should be called from preprocess.sh (which is created by do_run.sh)
# when cross-validation is needed.

# Create run directory for eden run
mkdir $RUN_DIR/test
mkdir $RUN_DIR/training
mkdir $RUN_DIR/eden_folds

# Make command list for running make_folds on each species.
#  Use info from counts.txt to produce correct arguments for make_folds.
i=-1
while read line; do
   i=$(($i + 1))
   # Skip first line
   if test $i -eq 0; then continue; fi
   species=$line
   echo "SPECIES = $species"
   count=$(grep -w $species $COUNTS_FILE | cut -d',' -f2)
   echo "count = $count"
   if [ -z "$count" ]; then
      echo "species = $species"
      i=$(($i -1))
      continue
   fi
   echo "cd $RUN_DIR; $TOOL_DIR/make_folds $RECORDS_DIR/$species.csv $count $CV_NUM_FOLDS &" >> eden_folds/commands.sh

   imod=$(($i % 20))
   if test $imod -eq 0; then
      echo 'wait' >> eden_folds/commands.sh
   fi

done < $CONFIG_FILE

echo 'wait' >> eden_folds/commands.sh
