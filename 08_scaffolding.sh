#!/usr/bin/env bash
#SBATCH --job-name=08scaffolding
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=12:00:00
#SBATCH --mem=10G

module load seqtk
module load samtools
module load emboss/6.6.0
module load bbmap/39.01
module load bedtools
module load bwa/0.7.17
module load picard/2.26.10
module load bowtie/1.3.1
module load salsa/2.3
module load hicexplorer
module load hic-pro/3.1.0
module load python/3.7.2

# user inputs
OUTDIR="/path/to/out"
GENOME="genome.fasta"
HAP="HaplotypeA.fasta"
GAP="gap.fasta"
TELO="FindTelomeres.py"   ####from Jana Sperschneider github

GENOME_NAME="${GENOME%.*}"
HAP_NAME="${HAP%.*}"

CONTIGDIR="${OUTDIR}/Haplotype_A"
CHRDIR="${OUTDIR}/Chromosomes_${GENOME_NAME}_HaplotypeA"
MATRIX100K="${OUTDIR}/${HAP_NAME}.100000.matrix.h5"

mkdir -p "$OUTDIR" "$CHRDIR"
cd "$OUTDIR"

# helper functions

rev_if_needed() {
    local contig="$1"
    local orient="$2"
    if [[ "$orient" == "-" ]]; then
        seqtk seq -r "${CONTIGDIR}/${contig}.fasta"
    else
        cat "${CONTIGDIR}/${contig}.fasta"
    fi
}

normalize_fasta() {
    local in="$1"
    local out="$2"
    local header="$3"

    awk '/^>/{print s? s"\n"$0:$0;s="";next}{s=s sprintf("%s",$0)}END{if(s)print s}' "$in" > tmp1
    union -sequence tmp1 -outseq tmp2
    awk '/^>/{print s? s"\n"$0:$0;s="";next}{s=s sprintf("%s",$0)}END{if(s)print s}' tmp2 > tmp3
    sed "s/>.*/>${header}/" tmp3 > "$out"

    rm -f tmp1 tmp2 tmp3
}

shorten_N_runs() {
    perl -0pi -e 's/N{500}/"N"x100/ge' "$1"
}

plot_chr() {
    local chr="$1"; shift
    hicPlotMatrix \
        --matrix "$MATRIX100K" \
        --out "${CHRDIR}/${chr}_${GENOME_NAME}.png" \
        --dpi 300 \
        --log1p \
        --chr "$@"
}

build_chr() {
    local chr="$1"; shift
    local outfile="${CHRDIR}/${chr}_${GENOME_NAME}.fasta"
    local buildfile="${CHRDIR}/${chr}_${GENOME_NAME}_build.fasta"

    : > "$buildfile"

    local first=1
    for item in "$@"; do
        local contig="${item%:*}"
        local orient="${item#*:}"

        [[ "$first" -eq 0 ]] && cat "$GAP" >> "$buildfile"
        rev_if_needed "$contig" "$orient" >> "$buildfile"
        first=0
    done

    normalize_fasta "$buildfile" "$outfile" "${chr}_A"
    shorten_N_runs "$outfile"

    stats.sh "$outfile"
    python "$TELO" "$buildfile"
    python "$TELO" "$outfile"
}

# 1. split contigs

stats.sh "$GENOME"

mkdir -p contigs
find contigs -type f -delete

seqretsplit -auto Y -sequence "$GENOME" -outseq contigs/@_tmp.fasta

# 2. haplotype A extraction

mkdir -p "$CONTIGDIR"
find "$CONTIGDIR" -type f -delete

cp contigs/h1tg* "$CONTIGDIR"/

cat "$CONTIGDIR"/*.fasta > "$HAP"
stats.sh "$HAP"

# 3. chromosome definitions

readarray -t CHR_CONFIG <<'EOF'
chr1  h1tg000004l:+ h1tg000001l:-
chr2  h1tg000003l:+
chr3  h1tg000025l:- h1tg000006l:-
chr4  h1tg000016l:+
chr5  h1tg000002l:+ h1tg000011l:+
chr6  h1tg000008l:-
chr7  h1tg000013l:-
chr8  h1tg000007l:- h1tg000034l:+ h1tg000021l:+
chr9  h1tg000019l:- h1tg000148l:- h1tg000060l:-
chr10 h1tg000020l:-
chr11 h1tg000009l:- h1tg000010l:-
chr12 h1tg000018l:+
chr13 h1tg000014l:+
chr14 h1tg000012l:-
chr15 h1tg000026l:-
chr16 h1tg000005l:+
chr17 h1tg000032l:+ h1tg000030l:-
chr18 h1tg000015l:+
EOF

# 4. build chromosomes

cd "$CHRDIR"

for line in "${CHR_CONFIG[@]}"; do
    read -r chr rest <<< "$line"
    read -r -a parts <<< "$rest"

    contigs=()
    for p in "${parts[@]}"; do
        contigs+=("${p%:*}")
    done

    echo "Building ${chr}"
    plot_chr "$chr" "${contigs[@]}"
    build_chr "$chr" "${parts[@]}"
done
