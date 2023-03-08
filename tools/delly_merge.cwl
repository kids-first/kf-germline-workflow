cwlVersion: v1.2
class: CommandLineTool
id: delly_merge 
doc: "Delly Merge tool"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dellytools/delly:latest'

baseCommand: [delly, merge]
inputs:
  # Required Arguments
  input_bcfs: { type: 'File[]', inputBinding: { position: 9 }, doc: "Input bcf files" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--outfile"}, doc: "Merged SV BCF output file" }

  # Generic Arguments
  quality: { type: 'int?', inputBinding: { position: 2, prefix: "--quality"}, doc: "min. SV site quality" }
  chunks: { type: 'int?', inputBinding: { position: 2, prefix: "--chunks"}, doc: "max. chunk size to merge groups of BCF files" }
  vaf: { type: 'float?', inputBinding: { position: 2, prefix: "--vaf"}, doc: "min. fractional ALT support" }
  coverage: { type: 'int?', inputBinding: { position: 2, prefix: "--coverage"}, doc: "min. coverage" }
  minsize: { type: 'int?', inputBinding: { position: 2, prefix: "--minsize"}, doc: "min. SV size" }
  maxsize: { type: 'int?', inputBinding: { position: 2, prefix: "--maxsize"}, doc: "max. SV size" }
  cnvmode: { type: 'boolean?', inputBinding: { position: 2, prefix: "--cnvmode"}, doc: "Merge delly CNV files" }
  precise: { type: 'boolean?', inputBinding: { position: 2, prefix: "--precise"}, doc: "Filter sites for PRECISE" }
  pass: { type: 'boolean?', inputBinding: { position: 2, prefix: "--pass"}, doc: "Filter sites for PASS" }
  
  # Overlap Arguments
  bp_offset: { type: 'int?', inputBinding: { position: 2, prefix: "--bp-offset"}, doc: "max. breakpoint offset" }
  rec_overlap: { type: 'float?', inputBinding: { position: 2, prefix: "--rec-overlap"}, doc: "min. reciprocal overlap" }

  # Resource Control
  cpu: {type: 'int?', default: 16, doc: "CPUs to allocate to this tool"}
  ram: {type: 'int?', default: 32, doc: "GB of RAM to allocate to this tool"}
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_filename) 
