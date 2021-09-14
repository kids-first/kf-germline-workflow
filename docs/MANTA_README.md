# KFDRC Manta Workflow
The KFDRC Manta Workflow uses [Manta](https://github.com/Illumina/manta).
Manta is a structural variant and indel caller for mapped sequencing data.

![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

### Modes
This tool can be used in three different modes:
- Somatic
- Germline
- Tumor Only

The tool will automatically select the correct mode based on the inputs provided.
If both `input_normal_cram` and `input_tumor_cram` are provided, the tool will
run in its somatic mode. If only `input_normal_cram` is provided then it will run
in germline mode. If only `input_tumor_cram` is provided, the tool will run in
tumor only mode.

In terms of runtime parameters, little changes among the three modes. The only
difference is what input reads are given to the `runWorkflow.py` script. The most
significant difference is what outputs are provided. Based on the mode, Manta
will provide different sets of outputs: https://github.com/Illumina/manta/blob/master/docs/userGuide/README.md#outputs.
In addition to `candidateSmallIndels.vcf.gz` provided in all modes, the tool
will only return the appropriate SV outputs for the mode:
- `diploidSV.vcf.gz` for germline
- `tumorSV.vcf.gz` for tumor only
- `somaticSV.vcf.gz` for somatic

### Runtime Estimates
3 GB Normal CRAM: 15 minutes & $0.15

### Tips To Run

### Other Resources
- dockerfiles: https://github.com/d3b-center/bixtools
