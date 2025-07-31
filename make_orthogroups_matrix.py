import pandas as pd
import numpy as np
from itertools import combinations
from random import sample

# Load OrthoFinder table
df = pd.read_csv("Orthogroups.tsv", sep="\t")

# Extract just the isolate columns
isolate_cols = df.columns[1:]  # skip 'Orthogroup' column
n_isolates = len(isolate_cols)

# Convert to presence/absence (1 if any gene present, 0 if NA or blank)
binary_df = df[isolate_cols].notna().astype(int)
binary_df["Orthogroup"] = df["Orthogroup"]

# Rearrange so 'Orthogroup' is the index
combined = binary_df.set_index("Orthogroup")

# Function to calculate core, unique, and pangenome OG counts
def pangenome_stats(isolate_subset):
    sub = combined[isolate_subset]
    core = (sub.sum(axis=1) == len(isolate_subset)).sum()
    unique = (sub.sum(axis=1) == 1).sum()
    pan = (sub.sum(axis=1) > 0).sum()
    return core, unique, pan

# Rarefaction analysis across 1 to 10 genomes
results = []
for i in range(1, n_isolates + 1):
    for _ in range(100):  # 100 replicates per genome count
        subset = sample(list(isolate_cols), i)
        core, unique, pan = pangenome_stats(subset)
        results.append({
            "N_genomes": i,
            "core": core,
            "unique": unique,
            "pangenome": pan
        })

# Save to CSV for plotting
pd.DataFrame(results).to_csv("pangenome_completeness_stats.csv", index=False)
