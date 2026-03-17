process CAPSTARRSEQ_FOLDCHANGE {
    label 'process_medium'

    conda 'conda-forge::r-base=4.2.2'
    container "${params.r_container ?: 'biocontainers/r-base:4.2.2'}"

    input:
    path counts
    path samplesheet

    output:
    path "foldchange_results.txt",    emit: results
    path "foldchange_plots.pdf",      emit: plots
    path "versions.yml",              emit: versions

    when:
    params.capstarrseq_mode && !params.capstarrseq_diffexp

    script:
    def args = task.ext.args ?: ''
    """
    capstarrseq_foldchange.R \\
        --counts ${counts} \\
        --samplesheet ${samplesheet} \\
        --output-prefix foldchange \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(R --version | head -n 1 | sed 's/R version //' | sed 's/ .*//')
    END_VERSIONS
    """
}
