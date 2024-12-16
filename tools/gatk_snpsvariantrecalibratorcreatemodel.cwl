cwlVersion: v1.0
class: CommandLineTool
id: gatk_snpsvariantrecalibratorcreatemodel
requirements:
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      set -e

      /gatk --java-options "-Xmx$(inputs.ram - 1)g -Xms$(Math.floor(inputs.ram / 2))g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O snps.recal
      --tranches-file snps.tranches
      --trust-all-polymorphic
      --mode SNP
      --output-model snps.model.report
      --max-gaussians $(inputs.max_gaussians)
      -resource hapmap,known=false,training=true,truth=true,prior=15:$(inputs.hapmap_resource_vcf.path)
      -resource omni,known=false,training=true,truth=true,prior=12:$(inputs.omni_resource_vcf.path)
      -resource 1000G,known=false,training=true,truth=false,prior=10:$(inputs.one_thousand_genomes_resource_vcf.path)
      -resource dbsnp,known=true,training=false,truth=false,prior=7:$(inputs.dbsnp_resource_vcf.path)
      -tranche $(inputs.tranches.join(' -tranche '))
      -an $(inputs.annotations.join(' -an '))
      || (>%2 echo 'Failed with max gaussians $(inputs.max_gaussians), trying ${return Math.max(inputs.max_gaussians-2, 1)}' && /gatk --java-options "-Xmx$(inputs.ram - 1)g -Xms$(Math.floor(inputs.ram / 2))g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O snps.recal
      --tranches-file snps.tranches
      --trust-all-polymorphic
      --mode SNP
      --output-model snps.model.report
      --max-gaussians ${return Math.max(inputs.max_gaussians-2, 1)}
      -resource hapmap,known=false,training=true,truth=true,prior=15:$(inputs.hapmap_resource_vcf.path)
      -resource omni,known=false,training=true,truth=true,prior=12:$(inputs.omni_resource_vcf.path)
      -resource 1000G,known=false,training=true,truth=false,prior=10:$(inputs.one_thousand_genomes_resource_vcf.path)
      -resource dbsnp,known=true,training=false,truth=false,prior=7:$(inputs.dbsnp_resource_vcf.path)
      -tranche $(inputs.tranches.join(' -tranche '))
      -an $(inputs.annotations.join(' -an '))
      )
inputs:
  sites_only_variant_filtered_vcf:
    type: File
    secondaryFiles: [.tbi]
  hapmap_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  omni_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  one_thousand_genomes_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  dbsnp_resource_vcf:
    type: File
    secondaryFiles: [.idx]
  max_gaussians: { type: 'int?', default: 6 }
  tranches: { type: 'string[]', doc: "The levels of truth sensitivity at which to slice the data, in percent." }
  annotations: { type: 'string[]', doc: "The names of the annotations which should used for calculations." }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 60, doc: "GB of RAM to allocate to this task" }
outputs:
  model_report:
    type: File
    outputBinding:
      glob: snps.model.report
