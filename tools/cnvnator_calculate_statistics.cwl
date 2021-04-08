cwlVersion: v1.0
class: CommandLineTool
id: cnvnator_calculate_statistics
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing: $(inputs.input_root)
  - class: DockerRequirement
    dockerPull: 'dmiller15/cnvnator:0.4.1'
baseCommand: [cnvnator]
inputs:
  bin_size: { type: 'int', inputBinding: { prefix: '-stat'}, doc: "Size of the bins for the task" }
  input_root: { type: 'File', inputBinding: { prefix: '-root'}, doc: "Input root file" } 
  max_memory: { type: 'int?', default: 8, doc: "GB of memory to allocate to this task." }
  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task." }
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.input_root.basename)
