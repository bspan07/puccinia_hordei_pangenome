#!/bin/bash -l
#SBATCH --job-name=addsecreted
#SBATCH --nodes=1
#SBATCH --mem=30G
#SBATCH --tmp=10G
#SBATCH --cpus-per-task=32
#SBATCH --time=24:00:00

# User settings
SAMPLE="isolate_name"
GENOME="${SAMPLE}.fasta"
GTF="${SAMPLE}_stringtie.gtf"
FUN_GFF="${SAMPLE}_funannotate.gff3"
OUTDIR="/path/to/out"

mkdir -p "${OUTDIR}"
cd "${OUTDIR}"

# Input checks
for f in "../${GENOME}" "../${GTF}" "../${FUN_GFF}"; do
    [[ -s "$f" ]] || { echo "ERROR: missing or empty input: $f" >&2; exit 1; }
done

GENOME=$(realpath "../${GENOME}")
GTF=$(realpath "../${GTF}")
FUN_GFF=$(realpath "../${FUN_GFF}")

# 1. Predict ORFs from StringTie transcript models
module load transdecoder/6.0.0

# NB it is important to use the latest version of TransDecoder so that the command works -- I also found that earlier versions of TransDecoder gave protein entries with internal stop codons.
TransDecoder --genome "${GENOME}" --gtf "${GTF}" -m 50 --single_best_only --complete_orfs_only -O "${OUTDIR}"

PEP="${OUTDIR}/$(basename "${GENOME}").transdecoder.pep"
TD_GFF3="${OUTDIR}/$(basename "${GENOME}").transdecoder.genome.gff3"

[[ -s "${PEP}" ]] || { echo "ERROR: TransDecoder peptide output not found: ${PEP}" >&2; exit 1; }
[[ -s "${TD_GFF3}" ]] || { echo "ERROR: TransDecoder GFF3 output not found: ${TD_GFF3}" >&2; exit 1; }

# 2. Predict signal peptides
module load signalp/4.1

signalp -u 0.34 -U 0.34 -m "${SAMPLE}_mature.fasta" "${PEP}" > "${SAMPLE}_signalp.txt"

[[ -s "${SAMPLE}_signalp.txt" ]] || { echo "ERROR: SignalP output missing" >&2; exit 1; }
[[ -s "${SAMPLE}_mature.fasta" ]] || { echo "ERROR: SignalP mature peptide FASTA missing" >&2; exit 1; }

# 3. Predict TM domains on mature peptides
module load tmhmm/2.0c

cat "${SAMPLE}_mature.fasta" | tmhmm > "${SAMPLE}_tmhmm.txt"

[[ -s "${SAMPLE}_tmhmm.txt" ]] || { echo "ERROR: TMHMM output missing" >&2; exit 1; }

# 4. Keep proteins with SignalP YES and TMHMM = 0 TMHs
# SignalP: keep IDs with positive signal peptide call
awk '$1 !~ /^#/ && $0 ~ /[[:space:]]Y[[:space:]]/ {print $1}' "${SAMPLE}_signalp.txt" | sort -u > "${SAMPLE}_signalp_ids.txt"

# TMHMM: keep IDs with zero predicted TM helices
awk '/^#/ && /Number of predicted TMHs:[[:space:]]+0$/ {print $2}' "${SAMPLE}_tmhmm.txt" | sort -u > "${SAMPLE}_noTM_ids.txt"

# Secreted = SignalP-positive INTERSECT no-TM
comm -12 "${SAMPLE}_signalp_ids.txt" "${SAMPLE}_noTM_ids.txt" > "${SAMPLE}_secreted_ids.txt"

if [[ ! -s "${SAMPLE}_secreted_ids.txt" ]]; then
    echo "WARNING: no secreted candidates found after SignalP/TMHMM filtering" >&2
fi

# 5. Extract matching TransDecoder records
# grep -Ff uses a file of patterns
grep -Ff "${SAMPLE}_secreted_ids.txt" "${TD_GFF3}" > "${SAMPLE}.secreted.raw.gff3" || true

# Add GFF3 header if records were found
if [[ -s "${SAMPLE}.secreted.raw.gff3" ]]; then
    {
        echo "##gff-version 3"
        cat "${SAMPLE}.secreted.raw.gff3"
    } > "${SAMPLE}.secreted.gff3"
else
    echo "##gff-version 3" > "${SAMPLE}.secreted.gff3"
fi

# 6. Merge into main annotation and clean
module load agat

# Normalize both files first; AGAT parser standardizes IDs/parents/locations
agat_convert_sp_gxf2gxf.pl -g "${FUN_GFF}" -o "${SAMPLE}_funannotate.norm.gff3"
agat_convert_sp_gxf2gxf.pl -g "${SAMPLE}.secreted.gff3" -o "${SAMPLE}.secreted.norm.gff3"

# Merge annotations
agat_sp_merge_annotations.pl --gff "${SAMPLE}_funannotate.norm.gff3" --gff "${SAMPLE}.secreted.norm.gff3" -o "${SAMPLE}_funannotate.secreted.gff3"

# Fix overlapping genes if needed
agat_sp_fix_overlaping_genes.pl -f "${SAMPLE}_funannotate.secreted.gff3" -o "${SAMPLE}_funannotate.secreted.fixed.gff3"

# Retain genes > 50 bp
agat_sp_filter_gene_by_length.pl -f "${SAMPLE}_funannotate.secreted.fixed.gff3" -o "${SAMPLE}.annotation.min50bp.gff3" --size 50 --test ">"

# Keep longest isoform
agat_sp_keep_longest_isoform.pl -f "${SAMPLE}.annotation.min50bp.gff3" -o "${SAMPLE}.annotation.longestisoform.gff3"

echo "Done."
