cwlVersion: v1.2
class: CommandLineTool
id: gatk_sortvcf
doc: "Sort vcf file"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000)
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.2.0.0'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" SortVcf
inputs:
  input_vcf: { type: File, inputBinding: { prefix: "-I", position: 0 } }
  output_filename: { type: string, inputBinding: { prefix: "-O", position: 0 } }
  max_records_in_ram: { type: "int?", inputBinding: { prefix: "--MAX_RECORDS_IN_RAM", position: 0 } , default: 500000}
  cores: { type: "int?", default: 8}
  max_memory: { type: "int?", default: 64}
outputs:
  output: { type: File, outputBinding: {glob: '*.vcf.gz' } }