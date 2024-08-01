# LaundryFlow
Laundry with nextflow

This is meant to be a smaller, but complete training set of nextflow training materials inspired by those provided from [nf-core](https://github.com/nextflow-io/training) and [circos tutorials](https://circos.ca/tutorials/lessons/).

Laundry is a common chore that could use many of the same concepts possible with Nextflow resource organization and management. 

Dirty clothes must be
- gathered
- divided by attributes such as color or soil-level
- washed
- dried
- folded

This is a conceptual exersize with a visual dictionary to teach nextflow workflow usage.

If only laundry could be as easy as running a Nextflow workflow.

How to use this training:

Each collection of concepts has its own subdirectory and readme. Most concepts build on each other, but can also be skipped if relevant files are copied to the home directory.

- [Concept 1](./concept1/) : main.nf structure and input channel from path
- [Concept 2](./concept2/) : using channels to connect processes and collect()
- [Concept 3](./concept3/) : sample sheets, tuples, and metadata
- [Concept 4](./concept4/) : error messages and common directives
- [Concept 5](./concept5/) : filter and functions
- [Concept 6](./concept6/) : branch and mix
- [Concept 7](./concept7/) : groupTuple and joinby
- [Concept 8](./concept8/) : modules, params, config files, containers, and conda


Closing thoughts:
- [stubs](https://www.nextflow.io/docs/latest/process.html#stub) allow testing of channels operations without running each process
- [reports and resource usage](https://www.nextflow.io/docs/latest/metrics.html) allow better resource management
- [`-with-tower` vs seqera platform](https://training.nextflow.io/basic_training/seqera_platform/) are less similar than they seem
- [requirements](https://nf-co.re/docs/guidelines/pipelines/overview#requirements) are recommended usage for compatibility
