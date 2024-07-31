# Fourth concept

The purpose of this section is to 
1. inspect the directives of a process
  - time
  - tag
  - error
  - memory
  - cpus
2. evaluate errors
3. resume (`-resume`)
4. variables

## Basic format

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

An example from this workflow:
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

There are more things we can do, however.

A full list of directives can be found here : https://www.nextflow.io/docs/latest/process.html#directives

## Time

> The `time` directive allows you to define how long a process is allowed to run

This will count a process as failed if it takes too long.

Using this directive looks something like this:
```groovy
process WASH {
  time '1m'

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

This should cause a failure, and is the perfect way to discuss nextflow errors.

Also note: on local systems, may not actually stop the process.

## Tag

> The tag directive allows you to associate each process execution with a custom label, so that it will be easier to identify them in the log file or in the trace execution report.

Using this directive looks something like this:
```groovy
process WASH {
  tag 'washing clothes'

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

## errorStrategy

> The errorStrategy directive allows you to define how an error condition is managed by the process.

The following error strategies are the most common:
- terminate (default)
> When a task fails, terminate the pipeline immediately. Pending and running jobs are killed.
- finish
> When a task fails, wait for submitted and running tasks to finish and then terminate the pipeline.
- ignore
> Ignore all task failures and complete the pipeline execution successfully.
- retry
> When a task fails, retry it.

Using this directive looks something like this:
```groovy
process WASH {
  errorStrategy 'ignore'

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

## maxRetries
The maxRetries directive allows you to define the maximum number of times a process instance can be re-submitted in case of failure.

Using this directive looks something like this:
```groovy
process WASH {
  errorStrategy 'retry'
  maxRetries 2
  time '1m'

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

## memory

> The memory directive allows you to define how much memory the process is allowed to use.

This value defines much memory is allocated to the process by nextflow.

Using this directive looks something like this:
```groovy
process WASH {
  memory '2 GB'

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

## cpus

> The cpus directive allows you to define the number of (logical) CPU required by the process’ task.

This value defines how many cpus are allocated to the process by nextflow.

Using this directive looks something like this:
```groovy
process WASH {
  cpus 8

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


## container 

> The container directive allows you to execute the process script in a container.

This value defines a container image to use in this process, which is independent from other processes.

```groovy
process WASH {
  container "quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0"

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

## conda

> The conda directive allows for the definition of the process dependencies using the Conda package manager.

This value defines a conda environment for a process, which is independent from other processes.

```groovy
process WASH {
  conda pandas

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

## label

> The label directive allows the annotation of processes with mnemonic identifier of your choice.

This can be used to group directives and other metrics together.

```groovy
process WASH {
  label "whatever"

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

## variables

Nextflow allows the usage of variables in processes. This isn't a directive.

Variables can be defined at runtime from the inputs and directives to a process or in a config file.

```groovy
process WASH {
  label "whatever"

  input:
  file(clothes)

  output:
  path("*_wet.txt")
    
  shell:
  def args = task.ext.args ?: ''
  """
  wash $args
  """
}
```

A breakdown of
```groovy
def args = task.ext.args ?: ''
```

- The variable `args` is used as `$args` in the shell portion of the process.
- `args` can equal one of two values.
- If there is a value defined in a config file, then that value is used.
- If nothing is defined in a config file, then `''` (which is an empty string) is used.

## An example

An example from https://github.com/nf-core/viralrecon/blob/master/modules/nf-core/pangolin/main.nf
```groovy
process PANGOLIN {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::pangolin=4.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pangolin:4.2--pyhdfd78af_1' :
        'quay.io/biocontainers/pangolin:4.2--pyhdfd78af_1' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*.csv'), emit: report
    path  "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pangolin \\
        $fasta\\
        --outfile ${prefix}.pangolin.csv \\
        --threads $task.cpus \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pangolin: \$(pangolin --version | sed "s/pangolin //g")
    END_VERSIONS
    """
}
```

Please note the usage of:
- tag
- label
- prefix
- task.cpus
- `\\` to split over lines
- when `$` and `\$` are used

## Catching Up

Nothing in this concept is required, and copying the concept4/main.nf to your current directory is intended to produce errors.
