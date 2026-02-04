#!/bin/bash -l
#SBATCH --job-name=syntenyplot
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=10GB
#SBATCH --time=12:00:00

module load minimap2
module load samtools

minimap2 -ax asm5 -t 4 --eqx TX94-4_hapA.fasta 15CA06C_hapA.fasta -o TxA-CaA.sam
samtools view -Sb TxA-CaA.sam | samtools sort -O BAM -o TxA-CaA.bam
samtools index TxA-CaA.bam

minimap2 -ax asm5 -t 4 --eqx 15CA06C_hapA.fasta TX94-4_hapB.fasta -o CaA-TxB.sam
samtools view -Sb CaA-TxB.sam | samtools sort -O BAM -o CaA-TxB.bam
samtools index CaA-TxB.bam

minimap2 -ax asm5 -t 4 --eqx TX94-4_hapB.fasta 15CA06C_hapB.fasta -o TxB-CaB.sam
samtools view -Sb TxB-CaB.sam | samtools sort -O BAM -o TxB-CaB.bam
samtools index TxB-CaB.bam

minimap2 -ax asm5 -t 4 --eqx 15CA06C_hapB.fasta VA93-27_hapB.fasta -o CaB-VaB.sam
samtools view -Sb CaB-VaB.sam | samtools sort -O BAM -o CaB-VaB.bam
samtools index CaB-VaB.bam

minimap2 -ax asm5 -t 4 --eqx VA93-27_hapB.fasta 17MN32B_hapB.fasta -o VaB-MnB.sam
samtools view -Sb VaB-MnB.sam | samtools sort -O BAM -o VaB-MnB.bam
samtools index VaB-MnB.bam

minimap2 -ax asm5 -t 4 --eqx 17MN32B_hapB.fasta VA93-27_hapC.fasta -o MnB-VaC.sam
samtools view -Sb MnB-VaC.sam | samtools sort -O BAM -o MnB-VaC.bam
samtools index MnB-VaC.bam

minimap2 -ax asm5 -t 4 --eqx VA93-27_hapC.fasta 17MN32B_hapC.fasta -o VaC-MnC.sam
samtools view -Sb VaC-MnC.sam | samtools sort -O BAM -o VaC-MnC.bam
samtools index VaC-MnC.bam

minimap2 -ax asm5 -t 4 --eqx 17MN32B_hapC.fasta VA82_hapD.fasta -o MnC-VaD.sam
samtools view -Sb MnC-VaD.sam | samtools sort -O BAM -o MnC-VaD.bam
samtools index MnC-VaD.bam

minimap2 -ax asm5 -t 4 --eqx VA82_hapD.fasta WA92-74_hapD.fasta -o VaD-WaD.sam
samtools view -Sb VaD-WaD.sam | samtools sort -O BAM -o VaD-WaD.bam
samtools index VaD-WaD.bam

minimap2 -ax asm5 -t 4 --eqx WA92-74_hapD.fasta VA82_hapE.fasta -o WaD-VaE.sam
samtools view -Sb WaD-VaE.sam | samtools sort -O BAM -o WaD-VaE.bam
samtools index WaD-VaE.bam

minimap2 -ax asm5 -t 4 --eqx VA82_hapE.fasta WA92-74_hapE.fasta -o VaE-WaE.sam
samtools view -Sb VaE-WaE.sam | samtools sort -O BAM -o VaE-WaE.bam
samtools index VaE-WaE.bam

minimap2 -ax asm5 -t 4 --eqx WA92-74_hapE.fasta ISR90-3_hapF.fasta -o WaE-IsrF.sam
samtools view -Sb WaE-IsrF.sam | samtools sort -O BAM -o WaE-IsrF.bam
samtools index WaE-IsrF.bam

minimap2 -ax asm5 -t 4 --eqx ISR90-3_hapF.fasta ISR90-3_hapG.fasta -o IsrF-IsrG.sam
samtools view -Sb IsrF-IsrG.sam | samtools sort -O BAM -o IsrF-IsrG.bam
samtools index IsrF-IsrG.bam

minimap2 -ax asm5 -t 4 --eqx ISR90-3_hapG.fasta CHI_hapH.fasta -o IsrG-ChiH.sam
samtools view -Sb IsrG-ChiH.sam | samtools sort -O BAM -o IsrG-ChiH.bam
samtools index IsrG-ChiH.bam

