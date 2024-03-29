cwlVersion: v1.2
class: CommandLineTool
id: gatk_determinegermlinecontigploidy_cohort
doc: "Determines the baseline contig ploidy for germline samples given counts data. Cohort mode."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000)
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.2.0.0'
baseCommand: ['/bin/bash', '-c']
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eu

      export MKL_NUM_THREADS=$(inputs.cores)

      export OMP_NUM_THREADS=$(inputs.cores)

      gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m"  DetermineGermlineContigPloidy
      --input ${var arr=[]; for (var x = 0; x < inputs.read_count_files.length; x++) {arr.push(inputs.read_count_files[x].path)}; return arr.join(' --input ')}
      --contig-ploidy-priors $(inputs.contig_ploidy_priors.path)
      --interval-merging-rule $(inputs.interval_merging_rule)
      --output out
      --output-prefix $(inputs.output_basename)
      --verbosity $(inputs.verbosity)
      --mapping-error-rate $(inputs.mapping_error)
      --mean-bias-standard-deviation $(inputs.mean_bias_sd)
      --global-psi-scale $(inputs.psi_scale_global)
      --sample-psi-scale $(inputs.psi_scale_sample)
      $(inputs.interals_list ? "-L " + inputs.intervals_list.path : '')

      tar czf $(inputs.output_basename)-contig-ploidy-model.tar.gz -C out/$(inputs.output_basename)-model .

      tar czf $(inputs.output_basename)-contig-ploidy-calls.tar.gz -C out/$(inputs.output_basename)-calls .
inputs:
  output_basename: { type: 'string', doc: "String value to use as the basename for the outputs" }
  intervals_list: { type: 'File?', doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs." }
  read_count_files: { type: 'File[]', doc: "Input paths for read-count files containing integer read counts in genomic intervals for all samples. All intervals specified via -L/-XL must be contained; if none are specified, then intervals must be identical and in the same order for all samples. If read-count files are given by Google Cloud Storage paths, have the extension .counts.tsv or .counts.tsv.gz, and have been indexed by IndexFeatureFile, only the specified intervals will be queried and streamed; this can reduce disk usage by avoiding the complete localization of all read-count files" }
  contig_ploidy_priors: { type: 'File', doc: "Input file specifying contig-ploidy priors. If only a single sample is specified, this input should not be provided. If multiple samples are specified, this input is required" }
  mapping_error: { type: 'float?', default: 0.3, doc: "Typical mapping error rate." }
  mean_bias_sd: { type: 'float?', default: 1, doc: "Prior standard deviation of the contig-level mean coverage bias. If a single sample is provided, this input will be ignored." }
  psi_scale_global: { type: 'float?', default: 0.001, doc: "Prior scale of contig coverage unexplained variance. If a single sample is provided, this input will be ignored." }
  psi_scale_sample: { type: 'float?', default: 0.0001, doc: "Prior scale of the sample-specific correction to the coverage unexplained variance." }
  verbosity:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ERROR","WARNING","INFO","DEBUG"]
    doc: "Control verbosity of logging."
    default: "DEBUG"
  interval_merging_rule:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ALL","OVERLAPPING_ONLY"]
    doc: "By default, the program merges abutting intervals (i.e. intervals that are directly side-by-side but do not actually overlap) into a single continuous interval. However you can change this behavior if you want them to be treated as separate intervals instead."
    default: "OVERLAPPING_ONLY"
  max_memory: { type: 'int?', default: 8, doc: "GB of RAM to allocate to the task." }
  cores: { type: 'int?', default: 8, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  contig_ploidy_model_tar: { type: 'File', outputBinding: { glob: '*model.tar.gz' } }
  contig_ploidy_calls_tar: { type: 'File', outputBinding: { glob: '*calls.tar.gz' } }
