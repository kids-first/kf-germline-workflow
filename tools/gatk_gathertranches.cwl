cwlVersion: v1.2
class: CommandLineTool
id: gatk_gathertranches
requirements:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.6.1.0'
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      gatk --java-options "-Xmx$(Math.floor(inputs.ram*1000/1.074-1))m -Xms$(Math.floor((inputs.ram - 1)*1000/1.074-1))m"
      GatherTranches
      $(inputs.extra_args ? inputs.extra_args : "")
inputs:
  tranches:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --input
    inputBinding:
      position: 9
  mode: {type: {type: 'enum', symbols: ["SNP", "INDEL", "BOTH"], name: "mode"}, inputBinding: {position: 2, prefix: "--mode"}, doc: "Use either SNP for recalibrating only SNPs (emitting indels untouched in the output VCF) or INDEL for indels (emitting SNPs untouched in the output VCF). There is also a BOTH option for recalibrating both SNPs and indels simultaneously, but this is meant for testing purposes only and should not be used in actual analyses." }
  output_filename: { type: 'string?', default: "out.tranches", inputBinding: {position: 2, prefix: "--output"}, doc: "String to use as name for output file" }
  extra_args: { type: 'string?', doc: "Any extra arguments for this task" }
  cpu: { type: 'int?', default: 2, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 7, doc: "GB of RAM to allocate to this task." }
outputs:
  output:
    type: File
    outputBinding:
      glob: "$(inputs.output_filename)"
