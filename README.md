# Kids First Data Resource Center Germline Variant Workflows

<p align="center">
  <img src="https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png">
</p>

This repository contains Germline Workflows used for the Kids First Data Resource Center (DRC).

## Germline Variant Workflow

The preeminent workflow in this repository is the Germline Variant Caller
Workflow. This all encompassing workflow takes an input BAM/CRAM file and runs
all of our production-level calling workflows on it. It will call copy number
(CNV), single nucleotide (SNV), and structural variants (SV). Annotation is run
on the outputs of the SNV and SV callers.

Complete documentation can be found for the main workflow an its subworkflows here:

- [Germline Variant Workflow](./docs/GERMLINE_VARIANT_README.md)
    - [CNV Variant Workflow](./docs/GERMLINE_CNV_README.md)
    - [SNV Variant Workflow](./docs/GERMLINE_SNV_README.md)
    - [SNV Annotation Workflow](./docs/GERMLINE_SNV_ANNOT_README.md)
    - [SV Variant Workflow](./docs/GERMLINE_SV_README.md)

### Other Workflows

While not in our Germline Variant workflow, other workflows potentially useful
for germline calling can be found in this repository:

- [Smoove/Lumpy](./docs/SMOOVE_LUMPY_GERMLINE_README.md)
- [CNVkit](./docs/CNVKIT_README.md)
