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
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0'
baseCommand: [/gatk]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --java-options "-Xmx${ return Math.floor(inputs.max_memory*1000/1.074-1) }m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10"
      VariantFiltration
      -V $(inputs.input_vcf.path)
      -O $(inputs.output_filename)
      $(inputs.variant_filters ? inputs.variant_filters : "")

inputs:
  input_vcf: { type: 'File', secondaryFiles: [{pattern: ".tbi", required: false}] }
  output_filename: { type: 'string', doc: "String value to use as the base for the output filename" }
  variant_filters: { type: 'string?', doc: "Any filters (with filter names) to add to the input_vcf" }
  max_memory: { type: 'int?', default: 8, doc: "GB of memory to allocate to this task. default: 8" }
  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task. default: 2" }
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles: [{pattern: ".tbi", required: false}]
