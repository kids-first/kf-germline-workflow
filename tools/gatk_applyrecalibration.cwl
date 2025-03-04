cwlVersion: v1.2
class: CommandLineTool
id: gatk_applyrecalibration
requirements:
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0'
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
      /gatk --java-options "-Xms$(Math.floor((inputs.ram - 1)*1000/1.074-1))m -Xmx$(Math.floor(inputs.ram*1000/1.074-1))m"
      ApplyVQSR
      -O tmp.indel.recalibrated.vcf
      -V $(inputs.input_vcf.path)
      --recal-file $(inputs.indels_recalibration.path)
      --tranches-file $(inputs.indels_tranches.path)
      -ts-filter-level $(inputs.indel_ts_filter_level)
      --create-output-bam-index true
      -mode INDEL

      /gatk --java-options "-Xms$(Math.floor((inputs.ram - 1)*1000/1.074-1))m -Xmx$(Math.floor(inputs.ram*1000/1.074-1))m"
      ApplyVQSR
      -O scatter.filtered.vcf.gz
      -V tmp.indel.recalibrated.vcf
      --recal-file $(inputs.snps_recalibration.path)
      --tranches-file $(inputs.snps_tranches.path)
      -ts-filter-level $(inputs.snp_ts_filter_level)
      --create-output-bam-index true
      -mode SNP
inputs:
  input_vcf:
    type: File
    secondaryFiles: [{pattern: '.tbi', required: true}]
  indels_recalibration:
    type: File
    secondaryFiles: [{pattern: '.idx', required: true}]
  indels_tranches: File
  snps_recalibration:
    type: File
    secondaryFiles: [{pattern: '.idx', required: true}]
  snps_tranches: File
  snp_ts_filter_level: { type: 'float', doc: "The truth sensitivity level at which to start filtering SNP data" }
  indel_ts_filter_level: { type: 'float', doc: "The truth sensitivity level at which to start filtering INDEL data" }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 7, doc: "GB of RAM to allocate to this task." }

outputs:
  recalibrated_vcf:
    type: File
    outputBinding:
      glob: scatter.filtered.vcf.gz
    secondaryFiles: [{pattern: '.tbi', required: true}]
