# KFDRC Freebayes Workflow
The KFDRC Freebayes Workflow uses [Freebayes](https://github.com/freebayes/freebayes) to detect small polymorphisms
in short-read sequencing files. The Freebayes tool takes a reference file, one or more input BAM files, and
and output basename and returns a single VCF file.

The workflow improves on the base implementation of Freebayes in that runs the tool in parallel. The input
reference dict is split into 50 smaller intervals which then is used for localized Freebayes variant
calling. The resulting VCFs are then merged using GATK.

### Runtime Estimates
1. Trio of 65 GB BAMs on spot instances: 180 minutes & $2.00
1. Trio of 120 GB BAMs on spot instances: 270 minutes & $3.25
1. Single 65 GB BAM on spot instances: 110 minutes & $1.25
1. Single 35 GB BAM on spot instances: 45 minutes & $0.50
