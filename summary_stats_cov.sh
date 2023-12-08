#!/bin/bash

SAMPLE_LIST=$1

# number of samples
NUM_SAMPLES=$2
#NUM_SAMPLES=3
((MAX_COL=$NUM_SAMPLES+2))

NUM_THREADS=$3

# type in output file name
OUT=$4

# calculating mean, standard deviation, and coefficient of variation for each sample (row=sample)

touch $OUT

T0=$(date +%T)
echo "Start data processing:"
echo $T0

samtools depth -H -@ $NUM_THREADS -f $SAMPLE_LIST | \
awk 'NR==1{OFS=FS="\t";for (i=3;i<='"$MAX_COL"';i++) samples[i]=$i}{for (i=3;i<='"$MAX_COL"';i++) sum[i]+=$i; \
for (i=3;i<='"$MAX_COL"';i++) sum_sq[i]+=($i)^2}\
END{for(i=3;i<='"$MAX_COL"';i++) print samples[i],"\011",\
sum[i]/NR,"\011",\
sqrt(1/NR *sum_sq[i] - (sum[i]/NR)^2),"\011",\
(sqrt(1/NR *sum_sq[i] - (sum[i]/NR)^2))/((sum[i]+0.0001)/NR)}' > $OUT


T1=$(date +%T)
echo "Finished data processing:"
echo $T1
