cwlVersion: v1.2
class: CommandLineTool
id: gatk_germlinecnvcaller_case
doc: "Calls copy-number variants in germline samples given their counts and the output of DetermineGermlineContigPloidy. Run in case mode."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory * 1000)
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.2.0.0'
baseCommand: ['/bin/bash','-c']
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      set -eu

      export MKL_NUM_THREADS=$(inputs.cores)

      export OMP_NUM_THREADS=$(inputs.cores)

      mkdir contig-ploidy-calls

      tar xzf $(inputs.contig_ploidy_calls_tar.path) -C contig-ploidy-calls

      mkdir gcnv-model

      tar xzf $(inputs.gcnv_model_tar.path) -C gcnv-model

      gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m"  GermlineCNVCaller
      --run-mode CASE
      ${var arr=[]; for (var x = 0; x < inputs.read_count_files.length; x++) {arr.push(inputs.read_count_files[x].path)}; return (arr.length > 0 ? '--input ' + arr.join(' --input ') : '')}
      --contig-ploidy-calls contig-ploidy-calls
      --model gcnv-model
      --output out
      --output-prefix case
      --verbosity $(inputs.verbosity)
      $(inputs.p_alt == null ? "" : "--p-alt " + inputs.p_alt)
      $(inputs.cnv_coherence_length == null ? "" : "--cnv-coherence-length " + inputs.cnv_coherence_length)
      $(inputs.max_copy_number == null ? "" : "--max-copy-number " + inputs.max_copy_number)
      $(inputs.mapping_error_rate == null ? "" : "--mapping-error-rate " + inputs.mapping_error_rate)
      $(inputs.sample_psi_scale == null ? "" : "--sample-psi-scale " + inputs.sample_psi_scale)
      $(inputs.depth_correction_tau == null ? "" : "--depth-correction-tau " + inputs.depth_correction_tau)
      $(inputs.copy_number_posterior_expectation_mode == null ? "" : "--copy-number-posterior-expectation-mode " + inputs.copy_number_posterior_expectation_mode)
      $(inputs.active_class_padding_hybrid_mode == null ? "" : "--active-class-padding-hybrid-mode " + inputs.active_class_padding_hybrid_mode)
      $(inputs.learning_rate == null ? "" : "--learning-rate " + inputs.learning_rate)
      $(inputs.adamax_beta_1 == null ? "" : "--adamax-beta-1 " + inputs.adamax_beta_1)
      $(inputs.adamax_beta_2 == null ? "" : "--adamax-beta-2 " + inputs.adamax_beta_2)
      $(inputs.log_emission_samples_per_round == null ? "" : "--log-emission-samples-per-round " + inputs.log_emission_samples_per_round)
      $(inputs.log_emission_sampling_median_rel_error == null ? "" : "--log-emission-sampling-median-rel-error " + inputs.log_emission_sampling_median_rel_error)
      $(inputs.log_emission_sampling_rounds == null ? "" : "--log-emission-sampling-rounds " + inputs.log_emission_sampling_rounds)
      $(inputs.max_advi_iter_first_epoch == null ? "" : "--max-advi-iter-first-epoch " + inputs.max_advi_iter_first_epoch)
      $(inputs.max_advi_iter_subsequent_epochs == null ? "" : "--max-advi-iter-subsequent-epochs " + inputs.max_advi_iter_subsequent_epochs)
      $(inputs.min_training_epochs == null ? "" : "--min-training-epochs " + inputs.min_training_epochs)
      $(inputs.max_training_epochs == null ? "" : "--max-training-epochs " + inputs.max_training_epochs)
      $(inputs.initial_temperature == null ? "" : "--initial-temperature " + inputs.initial_temperature)
      $(inputs.num_thermal_advi_iters == null ? "" : "--num-thermal-advi-iters " + inputs.num_thermal_advi_iters)
      $(inputs.convergence_snr_averaging_window == null ? "" : "--convergence-snr-averaging-window " + inputs.convergence_snr_averaging_window)
      $(inputs.convergence_snr_trigger_threshold == null ? "" : "--convergence-snr-trigger-threshold " + inputs.convergence_snr_trigger_threshold)
      $(inputs.convergence_snr_countdown_window == null ? "" : "--convergence-snr-countdown-window " + inputs.convergence_snr_countdown_window)
      $(inputs.max_calling_iters == null ? "" : "--max-calling-iters " + inputs.max_calling_iters)
      $(inputs.caller_update_convergence_threshold == null ? "" : "--caller-update-convergence-threshold " + inputs.caller_update_convergence_threshold)
      $(inputs.caller_internal_admixing_rate == null ? "" : "--caller-internal-admixing-rate " + inputs.caller_internal_admixing_rate)
      $(inputs.caller_external_admixing_rate == null ? "" : "--caller-external-admixing-rate " + inputs.caller_external_admixing_rate)
      $(inputs.disable_annealing == null ? "" : "--disable-annealing " + inputs.disable_annealing)

      tar czf case-gcnv-tracking-shard-$(inputs.scatter_index).tar.gz -C out/case-tracking . || :

      CURRENT_SAMPLE=0

      NUM_SAMPLES=$(inputs.read_count_files.length)

      NUM_DIGITS=${return "${#NUM_SAMPLES}"}

      while [ $CURRENT_SAMPLE -lt $NUM_SAMPLES ]; do
          sleep 10
          CURRENT_SAMPLE_WITH_LEADING_ZEROS=${ return "$(printf \"%0${NUM_DIGITS}d\" $CURRENT_SAMPLE)" }
          tar czf case-gcnv-calls-shard-$(inputs.scatter_index)-sample-$CURRENT_SAMPLE_WITH_LEADING_ZEROS.tar.gz -C out/case-calls/SAMPLE_$CURRENT_SAMPLE . || :
          let CURRENT_SAMPLE=CURRENT_SAMPLE+1
      done

      rm -rf contig-ploidy-calls

      rm -rf gcnv-model
