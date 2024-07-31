# Eighth concept

The purpose of this section is to
- Review
  - container directive
  - conda directive
- Introduce params, modules, and config files 

This final concept is to familiarize your workflow with commonly used concepts.

## Step 1. Modularize your processes

Nextflow files can get very large, and large files can be hard to read. Processes and subworkflows can instead be saved to separate files and imported into the main nextflow script.

The basic syntax is like this
```groovy
include { PROCESS NAME } from './modules/local/process_name'
```

Relative paths are often used for files that are packaged together. Relative paths are to the nextflow workflow or subworkflow file and not the directory that is being used to run the workflow. Absolute paths can also be used, but these will vary by user and not used very often.


### Step 1A. Create some new files.

```bash
mkdir -p modules/local
touch modules/local/dry.nf
touch modules/local/wash.nf
touch modules/local/fold.nf
```

### Step 1B. Cut and paste processes to new files

Now copy each process to this new file.

### Step 1C. Import these processes

```groovy
include { DRY } from './modules/local/dry'
include { FOLD } from './modules/local/fold'
include { WASH } from './modules/local/wash'
```

Processes can also be given alias in case they need to be used again (like if you wanted to do a pre-wash).

```groovy
include { WASH as PREWASH } from './modules/local/wash'
```

## Step 2. Set up some adjustable values

Parameters, or `params`, let the end user imput values into the workflow. This adds flexibility to a nextflow workflow.

Let's set the sample sheet to a param called `input`.

The original fixed path 
```groovy
Channel
  .fromPath("sample_sheet.txt", checkIfExists: true)
```

With an `input` param.
```groovy
Channel
  .fromPath("${params.input}", checkIfExists: true)
```

Now instead of using
```bash
nextflow run .
```

We have to specify the sample sheet for `input`.

```bash
nextflow run . --input sample_sheet.txt 
```

Note: params can be any type that is supported by groovy. They can be strings, booleans, integers, lists, etc. This example is using the input as a string, which is the default. Multi-word values will need quotations. Boolean values are lower case without quotes or they are treated as strings.  


## Step 3. Config files

Config files are text files with values that allow you to change the values of params and process directives.

Params can be defined in a config file or a param file.

### Listed params in config file
```groovy
params.input = 'sample_sheet.txt'
```

### Scoped params in config file
```groovy
params {
  input = 'sample_sheet.txt'
}
```

### In a json-formatted param file
```json
{
    "input": "sample_sheet.txt"
}
```

### Config files can also be used to adjust processes

To adjust for all processes
```groovy
process {
    cpus = 10
    memory = 8.GB
    container = 'biocontainers/bamtools:v2.4.0_cv3'
}
```

To adjust for a single processes
```groovy
process {
	withName:wash{
		cpus=2
		memory = { 6.GB  }
		errorStrategy = { task.attempt < 2 ? 'retry' : 'terminate'}
	}
}
```

### Config files can be linked together
```groovy
includeConfig 'relative/path/to/config/from/this/config'
```

### Profiles 
Profiles can set default values for params. They are often used to set docker and conda.

```groovy
profiles {
  name {
    params.input = 'value1'
  }
  name1 {
    params.input = 'value2'
  }
}
```

### Walkthrough
See 'https://github.com/nf-core/chipseq/blob/master/nextflow.config' for an example config file.


### Config file warnings

Not all nextflow configurations support config files!!!

### Copying and editing the config file

```bash
cp concept8/nextflow.config .
```

Config file contents
```groovy
manifest {
    name            = 'LaundryFlow'
    author          = 'Erin Young'
    homePage        = 'github.com/erinyoung/LaundryFlow'
    description     = 'Conceptualizing nextflow.'
    mainScript      = 'main.nf'
    nextflowVersion = '!>=21.10.3'
    version         = '0.0.1'
}

profiles {
    conda {
        params.enable_conda    = true
        docker.enabled         = false
    }
    docker {
        docker.enabled         = true
        docker.userEmulation   = true
    }
}
```


The file 'nextflow.config' is (mostly) automatically pulled into the workflow during runtime, but other config files are used with `-c`.
```bash
nextflow run . -c config.config 
```

The user defined config files should be evaluated last and replace any prior default values, but this... does seem to vary by system.


## Step 4. Control the environment of each process

Nextflow supports the use of conda environments and container images. 


## Step 4A. Using conda environments

This is not going to be tested in this gitpod environment, but it is as simple as adding the name of a conda package to a directive or the relative path to an environment.yml file.

### General syntax

Using the package name
```groovy
process FOO {
    conda pandas
}
```

Using an environmental file
```groovy
process FOO {
  conda '/some/path/env.yaml'
```

Using a specific channel
```groovy
process SAMTOOLS_SORT {
    conda bioconda::samtools
}
```

Using a specific version and channel
```groovy
process SAMTOOLS_SORT {
    conda bioconda::samtools=1.19
}
```

Using with the nextflow workflow
```bash
nextflow run -profile conda . --input sample_sheet.txt 
```

Conda environments are process specific. Hopefully.


## Step 4B. Using container images

Nextflow also supports many container engines, including docker and singularity. Singularity cannot be used in gitpod, but we can test how it works with docker.

Using the pandas container from biocontainers.
```groovy
process DRY {
  tag 'drying'
  publishDir "dry_laundry", mode: 'copy'
  container "quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0"
```

Then using a profile or config file to use the image at run time.
```bash
nextflow run -profile docker . --input sample_sheet.txt 
```

## Step 4C. Creating container images

Container images tend to be the most stable way to run workflows. Public health bioinformaticians have their own open-source-sponsored (OSS) dockerhub repository for any images that are needed for workflows for the public health community.

All dockerfiles for these images are stored here : https://github.com/StaPH-B/docker-builds
All docker images are available on 
dockerhub : https://hub.docker.com/u/staphb
quay : https://quay.io/organization/staphb

## Catching Up

To bring this script to the main directory for running:

```bash
mkdir -p modules/local
cp concept8/main.nf .
cp concept8/nextflow.config .
cp concept8/dry.nf modules/local/.
cp concept8/fold.nf modules/local/.
cp concept8/wash.nf modules/local/.
```
