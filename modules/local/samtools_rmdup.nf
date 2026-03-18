process SAMTOOLS_RMDUP {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::samtools=1.17'
    container (params.samtools_container ?: 'biocontainers/samtools:1.17--h00cdaf9_0')

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.rmdup.bam"), emit: bam
    path "versions.yml",                  emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def is_single_end = meta.single_end ? '-s' : ''
    """
    samtools rmdup \\
        ${is_single_end} \\
        ${args} \\
        ${bam} \\
        ${prefix}.rmdup.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(samtools --version | head -n 1 | sed 's/samtools //')
    END_VERSIONS
    """
}
