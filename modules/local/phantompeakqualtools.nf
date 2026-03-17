process PHANTOMPEAKQUALTOOLS {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::phantompeakqualtools=1.2.2'
    container "${params.phantompeakqualtools_container ?: 'biocontainers/phantompeakqualtools:1.2.2--hdfd78af_2'}"

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("*.spp.out"), emit: spp
    tuple val(meta), path("*.pdf"),     emit: pdf
    path "versions.yml",                emit: versions

    when:
    params.run_phantompeak

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    run_spp.R \\
        -c=${bam} \\
        -savp=${prefix}.spp.pdf \\
        -out=${prefix}.spp.out \\
        -p=${task.cpus} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phantompeakqualtools: \$(run_spp.R --version 2>&1 | sed 's/SPP version //')
    END_VERSIONS
    """
}
