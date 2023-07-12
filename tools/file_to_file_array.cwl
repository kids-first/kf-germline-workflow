cwlVersion: v1.2
class: CommandLineTool
requirements:
  - class: InlineJavascriptRequirement

baseCommand: [echo, done]

inputs:
  in_file: File

outputs:
  out_file_array:
    type: File[]
    outputBinding:
      outputEval: |
        $([inputs.in_file])
