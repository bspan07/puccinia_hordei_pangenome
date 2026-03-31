#!/bin/bash -l
#SBATCH --job-name=lowcov
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --time=12:00:00

##NB: since the coverage threshold needs to be defined per isolate, this cannot be run as an array.

module load minimap2/2.30
module load bbmap/39.01

OUTDIR="/output/path"
SAMPLE="isolate_name"
####LOWCOV value should be modified depending on coverage distribution of isolate
LOWCOV=5

cd "$OUTDIR"

cat "${SAMPLE}.asm.hic.hap1.p_ctg.fa" "${SAMPLE}.asm.hic.hap2.p_ctg.fa" > "${SAMPLE}_combined.fasta"

minimap2 -ax map-hifi "${SAMPLE}_combined.fasta" "${SAMPLE}_reads.fasta" > "${SAMPLE}.sam"

pileup.sh in="${SAMPLE}.sam" out="${SAMPLE}_pileup.txt"

awk -v x="$LOWCOV" '$2 <= x {print $1}' "${SAMPLE}_pileup.txt" > "${SAMPLE}_low_cov.txt"

awk 'FNR==NR {bad[$1]; next} /^>/ {keep=!(substr($1,2) in bad)} keep' \
    "${SAMPLE}_low_cov.txt" "${SAMPLE}_combined.fasta" > "${SAMPLE}_lowcov_removed.fa"
