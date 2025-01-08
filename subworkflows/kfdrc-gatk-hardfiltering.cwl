cwlVersion: v1.2
class: Workflow
id: kfdrc-gatk-hardfiltering
requirements:
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
doc: |-
  This workflow performs manual site-level variant filtration on an input VCF using the generic hard-filtering thresholds and example commands in the
  [documentation from Broad](https://gatk.broadinstitute.org/hc/en-us/articles/360035531112--How-to-Filter-variants-either-with-VQSR-or-by-hard-filtering#2).

  The input VCF is split into SNP and INDEL VCFs using GATK SelectVariants. Those individual VCFs are then filtered using GATK VariantFiltration.
  Finally the VCFs are merged back together using bcftools concat and returned.

inputs:
  input_vcf: {type: 'File', secondaryFiles: [{pattern: '.tbi', required: true}], doc: "Input VCF containing INDEL and SNP variants"}
  output_basename: {type: 'string', doc: "String value to use as the base for the filename of the output"}
  snp_plot_annots: {type: 'string[]?', doc: "The name of a standard VCF field or an INFO field to include in the output table for SNPs"}
  indel_plot_annots: {type: 'string[]?', doc: "The name of a standard VCF field or an INFO field to include in the output table for INDELs"}
  snp_hardfilters: {type: 'string', doc: "String value of hardfilters to set for SNPs in input_vcf" }
  indel_hardfilters: {type: 'string', doc: "String value of hardfilters to set for INDELs in input_vcf" }
  snp_filtration_extra_args: {type: 'string?', doc: "Any extra arguments for SNP VariantFiltration" }
  indel_filtration_extra_args: {type: 'string?', doc: "Any extra arguments for INDEL VariantFiltration" }
  filtration_cpu: { type: 'int?', doc: "CPUs to allocate to GATK VariantFiltration" }
  filtration_ram: { type: 'int?', doc: "GB of RAM to allocate to GATK VariantFiltration" }

outputs:
  annotation_plots: {type: 'File', outputSource: tar_plots/output}
  hardfiltered_vcf: {type: 'File', secondaryFiles: [{pattern: '.tbi', required: true}], outputSource: bcftools_concat_snps_indels/output}

steps:
  gatk_selectvariants_snps:
    run: ../tools/gatk_selectvariants.cwl
    in:
      input_vcf: input_vcf
      output_basename: output_basename
      selection: {valueFrom: "SNP"}
    out: [output]
  gatk_selectvariants_indels:
    run: ../tools/gatk_selectvariants.cwl
    in:
      input_vcf: input_vcf
      output_basename: output_basename
      selection: {valueFrom: "INDEL"}
    out: [output]
  gatk_variantstotable_snps:
    run: ../tools/gatk_variantstotable.cwl
    in:
      input_vcf: gatk_selectvariants_snps/output
      fields: snp_plot_annots
      output_filename: { valueFrom: "temp.snp.tsv"}
    out: [output]
  gatk_variantstotable_indels:
    run: ../tools/gatk_variantstotable.cwl
    in:
      input_vcf: gatk_selectvariants_indels/output
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
  gatk_variantfiltration_snps:
    run: ../tools/gatk_variantfiltration.cwl
    in:
      input_vcf: gatk_selectvariants_snps/output
      output_basename:
        source: output_basename
        valueFrom: |
          $(self).snp.filtered
      variant_filters: snp_hardfilters
      extra_args: snp_filtration_extra_args
      max_memory: filtration_ram
      cpu: filtration_cpu
    out: [output]
  gatk_variantfiltration_indels:
    run: ../tools/gatk_variantfiltration.cwl
    in:
      input_vcf: gatk_selectvariants_indels/output
      output_basename:
        source: output_basename
        valueFrom: |
          $(self).indel.filtered
      variant_filters: indel_hardfilters
      extra_args: indel_filtration_extra_args
      max_memory: filtration_ram
      cpu: filtration_cpu
    out: [output]
  bcftools_concat_snps_indels:
    run: ../tools/bcftools_concat.cwl
    in:
      indel_vcf: gatk_variantfiltration_indels/output
      snp_vcf: gatk_variantfiltration_snps/output
      output_basename: output_basename
    out: [output]
