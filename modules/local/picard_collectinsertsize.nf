process PICARD_COLLECTINSERTSIZE {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::picard=3.0.0'
    container "${params.picard_container ?: 'biocontainers/picard:3.0.0--hdfd78af_1'}"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.txt"),    emit: metrics
    tuple val(meta), path("*.pdf"),    emit: histogram
    path "versions.yml",               emit: versions

    when:
    !meta.single_end

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def avail_mem = task.memory ? "-Xmx${task.memory.toGiga()}g" : ''
    """
    picard ${avail_mem} CollectInsertSizeMetrics \\
        ${args} \\
        INPUT=${bam} \\
        OUTPUT=${prefix}.insert_size_metrics.txt \\
        HISTOGRAM_FILE=${prefix}.insert_size_histogram.pdf \\
        VALIDATION_STRINGENCY=LENIENT

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        picard: \$(picard CollectInsertSizeMetrics --version 2>&1 | grep -o 'Version:.*' | sed 's/Version://')
    END_VERSIONS
    """
}
