# Kids First DRC Germline SNV Annotation Workflow
This workflow is used to annotate germline outputs with popular annotation resources. This includes using VEP to annotate with ENSEMBL v105 reference as well using bcftools to add further annotation described below.

![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

## Overall annotation steps
1. Prefilter input VCF (optional) to remove variants that are undesired to go into annotation
1. Normalize VCF
1. Strip pre-existing annotations (optional) to prevent downstream conflicts
1. Annotate with VEP 105. Default plugins include:
   - dbnsfp
   - cadd
1. Use bcftools to annotate with an external reference (default gnomad 3.1.1)
1. Use bcftools to annotate with another external reference (default clinvar)
1. Simple rename outputs step

## Default annotations
By default, the workflow will add the following annotations:

### ENSEMBL 105
This is added on using variant effect predictor to use the ENSEMBL reference to add gene model information as well as additional resources provided in their cache. It's highly recommended that when you download their cache, to [convert and index](https://uswest.ensembl.org/info/docs/tools/vep/script/vep_cache.html#convert). It will speed up annotation and reduce memory footprint significantly. Annotation resources in the cache include:

```
# CACHE UPDATED 2022-09-26 18:18:29
assembly	GRCh38
bam	GCF_000001405.39_GRCh38.p13_knownrefseq_alns.bam
polyphen	b
sift	b
source_assembly	GRCh38.p13
source_gencode	GENCODE 39
source_genebuild	2014-07
source_polyphen	2.2.2
source_refseq	2021-05-28 21:42:08 - GCF_000001405.39_GRCh38.p13_genomic.gff
source_sift	sift5.2.2
species	homo_sapiens
variation_cols	chr,variation_name,failed,somatic,start,end,allele_string,strand,minor_allele,minor_allele_freq,clin_sig,phenotype_or_disease,clin_sig_allele,pubmed,var_synonyms,AFR,AMR,EAS,EUR,SAS,AA,EA,gnomAD,gnomAD_AFR,gnomAD_AMR,gnomAD_ASJ,gnomAD_EAS,gnomAD_FIN,gnomAD_NFE,gnomAD_OTH,gnomAD_SAS
source_COSMIC	94
source_HGMD-PUBLIC	20204
source_ClinVar	105202106
source_dbSNP	154
source_1000genomes	phase3
source_ESP	V2-SSA137
source_gnomAD	r2.1.1
regulatory	1
cell_types	A549,A673,B,B_(PB),CD14+_monocyte_(PB),CD14+_monocyte_1,CD4+_CD25+_ab_Treg_(PB),CD4+_ab_T,CD4+_ab_T_(PB)_1,CD4+_ab_T_(PB)_2,CD4+_ab_T_(Th),CD4+_ab_T_(VB),CD8+_ab_T_(CB),CD8+_ab_T_(PB),CMP_CD4+_1,CMP_CD4+_2,CMP_CD4+_3,CM_CD4+_ab_T_(VB),DND-41,EB_(CB),EM_CD4+_ab_T_(PB),EM_CD8+_ab_T_(VB),EPC_(VB),GM12878,H1-hESC_2,H1-hESC_3,H9_1,HCT116,HSMM,HUES48,HUES6,HUES64,HUVEC,HUVEC-prol_(CB),HeLa-S3,HepG2,K562,M0_(CB),M0_(VB),M1_(CB),M1_(VB),M2_(CB),M2_(VB),MCF-7,MM.1S,MSC,MSC_(VB),NHLF,NK_(PB),NPC_1,NPC_2,NPC_3,PC-3,PC-9,SK-N.,T_(PB),Th17,UCSF-4,adrenal_gland,aorta,astrocyte,bipolar_neuron,brain_1,cardiac_muscle,dermal_fibroblast,endodermal,eosinophil_(VB),esophagus,foreskin_fibroblast_2,foreskin_keratinocyte_1,foreskin_keratinocyte_2,foreskin_melanocyte_1,foreskin_melanocyte_2,germinal_matrix,heart,hepatocyte,iPS-15b,iPS-20b,iPS_DF_19.11,iPS_DF_6.9,keratinocyte,kidney,large_intestine,left_ventricle,leg_muscle,lung_1,lung_2,mammary_epithelial_1,mammary_epithelial_2,mammary_myoepithelial,monocyte_(CB),monocyte_(VB),mononuclear_(PB),myotube,naive_B_(VB),neuron,neurosphere_(C),neurosphere_(GE),neutro_myelocyte,neutrophil_(CB),neutrophil_(VB),osteoblast,ovary,pancreas,placenta,psoas_muscle,right_atrium,right_ventricle,sigmoid_colon,small_intestine_1,small_intestine_2,spleen,stomach_1,stomach_2,thymus_1,thymus_2,trophoblast,trunk_muscle
source_regbuild	1.0
var_type	tabix
```

### [dbNSFP v4.3a](http://database.liulab.science/dbNSFP#intro)
This resource compiles from dozens of sources annotations for ~84M SNVs. By default, from this resource, we annotate the following:
```
SIFT4G_pred
Polyphen2_HDIV_pred
Polyphen2_HVAR_pred
LRT_pred
MutationTaster_pred
MutationAssessor_pred
FATHMM_pred
PROVEAN_pred
VEST4_score
VEST4_rankscore
MetaSVM_pred
MetaLR_pred
MetaRNN_pred
M-CAP_pred
REVEL_score
REVEL_rankscore
PrimateAI_pred
DEOGEN2_pred
BayesDel_noAF_pred
ClinPred_pred
LIST-S2_pred
Aloft_pred
fathmm-MKL_coding_pred
fathmm-XF_coding_pred
Eigen-phred_coding
Eigen-PC-phred_coding
phyloP100way_vertebrate
phyloP100way_vertebrate_rankscore
phastCons100way_vertebrate
phastCons100way_vertebrate_rankscore
TWINSUK_AC
TWINSUK_AF
ALSPAC_AC
ALSPAC_AF
UK10K_AC
UK10K_AF
gnomAD_exomes_controls_AC
gnomAD_exomes_controls_AN
gnomAD_exomes_controls_AF
gnomAD_exomes_controls_nhomalt
gnomAD_exomes_controls_POPMAX_AC
gnomAD_exomes_controls_POPMAX_AN
gnomAD_exomes_controls_POPMAX_AF
gnomAD_exomes_controls_POPMAX_nhomalt
Interpro_domain
GTEx_V8_gene
GTEx_V8_tissue
```

### [CADD v1.6](https://cadd.gs.washington.edu/)
Using a VEP plugin, we add Combined Annotation Dependent Depletion scores

### [gnomAD 3.1.1](https://gnomad.broadinstitute.org/)
Using bcftools, we annotate from gnomAD v3.1.1 the following population statistics (columns are give a `gnomad_3_1_1_` prefix to denote source):
```
gnomad_3_1_1_AC
gnomad_3_1_1_AN
gnomad_3_1_1_AF
gnomad_3_1_1_nhomalt
gnomad_3_1_1_AC_popmax
gnomad_3_1_1_AN_popmax
gnomad_3_1_1_AF_popmax
gnomad_3_1_1_nhomalt_popmax
gnomad_3_1_1_AC_controls_and_biobanks
gnomad_3_1_1_AN_controls_and_biobanks
gnomad_3_1_1_AF_controls_and_biobanks
gnomad_3_1_1_AF_non_cancer
gnomad_3_1_1_primate_ai_score
gnomad_3_1_1_splice_ai_consequence
```

### [ClinVar 20220507](https://www.ncbi.nlm.nih.gov/clinvar/)
A curated resource with annotations of clinical significance per variant. Note, for this pipeline, the default reference was modified by:
   - Switching from `1` chromosome nomenclature to `chr1`, and especially `MT` -> `chrM`
   - Removing the entry assigned to `NW_009646201.1`. It's a benign it and also not present in our fasta reference.
By default, we annotate the following:
```
ALLELEID
CLNDN
CLNDNINCL
CLNDISDB
CLNDISDBINCL
CLNHGVS
CLNREVSTAT
CLNSIG
CLNSIGCONF
CLNSIGINCL
CLNVC
CLNVCSO
CLNVI
```

### [InterVar](https://github.com/WGLab/InterVar)
This is a custom reference generated by the authors of the tool linked above. It contains only exonic snps. To utilize the full capabilities of their classification, you must run the tool.

## Workflow Inputs
```yaml
  indexed_reference_fasta: {type: 'File', secondaryFiles: [.fai, ^.dict], "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [{class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict},
        {class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai}]}}
  input_vcf: {type: 'File', secondaryFiles: ['.tbi'], doc: "Input vcf to annotate"}
  output_basename: string
  tool_name: string

  bcftools_prefilter_csv: {type: 'string?', doc: "csv of bcftools filter params if\
      \ you want to prefilter before annotation"}
  # bcftools strip, if needed
  bcftools_strip_columns: {type: 'string?', doc: "csv string of columns to strip if needed to avoid conflict, i.e INFO/AF"}
  # bcftools annotate if more to do
  bcftools_annot_gnomad_columns: {type: 'string?', doc: "csv string of columns from annotation to port into the input vcf, i.e", default: "INFO/gnomad_3_1_1_AC:=INFO/AC,INFO/gnomad_3_1_1_AN:=INFO/AN,INFO/gnomad_3_1_1_AF:=INFO/AF,INFO/gnomad_3_1_1_nhomalt:=INFO/nhomalt,INFO/gnomad_3_1_1_AC_popmax:=INFO/AC_popmax,INFO/gnomad_3_1_1_AN_popmax:=INFO/AN_popmax,INFO/gnomad_3_1_1_AF_popmax:=INFO/AF_popmax,INFO/gnomad_3_1_1_nhomalt_popmax:=INFO/nhomalt_popmax,INFO/gnomad_3_1_1_AC_controls_and_biobanks:=INFO/AC_controls_and_biobanks,INFO/gnomad_3_1_1_AN_controls_and_biobanks:=INFO/AN_controls_and_biobanks,INFO/gnomad_3_1_1_AF_controls_and_biobanks:=INFO/AF_controls_and_biobanks,INFO/gnomad_3_1_1_AF_non_cancer:=INFO/AF_non_cancer,INFO/gnomad_3_1_1_primate_ai_score:=INFO/primate_ai_score,INFO/gnomad_3_1_1_splice_ai_consequence:=INFO/splice_ai_consequence"}
  bcftools_annot_clinvar_columns: {type: 'string?', doc: "csv string of columns from annotation to port into the input vcf", default: "INFO/ALLELEID,INFO/CLNDN,INFO/CLNDNINCL,INFO/CLNDISDB,INFO/CLNDISDBINCL,INFO/CLNHGVS,INFO/CLNREVSTAT,INFO/CLNSIG,INFO/CLNSIGCONF,INFO/CLNSIGINCL,INFO/CLNVC,INFO/CLNVCSO,INFO/CLNVI"}
  gnomad_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional bgzipped annotation vcf file", "sbg:suggestedValue": {
      class: File, path: 6324ef5ad01163633daa00d8, name: gnomad_3.1.1.vwb_subset.vcf.gz, secondaryFiles: [{
      class: File, path: 6324ef5ad01163633daa00d7, name: gnomad_3.1.1.vwb_subset.vcf.gz.tbi}]}}
  clinvar_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional bgzipped annotation vcf file", "sbg:suggestedValue": {
      class: File, path: 632c6cbb2a5194517cff1593, name: clinvar_20220507_chr.vcf.gz, secondaryFiles: [{
      class: File, path: 632c6cbb2a5194517cff1592, name: clinvar_20220507_chr.vcf.gz.tbi}]}}
  # VEP-specific
  vep_ram: {type: 'int?', default: 48, doc: "In GB, may need to increase this value depending on the size/complexity of input"}
  vep_cores: {type: 'int?', default: 32, doc: "Number of cores to use. May need to increase for really large inputs"}
  vep_buffer_size: {type: 'int?', default: 100000, doc: "Increase or decrease to balance speed and memory usage"}
  vep_cache: {type: 'File', doc: "tar gzipped cache from ensembl/local converted cache",
    "sbg:suggestedValue": {class: File, path: 6332f8e47535110eb79c794f, name: homo_sapiens_merged_vep_105_indexed_GRCh38.tar.gz}}
  dbnsfp: { type: 'File?', secondaryFiles: [.tbi,^.readme.txt], doc: "VEP-formatted plugin file, index, and readme file containing dbNSFP annotations", "sbg:suggestedValue": {
      class: File, path: 63d97e944073196d123db264, name: dbNSFP4.3a_grch38.gz, secondaryFiles: [
      {class: File, path: 63d97e944073196d123db262, name: dbNSFP4.3a_grch38.gz.tbi},
      {class: File, path: 63d97e944073196d123db263, name: dbNSFP4.3a_grch38.readme.txt}]} }
  dbnsfp_fields: { type: 'string?', doc: "csv string with desired fields to annotate. Use ALL to grab all",
    default: 'SIFT4G_pred,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,VEST4_score,VEST4_rankscore,MetaSVM_pred,MetaLR_pred,MetaRNN_pred,M-CAP_pred,REVEL_score,REVEL_rankscore,PrimateAI_pred,DEOGEN2_pred,BayesDel_noAF_pred,ClinPred_pred,LIST-S2_pred,Aloft_pred,fathmm-MKL_coding_pred,fathmm-XF_coding_pred,Eigen-phred_coding,Eigen-PC-phred_coding,phyloP100way_vertebrate,phyloP100way_vertebrate_rankscore,phastCons100way_vertebrate,phastCons100way_vertebrate_rankscore,TWINSUK_AC,TWINSUK_AF,ALSPAC_AC,ALSPAC_AF,UK10K_AC,UK10K_AF,gnomAD_exomes_controls_AC,gnomAD_exomes_controls_AN,gnomAD_exomes_controls_AF,gnomAD_exomes_controls_nhomalt,gnomAD_exomes_controls_POPMAX_AC,gnomAD_exomes_controls_POPMAX_AN,gnomAD_exomes_controls_POPMAX_AF,gnomAD_exomes_controls_POPMAX_nhomalt,Interpro_domain,GTEx_V8_gene,GTEx_V8_tissue'
    }
  merged: { type: 'boolean?', doc: "Set to true if merged cache used", default: true }
  run_cache_existing: { type: 'boolean?', doc: "Run the check_existing flag for cache", default: true }
  run_cache_af: { type: 'boolean?', doc: "Run the allele frequency flags for cache", default: true }
  run_stats: { type: 'boolean?', doc: "Create stats file? Disable for speed", default: false }
  cadd_indels: { type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file and index containing CADD indel annotations", "sbg:suggestedValue": {
      class: File, path: 632a2b417535110eb78312a6, name: CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz, secondaryFiles: [{
      class: File, path: 632a2b417535110eb78312a5, name: CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz.tbi}]}}
  cadd_snvs: { type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file and index containing CADD SNV annotations", "sbg:suggestedValue": {
      class: File, path: 632a2b417535110eb78312a4, name: CADDv1.6-38-whole_genome_SNVs.tsv.gz, secondaryFiles: [{
      class: File, path: 632a2b417535110eb78312a5, name: CADDv1.6-38-whole_genome_SNVs.tsv.gz.tbi}]} }
  intervar: { type: 'File?', doc: "Intervar vcf-formatted file. Exonic SNVs only - for more comprehensive run InterVar. See docs for custom build instructions", secondaryFiles: [.tbi], "sbg:suggestedValue": {
          class: File, path: 633348619968f3738e4ec4b5, name: Exons.all.hg38.intervar.2021-07-31.vcf.gz, secondaryFiles: [{
          class: File, path: 633348619968f3738e4ec4b6, name: Exons.all.hg38.intervar.2021-07-31.vcf.gz.tbi}]} }
```

## Workflow Outputs
```yaml
  annotated_vcf: {type: 'File[]', outputSource: rename_output/renamed_files}
```