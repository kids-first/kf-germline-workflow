cwlVersion: v1.2
class: CommandLineTool
id: gatk_gathervcfscloud
requirements:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.6.1.0'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      gatk --java-options "-Xmx$(Math.floor((inputs.ram - 1)*1000/1.074-1))m -Xms$(Math.floor((inputs.ram - 1)*1000/1.074-1))m"
      GatherVcfsCloud
      --output $(inputs.output_basename).vcf.gz
inputs:
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    secondaryFiles: [{pattern: '.tbi', required: true}]
    inputBinding:
      position: 1
  output_basename: string
  extra_args: { type: 'string?', inputBinding: {position: 2},  doc: "Any extra arguments for this task." }
  cpu: { type: 'int?', default: 2, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 7, doc: "GB of RAM to allocate to this task." }
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_basename).vcf.gz
    secondaryFiles: [{pattern: '.tbi', required: true}]
