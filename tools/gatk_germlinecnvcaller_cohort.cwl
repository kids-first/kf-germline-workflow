cwlVersion: v1.0
class: CommandLineTool
id: gatk_germlinecnvcaller_cohort
doc: "Calls copy-number variants in germline samples given their counts and the output of DetermineGermlineContigPloidy. Run in cohort mode."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.1.7.0R'
baseCommand: ['/bin/bash/','-c']
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eu
      export MKL_NUM_THREADS=$(inputs.cores)
      export OMP_NUM_THREADS=$(inputs.cores)

      mkdir contig-ploidy-calls
      tar xzf $(inputs.contig_ploidy_calls_tar.path) -C contig-ploidy-calls

      /gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m"  GermlineCNVCaller \\
          --run-mode COHORT \\
          -L $(inputs.intervals_list.path) \\
          ${var arr=[]; for (var x = 0; x < inputs.read_count_files.length; x++) {arr.push(inputs.read_count_files[x].path)}; return "--input " + arr.join(' --input ')} \\
          --contig-ploidy-calls contig-ploidy-calls \\
          $(inputs.annotated_intervals ? "--annotated-intervals " + inputs.annotated_intervals.path : "") \\
          --interval-merging-rule $(inputs.interval_merging_rule) \\
          --output out \\
          --verbosity $(inputs.verbosity) \\
          $(inputs.p_alt == "null" ? "" : "--p-alt " + inputs.p_alt) \\
          $(inputs.p_active == "null" ? "" : "--p-active " + inputs.p_active) \\
          $(inputs.cnv_coherence_length == "null" ? "" : "--cnv-coherence-length " + inputs.cnv_coherence_length) \\
          $(inputs.class_coherence_length == "null" ? "" : "--class-coherence-length " + inputs.class_coherence_length) \\
          $(inputs.max_copy_number == "null" ? "" : "--max-copy-number " + inputs.max_copy_number) \\
          $(inputs.max_bias_factors == "null" ? "" : "--max-bias-factors " + inputs.max_bias_factors) \\
          $(inputs.mapping_error_rate == "null" ? "" : "--mapping-error-rate " + inputs.mapping_error_rate) \\
          $(inputs.interval_psi_scale == "null" ? "" : "--interval-psi-scale " + inputs.interval_psi_scale) \\
          $(inputs.sample_psi_scale == "null" ? "" : "--sample-psi-scale " + inputs.sample_psi_scale) \\
          $(inputs.depth_correction_tau == "null" ? "" : "--depth-correction-tau " + inputs.depth_correction_tau) \\
          $(inputs.log_mean_bias_standard_deviation == "null" ? "" : "--log-mean-bias-standard-deviation " + inputs.log_mean_bias_standard_deviation) \\
          $(inputs.init_ard_rel_unexplained_variance == "null" ? "" : "--init-ard-rel-unexplained-variance " + inputs.init_ard_rel_unexplained_variance) \\
          $(inputs.num_gc_bins == "null" ? "" : "--num-gc-bins " + inputs.num_gc_bins) \\
          $(inputs.gc_curve_standard_deviation == "null" ? "" : "--gc-curve-standard-deviation " + inputs.gc_curve_standard_deviation) \\
          $(inputs.copy_number_posterior_expectation_mode == "null" ? "" : "--copy-number-posterior-expectation-mode " + inputs.copy_number_posterior_expectation_mode) \\
          $(inputs.enable_bias_factors == "null" ? "" : "--enable-bias-factors " + inputs.enable_bias_factors) \\
          $(inputs.active_class_padding_hybrid_mode == "null" ? "" : "--active-class-padding-hybrid-mode " + inputs.active_class_padding_hybrid_mode) \\
          $(inputs.learning_rate == "null" ? "" : "--learning-rate " + inputs.learning_rate) \\
          $(inputs.adamax_beta_1 == "null" ? "" : "--adamax-beta-1 " + inputs.adamax_beta_1) \\
          $(inputs.adamax_beta_2 == "null" ? "" : "--adamax-beta-2 " + inputs.adamax_beta_2) \\
          $(inputs.log_emission_samples_per_round == "null" ? "" : "--log-emission-samples-per-round " + inputs.log_emission_samples_per_round) \\
          $(inputs.log_emission_sampling_median_rel_error == "null" ? "" : "--log-emission-sampling-median-rel-error " + inputs.log_emission_sampling_median_rel_error) \\
          $(inputs.log_emission_sampling_rounds == "null" ? "" : "--log-emission-sampling-rounds " + inputs.log_emission_sampling_rounds) \\
          $(inputs.max_advi_iter_first_epoch == "null" ? "" : "--max-advi-iter-first-epoch " + inputs.max_advi_iter_first_epoch) \\
          $(inputs.max_advi_iter_subsequent_epochs == "null" ? "" : "--max-advi-iter-subsequent-epochs " + inputs.max_advi_iter_subsequent_epochs) \\
          $(inputs.min_training_epochs == "null" ? "" : "--min-training-epochs " + inputs.min_training_epochs) \\
          $(inputs.max_training_epochs == "null" ? "" : "--max-training-epochs " + inputs.max_training_epochs) \\
          $(inputs.initial_temperature == "null" ? "" : "--initial-temperature " + inputs.initial_temperature) \\
          $(inputs.num_thermal_advi_iters == "null" ? "" : "--num-thermal-advi-iters " + inputs.num_thermal_advi_iters) \\
          $(inputs.convergence_snr_averaging_window == "null" ? "" : "--convergence-snr-averaging-window " + inputs.convergence_snr_averaging_window) \\
          $(inputs.convergence_snr_trigger_threshold == "null" ? "" : "--convergence-snr-trigger-threshold " + inputs.convergence_snr_trigger_threshold) \\
          $(inputs.convergence_snr_countdown_window == "null" ? "" : "--convergence-snr-countdown-window " + inputs.convergence_snr_countdown_window) \\
          $(inputs.max_calling_iters == "null" ? "" : "--max-calling-iters " + inputs.max_calling_iters) \\
          $(inputs.caller_update_convergence_threshold == "null" ? "" : "--caller-update-convergence-threshold " + inputs.caller_update_convergence_threshold) \\
          $(inputs.caller_internal_admixing_rate == "null" ? "" : "--caller-internal-admixing-rate " + inputs.caller_internal_admixing_rate) \\
          $(inputs.caller_external_admixing_rate == "null" ? "" : "--caller-external-admixing-rate " + inputs.caller_external_admixing_rate) \\
          $(inputs.disable_annealing == "null" ? "" : "--disable-annealing " + inputs.disable_annealing)

      tar czf $(inputs.cohort_entity_id)-gcnv-model-shard-$(inputs.scatter_index).tar.gz -C out/$(inputs.cohort_entity_id)-model .
      tar czf $(inputs.cohort_entity_id)-gcnv-tracking-shard-$(inputs.scatter_index).tar.gz -C out/$(inputs.cohort_entity_id)-tracking .

      CURRENT_SAMPLE=0
      NUM_SAMPLES=$(inputs.read_count_files.length)
      NUM_DIGITS=${return "${#NUM_SAMPLES}"}
      while [ $CURRENT_SAMPLE -lt $NUM_SAMPLES ]; do
          CURRENT_SAMPLE_WITH_LEADING_ZEROS=${ return "$(printf \"%0${NUM_DIGITS}d\" $CURRENT_SAMPLE)" }
          tar czf $(inputs.cohort_entity_id)-gcnv-calls-shard-$(inputs.scatter_index)-sample-$CURRENT_SAMPLE_WITH_LEADING_ZEROS.tar.gz -C out/$(inputs.cohort_entity_id)-calls/SAMPLE_$CURRENT_SAMPLE .
          let CURRENT_SAMPLE=CURRENT_SAMPLE+1
      done

      rm -rf contig-ploidy-calls
