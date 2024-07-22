# Sixth concept

The purpose of this section is to 
1. Introduction to Channel manipulation
  - branch
  - mix

Filtering is great, but then... how do the red shirts get washed?

There are a lot of operators, and this tutorial is going to use a few for training purposes.

The documentation on operators can be found at https://www.nextflow.io/docs/latest/operator.html


## Step 1. Create new channels with branch

In concept 5, we filtered out red clothing, but we do not actually want to filter these items out. We want to group them into their own load.

```groovy
ch_clothes
  .branch { it ->
    red: it[0].color != 'red'
    all: true
  }
  .set { ch_clothes_map }

ch_clothes_map.red.view{"red $it"}
ch_clothes_map.all.view{"not red $it"}
```

## Step 2. Collect each channel separatly for washing

By the way, these accomplish the same goals

```groovy
ch_collected_red_clothes = ch_clothes_map.red.collect()

ch_clothes_map.all
  .collect()
  .set { ch_collected_other_clothes }
```

## Step 3. Mix the two channels together so that everything gets washed

There are several ways to combine two channels. `mix` will take two channels and to create one as they are read in. `concat` is similar, but it waits for everything in the first channel to finish before it adds in the items from the next channel. 

```groovy
ch_collected_red_clothes
  .mix(ch_collected_other_clothes)
  .set{ch_separated_clothes}
```

## Step 4. Now use ch_separated_clothes in your workflow.

```groovy
workflow {
    ch_clothes
        .multiMap { it ->
            red: it[0].color != 'red'
            all: true
        }
        .set { ch_clothes_map }

    ch_collected_red_clothes = ch_clothes_map.red.collect()

    ch_clothes_map.all
        .collect()
        .set { ch_collected_other_clothes }

    ch_collected_red_clothes
        .mix(ch_collected_other_clothes)
        .set{ch_separated_clothes}

    WASH(ch_separated_clothes)

    DRY(WASH.out.clothes)
}
```

The washing step runs twice!!!

## Step 5. Collect resuls for washing

And if we are cheap, we can combine everything in one load for the dryer.

```groovy
workflow {
    ch_clothes
        .multiMap { it ->
            red: it[0].color != 'red'
            all: true
        }
        .set { ch_clothes_map }

    ch_collected_red_clothes = ch_clothes_map.red.collect()

    ch_clothes_map.all
        .collect()
        .set { ch_collected_other_clothes }

    ch_collected_red_clothes
        .mix(ch_collected_other_clothes)
        .set{ch_separated_clothes}

    WASH(ch_separated_clothes)

    DRY(WASH.out.clothes.collect())
}
```


## Catching Up

To bring this script to the main directory for running:

```bash
cp concept6/main.nf .
```