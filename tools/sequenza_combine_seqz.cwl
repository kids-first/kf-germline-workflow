cwlVersion: v1.2
id: sequenze_combine_seqz
doc: "Rough cat | awk | bgzip bash line that combines seqz files into a singular file."
requirements:
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/samtools:1.15.1'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
class: CommandLineTool
baseCommand: [/bin/bash, -c]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: |
      cat $(inputs.input_seqzs.map(function(i){return i.path}).join(' ')) | awk '{if (NR==1 || $1 != "chromosome") {print $0}}' | bgzip > $(inputs.output_filename)
inputs:
  input_seqzs: { type: 'File[]', doc: "Name of the normal sample" }
  output_filename: { type: 'string', doc: "Sting to use as filename for merged output" }
  cpu: { type: 'int?', default: 2, doc: "Cores to allocate to this task" }
  ram: { type: 'int?', default: 4, doc: "GB of RAM to allocate to this task" }
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
