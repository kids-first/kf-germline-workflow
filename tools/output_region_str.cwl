cwlVersion: v1.2
class: CommandLineTool
id: output-region-str
doc: "A silly tool to capture file output as str"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement

baseCommand: []
stdout: region
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      cat

inputs:
    intervals_file: { type: File, doc: "Intervals file to cat",
      inputBinding: { position: 0 } }

outputs:
  output:
    type: Any
    outputBinding:
      glob: region
      loadContents: true
      outputEval: $( self[0].contents.replace('\n', '') )
