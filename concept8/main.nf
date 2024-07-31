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
    .fromPath("${params.input}", checkIfExists: true)
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

include { DRY } from './modules/local/dry'
include { FOLD } from './modules/local/fold'
include { WASH } from './modules/local/wash'

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

    DRY.out.clothes
        .flatten()
        .map{it -> tuple(it.baseName.replace("_dry", ""), it) }
        .set{ ch_dry_clothes }
    
    ch_dirty_clothes
        .map{ it -> tuple(it[1].baseName, it[0])}
        .set { ch_clothes_metadata }

    ch_clothes_metadata
        .join(ch_dry_clothes, by:[0, 0])
        .map{it -> tuple(it[1], it[2])}
        .branch { it ->
            pairs: it[1].baseName.contains('mitten') || it[1].baseName.contains('glove') || it[1].baseName.contains('sock')
            other: true
        }
        .set{ ch_separated_dry_clothes }

    ch_separated_dry_clothes.pairs
        .groupTuple(by: 0)
        .set { ch_separated_grouped_dry_clothes }

    ch_separated_grouped_dry_clothes
        .mix(ch_separated_dry_clothes.other)
        .set {ch_ready_for_folding }

    FOLD(ch_ready_for_folding)
}