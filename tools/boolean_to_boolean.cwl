cwlVersion: v1.2
class: CommandLineTool
requirements:
  - class: InlineJavascriptRequirement

baseCommand: [echo, done]

inputs:
  in_bool: boolean

outputs:
  out_bool:
    type: boolean 
    outputBinding:
      outputEval: |
        $(inputs.in_bool)
