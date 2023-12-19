# general_samples
This is a collection of scripts to compute and summarize information for WGS samples.
The information should include coverage, estimated sex of the individual, and relatedness between individuals.

## Coverage
To get summary statistics about mean, standard deviation and coefficient of variation (CV) of sequencing coverage the script `summary_stats_cov_job.sh` can be used on the lido-cluster. One needs to provide a list of the bam files (including their paths) that should be analyzed, the number of samples, the number of threads, and the output file name as arguments. Also, samtools needs to be installed because samtools depth is used in the script.

```sh
#!/bin/bash -l
#SBATCH --partition=med
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=07:59:00
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=300M
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
echo -e "sample\tmean\tstandard_deviation\tcoefficient_of_variation" > $OUT


# calculating mean, standard deviation, and coefficient of variation for each sample (row=sample in samtools depth output stream)

T0=$(date +%T)
echo "Start data processing:"
echo $T0

conda activate samtools

samtools depth -H -@ $NUM_THREADS -f $SAMPLE_LIST | \
awk 'NR==1{OFS=FS="\t";for (i=3;i<='"$MAX_COL"';i++) samples[i]=$i}{for (i=3;i<='"$MAX_COL"';i++) sum[i]+=$i; \
for (i=3;i<='"$MAX_COL"';i++) sum_sq[i]+=($i)^2}\
END{for(i=3;i<='"$MAX_COL"';i++) print samples[i]"\011"\
sum[i]/NR"\011"\
sqrt(1/NR *sum_sq[i] - (sum[i]/NR)^2)"\011"\
(sqrt(1/NR *sum_sq[i] - (sum[i]/NR)^2))/((sum[i]+0.0001)/NR)}' >> $OUT

conda deactivate

T1=$(date +%T)
echo "Finished data processing:"
echo $T1
```

## Sexing
To sex the samples I wrote a lido job script ``cov_ratio_job.sh that 1) calculates the average coverage over a "typical" chromosome (chromosome 3: NC_031770.1) and 2) also over the Z chromosome (NC_031799.1), and then calculates the ratio coverage chromosome Z over coverage chromosome 3. Since in birds males have ZZ and females have WZ (and therefore only one copy of the the Z chromsome), the ratio of Z over chromosome 3 will be around 0.5 in females and around 1.0 in males. This method seems to work well in the great tit samples analyzed so far.

```sh
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
echo "sample\tcov_NC_031770.1\tcov_NC_031799.1\tratio_Z_over_3" > $OUT
#echo -e "sample\tcov_NC_031770.1\tcov_NC_031799.1\tratio_Z_over_3" > $OUT

# get average coverage for "typical" chromosome 3 = NC_031770.1 and Z chromosome
samtools depth -H -@ $NUM_THREADS -f $SAMPLE_LIST | \
awk 'NR==1{OFS=FS="\t";for (i=3;i<='"$MAX_COL"';i++) samples[i]=$i}\
$1=="NC_031770.1"{j++; for (i=3;i<='"$MAX_COL"';i++) sum_3[i]+=$i} \
$1=="NC_031799.1"{k++; for (i=3;i<='"$MAX_COL"';i++) sum_z[i]+=$i}\
END{for(i=3;i<='"$MAX_COL"';i++) print samples[i]"\011"\
sum_3[i]/(j+0.0001)"\011"\
sum_z[i]/(k+0.0001)"\011"\
(sum_z[i]/(k+0.0001))/((sum_3[i]/(j+0.0001))+0.0001)}' >> $OUT


conda deactivate

T1=$(date +%T)
echo "Finished data processing:"
echo $T1

echo "done"
```

