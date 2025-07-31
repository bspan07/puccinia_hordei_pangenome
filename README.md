# Overview
Scripts used to complete the *Puccinia hordei* genome annotation and comparisons described in Spanner *et al.* (2025): DOI.
# Genome Annotation

**Gene Annotation**

Annotation of gene models was performed as described step-by-step in `annotation_pipeline.Rmd`.

**Repeat Element Annotation**

Annotation of repetitive elements was performed as described in `annotate_repeats.Rmd`. First, RepeatModeler is used to de novo annotate repeat elements. This library is then used with RepeatMasker to obtain repeat element annotation and statistics. 

# Pangenome Saturation
The python script `make_orthogroups_matrix.py` uses the output of OrthoFinder (list of orthogroups = Orthogroups.tsv) and converts it to a binary presence/absence matrix across the 10 diploid genomes. It also performs rarefaction analysis: for each value of n (1–10 genomes), 100 random subsets of n genomes are sampled without replacement. For each subset, the number of core orthogroups (present in all n genomes), unique orthogroups (present in exactly one genome), and pangenome orthogroups (present in at least one genome) is calculated. The R script `plot_pangenome_saturation.R` takes the output from the python script (pangenome_completeness_stats.csv) and plots the mean number of orthogroups at each value of n for each orthogroup category (core, unique and pangenome). 

# Data visualization
Bespoke code was used to make elements of the following Figures:

**Figure 1**
in `Figure1.R`: Heat map of virulence profiles across Bowman differential lines; bar chart showing nuclear contacts per chromosome.

**Figure 3**
in `Figure3.Rmd`: synteny between chromosomes using `syri` and `plotsR`; violin plots of chromosome lengths.

**Figure 4**
in `Figure4.Rmd`: chromosome-level map of 90ISR03 isolate.

**Figure 6**
in `Figure6.R`: stacked bar chart.


