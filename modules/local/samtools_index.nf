process SAMTOOLS_INDEX {
    tag "${meta.id}"
    label 'process_low'

    conda 'bioconda::samtools=1.17'
    container (params.samtools_container ?: 'biocontainers/samtools:1.17--h00cdaf9_0')

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path(bam), path("*.bai"), emit: bam_bai
    path "versions.yml",                       emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    samtools index \\
        ${args} \\
        -@ ${task.cpus} \\
        ${bam}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(samtools --version | head -n 1 | sed 's/samtools //')
    END_VERSIONS
    """
}
