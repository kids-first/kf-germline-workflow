# Kids First DRC Single Sample Genotyping Workflow
Kids First Data Resource Center Single Sample Genotyping Workflow. This workflow closely mirrors the [Kids First DRC Joint Genotyping Workflow](https://github.com/kids-first/kf-jointgenotyping-workflow/blob/master/workflow/kfdrc-jointgenotyping-refinement-workflow.cwl).

While the Joint Genotyping Workflow is meant to be used with whole genome
sequenced trios, this workflow is meant for processing single samples from any
sequencing experiment. The key difference between the different approaches is
the filtering process.

While non-germline samples can be run through this workflow, be wary that the
filtering process (VQSR/Hard Filtering) is specifically tuned for germline
data. We strongly recommend manually adjusting this process to fit your data.
See the available `vqsr_` and `hardfilter_` options.

## GATK Genotype Site-Level Filtering

Coming out of the GATK Genotyping process, site-level filtering must be done to
remove variants that might adversely affect downstream analysis.

GATK provides many different approaches to filtering:
- Variant Quality Score Recalibration (VQSR)
- CNNScoreVariants/NVScoreVariants
- Variant Extract-Train-Score (VETS)
- Hard Filtering

The first three are all complex, model-based approaches that attempt to infer
cutoff points based on the data provided. Hard Filtering involves manually setting
thresholds and removing variants that fail to meet those thresholds. For this
workflow, we only make use of VQSR and Hard Filtering at this time.

VQSR, being a model based approach, needs sufficient data to construct that
model. Normally in the joint filtering context, this means having hundreds of
samples. According to the documentation: "it is not suitable for some
small-scale experiments, such as targeted gene panels or exome studies with
fewer than 30 exomes." Therefore, VQSR is only activated in this workflow when
the input gVCFs for this workflow come from whole genome sequencing experiments
or when the user provides 30 or more exome gVCFs. The 30+ samples will be jointly
genotpyed and that genotyped VCF will be provided to VQSR.

Hard Filtering is really only constrained by having sufficient depth. In the
case of exome and targeted sequencing, the depths are more than sufficient. Our
current approach for hard filtering mirrors the default approach outlined in
the GATK documentation. However as they point out, "You absolutely SHOULD
expect to have to evaluate your results critically and TRY AGAIN with some
parameter adjustments until you find the settings that are right for your
data." As such, the workflow also allows you to provide your own hard filters
to replace the defaults in this workflow.

## Running the Workflow

If you would like to run this workflow using the CAVATICA public app, a basic primer on running public apps can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-Cavatica-af5ebb78c38a4f3190e32e67b4ce12bb).
Alternatively, if you'd like to run it locally using `cwltool`, a basic primer on that can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-CWLtool-b8dbbde2dc7742e4aff290b0a878344d) and combined with app-specific info from the readme below.

![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

### Runtime Estimates
Single 6 GB gVCF on spot instances: 420 minutes & $4.00

### Tips To Run:
1. inputs vcf files are the gVCF files from GATK Haplotype Caller, need to have the index **.tbi** files copy to the same project too.
1. ped file in the input shows the family relationship between samples, the format should be the same as in GATK website [link](https://gatkforums.broadinstitute.org/gatk/discussion/7696/pedigree-ped-files), the Individual ID, Paternal ID and Maternal ID must be the same as in the inputs vcf files header.
1. Here we recommend to use GRCh38 as reference genome to do the analysis, positions in gVCF should be GRCh38 too.
1. Reference locations:
    - Broad Institute Goolge Cloud: https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0
    - KFDRC S3 bucket: s3://kids-first-seq-data/broad-references/, s3://kids-first-seq-data/pipeline-references/
    - CAVATICA: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/
1. Suggested inputs:
    -  Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz
    -  Homo_sapiens_assembly38.dbsnp138.vcf
    -  hapmap_3.3.hg38.vcf.gz
    -  Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
    -  1000G_omni2.5.hg38.vcf.gz
    -  1000G_phase1.snps.high_confidence.hg38.vcf.gz
    -  Homo_sapiens_assembly38.dict
    -  Homo_sapiens_assembly38.fasta.fai
    -  Homo_sapiens_assembly38.fasta
    -  1000G_phase3_v4_20130502.sites.hg38.vcf
    -  hg38.even.handcurated.20k.intervals
    -  wgs_evaluation_regions.hg38.interval_list
    -  homo_sapiens_merged_vep_105_indexed_GRCh38.tar.gz, from ftp://ftp.ensembl.org/pub/release-105/variation/indexed_vep_cache/, then indexed using `convert_cache.pl`
        See germline annotation docs linked above.
    -  gnomad_3.1.1.custom.echtvar.zip
1. Optional inputs:
    -  clinvar_20220507_chr.vcf.gz
    -  dbNSFP4.3a_grch38.gz
    -  CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz
    -  CADDv1.6-38-whole_genome_SNVs.tsv.gz
    -  Exons.all.hg38.intervar.2021-07-31.vcf.gz


## Other Resources
- dockerfiles: https://github.com/d3b-center/bixtools
