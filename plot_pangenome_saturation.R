# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)

# Read in your data
df <- read_csv("pangenome_completeness_stats.csv")

# Convert to long format for ggplot
df_long <- df %>%
  pivot_longer(cols = c(core, unique, pangenome), 
               names_to = "Category", 
               values_to = "Orthogroup_Count")

# Calculate summary stats (mean and sd) for plotting
summary_df <- df_long %>%
  group_by(N_genomes, Category) %>%
  summarise(mean = mean(Orthogroup_Count),
            sd = sd(Orthogroup_Count), .groups = "drop")

# Plot
ggplot(summary_df, aes(x = N_genomes, y = mean, color = Category)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd, fill = Category), 
              alpha = 0.2, color = NA) +
  scale_x_continuous(breaks = 1:max(df$N_genomes)) +
  labs(
    title = "Pangenome Completeness Across Puccinia hordei Isolates",
    x = "Number of Isolates",
    y = "Number of Orthogroups",
    color = "Category",
    fill = "Category"
  ) +
  theme_minimal(base_size = 14)
