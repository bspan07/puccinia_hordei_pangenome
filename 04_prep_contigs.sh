#!/bin/bash -l
#SBATCH --job-name=prep_contigs
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --time=2:00:00

##submit as: sbatch 04_prep_contigs.sh isolates.txt
###This is to separate assembly into its constituent contigs which in the next script are aligned to the NCBI nucleotide database to look for contaminants.
OUTDIR="/output/path"
ISOLATES="$1"

cd "$OUTDIR"
mkdir -p contigs
cd contigs

mapfile -t SAMPLES < <(cut -f1 "$ISOLATES")

for s in "${SAMPLES[@]}"; do
    awk -v sample="$s" '
        /^>/ {
            if (out) close(out)
            out=sample";"substr($0,2)".fasta"
        }
        {print >> out}
    ' "../${s}_no_mito.fa"
done

find . -maxdepth 1 -name "*.fasta" -printf "%f\n" | sed 's/\.fasta$//' > all_tiglist.txt
