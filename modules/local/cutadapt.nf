process CUTADAPT {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::cutadapt=4.4'
    container (params.cutadapt_container ?: 'biocontainers/cutadapt:4.4--py39hf95cd2a_1')

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_trimmed*.fastq.gz"), emit: reads
    tuple val(meta), path("*.log"),               emit: log
    path "versions.yml",                          emit: versions

    when:
    params.run_cutadapt

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    if (meta.single_end) {
        """
        cutadapt \\
            ${args} \\
            -j ${task.cpus} \\
            -o ${prefix}_trimmed.fastq.gz \\
            ${reads} \\
            > ${prefix}_cutadapt.log

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            cutadapt: \$(cutadapt --version)
        END_VERSIONS
        """
    } else {
        """
        cutadapt \\
            ${args} \\
            -j ${task.cpus} \\
            -o ${prefix}_trimmed_R1.fastq.gz \\
            -p ${prefix}_trimmed_R2.fastq.gz \\
            ${reads[0]} ${reads[1]} \\
            > ${prefix}_cutadapt.log

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            cutadapt: \$(cutadapt --version)
        END_VERSIONS
        """
    }
}
