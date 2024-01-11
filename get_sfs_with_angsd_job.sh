#!/bin/bash -l
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=0-16:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=3G
#SBATCH --job-name=get_sfs_with_angsd_job
#SBATCH --mail-user=nikolas.vellnow@tu-dortmund.de
#SBATCH --mail-type=All

# type in path to text file with list of samples
SAMPLE_LIST=$1

# type in output file name
OUT=$2

# number of threads used in angsd
NUM_THREADS=$3

# path to reference genome
PATH_REF=/home/mnikvell/Desktop/work/data/genomes/refseq/vertebrate_other/GCF_001522545.3/GCF_001522545.3_Parus_major1.1_genomic.fna

touch $OUT

T0=$(date +%T)
echo "Start data processing:"
echo $T0

conda activate angsd

angsd \
-b $SAMPLE_LIST \
-rf regions_sfs.txt \
-doSaf 1 \
-out $OUT \
-anc $PATH_REF \
-GL 2 \
-minMapQ 30 \
-minQ 20 \
-P $NUM_THREADS

realSFS "${OUT}".saf.idx -fold 1 -maxIter 100 -P $NUM_THREADS > "${OUT}".sfs


conda deactivate

T1=$(date +%T)
echo "Finished data processing:"
echo $T1

echo "done"

