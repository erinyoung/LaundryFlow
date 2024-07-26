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
    .set { ch_clothes }


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
    ch_clothes
        .branch { it ->
            red: it[0].color == 'red'
            all: true
        }
        .set { ch_clothes_branch }

    //ch_clothes_branch.red.view{"red $it"}
    //ch_clothes_branch.all.view{"not red $it"}

    ch_collected_red_clothes = ch_clothes_branch.red.collect()

    ch_clothes_branch.all
        .collect()
        .set { ch_collected_other_clothes }

    ch_collected_red_clothes
        .mix(ch_collected_other_clothes)
        .set{ch_separated_clothes}

    WASH(ch_separated_clothes)

    DRY(WASH.out.clothes.collect())
}