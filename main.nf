#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * STARR-seq and CapSTARR-seq Analysis Pipeline
 * Converted from Bpipe to Nextflow DSL2
 */

// Include workflows
include { STARRSEQ_WORKFLOW     } from './workflows/starrseq'
include { CAPSTARRSEQ_WORKFLOW  } from './workflows/capstarrseq'

// Main workflow
workflow {
    main:
    // Print pipeline header
    log.info """
        ==============================================
        STARR-seq / CapSTARR-seq Analysis Pipeline
        ==============================================
        Pipeline Mode   : ${params.capstarrseq_mode ? 'CapSTARR-seq' : 'STARR-seq'}
        Input Directory : ${params.input}
        Output Directory: ${params.outdir}
        Reference Genome: ${params.genome}
        ==============================================
        """.stripIndent()
    
    // Validate required parameters
    if (!params.input) {
        log.error "ERROR: --input parameter is required!"
        exit 1
    }
    
    // Create input channel from samplesheet or directory
    def ch_input = params.input.endsWith('.csv') ?
        channel.fromPath(params.input)
            .splitCsv(header: true)
            .map { row ->
                def meta = [
                    id: row.sample,
                    single_end: row.single_end.toBoolean(),
                    type: row.type ?: 'input',
                    condition: row.condition ?: 'control'
                ]
                def reads = row.single_end.toBoolean() ? 
                    file(row.fastq_1) : 
                    [file(row.fastq_1), file(row.fastq_2)]
                tuple(meta, reads)
            } :
        channel.fromFilePairs("${params.input}/*_R{1,2}*.fastq.gz", size: -1)
            .map { sample_id, files ->
                def meta = [
                    id: sample_id,
                    single_end: files.size() == 1,
                    type: 'input',
                    condition: 'control'
                ]
                tuple(meta, files)
            }
    
    // Run appropriate workflow based on mode
    if (params.capstarrseq_mode) {
        CAPSTARRSEQ_WORKFLOW(ch_input)
    } else {
        STARRSEQ_WORKFLOW(ch_input)
    }
}
