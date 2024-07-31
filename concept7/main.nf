/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Laundry
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INPUT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// reading files into a channel
Channel
    .fromPath("sample_sheet.txt", checkIfExists: true)
    .splitCsv( header: true, sep: ',' )
    .map { it ->
        meta = [
            person:it.person,
            color:it.color,
            soil:it.soil,
            wash_instr:it.wash_instr,
            dry_instr:it.dry_instr
            ]
        tuple(meta, file(it.item, checkIfExists: true))
    }
    .set { ch_dirty_clothes }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PROCESS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
process DRY {
    tag 'drying'
    publishDir "dry_laundry", mode: 'copy'

    input:
    file(clothes)

    output:
    path("*_dry.txt"), emit: clothes
    
    shell:
    """
    dry
    """
}

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

process WASH {
    tag 'washing'
    publishDir "wet_laundry", mode: 'copy'

    input:
    file(clothes)

    output:
    path("*_wet.txt"), emit: clothes
    
    shell:
    """
    wash
    """
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    ch_dirty_clothes
        .branch { it ->
            red: it[0].color == 'red'
            all: true
        }
        .set { ch_clothes_branch }

    ch_collected_red_clothes = ch_clothes_branch.red.collect()

    ch_clothes_branch.all
        .collect()
        .set { ch_collected_other_clothes }

    ch_collected_red_clothes
        .mix(ch_collected_other_clothes)
        .set{ch_separated_clothes}

    WASH(ch_separated_clothes)

    DRY(WASH.out.clothes.collect())

    //DRY.out.clothes.view()
    //ch_dirty_clothes.view()

    DRY.out.clothes
        //.view()
        .flatten()
        //.view()
        .map{it -> tuple(it.baseName.replace("_dry", ""), it) }
        //.view{it[0]}
        .set{ ch_dry_clothes }
    
    ch_dirty_clothes
        //.view()
        .map{ it -> tuple(it[1].baseName, it[0])}
        //.view()
        .set { ch_clothes_metadata }

    ch_clothes_metadata
        //.view{it[1]}
        .join(ch_dry_clothes, by:[0, 0])
        //.view()
        .map{it -> tuple(it[1], it[2])}
        //.view()
        .branch { it ->
            pairs: it[1].baseName.contains('mitten') || it[1].baseName.contains('glove') || it[1].baseName.contains('sock')
            other: true
        }
        .set{ ch_separated_dry_clothes }

    ch_separated_dry_clothes.pairs
        //.view()
        .groupTuple(by: 0)
        //.view()
        .set { ch_separated_grouped_dry_clothes }

    ch_separated_grouped_dry_clothes
        .mix(ch_separated_dry_clothes.other)
        //.view()
        .set {ch_ready_for_folding }

    FOLD(ch_ready_for_folding)

}