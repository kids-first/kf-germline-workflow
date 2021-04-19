cwlVersion: v1.0
class: ExpressionTool
id: expression_flatten_list
requirements:
  - class: InlineJavascriptRequirement

inputs:
  input_list: Any[]

outputs:
  output: Any[] 

expression: |
  ${  
    var flatten = function flatten(ary) {
        var ret = [];
        for(var i = 0; i < ary.length; i++) {
            if(Array.isArray(ary[i])) {
                ret = ret.concat(flatten(ary[i]));
            } else {
                ret.push(ary[i]);
            }
        }
        return ret;
    }
    var flatin = flatten(inputs.input_list)
    return {output: flatin}
  }