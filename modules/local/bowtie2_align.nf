process BOWTIE2_ALIGN {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::bowtie2=2.5.1 bioconda::samtools=1.17'
    container "${params.bowtie2_container ?: 'biocontainers/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:1744f68fe955578c63054b55309e05b41c37a80d-0'}"

    input:
    tuple val(meta), path(reads)
    path index

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml",            emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def read_input = meta.single_end ? "-U ${reads}" : "-1 ${reads[0]} -2 ${reads[1]}"
    def index_name = index[0].toString().replaceAll(/\.rev\.[0-9]\.bt2[l]?$/, '')
    """
    bowtie2 \\
        -x ${index_name} \\
        ${read_input} \\
        --threads ${task.cpus} \\
        ${args} \\
        2> ${prefix}.bowtie2.log \\
        | samtools view -@ ${task.cpus} -bS -o ${prefix}.bam -

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(bowtie2 --version 2>&1 | head -n 1 | sed 's/.*version //; s/ .*//')
        samtools: \$(samtools --version | head -n 1 | sed 's/samtools //')
    END_VERSIONS
    """
}
