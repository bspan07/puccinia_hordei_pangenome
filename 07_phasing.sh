#!/usr/bin/env bash
#SBATCH --job-name=07_phasing
#SBATCH --time=4:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --mem=10G

# Define paths
OUTDIR="/output/path"
GENOME="genome_file.fasta"
HIC_DATA="/path/to/HiC_data"
HICPRO_PY="/path/to/HiCProConfFile.py"
DIGEST_PY="hic-pro/3.1.0/HiC-Pro-master/bin/utils/digest_genome.py"

HICPRO_RUN="output_nested_folder_name"
CONF="hicpro.conf"
MATRIX_OUT="/path/where_you_want/output_to_go/isolate_name.20000.matrix"

BUSCO_DB="/pathto/basidiomycota_odb9"
BUSCO_PREFIX="output_name_prefix"
AUGUSTUS_BASE="/PATH/augustus"

BIOKANGA_DIR="/PATH_to/biokanga_index"
BIOKANGA_PREFIX="annotation_output_prefix"
BIOKANGA_QUERY="/Path_to/annotations_from_same_species.fasta"
BIOKANGA_OUT="/output/path/biokanga_blitz_output_file_name.txt"

BUSCO_TABLE_COPY="/path/to/safe/place/useful_filename.tsv"

NUCLEARPHASER_PY="/path/to/install_of/NuclearPhaser/NuclearPhaser.py"
NUCLEARPHASER_OUT="${OUTDIR}/nuclearphaser_output_folder_name"
NUCLEARPHASER_LOG="/path_for/logfile/NuclearPhaser.log"

############################
# Derived names
############################
mkdir -p "$OUTDIR"
cd "$OUTDIR"

GENOME_BASENAME="$(basename "$GENOME" .fasta)"
HICPRO_OUT="${OUTDIR}/${HICPRO_RUN}"

# 1. Hi-C mapping with HiC-Pro

module load hic-pro/3.1.0
module load python/3.7.2

python "$HICPRO_PY" "$GENOME" 10 "$HICPRO_OUT" > "$CONF"
sed -i 's/N_CPU = 2/N_CPU = 16/' "$CONF"

mkdir -p "$HICPRO_OUT"
cp "$GENOME" "$HICPRO_OUT/"
cd "$HICPRO_OUT"

# Restriction digest BED
# DpnII, DdeI, HinfI, MseI
"$DIGEST_PY" -r '^GATC' 'C^TNAG' 'G^ANTC' 'T^TAA' -o "${GENOME_BASENAME}.bed" "$GENOME"

# Genome index files
bowtie2-build "$GENOME" "$GENOME_BASENAME"
samtools faidx "$GENOME"
cut -f1,2 "${GENOME}.fai" > "${GENOME_BASENAME}.sizes"

rm -rf "./${HICPRO_RUN}"

# HiC-Pro expects HiC_data/sample1/*_R1.fastq.gz and *_R2.fastq.gz structure
HiC-Pro -i "$HIC_DATA" -o "./${HICPRO_RUN}" -c "../${CONF}"

cd "$OUTDIR"

# 2. Convert HiC-Pro matrix

##module load hicexplorer
module load conda
source activate hicexplorer

hicConvertFormat \
  --matrices "${HICPRO_RUN}/${HICPRO_RUN}/hic_results/matrix/rawdata/iced/20000/rawdata_20000_iced.matrix" \
  --inputFormat hicpro \
  --outputFormat ginteractions \
  --outFileName "$MATRIX_OUT" \
  --bedFileHicpro "${HICPRO_RUN}/${HICPRO_RUN}/hic_results/matrix/rawdata/raw/20000/rawdata_20000_abs.bed"

# 3. BUSCO

module load busco/3.0.2

mkdir -p "${AUGUSTUS_BASE}"
cp -r /apps/augustus/3.3.3/config "${AUGUSTUS_BASE}/config"
export AUGUSTUS_CONFIG_PATH="${AUGUSTUS_BASE}/config"

rm -rf tmp

run_BUSCO.py \
  -f \
  -i "$GENOME" \
  -o "$BUSCO_PREFIX" \
  -l "$BUSCO_DB" \
  -m geno \
  -sp coprinus \
  -c 4

cp "${OUTDIR}/run_${BUSCO_PREFIX}/full_table_${BUSCO_PREFIX}.tsv" "$BUSCO_TABLE_COPY"

# 4. Biokanga

module load biokanga/4.4.2
module load samtools

mkdir -p "$BIOKANGA_DIR"

biokanga index \
  --threads=16 \
  -i "$GENOME" \
  -o "${BIOKANGA_DIR}/${BIOKANGA_PREFIX}" \
  -r gene_mapping

biokanga blitz \
  --sensitivity=2 \
  --mismatchscore=1 \
  --threads=16 \
  -o "$BIOKANGA_OUT" \
  --in="$BIOKANGA_QUERY" \
  --sfx="${BIOKANGA_DIR}/${BIOKANGA_PREFIX}"

# 5. NuclearPhaser

module load python/3.9.4
module load minimap2

echo "Start phasing"

python "$NUCLEARPHASER_PY" \
  "$BIOKANGA_OUT" \
  "$BUSCO_TABLE_COPY" \
  "${MATRIX_OUT}.tsv" \
  "$GENOME" \
  "$NUCLEARPHASER_OUT" \
  > "$NUCLEARPHASER_LOG"
