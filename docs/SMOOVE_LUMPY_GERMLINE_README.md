# KFDRC Smoove/Lumpy Workflow
The KFDRC Smoove/Lumpy Workflow is a tool that uses the [smoove small cohort implementation](https://github.com/brentp/smoove#small-cohorts-n---40)
to perform single or joint strucural varaint (SV) calling of input BAM(s)/CRAM(s).

The tool requires one or more BAM/CRAM inputs, a reference fasta + fai, and basename for the outputs.
The tool will then output a single bgzip compressed VCF and associated tabix index.

## Tips for Running:
1. To improve performace, consider using the `exclude_bed` option with the following [file](https://github.com/hall-lab/speedseq/blob/master/annotations/exclude.cnvnator_100bp.GRCh38.20170403.bed).
