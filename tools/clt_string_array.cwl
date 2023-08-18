cwlVersion: v1.2
class: CommandLineTool
id: clt_string_array 
doc: |
  Given a string array, return a string array.
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >
      echo done3
inputs:
  input: { type: 'string[]' }
outputs:
  output:
    type: 'string[]'
    outputBinding:
      outputEval: |
        $(inputs.input)
