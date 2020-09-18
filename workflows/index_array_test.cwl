cwlVersion: v1.0
class: Workflow
id: index_array_test
doc: "hello"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement

inputs: 
  string_array: string[] 
outputs: []
steps:
  create_scatter_index:
    run: ../tools/expression_create_scatter_index.cwl
    in:
      array: string_array
    out: [scatter_index_array]
  scatter_echo: 
    run: ../tools/echo.cwl
    scatter: message_index
    in:
      message_index: create_scatter_index/scatter_index_array 
      message_array: string_array
    out: []

