cwlVersion: v1.0
class: CommandLineTool
id: gatk_filterintervals
doc: "Filters intervals based on annotations and/or count statistics"
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
    shellQuote: true
    valueFrom: >-
      set -eu

      /gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" FilterIntervals
      -L $(inputs.intervals_list.path)
      --minimum-gc-content $(inputs.gc_content_min)
      --maximum-gc-content $(inputs.gc_content_max)
      --minimum-mappability $(inputs.mappability_min)
      --maximum-mappability $(inputs.mappability_max)
      --minimum-segmental-duplication-content $(inputs.sd_content_min)
      --maximum-segmental-duplication-content $(inputs.sd_content_max)
      --low-count-filter-count-threshold $(inputs.lc_filter_count)
      --low-count-filter-percentage-of-samples $(inputs.lc_filter_percent)
      --extreme-count-filter-minimum-percentile $(inputs.ec_filter_min)
      --extreme-count-filter-maximum-percentile $(inputs.ec_filter_max)
      --extreme-count-filter-percentage-of-samples $(inputs.ec_filter_percent)
      --interval-merging-rule $(inputs.interval_merging_rule)
      --output $(inputs.intervals_list.nameroot).filtered.interval_list
      ${var arr= []; if (inputs.read_count_files) {for (var x = 0; x < inputs.read_count_files.length; x++) {arr.push(inputs.read_count_files[x].path)}; if (arr.length > 0) {return '--input ' + arr.join(' --input ');} else {return '';}} else { return '';}}
      $(inputs.blacklist_intervals_list ? "-XL " + inputs.blacklist_intervals_list.path : '')
      $(inputs.annotated_intervals ? "--annotated-intervals " + inputs.annotated_intervals.path : '')
inputs:
  intervals_list: { type: 'File', doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs." }
  blacklist_intervals_list: { type: 'File?', doc: "One or more genomic intervals to exclude from processing. Use this input when providing interval list files or other file based inputs." }
  read_count_files: { type: 'File[]?', doc: "Input TSV or HDF5 files containing integer read counts in genomic intervals (output of CollectReadCounts). Must be provided if no annotated-intervals file is provided." }
  annotated_intervals: { type: 'File?', doc: "Input file containing annotations for genomic intervals (output of AnnotateIntervals). Must be provided if no counts files are provided." }
  ec_filter_max: { type: 'float?', default: 99.0, doc: "Maximum-percentile parameter for the extreme-count filter. Intervals with a count that has a percentile strictly greater than this in a percentage of samples strictly greater than extreme-count-filter-percentage-of-samples will be filtered out. (This is the second count-based filter applied.)" }
  ec_filter_min: { type: 'float?', default: 1.0, doc: "Minimum-percentile parameter for the extreme-count filter. Intervals with a count that has a percentile strictly less than this in a percentage of samples strictly greater than extreme-count-filter-percentage-of-samples will be filtered out. (This is the second count-based filter applied.)" }
  ec_filter_percent: { type: 'float?', default: 90.0, doc: "Percentage-of-samples parameter for the extreme-count filter. Intervals with a count that has a percentile outside of [extreme-count-filter-minimum-percentile, extreme-count-filter-maximum-percentile] in a percentage of samples strictly greater than this will be filtered out. (This is the second count-based filter applied.)" }
  gc_content_max: { type: 'float?', default: 0.9, doc: "Maximum allowed value for GC-content annotation (inclusive)." }
  gc_content_min: { type: 'float?', default: 0.1, doc: "Minimum allowed value for GC-content annotation (inclusive)." }
  lc_filter_count: { type: 'int?', default: 5, doc: "Count-threshold parameter for the low-count filter. Intervals with a count strictly less than this threshold in a percentage of samples strictly greater than low-count-filter-percentage-of-samples will be filtered out. (This is the first count-based filter applied.)" }
  lc_filter_percent: { type: 'float?', default: 90.0, doc: "Percentage-of-samples parameter for the low-count filter. Intervals with a count strictly less than low-count-filter-count-threshold in a percentage of samples strictly greater than this will be filtered out. (This is the first count-based filter applied.)" }
  mappability_max: { type: 'float?', default: 1.0, doc: "Maximum allowed value for mappability annotation (inclusive)." }
  mappability_min: { type: 'float?', default: 0.9, doc: "Minimum allowed value for mappability annotation (inclusive)." }
  sd_content_max: { type: 'float?', default: 0.5, doc: "Maximum allowed value for segmental-duplication-content annotation (inclusive)." }
  sd_content_min: { type: 'float?', default: 0.0, doc: "Minimum allowed value for segmental-duplication-content annotation (inclusive)." }
  interval_merging_rule:
    type:
      - 'null'
      - type: 'enum'
        name: interval_merging_rule
        symbols: ["ALL","OVERLAPPING_ONLY"]
    doc: "By default, the program merges abutting intervals (i.e. intervals that are directly side-by-side but do not actually overlap) into a single continuous interval. However you can change this behavior if you want them to be treated as separate intervals instead."
    default: "OVERLAPPING_ONLY"
  max_memory: { type: 'int?', default: 8, doc: "GB of RAM to allocate to the task. default: 8" }
  cores: { type: 'int?', default: 4, doc: "Minimum reserved number of CPU cores for the task. default: 4" }
outputs:
  filtered_intervals: { type: 'File', outputBinding: { glob: '*filtered.interval_list' } }
