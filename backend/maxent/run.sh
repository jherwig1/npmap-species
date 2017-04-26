#!/bin/bash -l

echo $(date) > start_time.txt
echo $(date +%s) > start_secs.txt

#. /usr/share/modules/init/bash
./do_run.sh && \
./preprocess.sh && \
./maxent.sh &&
#./postprocess.sh
#./visit.sh

echo $(date) > end_time.txt
echo $(date +%s) > end_secs.txt

#eval "qsub visit.pbs -W depend=afterok:$(cat current_eden_job.txt | grep nics.utk.edu) > current_eden_job.txt" && \
