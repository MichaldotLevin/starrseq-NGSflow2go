process FASTQ_SCREEN {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::fastq-screen=0.15.3'
    container "${params.fastq_screen_container ?: 'biocontainers/fastq-screen:0.15.3--pl5321hdfd78af_0'}"

    input:
    tuple val(meta), path(reads)
    path config

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.txt"),  emit: txt
    path "versions.yml",             emit: versions

    when:
    params.run_fastq_screen

    script:
    def args = task.ext.args ?: ''
    """
    fastq_screen \\
        ${args} \\
        --conf ${config} \\
        --threads ${task.cpus} \\
        ${reads}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastq_screen: \$(fastq_screen --version 2>&1 | sed -n 's/.*version: //p')
    END_VERSIONS
    """
}
