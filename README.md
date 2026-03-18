# CapSTARR-seq Nextflow Pipeline

A modern Nextflow DSL2 implementation of the CapSTARR-seq analysis pipeline, converted from the original Bpipe-based NGSpipe2go framework.

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A525.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](https://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

> 📋 **See `FILE_INVENTORY.md` for a complete list of all pipeline files and their purposes.**

## Introduction

**CapSTARR-seq** (Capture STARR-seq) is a variant of STARR-seq that assays a predetermined set of target regions enriched from genomic DNA using a DNA capture approach. This pipeline analyzes both the RNA (transcription from enhancers) and DNA (input material) to identify active enhancers within the captured regions.

### Pipeline Overview

The pipeline performs:
1. **Quality Control**: FastQC and optional FastQ Screen
2. **Read Trimming**: Optional adapter trimming with Cutadapt
3. **Alignment**: Bowtie2 alignment to reference genome
4. **Post-alignment QC**: BAM filtering, deduplication, quality metrics
5. **RNA-seq Analysis**: Gene/region quantification with featureCounts
6. **Differential Analysis**: DESeq2 or simple fold-change analysis
7. **Peak Calling**: Optional STARRPeaker peak calling
8. **Visualization**: Coverage tracks and insert size metrics
9. **Report Generation**: Comprehensive MultiQC report

## Quick Start

### 1. Install Nextflow

Nextflow (≥25.04.0) is required:

```bash
curl -s https://get.nextflow.io | bash
```

### 2. Prepare Input Samplesheet

Create a CSV file with your samples (see [Input Samplesheet](#input-samplesheet) below):

```csv
sample,fastq_1,fastq_2,type
RNA_rep1,/path/to/RNA_rep1_R1.fastq.gz,/path/to/RNA_rep1_R2.fastq.gz,input
DNA_rep1,/path/to/DNA_rep1_R1.fastq.gz,/path/to/DNA_rep1_R2.fastq.gz,control
```

### 3. Configure Parameters

**Option A: Use a parameter file (recommended)**

Copy and customize the template parameter file:

```bash
cp params.yaml my_params.yaml
# Edit my_params.yaml with your specific settings
```

Or use one of the example configurations in `params_examples/`:
- `starrseq_example.yaml` - Standard STARR-seq analysis
- `capstarrseq_example.yaml` - CapSTARR-seq with DESeq2
- `test_example.yaml` - Quick test run

**Option B: Use command-line parameters**

Provide parameters directly on the command line (see below).

### 4. Run the Pipeline

**Using a parameter file:**

```bash
nextflow run main.nf -params-file my_params.yaml -profile docker
```

**Using command-line parameters:**

```bash
nextflow run main.nf \
    --input samplesheet.csv \
    --genome hg38 \
    --bowtie2_index /path/to/bowtie2/hg38 \
    --genes_gtf /path/to/genes.gtf \
    --outdir results \
    -profile docker
```

## Input Samplesheet

The input samplesheet is a CSV file with the following columns:

| Column    | Description                                                     |
|-----------|-----------------------------------------------------------------|
| `sample`  | Unique sample identifier (required)                             |
| `fastq_1` | Full path to read 1 FASTQ file (required)                      |
| `fastq_2` | Full path to read 2 FASTQ file (optional, for paired-end)      |
| `type`    | Sample type: `input` (RNA) or `control` (DNA) (required)      |

**Example:**

```csv
sample,fastq_1,fastq_2,type
RNA_rep1,data/RNA_rep1_R1.fq.gz,data/RNA_rep1_R2.fq.gz,input
RNA_rep2,data/RNA_rep2_R1.fq.gz,data/RNA_rep2_R2.fq.gz,input
DNA_rep1,data/DNA_rep1_R1.fq.gz,data/DNA_rep1_R2.fq.gz,control
DNA_rep2,data/DNA_rep2_R1.fq.gz,data/DNA_rep2_R2.fq.gz,control
```

## Parameters

### Using Parameter Files

The easiest way to configure the pipeline is using a YAML parameter file. We provide:

1. **`params.yaml`** - Complete template with all available parameters and documentation
2. **`params_examples/`** - Ready-to-use example configurations:
   - `starrseq_example.yaml` - Standard STARR-seq with MACS2 peak calling
   - `capstarrseq_example.yaml` - CapSTARR-seq with DESeq2 differential expression
   - `test_example.yaml` - Quick test run with minimal resources

**Usage:**
```bash
# Copy and customize the template
cp params.yaml my_analysis.yaml
# Edit my_analysis.yaml with your settings
# Run the pipeline
nextflow run main.nf -params-file my_analysis.yaml -profile docker
```

See `params_examples/README.md` for detailed examples and customization tips.

### Required Parameters

| Parameter          | Description                                      |
|--------------------|--------------------------------------------------|
| `--input`          | Path to input samplesheet (CSV format)          |
| `--genome`         | Reference genome name (e.g., hg38, mm10)        |
| `--bowtie2_index`  | Path to Bowtie2 index directory                 |
| `--genes_gtf`      | Path to gene annotation GTF file                |
| `--outdir`         | Output directory (default: 'results')           |

### Optional Parameters

> **Note:** All parameters can be set in a YAML file (recommended) or via command line.
> For a complete list with descriptions, see `params.yaml`.

#### Reference Files
| Parameter        | Description                              | Default       |
|------------------|------------------------------------------|---------------|
| `--fasta`        | Reference genome FASTA file             | null          |
| `--chromsizes`   | Chromosome sizes file                   | null          |

#### Quality Control
| Parameter              | Description                        | Default |
|------------------------|------------------------------------|---------|
| `--run_fastqc`         | Run FastQC on raw reads           | true    |
| `--run_fastqscreen`    | Run FastQ Screen                  | false   |
| `--fastqscreen_config` | FastQ Screen config file          | null    |

#### Trimming
| Parameter            | Description                          | Default |
|----------------------|--------------------------------------|---------|
| `--run_cutadapt`     | Trim adapters with Cutadapt         | false   |
| `--adapter_seq`      | Adapter sequence (3' end)           | null    |
| `--adapter_seq_pe`   | Adapter sequence for read 2 (PE)    | null    |

#### Alignment
| Parameter              | Description                        | Default |
|------------------------|------------------------------------|---------|
| `--bowtie2_threads`    | Threads for Bowtie2               | 4       |
| `--mapq_threshold`     | Minimum MAPQ for filtering        | 10      |

#### Analysis Options
| Parameter                  | Description                              | Default |
|----------------------------|------------------------------------------|---------|
| `--capstarrseq_diffexp`    | Use DESeq2 (true) or fold-change (false)| true    |
| `--run_starrpeaker`        | Run STARRPeaker peak calling            | false   |
| `--run_dupradar`           | Run dupRadar duplication analysis       | false   |
| `--run_phantompeak`        | Run PhantomPeak quality tools           | false   |

#### Performance
| Parameter        | Description                    | Default |
|------------------|--------------------------------|---------|
| `--max_cpus`     | Maximum CPUs per process      | 16      |
| `--max_memory`   | Maximum memory per process    | 128.GB  |
| `--max_time`     | Maximum time per process      | 240.h   |

### Complete Parameter List

For a complete list of all parameters with descriptions and validation, see:
```bash
nextflow run main.nf --help
```

Or view the parameter schema: `nextflow_schema.json`

## Output Structure

```
results/
├── fastqc/                    # FastQC reports
├── fastq_screen/             # FastQ Screen reports (optional)
├── cutadapt/                 # Trimmed reads (optional)
├── bowtie2/                  # Alignment BAM files and logs
├── filtered/                 # Filtered BAM files (MAPQ ≥ threshold)
├── markduplicates/           # Duplicate-marked BAM files
├── samtools_rmdup/           # Deduplicated BAM files (optional)
├── featurecounts/            # Gene/region count matrices
├── tpm/                      # TPM-normalized expression
├── deseq2/                   # DESeq2 differential analysis results
│   ├── results.csv           # DE results
│   ├── normalized_counts.csv # Normalized counts
│   └── plots/                # MA plots, PCA, heatmaps
├── foldchange/               # Simple fold-change analysis (alternative to DESeq2)
├── starrpeaker/              # Peak calls (optional)
├── bamcoverage/              # BigWig coverage tracks
├── insert_size/              # Insert size metrics (PE only)
├── dupradar/                 # Duplication analysis (optional)
├── phantompeak/              # Quality metrics (optional)
├── multiqc/                  # Comprehensive QC report
│   └── multiqc_report.html   # Main QC report
└── pipeline_info/            # Pipeline execution info
    ├── execution_report.html
    ├── execution_timeline.html
    └── execution_trace.txt
```

## Profiles

The pipeline supports multiple execution profiles:

### Container Engines
- **`docker`**: Use Docker containers (requires Docker)
- **`singularity`**: Use Singularity containers (requires Singularity)
- **`conda`**: Use Conda environments with Wave (default)

### Executors
- **`local`**: Run on local machine (default)
- **`slurm`**: Submit jobs to SLURM cluster
- **`sge`**: Submit jobs to SGE cluster
- **`lsf`**: Submit jobs to LSF cluster

### Usage Examples

```bash
# Run with Docker
nextflow run main.nf -profile docker --input samplesheet.csv ...

# Run on SLURM cluster with Singularity
nextflow run main.nf -profile slurm,singularity --input samplesheet.csv ...

# Run locally with Conda (default)
nextflow run main.nf --input samplesheet.csv ...
```

## Wave Containers

This pipeline uses **Wave** for automatic container provisioning. When using the `conda` profile (default), Wave automatically builds optimized containers based on the `conda` directives in each process. This eliminates the need for pre-built Docker images while ensuring reproducibility.

For more information: https://seqera.io/wave/

## Resource Requirements

### Minimum Requirements
- **CPU**: 4 cores
- **Memory**: 16 GB RAM
- **Storage**: 50 GB free space (varies with dataset size)

### Recommended Resources
- **CPU**: 16+ cores
- **Memory**: 64+ GB RAM
- **Storage**: 200+ GB for large datasets

Resource allocation can be customized via:
- Process labels in `conf/base.config`
- `--max_cpus`, `--max_memory`, `--max_time` parameters

## Differential Expression Analysis

The pipeline supports two modes for comparing RNA vs DNA samples:

### 1. DESeq2 Analysis (Default)
**Use when:** You have biological replicates and want robust statistical analysis

```bash
nextflow run main.nf \
    --input samplesheet.csv \
    --capstarrseq_diffexp true \
    ...
```

**Outputs:**
- `deseq2/results.csv` - Full DE results with log2FC, p-values, adjusted p-values
- `deseq2/normalized_counts.csv` - DESeq2 normalized counts
- `deseq2/plots/` - MA plots, PCA, sample correlation heatmaps

### 2. Simple Fold-Change Analysis
**Use when:** No replicates available or quick exploratory analysis needed

```bash
nextflow run main.nf \
    --input samplesheet.csv \
    --capstarrseq_diffexp false \
    ...
```

**Outputs:**
- `foldchange/results.csv` - RNA/DNA ratios for each region

## Troubleshooting

### Common Issues

**1. Bowtie2 index not found**
```
Error: Bowtie2 index files not found
```
**Solution:** Ensure `--bowtie2_index` points to the directory containing `.bt2` index files

**2. GTF file format issues**
```
Error: GTF file does not contain required fields
```
**Solution:** Ensure GTF follows standard format with gene_id attributes

**3. Memory errors**
```
Process exceeded memory limit
```
**Solution:** Increase memory allocation with `--max_memory 64.GB` or adjust process-specific resources in `conf/base.config`

### Debug Mode

Run with debug output:
```bash
nextflow run main.nf --input samplesheet.csv ... -with-report -with-trace -with-timeline
```

## Migration from Bpipe

This pipeline replaces the original Bpipe-based `capstarrseq.pipeline.groovy`. Key differences:

| Bpipe                          | Nextflow DSL2                    |
|--------------------------------|----------------------------------|
| `essential.vars.groovy`        | `--parameter` flags              |
| Branch-specific subdirectories | Flat output structure            |
| Manual resource allocation     | Automatic resource management    |
| Module loading (lmod)          | Wave/Conda automatic containers  |
| `targets.txt` / `contrasts.txt`| Samplesheet CSV                  |

### Converting Bpipe Variables

| Bpipe Variable              | Nextflow Parameter            |
|-----------------------------|-------------------------------|
| `ESSENTIAL_PROJECT`         | `--outdir`                    |
| `ESSENTIAL_BOWTIE_REF`      | `--bowtie2_index`             |
| `ESSENTIAL_GENESGTF`        | `--genes_gtf`                 |
| `ESSENTIAL_CHROMSIZES`      | `--chromsizes`                |
| `CAPSTARRSEQ_DIFFEXP`       | `--capstarrseq_diffexp`       |

## Credits

### Original Bpipe Pipeline
- **NGSpipe2go Framework**: IMB Bioinformatics Core, Mainz
- **Original Repository**: https://gitlab.rlp.net/imbforge/NGSpipe2go

### Nextflow Conversion
- Converted to Nextflow DSL2 by Seqera AI (2026)
- Modern workflow management with Wave container support
- Enhanced reproducibility and scalability

## Citations

If you use this pipeline, please cite:

- **Nextflow**: Di Tommaso, P., et al. (2017). Nextflow enables reproducible computational workflows. Nature Biotechnology, 35(4), 316-319.
- **Wave**: https://seqera.io/wave/
- **Original tools**: Please cite individual tools used in the pipeline (see MultiQC report)

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.


