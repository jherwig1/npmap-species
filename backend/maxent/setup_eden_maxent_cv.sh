#!/bin/sh

# This should be called from maxent.sh (which is produced by do_run.sh)

# Sets up eden run in eden_maxent/.
# MaxEnt output will go into maxent_results/

mkdir eden_maxent
#mkdir maxent_results

samples_dir=$RUN_DIR/training
test_samples_dir=$RUN_DIR/test
output_dir=$RUN_DIR/maxent_results
input_dir=$RUN_DIR/maxent_results

# Create commands list for running MaxEnt via eden
i=-1
while read line; do
   # Skip first line
   if test $i -eq -1; then 
       i=0
       continue; fi
   species=$line
   fold=0
   count=$(grep -w $species $COUNTS_FILE | cut -d',' -f2)
#   if [ -z "$count" ]; then
#      continue
#   fi
   while test $fold -lt $CV_NUM_FOLDS; do

      flags="\
autorun=true \
togglelayertype=cat \
perspeciesresults=true \
askoverwrite=false \
visible=false \
skipifexists=false \
plots=false \
pictures=false \
writebackgroundpredictions=false \
removeduplicates=false \
environmentallayers=$ENV_DIR \
samplesfile=$samples_dir/$species""_$fold.csv \
testsamplesfile=$test_samples_dir/$species""_$fold.csv \
outputdirectory=$output_dir/$species/fold$fold \
"

      maxent_cmd="java -Xms512m -Xmx512m -XX:-UsePerfData -jar $MAXENT_JAR $flags"
      asc2bov_cmd="cd $output_dir/$species/fold$fold && $TOOL_DIR/asc2bov $species.asc $species  && rm $species.asc"
      echo "mkdir -p $output_dir/$species/fold$fold && $maxent_cmd && $asc2bov_cmd &" >> eden_maxent/commands.sh
      fold=$(($fold + 1))
      i=$(( $i + 1 ))

      imod=$(($i % 30))
      if test $imod -eq 0; then
         echo "wait" >> eden_maxent/commands.sh
      fi
   done
done < $CONFIG_FILE


echo 'wait' >> eden_maxent/commands.sh
# calculate appropriate ncpus; cap at 256
if test $i -gt 256; then
   ncpus=256
elif test $i -gt 32; then
   ncpus=$(( $i + ((8-$i)%8+8)%8 ))
else
   ncpus=32
fi
