#!/bin/bash -l
#SBATCH --job-name=contam_blast
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --time=48:00:00
#SBATCH --mail-type=END,FAIL

##to check number of contigs: wc -l /output/path/contigs/all_tiglist.txt
###submit as: sbatch --array=0-642 05_contam.sh

module load ncbi_toolkit/25.2.0

OUTDIR="/output/path"
TIGLIST="${OUTDIR}/contigs/all_tiglist.txt"

cd "${OUTDIR}/contigs"

mapfile -t TIGS < "$TIGLIST"
TIG="${TIGS[$SLURM_ARRAY_TASK_ID]}"

blastn -query "${TIG}.fasta" -db nt -evalue 1e-2 -perc_identity 50 \
    -outfmt "6 qseqid sseqid pident length evalue bitscore sacc staxids sscinames scomnames stitle" \
    > "${TIG}_blast_results.txt"

if [[ ! -s "${TIG}_blast_results.txt" ]]; then
    blastn -task dc-megablast -query "${TIG}.fasta" -db nt -evalue 1e-5 -perc_identity 50 \
        -outfmt "6 qseqid sseqid pident length evalue bitscore sacc staxids sscinames scomnames stitle" \
        > "${TIG}_DC_blast_results.txt"
fi
