cwlVersion: v1.2
class: Workflow
id: kfdrc-single-sample-genotyping-wf
label: Kids First DRC Single Sample Genotyping Workflow
doc: |
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

requirements:
- class: ScatterFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcfs: {type: 'File[]', doc: 'Input array of individual sample gVCF files'}
  experiment_type:
    type:
    - type: enum
      name: experiment_type
      symbols: ["WGS", "WXS", "Targeted Sequencing"]
    doc: "Experimental strategy used to sequence the data in the input_vcfs"
  axiomPoly_resource_vcf: {type: File, secondaryFiles: [{pattern: '.tbi', required: true}], doc: 'Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz',
    "sbg:suggestedValue": {class: File, path: 60639016357c3a53540ca7c7, name: Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz,
      secondaryFiles: [{class: File, path: 6063901d357c3a53540ca81b, name: Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz.tbi}]}}
  dbsnp_vcf: {type: File, secondaryFiles: [{pattern: '.idx', required: true}], doc: 'Homo_sapiens_assembly38.dbsnp138.vcf', "sbg:suggestedValue": {
      class: File, path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf, secondaryFiles: [{class: File, path: 6063901e357c3a53540ca834,
          name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}]}}
  hapmap_resource_vcf: {type: File, secondaryFiles: [{pattern: '.tbi', required: true}], doc: 'Hapmap genotype SNP input vcf', "sbg:suggestedValue": {
      class: File, path: 60639016357c3a53540ca7be, name: hapmap_3.3.hg38.vcf.gz, secondaryFiles: [{class: File, path: 60639016357c3a53540ca7c5,
          name: hapmap_3.3.hg38.vcf.gz.tbi}]}}
  mills_resource_vcf: {type: File, secondaryFiles: [{pattern: '.tbi', required: true}], doc: 'Mills_and_1000G_gold_standard.indels.hg38.vcf.gz',
    "sbg:suggestedValue": {class: File, path: 6063901a357c3a53540ca7f3, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz, secondaryFiles: [
        {class: File, path: 6063901c357c3a53540ca806, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi}]}}
  omni_resource_vcf: {type: File, secondaryFiles: [{pattern: '.tbi', required: true}], doc: '1000G_omni2.5.hg38.vcf.gz', "sbg:suggestedValue": {
      class: File, path: 6063901e357c3a53540ca835, name: 1000G_omni2.5.hg38.vcf.gz, secondaryFiles: [{class: File, path: 60639016357c3a53540ca7b1,
          name: 1000G_omni2.5.hg38.vcf.gz.tbi}]}}
  one_thousand_genomes_resource_vcf: {type: File, secondaryFiles: [{pattern: '.tbi', required: true}], doc: '1000G_phase1.snps.high_confidence.hg38.vcf.gz,
      high confidence snps', "sbg:suggestedValue": {class: File, path: 6063901c357c3a53540ca80f, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz,
      secondaryFiles: [{class: File, path: 6063901e357c3a53540ca845, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi}]}}
  ped: {type: File, doc: 'Ped file for the family relationship'}
  indexed_reference_fasta: {type: File, secondaryFiles: [{pattern: '.fai', required: true}, {pattern: '^.dict', required: true}],
    doc: 'Homo_sapiens_assembly38.fasta', "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [{class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict}, {class: File, path: 60639016357c3a53540ca7af,
          name: Homo_sapiens_assembly38.fasta.fai}]}}
  unpadded_intervals_file: {type: File, doc: "Handcurated intervals over which the gVCF will be genotyped to create a VCF.", "sbg:suggestedValue": {
      class: File, path: 5f500135e4b0370371c051b1, name: hg38.even.handcurated.20k.intervals}}
  wgs_evaluation_interval_list: {type: File, doc: 'wgs_evaluation_regions.hg38.interval_list', "sbg:suggestedValue": {class: File,
      path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  genomicsdbimport_extra_args: {type: 'string?', doc: "Any extra arguments to give to GenomicsDBImport"}
  genotypegvcfs_extra_args: {type: 'string?', doc: "Any extra arguments to give to GenotypeGVCFs"}
  output_basename: string
  tool_name: {type: 'string?', default: "single.vqsr.filtered.vep_105", doc: "File name string suffx to use for output files"}

  # VQSR Options
  vqsr_snp_max_gaussians: {type: 'int?', doc: "Interger value for max gaussians in SNP VariantRecalibration. If a dataset gives fewer
      variants than the expected scale, the number of Gaussians for training should be turned down. Lowering the max-Gaussians forces
      the program to group variants into a smaller number of clusters, which results in more variants per cluster."}
  vqsr_indel_max_gaussians: {type: 'int?', doc: "Interger value for max gaussians in INDEL VariantRecalibration. If a dataset gives
      fewer variants than the expected scale, the number of Gaussians for training should be turned down. Lowering the max-Gaussians
      forces the program to group variants into a smaller number of clusters, which results in more variants per cluster."}
  vqsr_snp_tranches: {type: 'string[]?', doc: "The levels of truth sensitivity at which to slice the SNP recalibration data, in percent."}
  vqsr_snp_annotations: {type: 'string[]?', doc: "The names of the annotations which should used for SNP recalibration calculations."}
  vqsr_indel_tranches: {type: 'string[]?', doc: "The levels of truth sensitivity at which to slice the INDEL recalibration data, in
      percent."}
  vqsr_indel_annotations: {type: 'string[]?', doc: "The names of the annotations which should used for INDEL recalibration calculations."}
  vqsr_snp_ts_filter_level: {type: 'float?', doc: "The truth sensitivity level at which to start filtering SNP data"}
  vqsr_indel_ts_filter_level: {type: 'float?', doc: "The truth sensitivity level at which to start filtering INDEL data"}
  vqsr_snp_model_cpu: {type: 'int?', doc: "CPUs to allocate to VariantRecalibrator for SNP model creation."}
  vqsr_snp_model_ram: {type: 'int?', doc: "GB of RAM to allocate to VariantRecalibrator for SNP model creation."}
  vqsr_indel_recal_cpu: {type: 'int?', doc: "CPUs to allocate to VariantRecalibrator for INDEL recalibration."}
  vqsr_indel_recal_ram: {type: 'int?', doc: "GB of RAM to allocate to VariantRecalibrator for INDEL recalibration."}
  vqsr_snp_recal_cpu: {type: 'int?', doc: "CPUs to allocate to VariantRecalibrator for scattered SNP recalibration."}
  vqsr_snp_recal_ram: {type: 'int?', doc: "GB of RAM to allocate to VariantRecalibrator for scattered SNP recalibration."}
  vqsr_gathertranche_cpu: {type: 'int?', doc: "CPUs to allocate to GatherTranches."}
  vqsr_gathertranche_ram: {type: 'int?', doc: "GB of RAM to allocate to GatherTranches."}
  vqsr_apply_cpu: {type: 'int?', doc: "CPUs to allocate to ApplyVQSR for INDELs and SNPs."}
  vqsr_apply_ram: {type: 'int?', doc: "GB of RAM to allocate to ApplyVQSR for INDELs and SNPs."}
  vqsr_gathervcf_cpu: {type: 'int?', doc: "CPUs to allocate to GatherVcfsCloud."}
  vqsr_gathervcf_ram: {type: 'int?', doc: "GB of RAM to allocate to GatherVcfsCloud."}

  # HardFiltering Options
  hardfilter_snp_filters: {type: 'string?', doc: "String value of hardfilters to set for SNPs"}
  hardfilter_indel_filters: {type: 'string?', doc: "String value of hardfilters to set for INDELs"}
  hardfilter_snp_filter_extra_args: {type: 'string?', doc: "Any extra arguments for SNP VariantFiltration during HardFiltering"}
  hardfilter_indel_filter_extra_args: {type: 'string?', doc: "Any extra arguments for INDEL VariantFiltration during HardFiltering"}
  hardfilter_filtertration_cpu: {type: 'int?', doc: "CPUs to allocate to GATK VariantFiltration during HardFiltering"}
  hardfilter_filtertration_ram: {type: 'int?', doc: "GB of RAM to allocate to GATK VariantFiltration during HardFiltering"}

  # Annotation
  bcftools_annot_clinvar_columns: {type: 'string?', doc: "csv string of columns from annotation to port into the input vcf", default: "INFO/ALLELEID,INFO/CLNDN,INFO/CLNDNINCL,INFO/CLNDISDB,INFO/CLNDISDBINCL,INFO/CLNHGVS,INFO/CLNREVSTAT,INFO/CLNSIG,INFO/CLNSIGCONF,INFO/CLNSIGINCL,INFO/CLNVC,INFO/CLNVCSO,INFO/CLNVI"}
  echtvar_anno_zips: {type: 'File[]?', doc: "Annotation ZIP files for echtvar anno", "sbg:suggestedValue": [{class: File, path: 65c64d847dab7758206248c6,
        name: gnomad.v3.1.1.custom.echtvar.zip}]}
  clinvar_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional bgzipped annotation vcf file"}
  # VEP-specific
  vep_ram: {type: 'int?', default: 32, doc: "In GB, may need to increase this value depending on the size/complexity of input"}
  vep_cores: {type: 'int?', default: 16, doc: "Number of cores to use. May need to increase for really large inputs"}
  vep_buffer_size: {type: 'int?', default: 100000, doc: "Increase or decrease to balance speed and memory usage"}
  vep_cache: {type: 'File', doc: "tar gzipped cache from ensembl/local converted cache", "sbg:suggestedValue": {class: File, path: 6332f8e47535110eb79c794f,
      name: homo_sapiens_merged_vep_105_indexed_GRCh38.tar.gz}}
  dbnsfp: {type: 'File?', secondaryFiles: [.tbi, ^.readme.txt], doc: "VEP-formatted plugin file, index, and readme file containing
      dbNSFP annotations"}
  dbnsfp_fields: {type: 'string?', doc: "csv string with desired fields to annotate. Use ALL to grab all", default: 'SIFT4G_pred,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,VEST4_score,VEST4_rankscore,MetaSVM_pred,MetaLR_pred,MetaRNN_pred,M-CAP_pred,REVEL_score,REVEL_rankscore,PrimateAI_pred,DEOGEN2_pred,BayesDel_noAF_pred,ClinPred_pred,LIST-S2_pred,Aloft_pred,fathmm-MKL_coding_pred,fathmm-XF_coding_pred,Eigen-phred_coding,Eigen-PC-phred_coding,phyloP100way_vertebrate,phyloP100way_vertebrate_rankscore,phastCons100way_vertebrate,phastCons100way_vertebrate_rankscore,TWINSUK_AC,TWINSUK_AF,ALSPAC_AC,ALSPAC_AF,UK10K_AC,UK10K_AF,gnomAD_exomes_controls_AC,gnomAD_exomes_controls_AN,gnomAD_exomes_controls_AF,gnomAD_exomes_controls_nhomalt,gnomAD_exomes_controls_POPMAX_AC,gnomAD_exomes_controls_POPMAX_AN,gnomAD_exomes_controls_POPMAX_AF,gnomAD_exomes_controls_POPMAX_nhomalt,Interpro_domain,GTEx_V8_gene,GTEx_V8_tissue'}
  merged: {type: 'boolean?', doc: "Set to true if merged cache used", default: true}
  cadd_indels: {type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file and index containing CADD indel annotations"}
  cadd_snvs: {type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file and index containing CADD SNV annotations"}
  intervar: {type: 'File?', doc: "Intervar vcf-formatted file. Exonic SNVs only - for more comprehensive run InterVar. See docs for
      custom build instructions", secondaryFiles: [.tbi]}

outputs:
  collectvariantcallingmetrics: {type: 'File[]', doc: 'Variant calling summary and detailed metrics files', outputSource: picard_collectvariantcallingmetrics/output}
  peddy_html: {type: 'File[]', doc: 'html summary of peddy results', outputSource: peddy/output_html}
  peddy_csv: {type: 'File[]', doc: 'csv details of peddy results', outputSource: peddy/output_csv}
  peddy_ped: {type: 'File[]', doc: 'ped format summary of peddy results', outputSource: peddy/output_peddy}
  annotation_plots: {type: 'File?', outputSource: gatk_hardfiltering/annotation_plots}
  vep_annotated_vcf: {type: 'File[]', outputSource: annotate_vcf/annotated_vcf}

steps:
  filtering_defaults:
    run: ../tools/filtering_defaults.cwl
    in:
      num_vcfs:
        source: input_vcfs
        valueFrom: $(self.length)
      experiment_type: experiment_type
    out: [low_data, snp_tranches, indel_tranches, snp_annotations, indel_annotations, snp_ts_filter_level, indel_ts_filter_level,
      snp_hardfilter, indel_hardfilter, snp_plot_annots, indel_plot_annots]
  dynamicallycombineintervals:
    run: ../tools/script_dynamicallycombineintervals.cwl
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c5.9xlarge
    in:
      input_vcfs: input_vcfs
      interval: unpadded_intervals_file
    out: [out_intervals]
  gatk_genomicsdbimport_genotypegvcfs:
    run: ../tools/gatk_genomicsdbimport_genotypegvcfs.cwl
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c5.9xlarge
    scatter: [interval]
    in:
      input_vcfs: input_vcfs
      interval: dynamicallycombineintervals/out_intervals
      dbsnp_vcf: dbsnp_vcf
      reference_fasta: indexed_reference_fasta
      genomicsdbimport_extra_args: genomicsdbimport_extra_args
      genotypegvcfs_extra_args: genotypegvcfs_extra_args
    out: [genotyped_vcf]
  gatk_vqsr:
    run: ../subworkflows/kfdrc-gatk-vqsr.cwl
    when: $(!inputs.low_data)
    in:
      low_data: filtering_defaults/low_data
      genotyped_vcfs: gatk_genomicsdbimport_genotypegvcfs/genotyped_vcf
      output_basename: output_basename
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_vcf: dbsnp_vcf
      hapmap_resource_vcf: hapmap_resource_vcf
      mills_resource_vcf: mills_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      snp_max_gaussians: vqsr_snp_max_gaussians
      indel_max_gaussians: vqsr_indel_max_gaussians
      snp_tranches:
        source: [vqsr_snp_tranches, filtering_defaults/snp_tranches]
        valueFrom: "$(self[0] != null ? self[0] : self[1])"
      indel_tranches:
        source: [vqsr_indel_tranches, filtering_defaults/indel_tranches]
        valueFrom: "$(self[0] != null ? self[0] : self[1])"
      snp_annotations:
        source: [vqsr_snp_annotations, filtering_defaults/snp_annotations]
        valueFrom: "$(self[0] != null ? self[0] : self[1])"
      indel_annotations:
        source: [vqsr_indel_annotations, filtering_defaults/indel_annotations]
        valueFrom: "$(self[0] != null ? self[0] : self[1])"
      snp_ts_filter_level:
        source: [vqsr_snp_ts_filter_level, filtering_defaults/snp_ts_filter_level]
        valueFrom: "$(self[0] != null ? self[0] : self[1])"
      indel_ts_filter_level:
        source: [vqsr_indel_ts_filter_level, filtering_defaults/indel_ts_filter_level]
        valueFrom: "$(self[0] != null ? self[0] : self[1])"
      snp_model_cpu: vqsr_snp_model_cpu
      snp_model_ram: vqsr_snp_model_ram
      indel_recal_cpu: vqsr_indel_recal_cpu
      indel_recal_ram: vqsr_indel_recal_ram
      snp_recal_cpu: vqsr_snp_recal_cpu
      snp_recal_ram: vqsr_snp_recal_ram
      gathertranche_cpu: vqsr_gathertranche_cpu
      gathertranche_ram: vqsr_gathertranche_ram
      apply_cpu: vqsr_apply_cpu
      apply_ram: vqsr_apply_ram
      gathervcf_cpu: vqsr_gathervcf_cpu
      gathervcf_ram: vqsr_gathervcf_ram
    out: [recalibrated_vcf]
  gatk_gathervcfs:
    run: ../tools/gatk_gathervcfs.cwl
    when: $(inputs.low_data)
    in:
      low_data: filtering_defaults/low_data
      input_vcfs: gatk_genomicsdbimport_genotypegvcfs/genotyped_vcf
    out: [output]
  gatk_hardfiltering:
    run: ../subworkflows/kfdrc-gatk-hardfiltering.cwl
    when: $(inputs.low_data)
    in:
      low_data: filtering_defaults/low_data
      input_vcf: gatk_gathervcfs/output
      output_basename: output_basename
      snp_hardfilters:
        source: [hardfilter_snp_filters, filtering_defaults/snp_hardfilter]
        valueFrom: "$(self[0] != null ? self[0] : self[1])"
      indel_hardfilters:
        source: [hardfilter_indel_filters, filtering_defaults/indel_hardfilter]
        valueFrom: "$(self[0] != null ? self[0] : self[1])"
      snp_plot_annots: filtering_defaults/snp_plot_annots
      indel_plot_annots: filtering_defaults/indel_plot_annots
      snp_filtration_extra_args: hardfilter_snp_filter_extra_args
      indel_filtration_extra_args: hardfilter_indel_filter_extra_args
      filtration_cpu: hardfilter_filtertration_cpu
      filtration_ram: hardfilter_filtertration_ram
    out: [hardfiltered_vcf, annotation_plots]
  peddy:
    run: ../tools/kfdrc_peddy_tool.cwl
    doc: 'QC family relationships and sex assignment'
    in:
      ped: ped
      vqsr_vcf:
        source: [gatk_vqsr/recalibrated_vcf, gatk_hardfiltering/hardfiltered_vcf]
        pickValue: first_non_null
      output_basename: output_basename
    out: [output_html, output_csv, output_peddy]
  picard_collectvariantcallingmetrics:
    run: ../tools/picard_collectvariantcallingmetrics.cwl
    doc: 'picard calculate variant calling metrics'
    in:
      input_vcf:
        source: [gatk_vqsr/recalibrated_vcf, gatk_hardfiltering/hardfiltered_vcf]
        pickValue: first_non_null
      reference_dict:
        source: indexed_reference_fasta
        valueFrom: |
          $(self.secondaryFiles.filter(function(e) {return e.nameext == '.dict'})[0])
      output_basename:
        source: output_basename
        valueFrom: $(self).gatk.germline.hardfiltered
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]
  annotate_vcf:
    run: ../kf-annotation-tools/workflows/kfdrc-germline-snv-annot-workflow.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_vcf:
        source: [gatk_vqsr/recalibrated_vcf, gatk_hardfiltering/hardfiltered_vcf]
        pickValue: first_non_null
      output_basename: output_basename
      tool_name: tool_name
      bcftools_annot_clinvar_columns: bcftools_annot_clinvar_columns
      echtvar_anno_zips: echtvar_anno_zips
      clinvar_annotation_vcf: clinvar_annotation_vcf
      vep_ram: vep_ram
      vep_cores: vep_cores
      vep_buffer_size: vep_buffer_size
      vep_cache: vep_cache
      dbnsfp: dbnsfp
      dbnsfp_fields: dbnsfp_fields
      cadd_indels: cadd_indels
      cadd_snvs: cadd_snvs
      merged: merged
      intervar: intervar
    out: [annotated_vcf]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 2
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- GATK
- GENOTYPING
- JOINT
- PEDDY
- VCF
- VEP
"sbg:links":
- id: 'https://github.com/kids-first/kf-germline-workflow/releases/tag/v1.1.1'
  label: github-release
