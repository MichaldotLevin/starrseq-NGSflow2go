process PICARD_MARKDUPLICATES {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::picard=3.0.0'
    container "${params.picard_container ?: 'biocontainers/picard:3.0.0--hdfd78af_1'}"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.marked.bam"), emit: bam
    tuple val(meta), path("*.metrics.txt"), emit: metrics
    path "versions.yml",                    emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def avail_mem = task.memory ? "-Xmx${task.memory.toGiga()}g" : ''
    """
    picard ${avail_mem} MarkDuplicates \\
        ${args} \\
        INPUT=${bam} \\
        OUTPUT=${prefix}.marked.bam \\
        METRICS_FILE=${prefix}.markdup_metrics.txt \\
        ASSUME_SORTED=true \\
        VALIDATION_STRINGENCY=LENIENT

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        picard: \$(picard MarkDuplicates --version 2>&1 | grep -o 'Version:.*' | sed 's/Version://')
    END_VERSIONS
    """
}
