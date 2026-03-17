process DEEPTOOLS_BAMCOVERAGE {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::deeptools=3.5.2'
    container "${params.deeptools_container ?: 'biocontainers/deeptools:3.5.2--pyhdfd78af_1'}"

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("*.bigWig"), emit: bigwig
    path "versions.yml",               emit: versions

    when:
    params.run_deeptools

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bamCoverage \\
        --bam ${bam} \\
        --outFileName ${prefix}.bigWig \\
        --outFileFormat bigwig \\
        --numberOfProcessors ${task.cpus} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deeptools: \$(bamCoverage --version 2>&1 | sed 's/bamCoverage //')
    END_VERSIONS
    """
}
