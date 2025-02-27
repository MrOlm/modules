process FASTK_FASTK {
    tag "$meta.id"
    label 'process_medium'

    if (params.enable_conda) {
        error "Conda environments cannot be used when using the FastK tool. Please use docker or singularity containers."
    }
    container 'ghcr.io/nbisweden/fastk_genescopefk_merquryfk:1.0'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.hist")               , emit: hist
    tuple val(meta), path("*.ktab*", hidden: true), emit: ktab, optional: true
    tuple val(meta), path("*.prof*", hidden: true), emit: prof, optional: true
    path "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def FASTK_VERSION = 'f18a4e6d2207539f7b84461daebc54530a9559b0'
    """
    FastK \\
        $args \\
        -T$task.cpus \\
        -N${prefix}_fk \\
        $reads

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastk: $FASTK_VERSION
    END_VERSIONS
    """
}
