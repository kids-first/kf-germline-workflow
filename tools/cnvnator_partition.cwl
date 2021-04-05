cwlVersion: v1.0
class: CommandLineTool
id: cnvnator_parition 
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/cnvnator:0.4.1'
baseCommand: [cnvnator]
inputs:
  bin_size: { type: 'int', inputBinding: { prefix: '-partition'}, doc: "Size of the bins for the task" }
  chrom: { type: 'string', inputBinding: { prefix: '-chrom' }, doc: "Chromosome name(s) on which this task will be performed" }
  input_root: { type: 'File', inputBinding: { prefix: '-root'}, doc: "Input root file" }
  disable_gc_correction: { type: 'boolean?', inputBinding: { prefix: '-ngc' }, doc: "Use this option to not use GC corrected RD signal" }
  max_memory: { type: 'int?', default: 8, doc: "GB of memory to allocate to this task." }
  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task." }
outputs:
  output_root:
    type: 'File'
    outputBinding:
      glob: $(inputs.input_root.basename)
