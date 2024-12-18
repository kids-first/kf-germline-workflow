cwlVersion: v1.2
class: CommandLineTool
id: gatk_snpsvariantrecalibratorscattered
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
      /gatk --java-options "-Xmx3g -Xms3g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O scatter.snps.recal
      --tranches-file scatter.snps.tranches
      --output-tranches-for-scatter
      --trust-all-polymorphic
      --mode SNP
      --input-model $(inputs.model_report.path)
      --max-gaussians $(inputs.max_gaussians)
      -resource hapmap,known=false,training=true,truth=true,prior=15:$(inputs.hapmap_resource_vcf.path)
      -resource omni,known=false,training=true,truth=true,prior=12:$(inputs.omni_resource_vcf.path)
      -resource 1000G,known=false,training=true,truth=false,prior=10:$(inputs.one_thousand_genomes_resource_vcf.path)
      -resource dbsnp,known=true,training=false,truth=false,prior=7:$(inputs.dbsnp_resource_vcf.path)
      -tranche $(inputs.tranche.join(' -tranche '))
      -an $(inputs.annotations.join(' -an '))
inputs:
  sites_only_variant_filtered_vcf:
    type: File
    secondaryFiles: [{pattern: '.tbi', required: true}]
  model_report: File
  hapmap_resource_vcf:
    type: File
    secondaryFiles: [{pattern: '.tbi', required: true}]
  omni_resource_vcf:
    type: File
    secondaryFiles: [{pattern: '.tbi', required: true}]
  one_thousand_genomes_resource_vcf:
    type: File
    secondaryFiles: [{pattern: '.tbi', required: true}]
  dbsnp_resource_vcf:
    type: File
    secondaryFiles: [{pattern: '.idx', required: true}]
  max_gaussians: { type: 'int?', default: 6 }
  tranche: { type: 'string[]', doc: "The levels of truth sensitivity at which to slice the data, in percent." }
  annotations: { type: 'string[]', doc: "The names of the annotations which should used for calculations." }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 4, doc: "GB of RAM to allocate to this task." }
outputs:
  recalibration:
    type: File
    outputBinding:
      glob: scatter.snps.recal
    secondaryFiles: [.idx]
  tranches:
    type: File
    outputBinding:
      glob: scatter.snps.tranches
