cwlVersion: v1.0
class: CommandLineTool
id: gatk_annotateintervals
doc: >-
  Annotates intervals with GC content, and optionally, mappability and segmental-duplication content.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.1.7.0R'
baseCommand: ['/bin/bash', '-c']
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eu

      $(inputs.do_explicit_gc_correction ? '/gatk' : 'echo /gatk') --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" AnnotateIntervals \\
          -L $(inputs.intervals_list.path) \\
          --reference $(inputs.reference.path) \\
          --sequence-dictionary $(inputs.sequence_dictionary.path) \\
          --feature-query-lookahead $(inputs.feature_query_lookahead) \\
          --interval-merging-rule $(inputs.interval_merging_rule) \\
          --output $(inputs.intervals_list.nameroot).annotated.tsv \\
          $(inputs.mappability_track ? "--mappability-track " + inputs.mappability_track.path : "") \\
          $(inputs.segmental_duplication_track ? "--segmental-duplication-track " + inputs.segmental_duplication_track.path : "")
inputs:
  do_explicit_gc_correction: { type: 'boolean?', default: true, doc: "Trigger to turn off this tool and echo the command" } 
  reference: { type: 'File', secondaryFiles: ['.fai'], doc: "Reference fasta" }
  sequence_dictionary: { type: 'File', doc: "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file." }
  intervals_list: { type: 'File', doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs." }
  interval_merging_rule:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ALL","OVERLAPPING_ONLY"]
    default: "OVERLAPPING_ONLY"
    doc: "By default, the program merges abutting intervals (i.e. intervals that are directly side-by-side but do not actually overlap) into a single continuous interval. However you can change this behavior if you want them to be treated as separate intervals instead."
  mappability_track: { type: 'File?', secondaryFiles: ['.tbi'], doc: "Path to Umap single-read mappability track in .bed or .bed.gz format (see https://bismap.hoffmanlab.org/). Overlapping intervals must be merged." }
  segmental_duplication_track: { type: 'File?', secondaryFiles: ['.tbi'], doc: "Path to segmental-duplication track in .bed or .bed.gz format. Overlapping intervals must be merged."}
  feature_query_lookahead: { type: 'int?', default: 1000000 , doc: "Number of bases to cache when querying feature tracks" }
  max_memory: { type: 'int?', default: 2, doc: "GB of RAM to allocate to the task." }
  cores: { type: 'int?', default: 1, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  annotated_intervals: { type: 'File?', outputBinding: { glob: '*.annotated.tsv' } }
