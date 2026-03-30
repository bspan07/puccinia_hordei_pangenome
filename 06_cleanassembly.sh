#!/bin/bash -l
#SBATCH --job-name=clean_assembly
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --time=4:00:00
#SBATCH --mail-type=END,FAIL

##submit as: sbatch 06_cleanassembly.sh isolates.txt
module load bbmap/39.01

OUTDIR="/output/path"
ISOLATES="$1"

cd "${OUTDIR}/contigs"

grep_terms='Puccinia|Phakopsora|psidii|Melamps|Uromyces|ribosomal|Medioppia'

: > keep_contigs.txt
: > CONTAM_FOR_CHECKING.txt

for f in *_blast_results.txt *_DC_blast_results.txt; do
    [[ -e "$f" ]] || continue

    base=$(basename "$f")
    contig=$(echo "$base" | sed 's/_blast_results.txt//' | sed 's/_DC_blast_results.txt//' | sed 's/_DC$//')

    if [[ ! -s "$f" ]]; then
        echo "$contig" >> keep_contigs.txt
        continue
    fi

    first_line=$(head -n1 "$f")

    if echo "$first_line" | grep -Eq "$grep_terms"; then
        echo "$contig" >> keep_contigs.txt
    else
        echo -e "${contig}\t${first_line}" >> CONTAM_FOR_CHECKING.txt
    fi
done

sort -u keep_contigs.txt -o keep_contigs.txt

# Optional manual rescue step
[[ -f mistake_contigs.txt ]] && cat mistake_contigs.txt >> keep_contigs.txt
sort -u keep_contigs.txt -o keep_contigs.txt

cd "$OUTDIR"
mapfile -t SAMPLES < <(cut -f1 "$ISOLATES")

for s in "${SAMPLES[@]}"; do
    grep "^${s};" contigs/keep_contigs.txt | cut -d';' -f2 > "${s}_keep_contigs_final.txt"

    awk 'FNR==NR {good[$1]; next} /^>/ {keep=(substr($1,2) in good)} keep' \
        "${s}_keep_contigs_final.txt" "${s}_no_mito.fa" > "${s}_cleaned.fa"

    stats.sh in="${s}_cleaned.fa" out="${s}_cleaned.stats.txt"
done
