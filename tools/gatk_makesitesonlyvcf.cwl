cwlVersion: v1.2
class: CommandLineTool
id: gatk_makesitesonlyvcf
requirements:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.6.1.0'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
baseCommand: ["gatk", "MakeSitesOnlyVcf"]
inputs:
  input_vcf: { type: 'File', inputBinding: {position: 2, prefix: "--INPUT"}, secondaryFiles: [{pattern: '.tbi', required: false}], doc: "Input VCF or BCF containing genotype and site-level information." }
  output_filename: { type: 'string', inputBinding: {position: 2, prefix: "--OUTPUT"}, doc: "Name for output VCF or BCF file containing only site-level information." }
  extra_args: { type: 'string?', inputBinding: {position: 3, shellQuote: false}, doc: "Any extra arguments for this task" }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 4, doc: "GB of RAM to allocate to this task." }
outputs:
  sites_vcf:
    type: File
    secondaryFiles: [{pattern: '.tbi', required: false}]
    outputBinding:
      glob: $(inputs.output_filename)
