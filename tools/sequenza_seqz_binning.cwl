cwlVersion: v1.2
class: CommandLineTool
id: sequenza_seqz_binning 
doc: "Perform the binning of the seqz file to reduce file size and memory requirement for the analysis." 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/sequenza:3.0.0'
baseCommand: [sequenza-utils, seqz_binning]
arguments:
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  input_seqz:
    type: 'File'
    doc: "A seqz file."
    inputBinding:
      position: 2
      prefix: "--seqz"
  window:
    type: 'int?'
    doc: "Window size used for binning the original seqz file."
    inputBinding:
      position: 2
      prefix: "--window"
  output_filename:
    type: 'string'
    doc: "Name of output file." 
    inputBinding:
      position: 2
      prefix: "-o"

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  seqz:
    type: 'File'
    secondaryFiles: [{ pattern: '.tbi', required: true }]
    outputBinding:
      glob: $(inputs.output_filename)
