cwlVersion: v1.2
class: CommandLineTool
id: awk_parse_interval_list_contigs
doc: |
  Given an interval list, return a list of the uniq contig names.
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >
      awk '$1 !~ /^@/ { print $1 }' $(inputs.input_intervals.path) | uniq > out.txt
inputs:
  input_intervals: { type: 'File' }
outputs:
  contigs:
    type: 'string[]'
    outputBinding:
      glob: "out.txt"
      loadContents: true
      outputEval: |
        ${
          var lines = self[0].contents.trim().split('\n');
          return lines;
        }
