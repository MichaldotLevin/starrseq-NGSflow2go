process MULTIQC {
    label 'process_single'

    conda 'bioconda::multiqc=1.15'
    container "${params.multiqc_container ?: 'biocontainers/multiqc:1.15--pyhdfd78af_0'}"

    input:
    path multiqc_files
    path multiqc_config
    path multiqc_logo

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data",        emit: data
    path "versions.yml",        emit: versions

    script:
    def args = task.ext.args ?: ''
    def config = multiqc_config ? "--config ${multiqc_config}" : ''
    def logo = multiqc_logo ? "--logo ${multiqc_logo}" : ''
    """
    multiqc \\
        ${args} \\
        ${config} \\
        ${logo} \\
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$(multiqc --version | sed 's/multiqc, version //')
    END_VERSIONS
    """
}
