process FILTER2HTSEQ {
    tag "${meta.id}"
    label 'process_low'

    conda 'conda-forge::sed=4.8'
    container (params.base_container ?: 'ubuntu:22.04')

    input:
    tuple val(meta), path(counts)

    output:
    tuple val(meta), path("*.htseq.txt"), emit: htseq
    path "versions.yml",                  emit: versions

    when:
    params.capstarrseq_mode

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # Remove header and reformat for downstream tools (htseq-count format)
    tail -n +3 ${counts} | \\
        cut -f1,7 > ${prefix}.htseq.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sed: \$(sed --version | head -n 1 | sed 's/sed (GNU sed) //')
    END_VERSIONS
    """
}
