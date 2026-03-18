process MACS2_CALLPEAK {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::macs2=2.2.7.1'
    container (params.macs2_container ?: 'biocontainers/macs2:2.2.7.1--py39hf95cd2a_4')

    input:
    tuple val(meta), path(bam), path(bai)
    val gsize

    output:
    tuple val(meta), path("*_peaks.narrowPeak"), emit: peaks
    tuple val(meta), path("*_summits.bed"),      emit: summits
    tuple val(meta), path("*.xls"),              emit: xls
    path "versions.yml",                         emit: versions

    when:
    params.run_macs2

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def format = meta.single_end ? 'BAM' : 'BAMPE'
    """
    macs2 callpeak \\
        -t ${bam} \\
        -f ${format} \\
        -g ${gsize} \\
        -n ${prefix} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        macs2: \$(macs2 --version 2>&1 | sed 's/macs2 //')
    END_VERSIONS
    """
}
