process STARRPEAKER_CALLPEAK {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::starrpeaker=1.3.2'
    container (params.starrpeaker_container ?: 'biocontainers/starrpeaker:1.3.2--pyhdfd78af_0')

    input:
    tuple val(meta), path(input_bam), path(control_bam)
    path chromsizes

    output:
    tuple val(meta), path("*_peaks.bed"),   emit: peaks
    tuple val(meta), path("*_cov.bw"),      emit: coverage
    path "versions.yml",                    emit: versions

    when:
    params.run_starrpeaker

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    starrpeaker callPeak \\
        ${args} \\
        --input ${input_bam} \\
        --control ${control_bam} \\
        --chromsizes ${chromsizes} \\
        --prefix ${prefix} \\
        --threads ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        starrpeaker: \$(starrpeaker --version 2>&1 | sed 's/STARRPeaker //')
    END_VERSIONS
    """
}
