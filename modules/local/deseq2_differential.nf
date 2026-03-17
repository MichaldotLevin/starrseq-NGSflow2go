process DESEQ2_DIFFERENTIAL {
    label 'process_medium'

    conda 'bioconda::bioconductor-deseq2=1.36.0'
    container "${params.deseq2_container ?: 'biocontainers/bioconductor-deseq2:1.36.0--r41hdfd78af_0'}"

    input:
    path counts
    path samplesheet

    output:
    path "deseq2_results.txt",        emit: results
    path "deseq2_normalized.txt",     emit: normalized
    path "deseq2_plots.pdf",          emit: plots
    path "versions.yml",              emit: versions

    when:
    params.capstarrseq_mode && params.capstarrseq_diffexp

    script:
    def args = task.ext.args ?: ''
    """
    deseq2_analysis.R \\
        --counts ${counts} \\
        --samplesheet ${samplesheet} \\
        --output-prefix deseq2 \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(R --version | head -n 1 | sed 's/R version //' | sed 's/ .*//')
        DESeq2: \$(Rscript -e "cat(as.character(packageVersion('DESeq2')))")
    END_VERSIONS
    """
}
