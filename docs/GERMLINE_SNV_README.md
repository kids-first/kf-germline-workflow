# Kids First Data Resource Center Single Nucleotide Variant Workflow

<p align="center">
  <img src="https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png">
</p>

The Kids First Data Resource Center (KFDRC) Single Nucleotide Variant (SNV)
Workflow is a common workflow language (CWL) implmentation to generate
SNV calls from an aligned reads BAM or CRAM file. The workflow makes use of
GATK, Freebayes, and Strelka2 callers then performs annotation using VEP,
gnomAD.

## Relevant Softwares and Versions

- [Freebayes](https://github.com/freebayes/freebayes): `1.3.7`
- [GATK](https://github.com/broadinstitute/gatk): `4.2.0.0`
- [Strelka2](https://github.com/Illumina/strelka): `2.9.10`

### Freebayes

freebayes is a Bayesian genetic variant detector designed to find small
polymorphisms, specifically SNPs (single-nucleotide polymorphisms), indels
(insertions and deletions), MNPs (multi-nucleotide polymorphisms), and complex
events (composite insertion and substitution events) smaller than the length of
a short-read sequencing alignment.

freebayes is haplotype-based, in the sense that it calls variants based on the
literal sequences of reads aligned to a particular target, not their precise
alignment. This model is a straightforward generalization of previous ones
(e.g. PolyBayes, samtools, GATK) which detect or report variants based on
alignments. This method avoids one of the core problems with alignment-based
variant detection--- that identical sequences may have multiple possible
alignments

freebayes uses short-read alignments (BAM files with Phred+33 encoded quality
scores, now standard) for any number of individuals from a population and a
reference genome (in FASTA format) to determine the most-likely combination of
genotypes for the population at each position in the reference. It reports
positions which it finds putatively polymorphic in variant call file (VCF)
format. It can also use an input set of variants (VCF) as a source of prior
information, and a copy number variant map (BED) to define non-uniform ploidy
variation across the samples under analysis.

### GATK Single Sample Germline Variant Discovery

For GATK we use our [Kids First DRC Single Sample Genotyping
Workflow](./GATK_GERMLINE_README.md). This workflow calls variants using a
gVCF that is made unless the user provides one themselves.

### Strelka2

Strelka calls germline small variants from mapped sequencing reads.  It is
optimized for rapid clinical analysis of germline variation in small cohorts.
Strelka's germline caller employs a haplotype model to improve call quality and
provide short-range read-backed phasing in addition to a probabilistic variant
calling model using indel error rates adaptively estimated from each input
sample's sequencing data. The caller includes a final empirical variant
rescoring step using a random forest model to reflect numerous features
indicative of call reliability which may not be represented in the core variant
calling probability model.

Strelka accepts input read mappings from BAM or CRAM files, and optionally
candidate and/or forced-call alleles from VCF. It reports all small variant
predictions in VCF 4.1 format. Germline variant reporting uses the gVCF
conventions to represent both variant and reference call confidence.

For information on the germline outputs, please see the [Strelka2
documentation](https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/README.md#germline).

### Annotation

Variants from all three callers are annotated using the [Kids First DRC
Germline SNV Annotation Workflow](../kf-annotation-tools/docs/GERMLINE_SNV_ANNOT_README.md).
Generally, this workflow annotates the workflow using VEP, gnomAD.
For more information on the specific annotations, please see the documentation.

## Input Files

- Universal
    - `input_reads`: The germline BAM/CRAM input that has been aligned to a reference genome
    - `indexed_reference_fasta`: The reference genome fasta (and associated indicies) to which the germline BAM/CRAM was aligned
    - `calling_regions`: File, in BED or INTERVALLIST format, containing a set of genomic regions over which variants will be called
- GATK
    - `unpadded_intervals_file`: Handcurated intervals over which the gVCF will be genotyped to create a VCF
    - `wgs_evaluation_interval_list`: Evaluation regions for gVCF and known sites VCF metrics
    - `contamination_sites_bed`: .bed file for markers used in contamination analysis
    - `contamination_sites_mu`: .mu matrix file of genotype matrix
    - `contamination_sites_ud`: .UD matrix file from SVD result of genotype matrix
    - `dbsnp_vcf`: Population resource used for both indel and SNP recalibration as well as gVCF/VCF metrics; available from GATK
    - `axiomPoly_resource_vcf`: Population resource used for indel recalibration; available from GATK
    - `mills_resource_vcf`: Population resource used for indel recalibration; available from GATK
    - `hapmap_resource_vcf`: Population resource used for SNP recalibration; available from GATK
    - `omni_resource_vcf`: Population resource used for SNP recalibration; available from GATK
    - `one_thousand_genomes_resource_vcf`: Population resource used for SNP recalibration; available from GATK
    - `ped`: Ped file to establish familial relationship. For single sample, this file is a single line. For example, if you are handing in only a single CRAM from NA12878, the ped file would look like this:
```
 NA128	NA12878	0	0	2	2
```
- Annotation

    Recommended:
    - `gnomad_annotation_vcf`: gnomAD VCF used for annotation
    - `vep_cache`: TAR.GZ cache from ensembl/local converted cache

    Optional:
    - `clinvar_annotation_vcf`: ClinVar VCF used for annotation
    - `dbnsfp`: VEP-formatted plugin file, index, and readme file containing dbNSFP annotations
    - `cadd_indels`: VEP-formatted plugin file and index containing CADD indel annotations
    - `cadd_snvs`: VEP-formatted plugin file and index containing CADD SNV annotations
    - `intervar`: Intervar vcf-formatted file. Exonic SNVs only - for more comprehensive run InterVar. See docs for custom build instructions

## Output Files

- Freebayes
    - `freebayes_unfiltered_vcf`: Raw variants output from freebayes
- GATK
    - `gatk_gvcf`: GATK HaplotypeCaller generated gVCF
    - `gatk_gvcf_metrics`: GATK/Picard variant calling detail and summary metrics for the gVCF
    - `verifybamid_output`: VerifyBAMID metrics (contains contamination information)
    - `gatk_vcf_metrics`: GATK/Picard variant calling detail and summary metrics for the known sites VCF
    - `peddy_html`: HTML metrics files from Peddy
    - `peddy_csv`: CSV metrics for het_check, ped_check, and sex_check from Peddy
    - `peddy_ped`: PED file with additional metrics information from Peddy
- Strelka2
    - `strelka2_prepass_variants`: Raw variants output from Strelka2
    - `strelka2_gvcfs`: gVCF output from Strelka2
- VEP
    - `vep_annotated_freebayes_vcf`: Quality filtered and VEP annotated `freebayes_unfiltered_vcf`
    - `vep_annotated_gatk_vcf`: VQSR, Hard-filtered, and VEP annotated known sites VCF
    - `vep_annotated_strelka_vcf`: Pass filtered and VEP annotated `strelka2_prepass_variants`

## Basic Info
- [D3b dockerfiles](https://github.com/d3b-center/bixtools)
- Testing Tools:
    - [Seven Bridges CAVATICA Platform](https://cavatica.sbgenomics.com/)
    - [Common Workflow Language reference implementation (cwltool)](https://github.com/common-workflow-language/cwltool/)

## References
- KFDRC AWS S3 bucket: s3://kids-first-seq-data/broad-references/, s3://kids-first-seq-data/pipeline-references/
- CAVATICA: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/
- Broad Institute Goolge Cloud: https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0
