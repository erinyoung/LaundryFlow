# Fifth concept

The purpose of this section is to 
1. Channel operators : filter
2. Groovy functions

Now another topic of channel manipulation, with a focus on filter. First, we will filter based on a meta value, then we will filter using a custom groovy script.

## filter

Filter allows the removal of items from a channel.

This is the initial flow into the channel:
```groovy
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
    .set { ch_dirty_clothes }
```

Now to filter out all the 'red' items.
```groovy
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
    .filter{it[0].color != 'red'}
    .set { ch_dirty_clothes }
```

This will allow everything not labelled with 'red'.

## using a custom groovy function

Nextflow allows the use of groovy functions.


An example function
```groovy
def filter_clothes(meta) {
    def color = meta.color
    if (color == 'red') {
        return false
    } else if (color == 'denim') {
        return false
    } else {
        return true
    }
}
```

How it would be used
```groovy
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
    .filter{filter_clothes(it[0])}
    .set { ch_dirty_clothes }
```

This will filter out the 'red' and 'denim' colored items.

## Catching Up

Nothing in this concept is required for further concepts, but copying main.nf should not break anything.

```bash
cp concept5/main.nf .
```