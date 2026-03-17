#!/usr/bin/env Rscript

# Simple fold-change analysis for CapSTARR-seq (no statistical testing)

library(optparse)
library(ggplot2)

# Define options
option_list <- list(
  make_option(c("--counts"), type = "character", default = NULL,
              help = "Path to directory with count files", metavar = "character"),
  make_option(c("--samplesheet"), type = "character", default = NULL,
              help = "Path to samplesheet CSV file", metavar = "character"),
  make_option(c("--output-prefix"), type = "character", default = "foldchange",
              help = "Output file prefix [default= %default]", metavar = "character"),
  make_option(c("--fc-threshold"), type = "numeric", default = 2.0,
              help = "Fold-change threshold [default= %default]", metavar = "numeric")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Check required arguments
if (is.null(opt$counts) || is.null(opt$samplesheet)) {
  print_help(opt_parser)
  stop("Both --counts and --samplesheet arguments are required.", call. = FALSE)
}

# Read samplesheet
samplesheet <- read.csv(opt$samplesheet, header = TRUE)

# Read count files and create count matrix
count_files <- list.files(opt$counts, pattern = "\\.htseq\\.txt$", full.names = TRUE)
count_list <- lapply(count_files, function(f) {
  read.table(f, header = FALSE, sep = "\t", row.names = 1)
})

# Combine into matrix
count_matrix <- do.call(cbind, count_list)
colnames(count_matrix) <- samplesheet$sample

# Split by condition
conditions <- unique(samplesheet$condition)
if (length(conditions) != 2) {
  stop("Samplesheet must contain exactly 2 conditions for fold-change analysis.", call. = FALSE)
}

cond1_samples <- samplesheet$sample[samplesheet$condition == conditions[1]]
cond2_samples <- samplesheet$sample[samplesheet$condition == conditions[2]]

# Calculate mean counts per condition
cond1_mean <- rowMeans(count_matrix[, cond1_samples, drop = FALSE])
cond2_mean <- rowMeans(count_matrix[, cond2_samples, drop = FALSE])

# Calculate fold-change (add pseudocount to avoid division by zero)
pseudocount <- 1
fold_change <- (cond2_mean + pseudocount) / (cond1_mean + pseudocount)
log2_fold_change <- log2(fold_change)

# Create results data frame
results <- data.frame(
  GeneID = rownames(count_matrix),
  baseMean_cond1 = cond1_mean,
  baseMean_cond2 = cond2_mean,
  FoldChange = fold_change,
  log2FoldChange = log2_fold_change,
  Significant = abs(log2_fold_change) >= log2(opt$`fc-threshold`)
)

# Write results
write.table(results,
            file = paste0(opt$`output-prefix`, "_results.txt"),
            quote = FALSE, sep = "\t", row.names = FALSE)

# Generate plots
pdf(paste0(opt$`output-prefix`, "_plots.pdf"), width = 10, height = 8)

# MA plot equivalent
plot_data <- data.frame(
  baseMean = (cond1_mean + cond2_mean) / 2,
  log2FC = log2_fold_change
)

p1 <- ggplot(plot_data, aes(x = log10(baseMean + 1), y = log2FC)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = c(-log2(opt$`fc-threshold`), log2(opt$`fc-threshold`)),
             linetype = "dashed", color = "red") +
  labs(title = "Mean-Difference Plot",
       x = "log10(Mean Expression)",
       y = "log2(Fold Change)") +
  theme_bw()

print(p1)

# Volcano-like plot
p2 <- ggplot(results, aes(x = log2FoldChange, y = baseMean_cond1 + baseMean_cond2)) +
  geom_point(aes(color = Significant), alpha = 0.5) +
  scale_color_manual(values = c("gray", "red")) +
  labs(title = "Fold Change Distribution",
       x = "log2(Fold Change)",
       y = "Mean Expression") +
  theme_bw()

print(p2)

dev.off()

cat("Fold-change analysis completed successfully.\n")
cat(paste0("Results written to: ", opt$`output-prefix`, "_results.txt\n"))
cat(paste0("Plots written to: ", opt$`output-prefix`, "_plots.pdf\n"))
cat(paste0("Genes with |log2FC| >= ", log2(opt$`fc-threshold`), ": ",
           sum(results$Significant), "\n"))
