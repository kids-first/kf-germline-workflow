cwlVersion: v1.2
class: CommandLineTool
id: clt_passthrough_filelist
doc: |
  Just return the filelist you're given; logic handled at step input. 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      echo done 
inputs:
  infiles: { type: 'File[]', doc: "File list" }
outputs:
  output:
    type: File[]
    outputBinding:
      outputEval: $(inputs.infiles)
