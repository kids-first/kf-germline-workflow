# KFDRC CNVnator Workflow

The Kids First Data Resource Center CNVnator Workflow uses [CNVnator](https://github.com/abyzovlab/CNVnator).
CNVnator is a tool for CNV discovery and genotyping from depth-of-coverage by mapped reads.

This pipeline represents an update the existing CNVnator public app on Cavatica with the following steps:
- Extract reads
- Generate RD Histograms
- Calculate statistics
- Partition
- Call
- Generate VCF

The pipeline can take one or more input reads files.

![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

### Runtime Estimates
8 GB BAM: 30 min & $0.25

### Tips To Run

## Other Resources
- dockerfiles: https://github.com/d3b-center/bixtools
