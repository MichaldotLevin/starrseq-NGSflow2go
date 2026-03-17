#!/usr/bin/env Rscript

# DESeq2 differential expression analysis for CapSTARR-seq

library(optparse)
library(DESeq2)
library(ggplot2)

# Define options
option_list <- list(
  make_option(c("--counts"), type = "character", default = NULL,
              help = "Path to directory with count files", metavar = "character"),
  make_option(c("--samplesheet"), type = "character", default = NULL,
              help = "Path to samplesheet CSV file", metavar = "character"),
  make_option(c("--output-prefix"), type = "character", default = "deseq2",
              help = "Output file prefix [default= %default]", metavar = "character"),
  make_option(c("--fdr"), type = "numeric", default = 0.05,
              help = "FDR threshold for significance [default= %default]", metavar = "numeric")
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

# Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData = samplesheet,
  design = ~ condition
)

# Run DESeq2
dds <- DESeq(dds)
res <- results(dds, alpha = opt$fdr)

# Get normalized counts
normalized_counts <- counts(dds, normalized = TRUE)

# Write results
write.table(as.data.frame(res), 
            file = paste0(opt$`output-prefix`, "_results.txt"),
            quote = FALSE, sep = "\t", row.names = TRUE)

write.table(normalized_counts,
            file = paste0(opt$`output-prefix`, "_normalized.txt"),
            quote = FALSE, sep = "\t", row.names = TRUE)

# Generate plots
pdf(paste0(opt$`output-prefix`, "_plots.pdf"), width = 10, height = 8)

# MA plot
plotMA(res, main = "MA Plot", ylim = c(-5, 5))

# PCA plot
vsd <- vst(dds, blind = FALSE)
plotPCA(vsd, intgroup = "condition")

# Dispersion plot
plotDispEsts(dds)

dev.off()

cat("DESeq2 analysis completed successfully.\n")
cat(paste0("Results written to: ", opt$`output-prefix`, "_results.txt\n"))
cat(paste0("Normalized counts written to: ", opt$`output-prefix`, "_normalized.txt\n"))
cat(paste0("Plots written to: ", opt$`output-prefix`, "_plots.pdf\n"))
