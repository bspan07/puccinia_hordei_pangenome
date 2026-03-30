#!/bin/bash -l
#SBATCH --job-name=mito
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --time=10:00:00

##submit as: sbatch --array=0-9 03_mito.sh isolates.txt

module load ncbi_toolkit/2.12.0

OUTDIR="/output/path"
ISOLATES="$1"               # isolates.txt
MITOFA="/path/to/mitochondrion.1.1.genomic.fna"
MITODIR="${OUTDIR}/mito"

mkdir -p "$MITODIR"
cd "$OUTDIR"

if [[ ! -f MITO.nsq ]]; then
    makeblastdb -in "$MITOFA" -dbtype nucl -out MITO
fi

mapfile -t SAMPLES < <(cut -f1 "$ISOLATES")
SAMPLE="${SAMPLES[$SLURM_ARRAY_TASK_ID]}"

blastn -query "${SAMPLE}_lowcov_removed.fa" -db MITO -dust yes -perc_identity 90 \
    -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore" |
awk '($3>=98 && $4>=50) || ($3>=94 && $4>=100) || ($3>=90 && $4>=200)' \
    > "${MITODIR}/${SAMPLE}_MITO_CONTIGS.txt"

cut -f1 "${MITODIR}/${SAMPLE}_MITO_CONTIGS.txt" | sort | uniq -c | awk '{print $2"\t"$1}' \
    > "${MITODIR}/${SAMPLE}_mito_counts.txt"

awk '
    /^>/ {name=substr($1,2); getline; print name"\t"length($0)}
' "${SAMPLE}_lowcov_removed.fa" > "${MITODIR}/${SAMPLE}_contig_lengths.txt"

awk '
    NR==FNR {len[$1]=$2; next}
    $1 in len {
        dens=$2/len[$1]
        if (dens > 0.0004) print $1
    }
' "${MITODIR}/${SAMPLE}_contig_lengths.txt" "${MITODIR}/${SAMPLE}_mito_counts.txt" \
    > "${MITODIR}/${SAMPLE}_mito_contamination.txt"

awk 'FNR==NR {bad[$1]; next} /^>/ {keep=!(substr($1,2) in bad)} keep' \
    "${MITODIR}/${SAMPLE}_mito_contamination.txt" "${SAMPLE}_lowcov_removed.fa" > "${SAMPLE}_no_mito.fa"
