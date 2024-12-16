cwlVersion: v1.0
class: CommandLineTool
id: gatk_indelsvariantrecalibrator
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
      /gatk --java-options "-Xmx24g -Xms24g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O indels.recal
      --tranches-file indels.tranches
      --trust-all-polymorphic
      --mode INDEL
      --max-gaussians $(inputs.max_gaussians)
      -resource mills,known=false,training=true,truth=true,prior=12:$(inputs.mills_resource_vcf.path)
      -resource axiomPoly,known=false,training=true,truth=false,prior=10:$(inputs.axiomPoly_resource_vcf.path)
      -resource dbsnp,known=true,training=false,truth=false,prior=2:$(inputs.dbsnp_resource_vcf.path)
      -tranche $(inputs.tranches.join(' -tranche '))
      -an $(inputs.annotations.join(' -an '))
inputs:
  sites_only_variant_filtered_vcf:
    type: File
    secondaryFiles: [.tbi]
  mills_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  axiomPoly_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  dbsnp_resource_vcf:
    type: File
    secondaryFiles: [.idx]
  max_gaussians: { type: 'int?', default: 4 }
  tranches: { type: 'string[]', doc: "The levels of truth sensitivity at which to slice the data, in percent." }
  annotations: { type: 'string[]', doc: "The names of the annotations which should used for calculations." }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 25, doc: "GB of RAM to allocate to this task." }
outputs:
  recalibration:
    type: File
    outputBinding:
      glob: indels.recal
    secondaryFiles: [.idx]
  tranches:
    type: File
    outputBinding:
      glob: indels.tranches
