cwlVersion: v1.2
class: ExpressionTool
id: expression_transpose_two_dimension_file_array
doc: "Take two dimensional file array and transpose it. From: https://gist.github.com/femto113/1784503#gistcomment-2163931"
requirements:
  - class: InlineJavascriptRequirement

inputs:
  array:
    type:
      type: array
      items:
        type: array
        items: File

outputs:
  transposed_array:
    type:
      type: array
      items:
        type: array
        items: File

expression: |
  ${
    function transpose(a) {
      return a && a.length && a[0].map && a[0].map(function (_, c) { return a.map(function (r) { return r[c]; }); }) || [];
    }
    return {"transposed_array": transpose(inputs.array)}
  }