inputs:
  cohort_entity_id: { type: string , doc: "String value representing the cohort entity id" }
  scatter_index: { type: int }
  intervals_list: { type: 'File', doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs." }
  contig_ploidy_calls_tar: { type: 'File', doc: "GZipped TAR file containing contig-ploidy calls directory (output of DetermineGermlineContigPloidy)." }
  read_count_files: { type: 'File[]', doc: "Input paths for read-count files containing integer read counts in genomic intervals for all samples. All intervals specified via -L/-XL must be contained; if none are specified, then intervals must be identical and in the same order for all samples. If read-count files are given by Google Cloud Storage paths, have the extension .counts.tsv or .counts.tsv.gz, and have been indexed by IndexFeatureFile, only the specified intervals will be queried and streamed; this can reduce disk usage by avoiding the complete localization of all read-count files" }
  annotated_intervals: { type: 'File?', doc: "Input annotated-intervals file containing annotations for GC content in genomic intervals (output of AnnotateIntervals). All intervals specified via -L must be contained. This input should not be provided if an input denoising-model directory is given (the latter already contains the annotated-interval file)." }

  p_alt: {type: 'float?', doc: "Total prior probability of alternative copy-number states (the reference copy-number is set to the contig integer ploidy)"}
  p_active: {type: 'float?', doc: "Prior probability of treating an interval as CNV-active (in a CNV-active domains, all copy-number states are equally likely to be called)."}
  cnv_coherence_length: {type: 'float?', doc: "Coherence length of CNV events (in the units of bp)."}
  class_coherence_length: {type: 'float?', doc: "Coherence length of CNV-active and CNV-silent domains (in the units of bp)."}
  max_copy_number: {type: 'int?', doc: "Highest allowed copy-number state."}
  max_bias_factors: {type: 'int?', doc: "Maximum number of bias factors."}
  mapping_error_rate: {type: 'float?', doc: "Typical mapping error rate."}
  interval_psi_scale: {type: 'float?', doc: "Typical scale of interval-specific unexplained variance."}
  sample_psi_scale: {type: 'float?', doc: "Typical scale of sample-specific correction to the unexplained variance."}
  depth_correction_tau: {type: 'float?', doc: "Precision of read depth pinning to its global value."}
  log_mean_bias_standard_deviation: {type: 'float?', doc: "Standard deviation of log mean bias."}
  init_ard_rel_unexplained_variance: {type: 'float?', doc: "Initial value of ARD prior precisions relative to the scale of interval-specific unexplained variance."}
  num_gc_bins: {type: 'int?', doc: "Number of bins used to represent the GC-bias curves."}
  gc_curve_standard_deviation: {type: 'float?', doc: "Prior standard deviation of the GC curve from flat."}
  copy_number_posterior_expectation_mode: {type: 'string?', doc: "The strategy for calculating copy number posterior expectations in the coverage denoising model."}
  enable_bias_factors: {type: 'boolean?', doc: "Enable discovery of bias factors."}
  active_class_padding_hybrid_mode: {type: 'int?', doc: "If copy-number-posterior-expectation-mode is set to HYBRID, CNV-active intervals determined at any time will be padded by this value (in the units of bp) in order to obtain the set of intervals on which copy number posterior expectation is performed exactly."}
  learning_rate: {type: 'float?', doc: "Adamax optimizer learning rate."}
  adamax_beta_1: {type: 'float?', doc: "Adamax optimizer first moment estimation forgetting factor."}
  adamax_beta_2: {type: 'float?', doc: "Adamax optimizer second moment estimation forgetting factor."}
  log_emission_samples_per_round: {type: 'int?', doc: "Log emission samples drawn per round of sampling."}
  log_emission_sampling_median_rel_error: {type: 'float?', doc: "Maximum tolerated median relative error in log emission sampling."}
  log_emission_sampling_rounds: {type: 'int?', doc: "Log emission maximum sampling rounds."}
  max_advi_iter_first_epoch: {type: 'int?', doc: "Maximum ADVI iterations in the first epoch."}
  max_advi_iter_subsequent_epochs: {type: 'int?', doc: "Maximum ADVI iterations in subsequent epochs."}
  min_training_epochs: {type: 'int?', doc: "Minimum number of training epochs."}
  max_training_epochs: {type: 'int?', doc: "Maximum number of training epochs."}
  initial_temperature: {type: 'float?', doc: "Initial temperature (for DA-ADVI)."}
  num_thermal_advi_iters: {type: 'int?', doc: "Number of thermal ADVI iterations (for DA-ADVI)."}
  convergence_snr_averaging_window: {type: 'int?', doc: "Averaging window for calculating training signal-to-noise ratio (SNR) for convergence checking."}
  convergence_snr_trigger_threshold: {type: 'float?', doc: "The number of ADVI iterations during which the SNR is required to stay below the set threshold for convergence."}
  convergence_snr_countdown_window: {type: 'int?', doc: "The SNR threshold to be reached before triggering the convergence countdown."}
  max_calling_iters: {type: 'int?', doc: "Maximum number of internal self-consistency iterations within each calling step."}
  caller_update_convergence_threshold: {type: 'float?', doc: "Maximum tolerated calling update size for convergence."}
  caller_internal_admixing_rate: {type: 'float?', doc: "Admixing ratio of new and old called posteriors (between 0 and 1; larger values implies using more of the new posterior and less of the old posterior) for internal convergence loops."}
  caller_external_admixing_rate: {type: 'float?', doc: "Admixing ratio of new and old called posteriors (between 0 and 1; larger values implies using more of the new posterior and less of the old posterior) after convergence."}
  disable_annealing: {type: 'boolean?', doc: "(advanced) Disable annealing."}

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
  max_memory: { type: int?, default: 8, doc: "GB of RAM to allocate to the task." }
  cores: { type: int?, default: 8, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  gcnv_model_tar: { type: 'File', outputBinding: { glob: '$(inputs.cohorot_entity_id)-gcnv-model-shard-$(inputs.scatter_index).tar.gz' } }
  gcnv_call_tars: { type: 'File[]', outputBinding: { glob: '$(inputs.cohorot_entity_id)-gcnv-calls-shard-$(inputs.scatter_index)-sample-*.tar.gz' } }
  gcnv_tracking_tar: { type: 'File', outputBinding: { glob: '$(inputs.cohorot_entity_id)-gcnv-tracking-shard-$(inputs.scatter_index).tar.gz' } }
  calling_config_json: { type: 'File', outputBinding: { glob: 'out/$(inputs.cohorot_entity_id)-calls/calling_config.json' } }
  denoising_config_json: { type: 'File', outputBinding: { glob: 'out/$(inputs.cohorot_entity_id)-calls/denoising_config.json' } }
  gcnvkernel_version_json: { type: 'File', outputBinding: { glob: 'out/$(inputs.cohorot_entity_id)-calls/gcnvkernel_version.json' } }
  sharded_interval_list: { type: 'File', outputBinding: { glob: 'out/$(inputs.cohorot_entity_id)-calls/interval_list.tsv' } }
