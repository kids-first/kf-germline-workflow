cwlVersion: v1.0
class: Workflow
id: kfdrc_freebayes_wf
label: KFDRC Freebayes Workflow
doc: |
  # KFDRC Freebayes Workflow
  The KFDRC Freebayes Workflow uses [Freebayes](https://github.com/freebayes/freebayes) to detect small polymorphisms
  in short-read sequencing files. The Freebayes tool takes a reference file, one or more input BAM files, and
  and output basename and returns a single VCF file.

  The workflow improves on the base implementation of Freebayes in that runs the tool in parallel. The input
  reference dict is split into 50 smaller intervals which then is used for localized Freebayes variant
  calling. The resulting VCFs are then merged using GATK.  

  ### Runtime Estimates
  1. Trio of 65 GB BAMs on spot instances: 180 minutes & $2.00
  1. Trio of 120 GB BAMs on spot instances: 270 minutes & $3.25
  1. Single 65 GB BAM on spot instances: 110 minutes & $1.25
  1. Single 35 GB BAM on spot instances: 45 minutes & $0.50
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  reference_fasta: {type: 'File', "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3,
      name: Homo_sapiens_assembly38.fasta}, "sbg:fileTypes": "FASTA, FA"}
  reference_fai: {type: 'File?', "sbg:suggestedValue": {class: File, path: 60639016357c3a53540ca7af,
      name: Homo_sapiens_assembly38.fasta.fai}, "sbg:fileTypes": "FAI"}
  reference_dict: {type: 'File?', "sbg:suggestedValue": {class: File, path: 60639019357c3a53540ca7e7,
      name: Homo_sapiens_assembly38.dict}, "sbg:fileTypes": "DICT"}
  generate_bwa_indexes: {type: 'boolean?', default: false}
  input_bams: {type: 'File[]', secondaryFiles: [^.bai], "sbg:fileTypes": "BAM"}
  input_regions: {type: 'File?', doc: "GATK intervals list-style, or bed file, of\
      \ the regions contained in the input BAMs. Recommend canocical chromosomes with\
      \ N regions removed", "sbg:fileTypes": "BED, INTERVALS, INTERVAL_LIST"}
  output_basename: {type: 'string', doc: "String value to use as basename for outputs"}
  exome_flag: {type: 'string?', doc: "Whether to run in exome mode for callers. Y\
      \ for WXS, N for WGS. Defaults to N"}

  # Resource Requirements
  freebayes_cpu: {type: 'int?', doc: "CPUs to allocate to freebayes"}
  freebayes_ram: {type: 'int?', doc: "RAM in GB to allocate to freebayes"}

outputs:
  freebayes_merged_vcf: {type: 'File', outputSource: merge_vcfs/merged_vcf}

steps:
  prepare_reference:
    run: ../subworkflows/prepare_reference.cwl
    in:
      input_fasta: reference_fasta
      input_fai: reference_fai
      input_dict: reference_dict
      generate_bwa_indexes: generate_bwa_indexes
    out: [indexed_fasta, reference_dict]

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
      tool_name: {valueFrom: '${return "freebayes"}'}
    out: [merged_vcf]

$namespaces:
  sbg: https://sevenbridges.com
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
