# Seventh concept

The purpose of this section is to 
1. Channel operators
  - joinby
  - mix
  - grouptuple

Things are going to get a little crazy. This is going to take our figurative clothes that have been washed and dried, and then do some unnecessary channel operations in order to get the items folded and packaged correctly.

This is going to go fast.

## Step 1. Separating dry clothes

A shirt can be folded on its own, but a sock or mitten generally has a pair. We need to take our clothing and match (or 'join') it to its original metadata so similar items can be paired together.

### Step 1A. Flatten the collection

First, we need to separate our collected files into individual articles of clothing. This can be done with `flatten`.
```groovy
DRY.out.clothes
  .flatten()
  .view()
```
### Step 1B. Create a joining value for the dry clothes

To simplify (or complicate) things, we're going to map a string value to our channel that can be used to join another channel with the metadata.
```groovy
DRY.out.clothes
  .flatten()
  .map{it -> tuple(it.baseName.replace("_dry", ""), it) }
  .view()
  .set{ ch_dry_clothes }
```

### Step 1C. Create a joining value for the metadata

First, we need to remember what this channel looks like
```groovy
ch_dirty_clothes
  .view()
```

To simplify (or complicate) things, we're going to map a string value to our channel that can be used to join another channel with the clothes. 
```groovy
ch_dirty_clothes
  .map{ it -> tuple(it[1].baseName, it[0])}
  .view()
  .set { ch_clothes_metadata }
```


### Step 1D. Joining the two channels

It looks like the first tuple position in each channel can be used to join these two together.

```groovy
ch_clothes_metadata
  .join(ch_dry_clothes, by:[0, 0])
  .view()
```
### Step 1E. Dropping the element we used to join the channels

For "simplicity", the element we created to join the two channels is going to be dropped with `map`.
```groovy
ch_clothes_metadata
  .join(ch_dry_clothes, by:[0, 0])
  .map{it -> tuple(it[1], it[2])}
  .view()
```

### Step 1F. Branching the paired and non-paired clothing

Mittens, gloves, boots, socks, etc come in pairs. These are going to be separated from the rest of the clothes so they can be folded together instead of separately.

```groovy
ch_clothes_metadata
  .join(ch_dry_clothes, by:[0, 0])
  .map{it -> tuple(it[1], it[2])}
  .branch { it ->
    pairs: it[1].baseName.contains('mitten') || it[1].baseName.contains('glove') || it[1].baseName.contains('sock')
    other: true
  }
  .set{ ch_separated_dry_clothes }
```

### Step 1G. Grouping pairs

Now that the paired items are separated, we can group them by their meta value.
```groovy
ch_separated_dry_clothes.pairs
  .groupTuple(by: 0)
  .view()
  .set { ch_separated_grouped_dry_clothes }
```

### Step 1H. Mixing the dry clothes back into one channel
```groovy
  ch_separated_grouped_dry_clothes
    .mix(ch_separated_dry_clothes.other)
    .view()
    .set {ch_ready_for_folding }
```

### Step 1I. Creating another process

There are some new features with this channel, notably that we can read in a tuple. This means that we can add more relevant information to the directives.

```groovy
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
```

Note that the `tag` directive is dependent on the meta value.


### Step 1J. Folding the clothes

Now that the process and channel are ready, the clothes can finally be folded.
```groovy
  FOLD(ch_ready_for_folding)
```


## Catching Up

To bring this script to the main directory for running:

```bash
cp concept7/main.nf .
```
