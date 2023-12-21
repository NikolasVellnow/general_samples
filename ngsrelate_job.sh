#!/bin/bash -l
#SBATCH --partition=med
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=3G
#SBATCH --job-name=ngsrelate_job
#SBATCH --mail-user=nikolas.vellnow@tu-dortmund.de
#SBATCH --mail-type=All

# type in path to text file with list of samples
SAMPLE_LIST=$1

# type in output file name
OUT=$2

# number of samples
NUM_SAMPLES=$3

# number of threads used in angsd and ngsrelate
NUM_THREADS=$4

touch $OUT

T0=$(date +%T)
echo "Start data processing:"
echo $T0

conda activate angsd

angsd -b $SAMPLE_LIST -r NC_031770.1 -gl 2 -domajorminor 1 -snp_pval 1e-6 -domaf 1 -minmaf 0.05 -doGlf 3 -P $NUM_THREADS

zcat angsdput.mafs.gz | cut -f5 | sed 1d > freqs

ngsRelate -p $NUM_THREADS -g angsdput.glf.gz -n $NUM_SAMPLES -f freqs -O $OUT


conda deactivate

T1=$(date +%T)
echo "Finished data processing:"
echo $T1

echo "done"

