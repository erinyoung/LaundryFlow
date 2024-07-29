process DRY {
    tag 'drying'
    publishDir "dry_laundry", mode: 'copy'
    container "quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0"

    input:
    file(clothes)

    output:
    path("*_dry.txt"), emit: clothes
    
    shell:
    """
    dry
    """
}
