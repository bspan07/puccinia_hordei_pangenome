###first convert output of Orthofinder (Orthogroups.tsv) to a presence/absence matrix
library(readr); library(dplyr); library(tidyr); library(stringr)

og <- read_tsv("Orthogroups.tsv")  # rows = OGs, cols = genomes with comma-separated gene IDs
og_col <- "Orthogroup"
genome_cols <- setdiff(colnames(og), og_col)

og_bin <- og |>
  mutate(across(all_of(genome_cols),
                ~ if_else(is.na(.x) | str_trim(.x) == "", 0L, 1L),
                .names = "{.col}"))

pa <- og_bin |>
  pivot_longer(-all_of(og_col), names_to = "Genome", values_to = "presence") |>
  pivot_wider(names_from = !!sym(og_col), values_from = presence, values_fill = 0) |>
  arrange(Genome)

write_tsv(pa, "orthogroups_presence_absence.tsv")

###next plot pangenome saturation curve
library(readr)
library(dplyr)
library(ggplot2)
library(micropan)

# ---- Load presence/absence matrix (rows = genomes, cols = orthogroups; 0/1) ----
pan <- read_tsv("orthogroups_presence_absence.tsv")
rownames(pan) <- pan[[1]]
pan <- pan[,-1]
pan <- as.matrix(pan)
storage.mode(pan) <- "integer"
class(pan) <- c("panmat", "matrix")

G <- nrow(pan)
P <- ncol(pan)
nperm <- 1000

# ---- 1) Use micropan::rarefaction() for the pangenome curve ----
set.seed(42)
rare_pan <- rarefaction(pan, n.perm = nperm)  # first col = Genome, others = permutations

pan_summary <- rare_pan |>
  rename(Genome = 1) |>
  mutate(
    pan_mean = rowMeans(across(-Genome)),
    pan_sd   = apply(across(-Genome), 1, sd),
    pan_lo   = pan_mean - 1.96 * pan_sd,
    pan_hi   = pan_mean + 1.96 * pan_sd
  ) |>
  select(Genome, pan_mean, pan_sd, pan_lo, pan_hi)

# ---- 2) Manually compute mean CORE and UNIQUE across permutations ----
acc_init <- function(G) list(n=0,
                             sum_core=numeric(G), sumsq_core=numeric(G),
                             sum_uniq=numeric(G), sumsq_uniq=numeric(G))
acc_add <- function(acc, core_vec, uniq_vec){
  acc$n <- acc$n + 1
  acc$sum_core   <- acc$sum_core   + core_vec
  acc$sumsq_core <- acc$sumsq_core + core_vec^2
  acc$sum_uniq   <- acc$sum_uniq   + uniq_vec
  acc$sumsq_uniq <- acc$sumsq_uniq + uniq_vec^2
  acc
}
acc_finalize <- function(acc){
  m_core <- acc$sum_core / acc$n
  m_uniq <- acc$sum_uniq / acc$n
  sd_core <- sqrt(pmax(0, acc$sumsq_core/acc$n - m_core^2))
  sd_uniq <- sqrt(pmax(0, acc$sumsq_uniq/acc$n - m_uniq^2))
  tibble(
    Genome = seq_len(length(m_core)),
    core_mean = m_core, core_sd = sd_core,
    uniq_mean = m_uniq, uniq_sd = sd_uniq,
    core_lo = core_mean - 1.96 * core_sd,
    core_hi = core_mean + 1.96 * core_sd,
    uniq_lo = uniq_mean - 1.96 * uniq_sd,
    uniq_hi = uniq_mean + 1.96 * uniq_sd
  )
}

set.seed(42)  # separate loop; same seed for reproducibility
acc <- acc_init(G)
idx <- seq_len(G)

for(b in seq_len(nperm)){
  ord <- sample(idx, G, replace = FALSE)
  counts <- integer(P)
  core_vec <- integer(G)
  uniq_vec <- integer(G)
  
  for(s in seq_len(G)){
    g <- ord[s]
    counts <- counts + pan[g, ]
    core_vec[s] <- sum(counts == s)   # present in all s sampled
    uniq_vec[s] <- sum(counts == 1L)  # present in exactly one of s sampled
  }
  acc <- acc_add(acc, core_vec, uniq_vec)
}

cu_summary <- acc_finalize(acc)

# ---- 3) Merge summaries and (optionally) start at zero ----
summary_df <- pan_summary %>%
  inner_join(cu_summary, by = "Genome")

add_zero <- TRUE
if(add_zero){
  zero_row <- tibble(
    Genome=0L,
    pan_mean=0, pan_sd=0, pan_lo=0, pan_hi=0,
    core_mean=0, core_sd=0, core_lo=0, core_hi=0,
    uniq_mean=0, uniq_sd=0, uniq_lo=0, uniq_hi=0
  )
  summary_df <- bind_rows(zero_row, summary_df)
}

# ---- 4) Plot: mean curves (toggle ribbons if desired) ----
ggplot(summary_df, aes(x = Genome)) +
  # Uncomment any ribbons you want
  # geom_ribbon(aes(ymin = pan_lo,  ymax = pan_hi),  alpha = 0.10, linewidth = 0) +
  # geom_ribbon(aes(ymin = core_lo, ymax = core_hi), alpha = 0.08, linewidth = 0) +
  # geom_ribbon(aes(ymin = uniq_lo, ymax = uniq_hi), alpha = 0.08, linewidth = 0) +
  geom_line(aes(y = pan_mean),  linewidth = 1.2) +
  geom_line(aes(y = core_mean), linetype = "dotdash", linewidth = 1.1) +
  geom_line(aes(y = uniq_mean), linetype = "twodash", linewidth = 1.1) +
  scale_x_continuous(breaks = 0:max(summary_df$Genome)) +
  labs(
    x = "Number of genomes sampled",
    y = "Orthogroup count",
    title = "Pangenome rarefaction (mean): Pangenome, Core, and Unique",
    subtitle = paste("Permutations =", nperm, "(pangenome via micropan::rarefaction)")
  ) +
  theme_bw() +
  theme(
    text = element_text(size = 13),
    plot.title = element_text(face = "bold")
  ) + scale_x_continuous(breaks=seq(1, 13, by=1), limits=c(1,13))
