cwlVersion: v1.2
class: CommandLineTool
id: gatk_genomicsdbimport_genotypegvcfs
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0'
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk --java-options "-Xms$(((inputs.max_memory - 5) * 500)m -Xmx$((inputs.max_memory - 5) * 1000)m"
      GenomicsDBImport
      -L $(inputs.interval.path)
      --interval-padding 5
      --genomicsdb-workspace-path genomicsdb
      --batch-size 50
      --reader-threads 5
  - position: 10
    shellQuote: false
    valueFrom: >-
      && /gatk --java-options "-Xms$(Math.floor(inputs.max_memory*500/1.074-1))m -Xmx$(Math.floor(inputs.max_memory*1000/1.074-1))m"
      GenotypeGVCFs
      -R $(inputs.reference_fasta.path)
      -D $(inputs.dbsnp_vcf.path)
      -L $(inputs.interval.path)
      --only-output-calls-starting-in-intervals
      -V gendb://genomicsdb
      -G StandardAnnotation
      -G AS_StandardAnnotation
      -O output.vcf.gz
      -new-qual

inputs:
  interval: File
  reference_fasta: { type: 'File', secondaryFiles: [{pattern: '^.dict', required: true}, {pattern: '.fai', required: true}]}
  dbsnp_vcf: { type: 'File', secondaryFiles: [{pattern: '.idx', required: true}]}
  input_vcfs: { type: { type: array, items: 'File', inputBinding: { prefix: -V } }, inputBinding: { position: 1 }, secondaryFiles: [{pattern: '.tbi', requred: true}] }
  genomicsdbimport_extra_args: { type: 'string?', inputBinding: { position: 1, shellQuote: false } }
  genotypegvcfs_extra_args: { type: 'string?' inputBinding: { position: 11, shellQuote: false } }
  cpu: { type: 'int?', default: 5, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 10, doc: "GB of RAM to allocate to this task" }
outputs:
  genotyped_vcf:
    type: File
    secondaryFiles: [{pattern: '.tbi', required: true}]
    outputBinding:
      glob: 'output.vcf.gz'
