class: CommandLineTool
cwlVersion: v1.2
id: cnvnator_scatter_contigs
requirements:
  - class: InlineJavascriptRequirement
baseCommand: [echo]
inputs:
  cnv_contigs:
    type: File
    loadContents: true
outputs:
  scattered_contigs:
    type: string[]
    outputBinding:
      outputEval: |
        ${
          var out = [];
          var lines = inputs.cnv_contigs.contents.trim().split('\n');
          return lines;
        }

