cwlVersion: v1.0
class: CommandLineTool
id: cnvkit-export-seg
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'etal/cnvkit:0.9.8'
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)

baseCommand: [cnvkit.py,export,seg]

inputs:
  input_copy_ratios: { type: 'File', inputBinding: { position: 99 }, doc: "Segmented copy ratio data file(s) (*.cns), the output of the 'segment' sub-command." }
  enumerate_chroms: { type: 'boolean?', inputBinding: { prefix: "--enumerate-chroms" }, doc: "Replace chromosome names with sequential integer IDs." }
  output_filename: { type: 'string', inputBinding: { prefix: "--output" }, doc: "Output file name" }

  # Resource Control
  cpu: { type: 'int?', default: 16, doc: "CPU cores to allocate to this task" }
  ram: { type: 'int?', default: 32, doc: "GB of RAM to allocate to this task" }

outputs:
  output:
    type: 'File'
    outputBinding:
      glob: '$(inputs.output_filename)'
    doc: "Genemetrics table identifying targeted genes with copy number gain or loss"
