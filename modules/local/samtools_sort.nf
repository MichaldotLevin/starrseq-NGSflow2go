process SAMTOOLS_SORT {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::samtools=1.17'
    container "${params.samtools_container ?: 'biocontainers/samtools:1.17--h00cdaf9_0'}"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.sorted.bam"), emit: bam
    path "versions.yml",                   emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    samtools sort \\
        ${args} \\
        -@ ${task.cpus} \\
        -o ${prefix}.sorted.bam \\
        ${bam}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(samtools --version | head -n 1 | sed 's/samtools //')
    END_VERSIONS
    """
}
