/*
 * CapSTARR-seq Analysis Workflow
 * Combines STARR-seq pipeline with RNA-seq quantification
 */

// Import modules
include { FASTQC                        } from '../modules/local/fastqc'
include { FASTQ_SCREEN                  } from '../modules/local/fastq_screen'
include { CUTADAPT                      } from '../modules/local/cutadapt'
include { BOWTIE2_ALIGN                 } from '../modules/local/bowtie2_align'
include { SAMTOOLS_SORT                 } from '../modules/local/samtools_sort'
include { SAMTOOLS_INDEX                } from '../modules/local/samtools_index'
include { FILTER_BOWTIE2_UNIQUE         } from '../modules/local/filter_bowtie2_unique'
include { PICARD_MARKDUPLICATES         } from '../modules/local/picard_markduplicates'
include { SAMTOOLS_RMDUP                } from '../modules/local/samtools_rmdup'
include { DEEPTOOLS_BAMCOVERAGE         } from '../modules/local/deeptools_bamcoverage'
include { MACS2_CALLPEAK                } from '../modules/local/macs2_callpeak'
include { STARRPEAKER_PROCBAM           } from '../modules/local/starrpeaker_procbam'
include { STARRPEAKER_CALLPEAK          } from '../modules/local/starrpeaker_callpeak'
include { PICARD_COLLECTINSERTSIZE      } from '../modules/local/picard_collectinsertsize'
include { PHANTOMPEAKQUALTOOLS          } from '../modules/local/phantompeakqualtools'
include { SUBREAD_FEATURECOUNTS         } from '../modules/local/subread_featurecounts'
include { FILTER2HTSEQ                  } from '../modules/local/filter2htseq'
include { CALCULATE_TPM                 } from '../modules/local/calculate_tpm'
include { DESEQ2_DIFFERENTIAL           } from '../modules/local/deseq2_differential'
include { CAPSTARRSEQ_FOLDCHANGE        } from '../modules/local/capstarrseq_foldchange'
include { DUPRADAR                      } from '../modules/local/dupradar'
include { MULTIQC                       } from '../modules/local/multiqc'

workflow CAPSTARRSEQ_WORKFLOW {
    take:
    ch_input

    main:
    // Input channel is passed from main workflow

    // QC on raw reads
    FASTQC(ch_input)
    
    // Optional: FastQ Screen
    if (params.run_fastq_screen) {
        FASTQ_SCREEN(
            ch_input,
            file(params.fastq_screen_config)
        )
    }

    // Optional: Adapter trimming
    def trimmed_ch = params.run_cutadapt ? CUTADAPT(ch_input).reads : ch_input

    // Alignment with Bowtie2
    BOWTIE2_ALIGN(
        trimmed_ch,
        channel.fromPath("${params.bowtie2_index}*").collect()
    )

    // Sort BAM files
    SAMTOOLS_SORT(BOWTIE2_ALIGN.out.bam)

    // Filter unique mappings
    FILTER_BOWTIE2_UNIQUE(SAMTOOLS_SORT.out.bam)

    // Sort filtered BAMs
    SAMTOOLS_SORT(FILTER_BOWTIE2_UNIQUE.out.bam)
    def sorted_unique_ch = SAMTOOLS_SORT.out.bam

    // Branch into with/without deduplication
    sorted_unique_ch.branch { _meta, _bam ->
        with_dedup: true
        without_dedup: true
    }.set { branched_ch }

    // Path 1: Mark duplicates (keep all reads)
    PICARD_MARKDUPLICATES(branched_ch.with_dedup)
    SAMTOOLS_INDEX(PICARD_MARKDUPLICATES.out.bam)
    def with_dedup_indexed = SAMTOOLS_INDEX.out.bam_bai

    // Path 2: Remove duplicates
    SAMTOOLS_RMDUP(branched_ch.without_dedup)
    SAMTOOLS_INDEX(SAMTOOLS_RMDUP.out.bam)
    def without_dedup_indexed = SAMTOOLS_INDEX.out.bam_bai

    // Merge both paths for downstream analysis
    def all_indexed = with_dedup_indexed.mix(without_dedup_indexed)

    // Insert size metrics (paired-end only)
    PICARD_COLLECTINSERTSIZE(all_indexed.map { meta, bam, _bai -> tuple(meta, bam) })

    // Coverage tracks
    if (params.run_deeptools) {
        DEEPTOOLS_BAMCOVERAGE(all_indexed)
    }

    // Peak calling with MACS2
    if (params.run_macs2) {
        MACS2_CALLPEAK(
            all_indexed,
            params.macs2_gsize
        )
    }

    // Peak calling with STARRPeaker
    if (params.run_starrpeaker) {
        // Split into input and control
        def input_bams = all_indexed.filter { meta, _bam, _bai -> meta.type == 'input' }
        def control_bams = all_indexed.filter { meta, _bam, _bai -> meta.type == 'control' }

        // Process BAMs for STARRPeaker
        STARRPEAKER_PROCBAM(
            input_bams,
            control_bams
        )

        // Call peaks
        STARRPEAKER_CALLPEAK(
            STARRPEAKER_PROCBAM.out.input_bam.join(STARRPEAKER_PROCBAM.out.control_bam),
            file(params.chromsizes)
        )
    }

    // PhantomPeak quality tools
    if (params.run_phantompeak) {
        PHANTOMPEAKQUALTOOLS(all_indexed)
    }

    // ==========================================
    // CapSTARR-seq Specific: RNA-seq Analysis
    // ==========================================

    // Read quantification with featureCounts
    SUBREAD_FEATURECOUNTS(
        all_indexed,
        file(params.genes_gtf)
    )

    // Convert to htseq format
    FILTER2HTSEQ(SUBREAD_FEATURECOUNTS.out.counts)

    // Calculate TPM
    CALCULATE_TPM(
        SUBREAD_FEATURECOUNTS.out.counts,
        file(params.genes_gtf)
    )

    // Differential expression analysis
    if (params.capstarrseq_diffexp) {
        // DESeq2 analysis
        def all_counts = FILTER2HTSEQ.out.htseq.map { _meta, htseq -> htseq }.collect()
        
        DESEQ2_DIFFERENTIAL(
            all_counts,
            file(params.samplesheet)
        )
    } else {
        // Simple fold-change analysis
        def all_counts = FILTER2HTSEQ.out.htseq.map { _meta, htseq -> htseq }.collect()
        
        CAPSTARRSEQ_FOLDCHANGE(
            all_counts,
            file(params.samplesheet)
        )
    }

    // Optional: dupRadar analysis
    if (params.run_dupradar) {
        DUPRADAR(
            all_indexed,
            file(params.genes_gtf)
        )
    }

    // MultiQC
    def multiqc_files = channel.empty()
        .mix(FASTQC.out.zip.map { _meta, zip -> zip })
        .mix(BOWTIE2_ALIGN.out.log.map { _meta, log -> log })
        .mix(PICARD_MARKDUPLICATES.out.metrics.map { _meta, metrics -> metrics })
        .mix(SUBREAD_FEATURECOUNTS.out.summary.map { _meta, summary -> summary })
        .collect()

    MULTIQC(
        multiqc_files,
        file(params.multiqc_config ?: 'NO_FILE'),
        file(params.multiqc_logo ?: 'NO_FILE')
    )

    emit:
    multiqc_report = MULTIQC.out.report
    deseq2_results = params.capstarrseq_diffexp ? DESEQ2_DIFFERENTIAL.out.results : null
    foldchange_results = !params.capstarrseq_diffexp ? CAPSTARRSEQ_FOLDCHANGE.out.results : null
}
