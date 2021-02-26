cwlVersion: v1.0
class: CommandLineTool
id: gatk_preprocessintervals
doc: "Prepares bins for coverage collection"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R'
baseCommand: ['/bin/bash', '-c']
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      set -eu

      /gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" PreprocessIntervals
      --reference $(inputs.reference.path)
      --sequence-dictionary $(inputs.sequence_dictionary.path)
      --padding $(inputs.padding)
      --bin-length $(inputs.bin_length)
      --interval-merging-rule $(inputs.interval_merging_rule)
      --output $(inputs.intervals_list ? inputs.intervals_list.nameroot : 'wgs').preprocessed.interval_list
      $(inputs.intervals_list ? "-L " + inputs.intervals_list.path : '')
      $(inputs.blacklist_intervals_list ? "-XL " + inputs.blacklist_intervals_list.path : '')
inputs:
  reference: { type: File , secondaryFiles: ['.fai'] , doc: "Reference fasta" }
  sequence_dictionary: { type: 'File?', doc: "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file." }
  intervals_list: { type: 'File?', doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs." }
  blacklist_intervals_list: { type: 'File?', doc: "One or more genomic intervals to exclude from processing. Use this input when providing interval list files or other file based inputs." }
  padding: { type: 'int?', default: 250, doc: "Length (in bp) of the padding regions on each side of the intervals." }
  bin_length: { type: 'int?', default: 1000, doc: "Length (in bp) of the bins. If zero, no binning will be performed." }
  interval_merging_rule:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ALL","OVERLAPPING_ONLY"]
    default: "OVERLAPPING_ONLY"
    doc: "By default, the program merges abutting intervals (i.e. intervals that are directly side-by-side but do not actually overlap) into a single continuous interval. However you can change this behavior if you want them to be treated as separate intervals instead."
  max_memory: { type: int?, default: 8, doc: "GB of RAM to allocate to the task." }
  cores: { type: int?, default: 4, doc: "Minimum reserved number of CPU cores for the task." }

outputs:
  preprocessed_intervals: { type: File, outputBinding: { glob: '*preprocessed.interval_list' } }
