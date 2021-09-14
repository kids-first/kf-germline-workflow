# KFDRC CNVkit Workflow
The KFDRC CNVkit Workflow uses [CNVkit](https://github.com/etal/cnvkit). CNVkit
is a command-line toolkit and Python library for detecting copy number variants
and alterations genome-wide from high-throughput sequencing.

This workflow can run in both somatic, germline, or tumor-only mode.

![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

## Somatic
To run the workflow in somatic mode, simply provide both tumor and normal reads
as well as references, targets (and/or antitargets).

## Germline and Tumor Only
Germline and Tumor-Only are functionally the same. First, a CNN needs to be created
from a pool of samples (ideally normals). To do this, you can run the batch tool
as described here: https://cnvkit.readthedocs.io/en/stable/pipeline.html#batch.

Using this CNN, you can then run the pipeline without providing any matched normals.
This particular workflow has been calibrated to run using the recommended germline
settings by default: https://cnvkit.readthedocs.io/en/stable/germline.html?highlight=germline.

For tumor-only, alter the pipeline settings to match recommendations from CNVkit:
https://cnvkit.readthedocs.io/en/stable/tumor.html
The most important change would be setting `drop_low_coverage` to `true`.

### Runtime Estimates
6 GB Tumor CRAM and 3 GB Normal CRAM Somatic: 41 minutes & $0.25

### Tips To Run

## Other Resources
- dockerfiles: https://github.com/d3b-center/bixtools
