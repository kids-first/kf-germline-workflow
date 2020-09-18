cwlVersion: v1.0
class: CommandLineTool
baseCommand: echo
arguments:
  - position: 0
    valueFrom: >-
      ${ return inputs.message_array[inputs.message_index] }
inputs:
  message_array:
    type: string[]
  message_index:
    type: int
outputs: []
