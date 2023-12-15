#!/bin/bash

# type in path to text file with list of samples
SAMPLE_LIST=$1

# type in output file name
OUT=$2

# number of samples
NUM_SAMPLES=$3
((MAX_COL=$NUM_SAMPLES+2))


# number of threads used in samtools
NUM_THREADS=$4

touch $OUT
# write header
echo "sample\tcov_NC_031770.1\tcov_NC_031799.1\tratio_Z_over_3" > $OUT
#echo -e "sample\tcov_NC_031770.1\tcov_NC_031799.1\tratio_Z_over_3" > $OUT

# get average coverage for "typical" chromosome 3 = NC_031770.1
samtools depth -H -@ $NUM_THREADS -f $SAMPLE_LIST | \
awk 'NR==1{OFS=FS="\t";for (i=3;i<='"$MAX_COL"';i++) samples[i]=$i}\
$1=="NC_031770.1"{n_3++; for (i=3;i<='"$MAX_COL"';i++) sum_3[i]+=$i} \
$1=="NC_031799.1"{n_z++; for (i=3;i<='"$MAX_COL"';i++) sum_z[i]+=$i}\
END{for(i=3;i<='"$MAX_COL"';i++) print samples[i]"\011"\
sum_3[i]/n_z"\011"\
sum_z[i]/n_3"\011"\
(((sum_3[i]/n_z)+0.0001)/((sum_z[i]/n_3)+0.0001))}' >> $OUT
#awk '{n++; for(i=3;i<='"$MAX_COL"';i++) sum[i]+=$i;}END{for(i=3;i<='"$MAX_COL"';i++) print "NC_031770.1","\011",sum[i]/n}' > $OUT


echo "done"

