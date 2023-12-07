#!/bin/bash

SAMPLE_LIST=$1

# number of samples
NUM_SAMPLES=$2
#NUM_SAMPLES=3
((MAX_COL=$NUM_SAMPLES+2))

NUM_THREADS=$3

# calculating mean, standard deviation, and coefficient of variation for each sample (row=sample)

samtools depth -@ $NUM_THREADS -f $SAMPLE_LIST | \
awk '{for (i=3;i<='"$MAX_COL"';i++) sum[i]+=$i; \
for (i=3;i<='"$MAX_COL"';i++) sum_sq[i]+=($i)^2}\
END{for(i=3;i<='"$MAX_COL"';i++) print sum[i]/NR,"\011",\
sqrt(1/NR *sum_sq[i] - (sum[i]/NR)^2),"\011",\
(sqrt(1/NR *sum_sq[i] - (sum[i]/NR)^2))/((sum[i]+0.0001)/NR)}'

#awk '{n++; for(i=3;i<='"$MAX_COL"';i++) sum_sq[i]+=($i)^2}END{for(i=3;i<='"$MAX_COL"';i++) print sum_sq[i]/n}'



#zcat $INPUT_FILE | head -10 | awk '{n++; for(i=3;i<='"$MAX_COL"';i++) sum[i]+=$i;}END{for(i=3;i<='"$MAX_COL"';i++) print sum[i]/n,"\011",sum[i]/n}'
