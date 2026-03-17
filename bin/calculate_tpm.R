#!/usr/bin/env Rscript

# Calculate TPM (Transcripts Per Million) from featureCounts output

library(optparse)

# Define options
option_list <- list(
  make_option(c("--counts"), type = "character", default = NULL,
              help = "Path to featureCounts output file", metavar = "character"),
  make_option(c("--gtf"), type = "character", default = NULL,
              help = "Path to GTF annotation file", metavar = "character"),
  make_option(c("--output"), type = "character", default = "output.tpm.txt",
              help = "Output file name [default= %default]", metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Check required arguments
if (is.null(opt$counts) || is.null(opt$gtf)) {
  print_help(opt_parser)
  stop("Both --counts and --gtf arguments are required.", call. = FALSE)
}

# Read counts
counts_data <- read.table(opt$counts, header = TRUE, sep = "\t", skip = 1, row.names = 1)

# Extract gene lengths (6th column) and counts (7th column)
gene_lengths <- counts_data[, 5]
raw_counts <- counts_data[, 6]

# Calculate TPM
# TPM = (reads per gene / gene length in kb) / (sum of (reads per gene / gene length in kb) for all genes) * 10^6
rpk <- raw_counts / (gene_lengths / 1000)
tpm <- (rpk / sum(rpk)) * 1e6

# Create output data frame
tpm_output <- data.frame(
  GeneID = rownames(counts_data),
  Length = gene_lengths,
  Counts = raw_counts,
  TPM = tpm
)

# Write output
write.table(tpm_output, file = opt$output, quote = FALSE, sep = "\t", row.names = FALSE)

cat("TPM calculation completed successfully.\n")
cat(paste0("Output written to: ", opt$output, "\n"))
