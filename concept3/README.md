# Third concept

The purpose of this section is to 
1. Using a sample sheet
2. Introduction to tuples and meta mapping

## Step 1. Copy the sample sheet

Glob searching for files does not work in a lot of cloud resources. This is likely some sort of "feature." Sample sheets are requied in these scenarios.

A SAMPLE SHEET IS INCLUDED IN `concept3/sample_sheet.txt`.

```bash
cp concept3/sample_sheet.txt .
```

This file has a header (not required, but is nice), and then a row for each article of clothing with some metadata for each article.  
```
name,person,color,soil,wash_instr,dry_instr
1_sock.txt,mother,yellow,4,warm,low
2_sock.txt,mother,yellow,4,warm,low
3_shirt.txt,father,red,2,warm,low
4_jeans.txt,sister,blue,5,cold,air
5_hat.txt,brother,green,3,warm,low
6_shirt.txt,mother,green,2,warm,low
7_mitten.txt,brother,white,4,warm,low
```

## Step 2. Map the metadata

The recommended choice for keeping track of metadata in nextflow is via a map. See https://training.nextflow.io/advanced/metadata/ for more information.

This is how the files were being read into a channel.
```groovy
ch_dirty_clothes = Channel.fromPath("basket/*")
```

This is same thing, just typed differently. 
```groovy
Channel
    .fromPath("basket/*")
    .set { ch_dirty_clothes }
```

### Step 2a. Read in the sample sheet
Comment out the workflow lines, because this is going to change how the input channel works.

Instead of a list of files, use the path of the sample sheet.
```groovy
Channel
    .fromPath("sample_sheet.txt")
    .view()
```

### Step 2b. Read the sample sheet by line
There are many functions that manipulate the contents of a channel. This will use `splitCsv`, which will take each line of a text file into a channel.

```groovy
Channel
    .fromPath("sample_sheet.txt", checkIfExists: true)
    .splitCsv( header: true, sep: ',' )
    .view()
```

Note that the header is used to add information for each value of each row.

### Step 2c.
Mapping the values into a tuple (a tuple is a collection of values).

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
    .view()
```

### Step 2d.

Now this channel can be used for downstream processes.

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

Now the workflow comments can be removed.


## Catching Up

To bring this script to the main directory for running:

```bash
cp concept3/main.nf .
cp concept3/sample_sheet.txt .
```
