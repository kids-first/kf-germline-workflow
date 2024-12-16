cwlVersion: v1.2
class: Workflow
id: kfdrc-gatk-vqsr
doc: |-
  GATK workflow for Variant Quality Score Recalibration (VQSR)
requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  genotyped_vcfs: {type: 'File[]', secondaryFiles: [{pattern: '.tbi', required: true}], doc: "Input VCF that has been jointly genotyped"}
  output_basename: {type: 'string', doc: "String value to use as the base for the filename of the output"}

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
  snp_max_gaussians: {type: 'int?', doc: "Interger value for max gaussians in SNP VariantRecalibration. If a dataset gives fewer variants
      than the expected scale, the number of Gaussians for training should be turned down. Lowering the max-Gaussians forces the program
      to group variants into a smaller number of clusters, which results in more variants per cluster."}
  indel_max_gaussians: {type: 'int?', doc: "Interger value for max gaussians in INDEL VariantRecalibration. If a dataset gives fewer
      variants than the expected scale, the number of Gaussians for training should be turned down. Lowering the max-Gaussians forces
      the program to group variants into a smaller number of clusters, which results in more variants per cluster."}
  snp_tranches: { type: 'string[]', doc: "The levels of truth sensitivity at which to slice the SNP recalibration data, in percent." }
  snp_annotations: { type: 'string[]', doc: "The names of the annotations which should used for SNP recalibration calculations." }
  indel_tranches: { type: 'string[]', doc: "The levels of truth sensitivity at which to slice the INDEL recalibration data, in percent." }
  indel_annotations: { type: 'string[]', doc: "The names of the annotations which should used for INDEL recalibration calculations." }
  snp_ts_filter_level: { type: 'float', doc: "The truth sensitivity level at which to start filtering SNP data" }
  indel_ts_filter_level: { type: 'float', doc: "The truth sensitivity level at which to start filtering INDEL data" }

  # Resource Control
  snp_model_cpu: { type: 'int?', doc: "CPUs to allocate to VariantRecalibrator for SNP model creation." }
  snp_model_ram: { type: 'int?', doc: "GB of RAM to allocate to VariantRecalibrator for SNP model creation." }
  indel_recal_cpu: { type: 'int?', doc: "CPUs to allocate to VariantRecalibrator for INDEL recalibration." }
  indel_recal_ram: { type: 'int?', doc: "GB of RAM to allocate to VariantRecalibrator for INDEL recalibration." }
  snp_recal_cpu: { type: 'int?', doc: "CPUs to allocate to VariantRecalibrator for scattered SNP recalibration." }
  snp_recal_ram: { type: 'int?', doc: "GB of RAM to allocate to VariantRecalibrator for scattered SNP recalibration." }
  gathertranche_cpu: { type: 'int?', doc: "CPUs to allocate to GatherTranches." }
  gathertranche_ram: { type: 'int?', doc: "GB of RAM to allocate to GatherTranches." }
  apply_cpu: { type: 'int?', doc: "CPUs to allocate to ApplyVQSR for INDELs and SNPs." }
  apply_ram: { type: 'int?', doc: "GB of RAM to allocate to ApplyVQSR for INDELs and SNPs." }
  gathervcf_cpu: { type: 'int?', doc: "CPUs to allocate to GatherVcfsCloud." }
  gathervcf_ram: { type: 'int?', doc: "GB of RAM to allocate to GatherVcfsCloud." }

outputs:
  recalibrated_vcf: { type: 'File', secondaryFiles: [.tbi], outputSource: gatk_gatherfinalvcf/output }

steps:
  gatk_filter_excesshet:
    run: ../tools/tools/gatk_variantfiltration2.cwl
    scatter: [input_vcf]
    in:
      input_vcf: genotyped_vcfs
      output_filename:
        valueFrom: 'variant_filtered.vcf.gz'
      variant_filters:
        valueFrom: '--filter-expression "ExcessHet > 54.69" --filter-name ExcessHet'
    out: [filtered_vcf]
  gatk_makesitesonlyvcf:
    run: ../tools/gatk_makesitesonlyvcf.cwl
    scatter: [input_vcf]
    in:
      input_vcf: gatk_filter_excesshet/filtered_vcf
      output_filename:
        valueFrom: 'sites_only.variant_filtered.vcf.gz'
    out: [sites_vcf]
  gatk_gathervcfs:
    run: ../tools/gatk_gathervcfs.cwl
    in:
      input_vcfs: gatk_makesitesonlyvcf/sites_vcf
    out: [output]
  gatk_snpsvariantrecalibratorcreatemodel:
    run: ../tools/gatk_snpsvariantrecalibratorcreatemodel.cwl
    in:
      dbsnp_resource_vcf: dbsnp_vcf
      hapmap_resource_vcf: hapmap_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
      max_gaussians: snp_max_gaussians
      tranches: snp_tranches
      annotations: snp_annotations
      cpu: snp_model_cpu
      ram: snp_model_ram
    out: [model_report]
  gatk_indelsvariantrecalibrator:
    run: ../tools/gatk_indelsvariantrecalibrator.cwl
    in:
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_resource_vcf: dbsnp_vcf
      mills_resource_vcf: mills_resource_vcf
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
      max_gaussians: indel_max_gaussians
      tranches: indel_tranches
      annotations: indel_annotations
      cpu: indel_recal_cpu
      ram: indel_recal_ram
    out: [recalibration, tranches]
  gatk_snpsvariantrecalibratorscattered:
    run: ../tools/gatk_snpsvariantrecalibratorscattered.cwl
    scatter: [sites_only_variant_filtered_vcf]
    hints:
    - class: 'sbg:AWSInstanceType'
      value: r5.4xlarge
    in:
      sites_only_variant_filtered_vcf: gatk_filter_execesshet/filtered_vcf
      model_report: gatk_snpsvariantrecalibratorcreatemodel/model_report
      hapmap_resource_vcf: hapmap_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      dbsnp_resource_vcf: dbsnp_vcf
      max_gaussians: snp_max_gaussians
      tranches: snp_tranches
      annotations: snp_annotations
      cpu: snp_recal_cpu
      ram: snp_recal_ram
    out: [recalibration, tranches]
  gatk_gathertranches:
    run: ../tools/gatk_gathertranches.cwl
    in:
      tranches: gatk_snpsvariantrecalibratorscattered/tranches
      cpu: gathertranche_cpu
      ram: gathertranche_ram
    out: [output]
  gatk_applyrecalibration:
    run: ../tools/gatk_applyrecalibration.cwl
    scatter: [input_vcf, snps_recalibration]
    scatterMethod: dotproduct
    hints:
    - class: 'sbg:AWSInstanceType'
      value: r5.4xlarge
    in:
      indels_recalibration: gatk_indelsvariantrecalibrator/recalibration
      indels_tranches: gatk_indelsvariantrecalibrator/tranches
      input_vcf: variants_vcfs
      snps_recalibration: gatk_snpsvariantrecalibratorscattered/recalibration
      snps_tranches: gatk_gathertranches/output
      snp_ts_filter_level: snp_ts_filter_level
      indel_ts_filter_level: indel_ts_filter_level
      cpu: apply_cpu
      ram: apply_ram
    out: [recalibrated_vcf]
  gatk_gatherfinalvcf:
    run: ../tools/gatk_gatherfinalvcf.cwl
    in:
      input_vcfs: gatk_applyrecalibration/recalibrated_vcf
      output_basename: output_basename
      cpu: gathervcf_cpu
      ram: gathervcf_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
