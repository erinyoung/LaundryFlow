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
        tuple(meta, file(it.name, checkIfExists: true))
    }
    .set { ch_clothes }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PROCESS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
process DRY {
    tag 'drying clothes'
    time '1m'
    memory '8 GB'
    errorStrategy 'retry'
    maxRetries 2

    cpus 8
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
    tag 'washing clothes'
    time '1m'
    memory '8 GB'
    errorStrategy 'ignore'
    cpus 8
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
    WASH(ch_clothes.collect())

    DRY(WASH.out.clothes)
}