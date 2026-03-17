# Nextflow Pipeline File Inventory

## Core Pipeline Files
- [x] main.nf - Entry point for pipeline execution
- [x] nextflow.config - Main configuration file
- [x] nextflow_schema.json - Parameter validation schema
- [x] README.md - Comprehensive documentation

## Workflow Files (workflows/)
- [x] starrseq.nf - STARR-seq analysis workflow
- [x] capstarrseq.nf - CapSTARR-seq (with RNA-seq) workflow

## Process Modules (modules/local/) - 22 modules
### QC Processes
- [x] fastqc.nf - Quality control with FastQC
- [x] fastq_screen.nf - Contamination screening
- [x] multiqc.nf - Aggregate QC reporting

### Read Processing
- [x] cutadapt.nf - Adapter trimming

### Alignment
- [x] bowtie2_align.nf - Alignment with Bowtie2
- [x] samtools_sort.nf - BAM sorting
- [x] samtools_index.nf - BAM indexing
- [x] filter_bowtie2_unique.nf - Filter unique alignments

### Duplicate Handling
- [x] picard_markduplicates.nf - Mark duplicates with Picard
- [x] samtools_rmdup.nf - Remove duplicates with Samtools
- [x] dupradar.nf - Duplication rate analysis

### Coverage & Visualization
- [x] deeptools_bamcoverage.nf - Generate coverage tracks

### Peak Calling
- [x] macs2_callpeak.nf - Peak calling with MACS2
- [x] starrpeaker_procbam.nf - STARRPeaker BAM processing
- [x] starrpeaker_callpeak.nf - STARRPeaker peak calling

### RNA-seq Quantification (CapSTARR-seq specific)
- [x] subread_featurecounts.nf - Gene/exon counting
- [x] filter2htseq.nf - Convert to HTSeq format
- [x] calculate_tpm.nf - Calculate TPM values

### Differential Analysis (CapSTARR-seq specific)
- [x] deseq2_differential.nf - DESeq2 differential expression
- [x] capstarrseq_foldchange.nf - Simple fold-change analysis

### Additional QC
- [x] picard_collectinsertsize.nf - Insert size metrics
- [x] phantompeakqualtools.nf - ChIP-seq quality metrics

## Configuration Files (conf/)
- [x] base.config - Resource allocation by process label
- [x] modules.config - Process-specific parameters

## Assets (assets/)
- [x] multiqc_config.yaml - MultiQC configuration
- [x] samplesheet_example.csv - Example input samplesheet
- [x] schema_input.json - Samplesheet validation schema

## R Scripts (bin/)
- [x] calculate_tpm.R - TPM calculation from featureCounts
- [x] deseq2_analysis.R - DESeq2 differential expression analysis
- [x] capstarrseq_foldchange.R - Simple fold-change calculation

## Summary
- **Total Nextflow processes**: 22
- **Workflows**: 2 (STARR-seq, CapSTARR-seq)
- **Configuration files**: 3 (nextflow.config, base.config, modules.config)
- **R analysis scripts**: 3
- **Schema files**: 2 (nextflow_schema.json, schema_input.json)

## Status
✅ All core pipeline files present and lint-checked
✅ All 22 process modules created and functional
✅ Configuration files complete
✅ Documentation comprehensive and up-to-date
✅ Pipeline passes 'nextflow lint' with 0 errors

## Original Bpipe Files (retained for reference)
The original Bpipe pipeline files remain in:
- pipelines/STARRseq/
- tools/
- modules/NGS/

These are kept for reference but are NOT used by the Nextflow pipeline.
