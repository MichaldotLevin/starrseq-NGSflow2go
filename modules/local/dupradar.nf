process DUPRADAR {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::bioconductor-dupradar=1.26.0'
    container (params.dupradar_container ?: 'biocontainers/bioconductor-dupradar:1.26.0--r41hdfd78af_0')

    input:
    tuple val(meta), path(bam), path(bai)
    path gtf

    output:
    tuple val(meta), path("*_duprateExpDens.pdf"),     emit: density_plot
    tuple val(meta), path("*_expressionHist.pdf"),     emit: hist_plot
    tuple val(meta), path("*_dupMatrix.txt"),          emit: dupmatrix
    path "versions.yml",                               emit: versions

    when:
    params.capstarrseq_mode && params.run_dupradar

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def paired_end = meta.single_end ? 'FALSE' : 'TRUE'
    """
    #!/usr/bin/env Rscript
    library(dupRadar)

    dm <- analyzeDuprates(
        "${bam}",
        "${gtf}",
        stranded = 0,
        paired = ${paired_end},
        threads = ${task.cpus}
    )

    write.table(dm, file = "${prefix}_dupMatrix.txt", quote = FALSE, sep = "\\t")

    pdf("${prefix}_duprateExpDens.pdf")
    duprateExpDensPlot(dm)
    dev.off()

    pdf("${prefix}_expressionHist.pdf")
    expressionHist(dm)
    dev.off()

    cat("${task.process}:\\n  dupRadar:", as.character(packageVersion("dupRadar")), "\\n", file = "versions.yml")
    """
}
