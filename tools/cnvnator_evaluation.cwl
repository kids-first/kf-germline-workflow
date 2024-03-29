cwlVersion: v1.2
class: CommandLineTool
id: cnvnator_evaluation
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1'
baseCommand: [cnvnator]
inputs:
  bin_size: { type: 'int', inputBinding: { prefix: '-eval'}, doc: "Size of the bins for the task" }
  input_root: { type: 'File', inputBinding: { prefix: '-root'}, doc: "Input root file" }
  max_memory: { type: 'int?', default: 2, doc: "GB of memory to allocate to this task." }
  cpu: { type: 'int?', default: 1, doc: "Number of CPUs to allocate to this task." }
outputs:
  output:
    type: stdout
stdout: $(inputs.input_root.nameroot).cnvnator_eval.txt
