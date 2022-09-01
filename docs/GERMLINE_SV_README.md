# Kids First Data Resource Center Germline Structural Variant Caller Workflow

<p align="center">
  <img src="https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png">
</p>

The Kids First Data Resource Center (KFDRC) Germline Structural Variant (SV)
Caller Workflow is a common workflow language (CWL) implmentation to generate
SV calls from an aligned reads BAM or CRAM file. The workflow makes use of
Manta and SvABA to call varaiants then annotates these variants using AnnotSV.

## Relevant Softwares and Versions

- [Manta](https://github.com/Illumina/manta): `1.6.0`
- [SvABA](https://github.com/walaj/svaba): `1.1.0`
- [AnnotSV](https://github.com/lgmgeo/AnnotSV/): `3.1.1`

### Manta

Manta calls structural variants (SVs) and indels from mapped paired-end
sequencing reads. It is optimized for analysis of germline variation in small
sets of individuals and somatic variation in tumor/normal sample pairs. Manta
discovers, assembles and scores large-scale SVs, medium-sized indels and large
insertions within a single efficient workflow. The method is designed for rapid
analysis on standard compute hardware: NA12878 at 50x genomic coverage is
analyzed in less than 20 minutes on a 20 core server, and most WGS tumor/normal
analyses can be completed within 2 hours. Manta combines paired and split-read
evidence during SV discovery and scoring to improve accuracy, but does not
require split-reads or successful breakpoint assemblies to report a variant in
cases where there is strong evidence otherwise. It provides scoring models for
germline variants in small sets of diploid samples and somatic variants in
matched tumor/normal sample pairs.

### SvABA

SvABA is a method for detecting structural variants in sequencing data using
genome-wide local assembly. Under the hood, SvABA uses a custom implementation
of SGA (String Graph Assembler) by Jared Simpson, and BWA-MEM by Heng Li.
Contigs are assembled for every 25kb window (with some small overlap) for every
region in the genome. The default is to use only clipped, discordant, unmapped
and indel reads, although this can be customized to any set of reads at the
command line using VariantBam rules. These contigs are then immediately aligned
to the reference with BWA-MEM and parsed to identify variants. Sequencing reads
are then realigned to the contigs with BWA-MEM, and variants are scored by
their read support.

SvABA is currently configured to provide indel and rearrangement calls (and
anything "in between"). It can jointly call any number of BAM/CRAM/SAM files,
and has built-in support for case-control experiments (e.g. tumor/normal, or
trios or quads). In case/control mode, any number of cases and controls (but
min of 1 case) can be input, and will jointly assemble all sequences together.
If both a case and control are present, variants are output separately in
"somatic" and "germline" VCFs. If only a single BAM/CRAM is present (input with
the -t flag), a single SV and a single indel VCF will be emitted.

A BWA-MEM index reference genome must also be supplied with -G.

### AnnotSV

AnnotSV is a program designed for annotating and ranking Structural Variations
(SV). This tool compiles functionally, regulatory and clinically relevant
information and aims at providing annotations useful to i) interpret SV
potential pathogenicity and ii) filter out SV potential false positives.

## Input Files

At the moment the workflow uses only a few inputs:
- `germline_reads`: The germline BAM/CRAM input that has been aligned to a
  reference genome.
- `indexed_reference_fasta`: The reference genome fasta (and associated
  indicies) to which the germline BAM/CRAM was aligned.
- `annotsv_annotations_dir`: These annotations are simply those from the
  install-human-annotation installation process run during AnnotSV installation
(see: https://github.com/lgmgeo/AnnotSV/#quick-installation). Specifically
these are the annotations installed with v3.1.1 of the software. Newer or older
annotations can be slotted in here as needed.
- `annotsv_genome_build`: The genome build of the reference fasta. AnnotSV is
  capable of annotating the following genomes: "GRCh37","GRCh38","mm9","mm10".
- `output_basename`: Basename to use for the outputs.

## Output Files

    - Structural variant callers
        - Manta
            - `manta_svs`: Structural Variants called by Manta
            - `manta_indels`: Small INDELs called by Manta
        - SvABA
            - `svaba_svs`: Structural Variants called by SvABA
            - `svaba_indels`: Small INDELs called by SvABA
        - AnnotSV
            - `manta_annotated_svs`: This file contains all records from the `manta_svs` that AnnotSV could annotate.
            - `manta_unannotated_svs`: This file contains all records from the `manta_svs` that AnnotSV could not annotate.
            - `svaba_annotated_svs`: This file contains all records from the `svaba_svs` that AnnotSV could annotate.
            - `svaba_unannotated_svs`: This file contains all records from the `svaba_svs` that AnnotSV could not annotate.

## Basic Info
- [D3b dockerfiles](https://github.com/d3b-center/bixtools)
- Testing Tools:
    - [Seven Bridges Cavatica Platform](https://cavatica.sbgenomics.com/)
    - [Common Workflow Language reference implementation (cwltool)](https://github.com/common-workflow-language/cwltool/)

## References
- KFDRC AWS s3 bucket: s3://kids-first-seq-data/broad-references/
- Cavatica: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/
- Broad Institute Goolge Cloud: https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0/
