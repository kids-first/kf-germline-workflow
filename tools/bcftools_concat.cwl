cwlVersion: v1.2
class: CommandLineTool
id: bcftools_concat
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest'

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      bcftools
      concat
      --allow-overlaps
      --output-type z
      --output $(inputs.output_basename).merged.vcf.gz
      --threads $(inputs.cpu)
      $(inputs.indel_vcf.path)
      $(inputs.snp_vcf.path)

      tabix $(inputs.output_basename).merged.vcf.gz

inputs:
    indel_vcf: { type: 'File', secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF file containing INDELs" }
    snp_vcf: { type: 'File', secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF file containing SNPs" }
    output_basename: { type: 'string', doc: "String value to use as the base of the output filename" }
    ram: { type: 'int?', default: 8, doc: "GB of memory to allocate to this task. default: 8; softcap" }
    cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task. default: 4" }

outputs:
  output:
    type: 'File'
    outputBinding:
      glob: '$(inputs.output_basename).merged.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
