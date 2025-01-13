cwlVersion: v1.2
class: CommandLineTool
id: gatk_variantfiltration
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.6.1.0'
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      /gatk --java-options "-Xmx$(Math.floor(inputs.max_memory*1000/1.074-1))m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10"
      VariantFiltration
      -V $(inputs.input_vcf.path)
      -O $(inputs.output_basename).vcf.gz
      $(inputs.variant_filters ? inputs.variant_filters : "")
      $(inputs.extra_args ? inputs.extra_args : "")

inputs:
  input_vcf: { type: 'File', secondaryFiles: [{pattern: '.tbi', required: true}] }
  output_basename: { type: 'string', doc: "String value to use as output basename for file." }
  variant_filters: { type: 'string?', doc: "Any filters (with filter names) to add to the input_vcf" }
  extra_args: { type: 'string?', doc: "Any extra arguments for this task." }
  max_memory: { type: 'int?', default: 8, doc: "GB of memory to allocate to this task." }
  cpu: { type: 'int?', default: 2, doc: "Number of CPUs to allocate to this task." }
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
