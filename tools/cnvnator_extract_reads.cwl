cwlVersion: v1.2
class: CommandLineTool
id: cnvnator_extract_reads
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000 )
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      perl /opt/seq_cache_populate.pl -root .cache/hts-ref $(inputs.reference.path) 1>&2 && cnvnator
  - position: 99
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  input_reads: { type: 'File[]', secondaryFiles: [{pattern: ".bai", required: false}, {pattern: "^.bai", required: false}, {pattern: ".crai", required: false}, {pattern: "^.crai", required: false}], inputBinding: { prefix: '-tree'}, doc: "Specifies bam file(s) names" }
  reference: { type: 'File' }
  chrom: { type: 'string[]?', inputBinding: { prefix: '-chrom' }, doc: "Chromosome name(s) on which this task will be performed" }
  output_root: { type: 'string', inputBinding: { prefix: '-root'}, doc: "String value to use as the output root file name" }
  lite: { type: 'boolean?', inputBinding: { prefix: '-lite' }, doc: "Use this option to produce a lighter/smaller root file" }
  max_memory: { type: 'int?', default: 16, doc: "GB of memory to allocate to this task." }
  cpu: { type: 'int?', default: 8, doc: "Number of CPUs to allocate to this task." }
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_root)
