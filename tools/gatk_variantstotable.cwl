cwlVersion: v1.2
class: CommandLineTool
id: gatk_variantstotable
doc: |
  Extract fields from a VCF file to a tab-delimited table
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.6.1.0'
baseCommand: [gatk, VariantsToTable]
inputs:
  input_vcf: { type: 'File', secondaryFiles: [{pattern: '.tbi', required: false}], inputBinding: { position: 2, prefix: "--variant" }, doc: "The input VCF file to convert to a table." }
  input_intervals: { type: 'File?', inputBinding: { position: 2, prefix: "--intervals" }, doc: "One or more genomic intervals over which to operate" }
  reference: { type: 'File?', secondaryFiles: [{pattern: '.fai', required: true}, {pattern: '^.dict', required: true}], inputBinding: { position: 2, prefix: "--reference" }, doc: "Reference sequence" }
  fields:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: '--fields'
    inputBinding:
      position: 2
    doc: "The name of a standard VCF field or an INFO field to include in the output table"
  output_filename: { type: 'string?', default: "out.interval_list", inputBinding: { position: 2, prefix: "--output" }, doc: "Name for output file." }
  extra_args: { type: 'string?', inputBinding: { position: 2 }, doc: "Extra args for this task" }
  ram: { type: 'int?', default: 4, doc: "GB of RAM to allocate to the task." }
  cpu: { type: 'int?', default: 2, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  output: { type: 'File', outputBinding: { glob: $(inputs.output_filename) } }
