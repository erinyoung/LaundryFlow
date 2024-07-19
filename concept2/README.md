# Second concept

The purpose of this section is to 
1. connect processes together
2. channel manipulation : collect

## Step 1.
The clothes are wet.

WE AREN'T FINISHED!!!

WE MUST DRY THEM!!!

This means we need to connect our first process to another process.

### Step 1.A

To use a file, path, etc we must create a new channel with the output. This is done with `emit:`.
```groovy
process WASH {
    publishDir "wet_laundry", mode: 'copy'

    input:
    file(clothes)

    output:
    file("*_wet.txt"), emit: clothes
    
    shell:
    """
    wash
    """
}
```

### Step 1.b
We need to create a process to dry them

```groovy
process DRY {
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
```

This will publish the files a 'dry_laundry', so, now, techincally we have duplicated our clothing and my analogy falls apart. 

### Step 1.c

Now we need to connect the two processes in our workflow.

```groovy
workflow {
    WASH(ch_clothes)

    DRY(WASH.out.clothes)
}
```


<details>
  <summary>Click to see output</summary>
Now it should look something like this

```bash
$ ./nextflow run .

 N E X T F L O W   ~  version 24.04.3

Launching `./main.nf` [focused_hoover] DSL2 - revision: a2e08f5491

executor >  local (100)
[4a/076bcb] WASH (46) [100%] 50 of 50 ✔
[3f/863796] DRY (50)  [100%] 50 of 50 ✔
```
</details>


## Step 2

Aren't clothes normally washed together? This workflow would have us washing each article of clothing separately.

We actually want to wash all of these clothes together, and then dry them together. For that we are going to use the `.collect()` operator.

[Operators](https://www.nextflow.io/docs/latest/operator.html) are built-in nextflow functions for channel manipulation.

```groovy
workflow {
    WASH(ch_clothes.collect())

    DRY(WASH.out.clothes)
}
```

Now, each process only runs once, and it runs on all the files.

<details>
  <summary>Click to see output</summary>
Now it should look something like this


```bash
$ ./nextflow run . -resume

 N E X T F L O W   ~  version 24.04.3

Launching `./main.nf` [sick_faggin] DSL2 - revision: ad2ec5fece

executor >  local (1)
[15/f81e4f] WASH [100%] 1 of 1 ✔
[3b/46d55a] DRY  [100%] 1 of 1 ✔
Completed at: 19-Jul-2024 23:11:00
Duration    : 1m 45s
CPU hours   : 0.1
Succeeded   : 1
Cached      : 1
```
</details>



## Catching Up

To bring this script to the main directory for running:

```bash
cp concept2/main.nf .
```