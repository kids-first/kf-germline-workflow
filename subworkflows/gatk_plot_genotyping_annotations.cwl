cwlVersion: v1.2
class: Workflow
id: gatk_plot_genotyping_annotations
requirements:
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
doc: |-
  This workflow performs manual site-level variant filtration on an input VCF using the generic hard-filtering thresholds and example commands in the
  [documentation from Broad](https://gatk.broadinstitute.org/hc/en-us/articles/360035531112--How-to-Filter-variants-either-with-VQSR-or-by-hard-filtering#2).

  The input VCF is split into SNP and INDEL VCFs using GATK SelectVariants. Those individual VCFs are then filtered using GATK VariantFiltration.
  Finally the VCFs are merged back together using bcftools concat and returned.

inputs:
  snps_vcf: {type: 'File', secondaryFiles: [{pattern: '.tbi', required: false}], doc: "Input VCF containing SNP variants"}
  indels_vcf: {type: 'File', secondaryFiles: [{pattern: '.tbi', required: false}], doc: "Input VCF containing INDEL variants"}
  output_basename: {type: 'string', doc: "String value to use as the base for the filename of the output"}
  snp_plot_annots: {type: 'string[]?', doc: "The name of a standard VCF field or an INFO field to include in the output table for SNPs"}
  indel_plot_annots: {type: 'string[]?', doc: "The name of a standard VCF field or an INFO field to include in the output table for INDELs"}

outputs:
  annotation_plots: {type: 'File', outputSource: tar_plots/output}

steps:
  gatk_variantstotable_snps:
    run: ../tools/gatk_variantstotable.cwl
    in:
      input_vcf: snps_vcf
      fields: snp_plot_annots
      output_filename: { valueFrom: "temp.snp.tsv"}
    out: [output]
  gatk_variantstotable_indels:
    run: ../tools/gatk_variantstotable.cwl
    in:
      input_vcf: indels_vcf
      fields: indel_plot_annots
      output_filename: {valueFrom: "temp.snp.tsv"}
    out: [output]
  gatk_plot_annotations_snps:
    run: ../tools/gatk_plot_annotations.cwl
    in:
      input_table: gatk_variantstotable_snps/output
      input_type: {valueFrom: "SNP"}
      output_basename: output_basename
      annotation_fields: snp_plot_annots
    out: [plots]
  gatk_plot_annotations_indels:
    run: ../tools/gatk_plot_annotations.cwl
    in:
      input_table: gatk_variantstotable_snps/output
      input_type: {valueFrom: "INDEL"}
      output_basename: output_basename
      annotation_fields: indel_plot_annots
    out: [plots]
  tar_plots:
    run: ../tools/tar.cwl
    in:
      output_filename:
        source: output_basename
        valueFrom: '$(self).annotation_plots.tar.gz'
      input_files:
        source: [gatk_plot_annotations_snps/plots, gatk_plot_annotations_indels/plots]
        valueFrom: '$(self[0].concat(self[1]))'
    out: [output]
