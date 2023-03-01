cwlVersion: v1.2
class: CommandLineTool
id: gatk_collectreadcounts
doc: "Collects read counts at specified intervals. The count for each interval is calculated by counting the number of read starts that lie in the interval."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000)
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R'
baseCommand: ['/bin/bash','-c']
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      set -eu

      /gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" CollectReadCounts
      -L $(inputs.intervals_list.path)
      --input $(inputs.reads.path)
      --reference $(inputs.reference.path)
      --sequence-dictionary $(inputs.sequence_dictionary.path)
      --format $(inputs.output_format.replace('_GZ',''))
      --interval-merging-rule $(inputs.interval_merging_rule)
      --output $(inputs.reads.nameroot).${ return inputs.output_format.replace('_GZ','').toLowerCase()}
      $(inputs.disabled_read_filters ? "--diable-read-filter " + inputs.disabled_read_filters.join(' ') : '')

      ${ if (inputs.output_format == 'TSV_GZ') { return 'bgzip ' + inputs.reads.nameroot + '.' + inputs.output_format.replace('_GZ','').toLowerCase() } else if (inputs.output_format == 'TSV') { return '/gatk --javaOptions "-Xmx' + Math.floor(inputs.max_memory*1000/1.074-1) + 'm" IndexFeatureFile -I ' + inputs.reads.nameroot + '.' + inputs.output_format.replace('_GZ','').toLowerCase() } else { return '' } }

inputs:
  reference: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }], doc: "Reference fasta" }
  sequence_dictionary: { type: 'File', doc: "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file." }
  reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false }, { pattern: "^.bai", required: false }, { pattern: ".crai", required: false }, { pattern: "^.crai", required: false }], doc: "BAM/CRAM File containing reads" }
  intervals_list: { type: 'File', doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs." }
  interval_merging_rule:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ALL","OVERLAPPING_ONLY"]
    default: "OVERLAPPING_ONLY"
    doc: "By default, the program merges abutting intervals (i.e. intervals that are directly side-by-side but do not actually overlap) into a single continuous interval. However you can change this behavior if you want them to be treated as separate intervals instead."
  disabled_read_filters: { type: 'string[]?', doc: "Read filters to be disabled before analysis" }
  output_format:
    type:
      - 'null'
      - type: enum
        name: output_format
        symbols: ["HDF5","TSV","TSV_GZ"]
    doc: "Output file format."
    default: "HDF5"
  max_memory: { type: 'int?', default: 2, doc: "GB of RAM to allocate to the task." }
  cores: { type: 'int?', default: 1, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  entity_id: { type: 'string', outputBinding: { outputEval: '$(inputs.reads.nameroot)' } }
  counts: { type: 'File', outputBinding: { glob: "*.hdf5" } }
