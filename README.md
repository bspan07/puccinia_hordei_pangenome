# Overview
Scripts used to complete the *Puccinia hordei* genome annotation and comparisons described in Spanner *et al.* (2025): DOI.
# Genome Annotation

# Pangenome Saturation
The python script `make_orthogroups_matrix.py` uses the output of OrthoFinder (list of orthogroups = Orthogroups.tsv) and converts it to a binary presence/absence matrix across the 10 diploid genomes. It also performs rarefaction analysis: for each value of n (1–10 genomes), 100 random subsets of n genomes are sampled without replacement. For each subset, the number of core orthogroups (present in all n genomes), unique orthogroups (present in exactly one genome), and pangenome orthogroups (present in at least one genome) is calculated. The R script `plot_pangenome_saturation.R` takes the output from the python script (pangenome_completeness_stats.csv) and plots the mean number of orthogroups at each value of n for each orthogroup category (core, unique and pangenome). 
# Data visualization
**Figure 1**


