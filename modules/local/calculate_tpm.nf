process CALCULATE_TPM {
    tag "${meta.id}"
    label 'process_low'

    conda 'conda-forge::r-base=4.2.2 bioconda::bioconductor-genomicfeatures=1.48.0'
    container (params.r_container ?: 'biocontainers/r-base:4.2.2')

    input:
    tuple val(meta), path(counts)
    path gtf

    output:
    tuple val(meta), path("*.tpm.txt"), emit: tpm
    path "versions.yml",                emit: versions

    when:
    params.capstarrseq_mode

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    calculate_tpm.R \\
        --counts ${counts} \\
        --gtf ${gtf} \\
        --output ${prefix}.tpm.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(R --version | head -n 1 | sed 's/R version //' | sed 's/ .*//')
    END_VERSIONS
    """
}
