class: CommandLineTool
cwlVersion: v1.2
id: cnvnator_scatter_contigs
doc: "Given a file with contig names, one per line. Parse the names and return them as a list."
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

