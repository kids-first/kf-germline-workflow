cwlVersion: v1.2
class: Workflow
id: freebayes
doc: |
  Freebayes subworkflow. Scattered run and merge.
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  indexed_reference_fasta:
    type: 'File'
    secondaryFiles:
    - {pattern: '^.dict', required: true}
    - {pattern: '.fai', required: true}
    doc: |
      The reference genome fasta (and associated indicies) to which the germline BAM was aligned.
    "sbg:fileTypes": "FASTA, FA"
    "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [{class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict},
        {class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai}]}

  input_reads: {type: 'File[]', secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}], doc: "Aligned reads files to be analyzed", "sbg:fileTypes": "BAM,CRAM"}
  scattered_calling_beds: { type: 'File[]' }
  output_basename: {type: 'string', doc: "String value to use as basename for outputs"}

  # Resource Requirements
  freebayes_cpu: {type: 'int?', doc: "CPUs to allocate to freebayes"}
  freebayes_ram: {type: 'int?', doc: "RAM in GB to allocate to freebayes"}

outputs:
  freebayes_merged_vcf: {type: 'File', outputSource: merge_vcfs/merged_vcf}

steps:
  freebayes:
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c5.9xlarge
    run: ../tools/freebayes.cwl
    scatter: [targets_file]
    in:
      reference_fasta: indexed_reference_fasta
      input_reads: input_reads
      output_basename: output_basename
      targets_file: scattered_calling_beds
      ram: freebayes_ram
      cpu: freebayes_cpu
    out: [output]
  merge_vcfs:
    run: ../tools/gatk_mergevcfs.cwl
    in:
      input_vcfs: freebayes/output
      output_basename: output_basename
      reference_dict:
        source: indexed_reference_fasta
        valueFrom: |
          $(self.secondaryFiles.filter(function(e) {return e.nameext == '.dict'})[0])
      tool_name:
        valueFrom: "freebayes"
    out: [merged_vcf]

$namespaces:
  sbg: https://sevenbridges.com
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
