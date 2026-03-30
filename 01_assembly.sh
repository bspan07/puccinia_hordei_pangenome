#!/bin/bash -l
#SBATCH --job-name=hifiasm
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --mem=80G
#SBATCH --time=8:00:00

module load hifiasm/0.24.0
module load bbmap/39.01

OUTDIR="/output/path"
READS="/path/to/hifi/reads/reads.fasta"
HIC1="/path/to/Hi-C/R1.fastq.gz"
HIC2="/path/to/Hi-C/R2.fastq.gz"
PREFIX="phordei_isolate.asm"
THREADS=32

mkdir -p "$OUTDIR"
cd "$OUTDIR"

hifiasm -o "$PREFIX" -t "$THREADS" "$READS" --h1 "$HIC1" --h2 "$HIC2"

awk '/^S/{print ">"$2"\n"$3}' "${PREFIX}.hic.hap1.p_ctg.gfa" > "${PREFIX}.hic.hap1.p_ctg.fa"
awk '/^S/{print ">"$2"\n"$3}' "${PREFIX}.hic.hap2.p_ctg.gfa" > "${PREFIX}.hic.hap2.p_ctg.fa"

stats.sh in="${PREFIX}.hic.hap1.p_ctg.fa" out="${PREFIX}.hap1.stats.txt"
stats.sh in="${PREFIX}.hic.hap2.p_ctg.fa" out="${PREFIX}.hap2.stats.txt"
