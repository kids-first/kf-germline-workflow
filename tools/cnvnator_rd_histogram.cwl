cwlVersion: v1.2
class: CommandLineTool
id: cnvnator_rd_histogram
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000 )
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing: $(inputs.input_root)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1'
baseCommand: [cnvnator]
arguments:
  - position: 99
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  bin_size: { type: 'int', inputBinding: { prefix: '-his' }, doc: "Size of the bins for the task" }
  ref_fasta: { type: 'File', inputBinding: { prefix: '-fasta' }, doc: "Reference genome fasta(.gz)" }
  input_root: { type: 'File', inputBinding: { prefix: '-root', valueFrom: $(self.basename) }, doc: "Input root file" }
  chrom: { type: 'string[]?', inputBinding: { prefix: '-chrom' }, doc: "Chromosome name(s) on which this task will be performed" }
  max_memory: { type: 'int?', default: 2, doc: "GB of memory to allocate to this task." }
  cpu: { type: 'int?', default: 1, doc: "Number of CPUs to allocate to this task." }
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.input_root.basename)
