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
  input_vcf: {type: 'File', secondaryFiles: [.tbi], doc: "Input VCF containing INDEL and SNP variants"}
  output_basename: {type: 'string', doc: "String value to use as the base for the filename of the output"}
  snp_hardfilters: {type: 'string', doc: "String value of hardfilters to set for SNPs in input_vcf" }
  indel_hardfilters: {type: 'string', doc: "String value of hardfilters to set for INDELs in input_vcf" }

outputs:
  hardfiltered_vcf: {type: 'File', outputSource: bcftools_concat_snps_indels/output}

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
  gatk_variantfiltration_snps:
    run: ../tools/gatk_variantfiltration.cwl
    in:
      input_vcf: gatk_selectvariants_snps/output
      output_basename: output_basename
      selection: {valueFrom: "SNP"}
    out: [output]
  gatk_variantfiltration_indels:
    run: ../tools/gatk_variantfiltration.cwl
    in:
      input_vcf: gatk_selectvariants_indels/output
      output_basename: output_basename
      selection: {valueFrom: "INDEL"}
    out: [output]
  bcftools_concat_snps_indels:
    run: ../tools/bcftools_concat.cwl
    in:
      indel_vcf: gatk_variantfiltration_indels/output
      snp_vcf: gatk_variantfiltration_snps/output
      output_basename: output_basename
    out: [output]
