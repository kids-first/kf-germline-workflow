cwlVersion: v1.2
class: CommandLineTool
id: cnvnator_call
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |
      echo "CNV_type\tcoordinates\tCNV_size\tnormalized_RD\te-val1\te-val2\te-val3\te-val4\tq0" > $(inputs.input_root.nameroot).cnvnator_call.txt
  - position: 1
    shellQuote: false
    prefix: "&&"
    valueFrom: |
      cnvnator
  - position: 9
    shellQuote: false
    prefix: ">>"
    valueFrom: |
      $(inputs.input_root.nameroot).cnvnator_call.txt
inputs:
  bin_size: { type: 'int', inputBinding: { position: 2, prefix: '-call'}, doc: "Size of the bins for the task" }
  input_root: { type: 'File', inputBinding: { position: 2, prefix: '-root' }, doc: "Input root file" }
  chrom: { type: 'string[]?', inputBinding: { position: 2, prefix: '-chrom' }, doc: "Chromosome name(s) on which this task will be performed" }
  disable_gc_correction: { type: 'boolean?', inputBinding: { position: 2, prefix: '-ngc' }, doc: "Use this option to not use GC corrected RD signal" }
  max_memory: { type: 'int?', default: 2, doc: "GB of memory to allocate to this task." }
  cpu: { type: 'int?', default: 1, doc: "Number of CPUs to allocate to this task." }
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.input_root.nameroot).cnvnator_call.txt