inputs:
  scatter_index: { type: 'int' }
  gcnv_model_tar: { type: 'File', doc: "GZipped TAR file containing gcnv model directory (output of DetermineGermlineContigPloidy)." }
  contig_ploidy_calls_tar: { type: 'File', doc: "GZipped TAR file containing contig-ploidy calls directory (output of DetermineGermlineContigPloidy)." }
  read_count_files: { type: 'File[]', doc: "Input paths for read-count files containing integer read counts in genomic intervals for all samples. All intervals specified via -L/-XL must be contained; if none are specified, then intervals must be identical and in the same order for all samples. If read-count files are given by Google Cloud Storage paths, have the extension .counts.tsv or .counts.tsv.gz, and have been indexed by IndexFeatureFile, only the specified intervals will be queried and streamed; this can reduce disk usage by avoiding the complete localization of all read-count files" }

  p_alt: {type: 'float?', default: 0.0005, doc: "Total prior probability of alternative copy-number states (the reference copy-number is set to the contig integer ploidy)"}
  cnv_coherence_length: {type: 'float?', doc: "Coherence length of CNV events (in the units of bp)."}
  max_copy_number: {type: 'int?', doc: "Highest allowed copy-number state."}
  mapping_error_rate: {type: 'float?', doc: "Typical mapping error rate."}
  sample_psi_scale: {type: 'float?', default: 0.01, doc: "Typical scale of sample-specific correction to the unexplained variance."}
  depth_correction_tau: {type: 'float?', doc: "Precision of read depth pinning to its global value."}
  copy_number_posterior_expectation_mode: {type: 'string?', doc: "The strategy for calculating copy number posterior expectations in the coverage denoising model."}
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
  max_memory: { type: 'int?', default: 10, doc: "GB of RAM to allocate to the task." }
  cores: { type: 'int?', default: 6, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  gcnv_call_tars: { type: 'File[]', outputBinding: { glob: 'case-gcnv-calls-shard-$(inputs.scatter_index)-sample-*.tar.gz' } }
  gcnv_tracking_tar: { type: 'File', outputBinding: { glob: 'case-gcnv-tracking-shard-$(inputs.scatter_index).tar.gz' } }
  calling_config_json: { type: 'File', outputBinding: { glob: 'out/case-calls/calling_config.json' } }
  denoising_config_json: { type: 'File', outputBinding: { glob: 'out/case-calls/denoising_config.json' } }
  gcnvkernel_version_json: { type: 'File', outputBinding: { glob: 'out/case-calls/gcnvkernel_version.json' } }
  sharded_interval_list: { type: 'File', outputBinding: { glob: 'out/case-calls/interval_list.tsv' } }
