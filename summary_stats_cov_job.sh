#!/bin/bash -l
#SBATCH --partition=med
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=07:59:00 
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=1G
#SBATCH --job-name=summary_stats_cov_job
#SBATCH --mail-user=nikolas.vellnow@tu-dortmund.de
#SBATCH --mail-type=All

SAMPLE_LIST=$1

# number of samples
NUM_SAMPLES=$2
#NUM_SAMPLES=3
((MAX_COL=$NUM_SAMPLES+2))

# type in output file name
OUT=$3

NUM_THREADS=20

touch $OUT

# calculating mean, standard deviation, and coefficient of variation for each sample (row=sample in samtools depth output stream)

T0=$(date +%T)
echo "Start data processing:"
echo $T0

conda activate samtools

samtools depth -@ $NUM_THREADS -f $SAMPLE_LIST | \
awk '{for (i=3;i<='"$MAX_COL"';i++) sum[i]+=$i; \
for (i=3;i<='"$MAX_COL"';i++) sum_sq[i]+=($i)^2}\
END{for(i=3;i<='"$MAX_COL"';i++) print sum[i]/NR,"\011",\
sqrt(1/NR *sum_sq[i] - (sum[i]/NR)^2),"\011",\
(sqrt(1/NR *sum_sq[i] - (sum[i]/NR)^2))/((sum[i]+0.0001)/NR)}' > $OUT

conda deactivate

T1=$(date +%T)
echo "Finished data processing:"
echo $T1
