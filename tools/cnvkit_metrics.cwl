cwlVersion: v1.2
class: CommandLineTool
id: cnvkit-metrics
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'etal/cnvkit:0.9.8'
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)

baseCommand: [cnvkit.py,metrics]

arguments:
  - position: 99
    shellQuote: false
    valueFrom: |
      1>&2

inputs:
  input_coverage_files: { type: 'File[]', inputBinding: { position: 9 }, doc: "One or more bin-level coverage data files (*.cnn,*.cnr)" }
  segments: { type: 'File[]?', inputBinding: { prefix: "--segments" }, doc: "One or more segmentation data files (*.cns, output of the 'segment' command). If more than one file is given, the number must match the coverage data files, in which case the input files will be paired together in the given order. Otherwise, the same segments will be used for all coverage files." }
  drop_low_coverage: { type: 'boolean?', inputBinding: { prefix: "--drop-low-coverage" }, doc: "Drop very-low-coverage bins before segmentation to avoid false-positive deletions in poor-quality tumor samples." }
  output_filename: { type: 'string', inputBinding: { prefix: "--output", position: 8 }, doc: "Output table file name" }

  # Resource Control
  cpu: { type: 'int?', default: 16, doc: "CPU cores to allocate to this task" }
  ram: { type: 'int?', default: 32, doc: "GB of RAM to allocate to this task" }

outputs:
  output:
    type: 'File'
    outputBinding:
      glob: '$(inputs.output_filename)'
    doc: "Output metrics file"
