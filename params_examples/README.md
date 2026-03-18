# Parameter File Examples

This directory contains example parameter files for different use cases of the STARR-seq / CapSTARR-seq pipeline.

## How to Use Parameter Files

You can provide a parameter file to Nextflow using the `-params-file` option:

```bash
nextflow run main.nf -params-file params.yaml -profile docker
```

Or use one of the example configurations:

```bash
nextflow run main.nf -params-file params_examples/starrseq_example.yaml -profile docker
```

## Available Examples

### 1. `starrseq_example.yaml`
**Standard STARR-seq analysis** with:
- Adapter trimming
- Bowtie2 alignment
- Duplicate marking
- MACS2 peak calling
- PhantomPeakQualTools QC
- deepTools coverage tracks

**Use this for**: Traditional STARR-seq experiments where you want to identify active regulatory elements.

### 2. `capstarrseq_example.yaml`
**CapSTARR-seq analysis** with:
- Adapter trimming
- Bowtie2 alignment
- RNA-seq quantification with featureCounts
- DESeq2 differential expression analysis
- dupRadar duplication analysis
- deepTools coverage tracks

**Use this for**: CapSTARR-seq experiments where you want to quantify enhancer activity and perform differential expression analysis.

### 3. `test_example.yaml`
**Quick test run** with:
- Minimal resource requirements
- Faster processing options
- Suitable for testing pipeline setup

**Use this for**: Testing the pipeline installation or running on small test datasets.

## Customizing Parameters

### 1. Container Images
All example files include explicit container specifications using BioContainers. You can:
- **Keep defaults**: Use the BioContainers images specified in the examples (recommended)
- **Use Wave**: Replace with Wave-built containers for optimized performance
- **Custom registry**: Specify your own container registry

```yaml
# Default BioContainers (recommended)
fastqc_container: 'biocontainers/fastqc:0.12.1--hdfd78af_0'

# Wave container
fastqc_container: 'community.wave.seqera.io/library/fastqc:0.12.1--abc123'

# Custom registry
fastqc_container: 'your-registry.io/fastqc:custom'
```

See the main `params.yaml` file for complete container documentation and all available tools.

### 2. File Paths and Basic Setup
1. **Copy the template**: Start with the main `params.yaml` file or one of the examples
2. **Edit values**: Modify parameters according to your experiment
3. **Required parameters**: Make sure to set these minimum required values:
   - `input`: Path to your samplesheet
   - `outdir`: Where to save results
   - `bowtie2_index`: Path to your reference genome index
   - `chromsizes`: Path to chromosome sizes file
   - `genes_gtf`: Required for CapSTARR-seq mode
   - Container images for each tool you'll use

4. **Save and run**: Save your custom parameter file and provide it to Nextflow

## Common Parameter Combinations

### Enable quality control steps
```yaml
run_cutadapt: true
run_fastq_screen: true
run_phantompeak: true
fastq_screen_config: '/path/to/fastq_screen.conf'
```

### Use STARRPeaker instead of MACS2
```yaml
run_macs2: false
run_starrpeaker: true
```

### Adjust resource limits for HPC
```yaml
max_cpus: 32
max_memory: '256.GB'
max_time: '48.h'
```

### Use fold-change method for CapSTARR-seq
```yaml
capstarrseq_mode: true
capstarrseq_diffexp: false  # Use fold-change instead of DESeq2
foldchange_threshold: 2.0
```

## Parameter Validation

The pipeline will check for required parameters and provide helpful error messages if something is missing. Look for validation errors in the Nextflow output.

For a complete list of all available parameters, see the main `params.yaml` file in the root directory.

## Tips

- **Start simple**: Begin with a minimal configuration and add options as needed
- **Test first**: Use the test example with small data to verify your setup
- **Check paths**: Ensure all file paths are absolute or relative to where you run Nextflow
- **Resource limits**: Adjust `max_cpus`, `max_memory`, and `max_time` based on your compute environment
- **Container images**: You can specify custom container images for reproducibility

## Need Help?

See the main [README.md](../README.md) for complete pipeline documentation.