minimap2 -ax asm5 -t 4 --eqx CHI_hapH.fasta CHI_hapI.fasta -o ChiH-ChI.sam
samtools view -Sb ChiH-ChI.sam | samtools sort -O BAM -o ChiH-ChI.bam
samtools index ChiH-ChI.bam

minimap2 -ax asm5 -t 4 --eqx CHI_hapI.fasta GER5_hapJ.fasta -o ChI-GerJ.sam
samtools view -Sb ChI-GerJ.sam | samtools sort -O BAM -o ChI-GerJ.bam
samtools index ChI-GerJ.bam

minimap2 -ax asm5 -t 4 --eqx GER5_hapJ.fasta GER5_hapK.fasta -o GerJ-GerK.sam
samtools view -Sb GerJ-GerK.sam | samtools sort -O BAM -o GerJ-GerK.bam
samtools index GerJ-GerK.bam

minimap2 -ax asm5 -t 4 --eqx GER5_hapK.fasta NLD202_hapL.fasta -o GerK-NldL.sam
samtools view -Sb GerK-NldL.sam | samtools sort -O BAM -o GerK-NldL.bam
samtools index GerK-NldL.bam

minimap2 -ax asm5 -t 4 --eqx NLD202_hapL.fasta NLD202_hapM.fasta -o NldL-NldM.sam
samtools view -Sb NldL-NldM.sam | samtools sort -O BAM -o NldL-NldM.bam
samtools index NldL-NldM.bam


#run this in live mode

syri -c TxA-CaA.bam -r TX94-4_hapA.fasta -q 15CA06C_hapA.fasta -F B --prefix TxA-CaA &
syri -c CaA-TxB.bam -r 15CA06C_hapA.fasta -q TX94-4_hapB.fasta -F B --prefix CaA-TxB &
syri -c TxB-CaB.bam -r TX94-4_hapB.fasta -q 15CA06C_hapB.fasta -F B --prefix TxB-CaB &
syri -c CaB-VaB.bam -r 15CA06C_hapB.fasta -q VA93-27_hapB.fasta -F B --prefix CaB-VaB &
syri -c VaB-MnB.bam -r VA93-27_hapB.fasta -q 17MN32B_hapB.fasta -F B --prefix VaB-MnB &
syri -c MnB-VaC.bam -r 17MN32B_hapB.fasta -q VA93-27_hapC.fasta  -F B --prefix MnB-VaC &
syri -c VaC-MnC.bam -r VA93-27_hapC.fasta -q 17MN32B_hapC.fasta  -F B --prefix VaC-MnC &
syri -c MnC-VaD.bam -r 17MN32B_hapC.fasta -q VA82_hapD.fasta  -F B --prefix MnC-VaD &
syri -c VaD-WaD.bam -r VA82_hapD.fasta -q WA92-74_hapD.fasta  -F B --prefix VaD-WaD &
syri -c WaD-VaE.bam -r WA92-74_hapD.fasta -q VA82_hapE.fasta  -F B --prefix WaD-VaE &
syri -c VaE-WaE.bam -r VA82_hapE.fasta -q WA92-74_hapE.fasta -F B --prefix VaE-WaE &
syri -c WaE-IsrF.bam -r WA92-74_hapE.fasta -q ISR90-3_hapF.fasta -F B --prefix WaE-IsrF &
syri -c IsrF-IsrG.bam -r ISR90-3_hapF.fasta -q ISR90-3_hapG.fasta -F B --prefix IsrF-IsrG &
syri -c IsrG-ChiH.bam -r ISR90-3_hapG.fasta -q CHI_hapH.fasta -F B --prefix IsrG-ChiH &
syri -c ChiH-ChI.bam -r CHI_hapH.fasta -q CHI_hapI.fasta -F B --prefix ChiH-ChI &
syri -c ChI-GerJ.bam -r CHI_hapI.fasta -q GER5_hapJ.fasta -F B --prefix ChI-GerJ &
syri -c GerJ-GerK.bam -r GER5_hapJ.fasta -q GER5_hapK.fasta -F B --prefix GerJ-GerK &
syri -c GerK-NldL.bam -r GER5_hapK.fasta -q NLD202_hapL.fasta -F B --prefix GerK-NldL &
syri -c NldL-NldM.bam -r NLD202_hapL.fasta -q NLD202_hapM.fasta -F B --prefix NldL-NldM &


