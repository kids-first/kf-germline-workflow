cwlVersion: v1.2
class: CommandLineTool
id: gatk_gathertranches
requirements:
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0'
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk --java-options "-Xmx$(Math.floor(inputs.ram*1000/1.074-1))m -Xms$(Math.floor((inputs.ram - 1)*1000/1.074-1))m"
      GatherTranches
      --output snps.gathered.tranches
inputs:
  tranches:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --input
    inputBinding:
      position: 1
  cpu: { type: 'int?', default: 2, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 7, doc: "GB of RAM to allocate to this task." }
outputs:
  output:
    type: File
    outputBinding:
      glob: snps.gathered.tranches
