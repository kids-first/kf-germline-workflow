cwlVersion: v1.2
class: ExpressionTool
id: expression_file_array_create_index_array
doc: "Take a file array and create an int array of the index positions. For example, an input of ['a','b','c'] will return an array of [0,1,2]. Useful for tracking scatters. From: https://stackoverflow.com/a/28599347"
requirements:
  - class: InlineJavascriptRequirement

inputs:
  array: {type: 'File[]'}

outputs:
  index_array: {type: 'int[]'}

expression: |
  ${
    function create_index_array(a) {
      return Array.apply(null, Array(a.length)).map(function (x, i) { return i; });
    }
    return {"index_array": create_index_array(inputs.array) }
  }