#run plotsr
plotsr --itx --sr TxA-CaAsyri.out --sr CaA-TxBsyri.out --sr TxB-CaBsyri.out --sr CaB-VaBsyri.out --sr VaB-MnBsyri.out --sr MnB-VaCsyri.out --sr VaC-MnCsyri.out --sr MnC-VaDsyri.out --sr VaD-WaDsyri.out --sr WaD-VaEsyri.out --sr VaE-WaEsyri.out --sr WaE-IsrFsyri.out --sr IsrF-IsrGsyri.out --sr IsrG-ChiHsyri.out --sr ChiH-ChIsyri.out --sr ChI-GerJsyri.out --sr GerJ-GerKsyri.out --sr GerK-NldLsyri.out --sr NldL-NldMsyri.out --genomes genomes.txt --cfg base.cfg -s 50000 -S 0.7 -o allrevised.pdf -W 10 -H 8


#genomes.txt file should be in the same directory
#genomes have to be in order as they are plotted in plotsr

#file   name    tags
TX94-4_hapA.fasta	94TX04_HapA	lw:1;lc:#4D4D4D
15CA06C_hapA.fasta	15CA06C_HapA	lw:1;lc:#4D4D4D
TX94-4_hapB.fasta	94TX04_HapB	lw:1;lc:#4D4D4D
15CA06C_hapB.fasta	15CA06C_HapB	lw:1;lc:#4D4D4D
VA93-27_hapB.fasta	93VA27_HapB	lw:1;lc:#4D4D4D
17MN32B_hapB.fasta	17MN32B_HapB	lw:1;lc:#4D4D4D
VA93-27_hapC.fasta	93VA27_HapC	lw:1;lc:#4D4D4D
17MN32B_hapC.fasta	17MN32B_HapC	lw:1;lc:#4D4D4D
VA82_hapD.fasta	82VA01_HapD	lw:1;lc:#4D4D4D
WA92-74_hapD.fasta	92WA74_HapD	lw:1;lc:#4D4D4D
VA82_hapE.fasta	82VA01_HapE	lw:1;lc:#4D4D4D
WA92-74_hapE.fasta	92WA74_HapE	lw:1;lc:#4D4D4D
ISR90-3_hapF.fasta	90ISR03_HapF	lw:1;lc:#4D4D4D
ISR90-3_hapG.fasta	90ISR03_HapG	lw:1;lc:#4D4D4D
CHI_hapH.fasta	97CHN01_HapH	lw:1;lc:#4D4D4D
CHI_hapI.fasta	97CHN01_HapI	lw:1;lc:#4D4D4D
GER5_hapJ.fasta	91DEU05_HapJ	lw:1;lc:#4D4D4D
GER5_hapK.fasta	91DEU05_HapK	lw:1;lc:#4D4D4D
NLD202_hapL.fasta	91NLD202_HapL	lw:1;lc:#4D4D4D
NLD202_hapM.fasta	91NLD202_HapM	lw:1;lc:#4D4D4D



#base.cfg file to customize colors, margins, etc., should be in the directory

## COLOURS and transparency for alignments (syntenic, inverted, translocated, and duplicated)
syncol:#CCCCCC
invcol:#0000FF
tracol:#FF0000
dupcol:#FFA500

## Legend
legend:T                ## To plot legend use T, use F to not plot legend
genlegcol:4            ## Number of columns for genome legend, set -1 for automatic setup
bbox:0,0.95,0.5,0.5            ## [Left edge, bottom edge, width, height]
bbox_v:0,0.95,0.5,0.5  ## For vertical chromosomes (using -v option)
bboxmar:0.5             ## Margin between genome and annotation legends

## Margins and dimensions:
chrmar:0              ## Adjusts the gap between chromosomes and tracks. Higher values leads to more gap
exmar:0               ## Extra margin at the top and bottom of plot area
marginchr:0.1           ## Margin between adjacent chromosomes when using --itx








