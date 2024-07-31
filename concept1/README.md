# First concept

The purpose of this section is to 
1. create a nextflow workflow
2. read in files into a channel
3. put those items through a process
4. save those files somewhere

In the three dimensional world, we would need to take the dirty clothes in the laundry basket (or hamper in some regions) and put them in the washing machine.

In nextflow, the files representing these clothes are read into a [channel](https://www.nextflow.io/docs/latest/channel.html), which connects the files to a process. Processes are then connected together with other channels.

## Step 1.

Create a `main.nf` file.
```bash
touch main.nf
```

The filename `main.nf` is the default workflow file name. Nextflow will automatically look for this file. 

```bash
nextflow run .
```

<details>
  <summary>Click to see output</summary>

```bash
$ nextflow run .

 N E X T F L O W   ~  version 24.04.3

Launching `./main.nf` [thirsty_kalman] DSL2 - revision: 0000000000

```

</details>



This file could be named something different, nextflow would just need to be given the name of the file instead of the directory this file was in.

```bash
nextflow run other_name.nf
```


## Step 2.

We need a channel for all these files, so add the following line to your `main.nf` file:
```groovy
ch_clothes = Channel.fromPath("basket/*")
```

We can see everything in this channel with `.view()`
```groovy
ch_clothes.view()
```

<details>
  <summary>Click to see output</summary>

```bash
$ nextflow run .

 N E X T F L O W   ~  version 24.04.3

Launching `main.nf` [condescending_payne] DSL2 - revision: 880a0e3c87

/workspace/LaundryFlow/basket/1_sock.txt
/workspace/LaundryFlow/basket/2_sock.txt
/workspace/LaundryFlow/basket/3_shirt.txt
/workspace/LaundryFlow/basket/4_jeans.txt
/workspace/LaundryFlow/basket/5_hat.txt
/workspace/LaundryFlow/basket/6_shirt.txt
/workspace/LaundryFlow/basket/7_mitten.txt
/workspace/LaundryFlow/basket/8_mitten.txt
/workspace/LaundryFlow/basket/9_scarf.txt
/workspace/LaundryFlow/basket/10_sock.txt
/workspace/LaundryFlow/basket/11_sock.txt
/workspace/LaundryFlow/basket/12_dress.txt
/workspace/LaundryFlow/basket/13_jacket.txt
/workspace/LaundryFlow/basket/14_pants.txt
/workspace/LaundryFlow/basket/15_sweater.txt
/workspace/LaundryFlow/basket/16_skirt.txt
/workspace/LaundryFlow/basket/17_shirt.txt
/workspace/LaundryFlow/basket/18_shirt.txt
/workspace/LaundryFlow/basket/19_sock.txt
/workspace/LaundryFlow/basket/20_sock.txt
/workspace/LaundryFlow/basket/21_shorts.txt
/workspace/LaundryFlow/basket/22_sock.txt
/workspace/LaundryFlow/basket/23_mittens.txt
/workspace/LaundryFlow/basket/24_swimsuit.txt
/workspace/LaundryFlow/basket/25_swimsuit.txt
/workspace/LaundryFlow/basket/26_hoodie.txt
/workspace/LaundryFlow/basket/27_shirt_26.txt
/workspace/LaundryFlow/basket/28_leggings.txt
/workspace/LaundryFlow/basket/29_scarf.txt
/workspace/LaundryFlow/basket/30_hat.txt
/workspace/LaundryFlow/basket/31_jacket.txt
/workspace/LaundryFlow/basket/32_shirt.txt
/workspace/LaundryFlow/basket/33_pants.txt
/workspace/LaundryFlow/basket/34_jeans.txt
/workspace/LaundryFlow/basket/35_jeans.txt
/workspace/LaundryFlow/basket/36_jeans.txt
/workspace/LaundryFlow/basket/37_dress.txt
/workspace/LaundryFlow/basket/38_shirt.txt
/workspace/LaundryFlow/basket/39_jeans.txt
/workspace/LaundryFlow/basket/40_shirt.txt
/workspace/LaundryFlow/basket/41_cardigan.txt
/workspace/LaundryFlow/basket/42_glove.txt
/workspace/LaundryFlow/basket/43_glove.txt
/workspace/LaundryFlow/basket/44_socks.txt
/workspace/LaundryFlow/basket/45_socks.txt
/workspace/LaundryFlow/basket/46_hat.txt
/workspace/LaundryFlow/basket/47_scarf.txt
/workspace/LaundryFlow/basket/48_shorts.txt
/workspace/LaundryFlow/basket/49_shorts.txt
/workspace/LaundryFlow/basket/50_shorts.txt
```

</details>



We can add text to view with "{}".
```groovy
ch_clothes.view{"clothing file found: $it"}
```

<details>
  <summary>Click to see output</summary>

```bash
$ nextflow run .

 N E X T F L O W   ~  version 24.04.3

Launching `main.nf` [festering_picasso] DSL2 - revision: 18350f75d4

clothing file found: /workspace/LaundryFlow/basket/1_sock.txt
clothing file found: /workspace/LaundryFlow/basket/2_sock.txt
clothing file found: /workspace/LaundryFlow/basket/3_shirt.txt
clothing file found: /workspace/LaundryFlow/basket/4_jeans.txt
clothing file found: /workspace/LaundryFlow/basket/5_hat.txt
clothing file found: /workspace/LaundryFlow/basket/6_shirt.txt
clothing file found: /workspace/LaundryFlow/basket/7_mitten.txt
clothing file found: /workspace/LaundryFlow/basket/8_mitten.txt
clothing file found: /workspace/LaundryFlow/basket/9_scarf.txt
clothing file found: /workspace/LaundryFlow/basket/10_sock.txt
clothing file found: /workspace/LaundryFlow/basket/11_sock.txt
clothing file found: /workspace/LaundryFlow/basket/12_dress.txt
clothing file found: /workspace/LaundryFlow/basket/13_jacket.txt
clothing file found: /workspace/LaundryFlow/basket/14_pants.txt
clothing file found: /workspace/LaundryFlow/basket/15_sweater.txt
clothing file found: /workspace/LaundryFlow/basket/16_skirt.txt
clothing file found: /workspace/LaundryFlow/basket/17_shirt.txt
clothing file found: /workspace/LaundryFlow/basket/18_shirt.txt
clothing file found: /workspace/LaundryFlow/basket/19_sock.txt
clothing file found: /workspace/LaundryFlow/basket/20_sock.txt
clothing file found: /workspace/LaundryFlow/basket/21_shorts.txt
clothing file found: /workspace/LaundryFlow/basket/22_sock.txt
clothing file found: /workspace/LaundryFlow/basket/23_mittens.txt
clothing file found: /workspace/LaundryFlow/basket/24_swimsuit.txt
clothing file found: /workspace/LaundryFlow/basket/25_swimsuit.txt
clothing file found: /workspace/LaundryFlow/basket/26_hoodie.txt
clothing file found: /workspace/LaundryFlow/basket/27_shirt_26.txt
clothing file found: /workspace/LaundryFlow/basket/28_leggings.txt
clothing file found: /workspace/LaundryFlow/basket/29_scarf.txt
clothing file found: /workspace/LaundryFlow/basket/30_hat.txt
clothing file found: /workspace/LaundryFlow/basket/31_jacket.txt
clothing file found: /workspace/LaundryFlow/basket/32_shirt.txt
clothing file found: /workspace/LaundryFlow/basket/33_pants.txt
clothing file found: /workspace/LaundryFlow/basket/34_jeans.txt
clothing file found: /workspace/LaundryFlow/basket/35_jeans.txt
clothing file found: /workspace/LaundryFlow/basket/36_jeans.txt
clothing file found: /workspace/LaundryFlow/basket/37_dress.txt
clothing file found: /workspace/LaundryFlow/basket/38_shirt.txt
clothing file found: /workspace/LaundryFlow/basket/39_jeans.txt
clothing file found: /workspace/LaundryFlow/basket/40_shirt.txt
clothing file found: /workspace/LaundryFlow/basket/41_cardigan.txt
clothing file found: /workspace/LaundryFlow/basket/42_glove.txt
clothing file found: /workspace/LaundryFlow/basket/43_glove.txt
clothing file found: /workspace/LaundryFlow/basket/44_socks.txt
clothing file found: /workspace/LaundryFlow/basket/45_socks.txt
clothing file found: /workspace/LaundryFlow/basket/46_hat.txt
clothing file found: /workspace/LaundryFlow/basket/47_scarf.txt
clothing file found: /workspace/LaundryFlow/basket/48_shorts.txt
clothing file found: /workspace/LaundryFlow/basket/49_shorts.txt
clothing file found: /workspace/LaundryFlow/basket/50_shorts.txt
```

</details>


You can add other flair to your `.view` calls.

## Step 3. 

We need a [workflow](https://www.nextflow.io/docs/latest/workflow.html), which is enclosed in something like this
```groovy
workflow {
    //stuff
}
```

Workflows can contain and/or use
- other workflows (called subworkflows in this case)
- processes
- channel manupulations

For now, let's look at the first element in our channel
```groovy
workflow {
    ch_clothes.first().view()
}
```

## Step 4.

We don't actually want to look at our files, we want to DO something with them. To DO something, we can put our files into a `process`.


The basic process format looks like this, but with more specific values.
```groovy
process name {
    input:
    inputs

    output:
    outputs
    
    shell:
    """
    # stuff
    """
}
```

We want to put our files into a process called 'WASH', which will take our files and wash them.
```groovy
process WASH {
    input:
    file(clothes)

    output:
    path("*_wet.txt")
    
    shell:
    """
    wash
    """
}
```


<details>
  <summary>Click to see output</summary>

```bash
$ nextflow run .

 N E X T F L O W   ~  version 24.04.3

Launching `./main.nf` [kickass_marconi] DSL2 - revision: fa9379fd5d

executor >  local (50)
[86/d6094e] WASH (48) [100%] 50 of 50 ✔
```

</details>


## Step 5. 

WHERE ARE MY FILES?!?!?!

Everything looks complete, but there's... nothing here.

Nextflow copies and links files into their own directory per process. This helps run processes in parallel, but is painful to collect files from. It is like we left our laundry in the washing machine.

We, therefore, are going to add our first directive to our WASH process.

[Directives](https://www.nextflow.io/docs/latest/process.html#directives) adjust how a process is used. 

First directive: [publishDir](https://www.nextflow.io/docs/latest/process.html#publishdir)

### link

The following will `link` the files to their final destination
```groovy
process WASH {
    publishDir "wet_laundry"

    input:
    file(clothes)

    output:
    path("*_wet.txt")
    
    shell:
    """
    wash
    """
}
```

### copy

I recommend using `copy` instead (so work can be deleted)
```groovy
process WASH {
    publishDir "wet_laundry", mode: 'copy'

    input:
    file(clothes)

    output:
    path("*_wet.txt")
    
    shell:
    """
    wash
    """
}
```

Now all of the clean files will be copied over to the `wet_laundry` directory.


TA DA! That's basically it, now we're just going to do this over and over in different ways.


## Catching Up

To bring this script to the main directory for running:

```bash
cp concept1/main.nf .
```
