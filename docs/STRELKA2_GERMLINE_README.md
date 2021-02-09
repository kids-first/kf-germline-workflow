# KFDRC Strelka2 Germline Workflow
The KFDRC Strelka2 Germline Workflow uses Strelka2 in its [germline configuration](https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/README.md#germline-configuration-example).
This workflow can be run as a single or joint caller configuration.

The program takes one or more BAMs/CRAMs and a reference fasta + fai and returns a singular VCF with
all discovered variants as well as per-sample genome VCFs for every sample detected in the input BAMs/CRAMs.
For more information on these outputs, please see the [Strelka2 documentation](https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/README.md#germline).

## Tips for Running
1. For WGS runs, it is recommended that users use the `call_regions` options and provide a limited
bed file such as the one detailed [here](https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/README.md#improving-runtime-for-references-with-many-short-contigs-such-as-grch38).
