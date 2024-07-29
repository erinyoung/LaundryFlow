process FOLD {
    tag "${meta.person}"
    publishDir "clean_clothes_basket/${meta.person}", mode: 'copy'

    input:
    tuple val(meta), file(clothes)

    output:
    path("*_folded.txt"), emit: clothes
    
    shell:
    """
    fold_clothes
    """
}
