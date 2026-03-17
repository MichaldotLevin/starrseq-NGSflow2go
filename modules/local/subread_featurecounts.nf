process SUBREAD_FEATURECOUNTS {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::subread=2.0.4'
    container "${params.subread_container ?: 'biocontainers/subread:2.0.4--h7132678_0'}"

    input:
    tuple val(meta), path(bam), path(bai)
    path gtf

    output:
    tuple val(meta), path("*.counts.txt"),        emit: counts
    tuple val(meta), path("*.counts.txt.summary"), emit: summary
    path "versions.yml",                          emit: versions

    when:
    params.capstarrseq_mode

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def pe_params = meta.single_end ? '' : '-p --countReadPairs'
    """
    featureCounts \\
        ${args} \\
        -T ${task.cpus} \\
        -a ${gtf} \\
        -o ${prefix}.counts.txt \\
        ${pe_params} \\
        ${bam}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        subread: \$(featureCounts -v 2>&1 | sed -n 's/featureCounts v//p')
    END_VERSIONS
    """
}
