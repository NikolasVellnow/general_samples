#!/bin/bash -l
#SBATCH --partition=med
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=06:30:00
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=300M
#SBATCH --job-name=cov_ratio_job
#SBATCH --mail-user=nikolas.vellnow@tu-dortmund.de
#SBATCH --mail-type=All

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

T0=$(date +%T)
echo "Start data processing:"
echo $T0

conda activate samtools

# write header
#echo "sample\tcov_NC_031770.1\tcov_NC_031799.1\tratio_Z_over_3" > $OUT
echo -e "sample\tcov_mt_NC_040875.1\tcov_NC_031770.1\tcov_NC_031799.1\tratio_Z_over_3" > $OUT

# get average coverage for "typical" chromosome 3 = NC_031770.1 and Z chromosome
samtools depth -H -@ $NUM_THREADS -f $SAMPLE_LIST | \
awk 'NR==1{OFS=FS="\t";for (i=3;i<='"$MAX_COL"';i++) samples[i]=$i}\
$1=="NC_031770.1"{j++; for (i=3;i<='"$MAX_COL"';i++) sum_3[i]+=$i} \
$1=="NC_031799.1"{k++; for (i=3;i<='"$MAX_COL"';i++) sum_z[i]+=$i}\
$1=="NC_040875.1"{l++; for (i=3;i<='"$MAX_COL"';i++) sum_mt[i]+=$i}\
END{for(i=3;i<='"$MAX_COL"';i++) print samples[i]"\011"\
sum_mt[i]/(l+0.0001)"\011"\
sum_3[i]/(j+0.0001)"\011"\
sum_z[i]/(k+0.0001)"\011"\
(sum_z[i]/(k+0.0001))/((sum_3[i]/(j+0.0001))+0.0001)}' >> $OUT


conda deactivate

T1=$(date +%T)
echo "Finished data processing:"
echo $T1

echo "done"

