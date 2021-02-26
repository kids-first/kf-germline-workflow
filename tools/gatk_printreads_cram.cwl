cwlVersion: v1.0
class: CommandLineTool
id: gatk_printreads_cram
doc: "Print reads in the CRAM file"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R'
baseCommand: ['/bin/bash','-c']
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      set -eu

      /gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" PrintReads
      -L $(inputs.intervals_list.path)
      --reference $(inputs.reference.path)
      --input $(inputs.cram.path)
      --output $(inputs.cram.nameroot).$(inputs.intervals_list.nameroot).bam
      --disable-tool-default-read-filters true

inputs:
  reference:
    type: 'File'
    doc: "Reference fasta"
    secondaryFiles: ['.fai','^.dict']
  cram:
    type: 'File'
    doc: "CRAM file containing reads"
    secondaryFiles: ['.crai']
  intervals_list:
    type: 'File'
    doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs."
  max_memory: { type: int?, default: 2, doc: "GB of RAM to allocate to the task." }
  cores: { type: int?, default: 1, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  bam: { type: 'File', outputBinding: { glob: "*.bam" }, secondaryFiles: [^.bai] }
