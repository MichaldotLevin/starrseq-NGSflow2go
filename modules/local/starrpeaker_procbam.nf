process STARRPEAKER_PROCBAM {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::starrpeaker=1.3.2'
    container "${params.starrpeaker_container ?: 'biocontainers/starrpeaker:1.3.2--pyhdfd78af_0'}"

    input:
    tuple val(meta), path(input_bam), path(input_bai)
    tuple val(meta2), path(control_bam), path(control_bai)

    output:
    tuple val(meta), path("*.input.bam"),   emit: input_bam
    tuple val(meta), path("*.control.bam"), emit: control_bam
    path "versions.yml",                    emit: versions

    when:
    params.run_starrpeaker

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    starrpeaker procBam \\
        ${args} \\
        --input ${input_bam} \\
        --control ${control_bam} \\
        --output-prefix ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        starrpeaker: \$(starrpeaker --version 2>&1 | sed 's/STARRPeaker //')
    END_VERSIONS
    """
}
