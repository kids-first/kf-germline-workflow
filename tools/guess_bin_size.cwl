cwlVersion: v1.2
class: ExpressionTool
id: expression_guess_bin_size
doc: "Guess bin size"
requirements:
  - class: InlineJavascriptRequirement

inputs:
  roots: {type: 'File[]'}
  stats: {type: 'File[]', loadContents: true}
  bin_sizes: {type: 'int[]'}
  target_score: { type: 'int?', default: 5 }

outputs:
  root: {type: 'File'}
  stat: {type: 'File'}
  bin_size: { type: 'int' }

expression: |
  ${
    var l = [];
    for (var i in inputs.roots) {
      var statline = inputs.stats[i].contents.trim().split('\n')[1].split(' ');
      var dict = {root: inputs.roots[i], bin_size: inputs.bin_sizes[i], stat: inputs.stats[i], average: statline.slice(-1)[0], stddev: statline.slice(-4)[0]};
      l.push(dict);
    };
    var low = l.reduce(function(init, curr) { return Math.abs((init.average / init.stddev) - inputs.target_score) < Math.abs((curr.average / curr.stddev) - inputs.target_score) ? init : curr } );
    return {root: low.root, stat: low.stat, bin_size: low.bin_size};
  }
