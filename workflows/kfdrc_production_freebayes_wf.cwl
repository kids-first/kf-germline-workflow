cwlVersion: v1.0
class: Workflow
id: kfdrc_production_freebayes_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  reference_fasta: { type: File }
  reference_fai: { type: 'File?' }
  reference_dict: { type: 'File?' }
  generate_bwa_indexes: { type: 'boolean?', default: false }
  input_bams: { type: 'File[]' }
  input_regions: { type: 'File?', doc: "GATK intervals list-style, or bed file, of the regions contained in the input BAMs. Recommend canocical chromosomes with N regions removed" }
  output_basename: { type: string, doc: "String value to use as basename for outputs" }
  exome_flag: { type: 'string?', doc: "Whether to run in exome mode for callers. Y for WXS, N for WGS. Defaults to N" }

  # Resource Requirements
  freebayes_cpu: { type: int?, doc: "CPUs to allocate to freebayes" }
  freebayes_ram: { type: int?, doc: "RAM in GB to allocate to freebayes" }

outputs:
  freebayes_merged_vcf: { type: File, outputSource: merge_vcfs/merged_vcf }

steps:
  prepare_reference:
    run: ../sub_workflows/prepare_reference.cwl
    in:
      input_fasta: reference_fasta
      input_fai: reference_fai
      input_dict: reference_dict
      generate_bwa_indexes: generate_bwa_indexes 
    out: [indexed_fasta,reference_dict]

  gatk_intervallisttools:
    run: ../tools/gatk_intervallisttool.cwl
    in:
      interval_list: input_regions 
      reference_dict: prepare_reference/reference_dict
      exome_flag: exome_flag 
      scatter_ct:
        valueFrom: ${return 50}
      bands:
        valueFrom: ${return 80000000}
    out: [output]

  freebayes:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/freebayes.cwl
    scatter: [targets_file]
    in:
      reference_fasta: prepare_reference/indexed_fasta
      input_bams: input_bams
      output_basename: output_basename
      targets_file: gatk_intervallisttools/output 
      ram: freebayes_ram
      cpu: freebayes_cpu
    out: [output]

  merge_vcfs:
    run: ../tools/gatk_mergevcfs.cwl
    in:
      input_vcfs: freebayes/output
      output_basename: output_basename
      reference_dict: reference_dict
      tool_name: { valueFrom: '${return "freebayes"}' }
    out: [merged_vcf]

$namespaces:
  sbg: https://sevenbridges.com
