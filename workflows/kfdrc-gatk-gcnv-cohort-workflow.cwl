cwlVersion: v1.0
class: Workflow
id: kfdrc-gatk-cnv-germline-cohort-workflow
label: Kids First DRC GATK Germline CNV Cohort Workflow
doc: "hello"

requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement

inputs:
  # Multistep
  reference_tar: File
  intervals: File
  blacklist_intervals: File?
  normal_bams: { type: 'File[]', secondaryFiles: [.bai] }
  cohort_entity_id: string
  contig_ploidy_priors: File
  num_intervals_per_scatter: int

  # Preprocess intervals
  padding: int?
  bin_length: int?

  # Annotate intervals
  do_explicit_gc_correction: boolean?
  mappability_track_bed: File?
  mappability_track_bed_idx: File?
  segmental_duplication_track_bed: File?
  segmental_duplication_track_bed_idx: File?
  feature_query_lookahead: int?

  # Collect read counts
  disabled_read_filters_for_collect_counts: string[]?

  # Filter intervals
  blacklist_intervals_for_filter_intervals: File?
  extreme_count_filter_maximum_percentile: float?
  extreme_count_filter_minimum_percentile: float?
  extreme_count_filter_percentage_of_samples: float?
  maximum_gc_content: float?
  minimum_gc_content: float?
  low_count_filter_count_threshold: int?
  low_count_filter_percentage_of_samples: float?
  maximum_mappability: float?
  minimum_mappability: float?
  maximum_segmental_duplication_content: float?
  minimum_segmental_duplication_content: float?

  # Determine Germline Contig Ploidy
  ploidy_mapping_error_rate: float?
  ploidy_mean_bias_standard_deviation: float?
  ploidy_global_psi_scale: float?
  ploidy_sample_psi_scale: float?

  # Germline CNV Caller
  gcvn_p_alt: float?
  gcnv_p_active: float?
  gcnv_cnv_coherence_length: float?
  gcnv_class_coherence_length: float?
  gcnv_max_copy_number: int?
  gcnv_max_bias_factors: int?
  gcnv_mapping_error_rate: float?
  gcnv_interval_psi_scale: float?
  gcnv_sample_psi_scale: float?
  gcnv_depth_correction_tau: float?
  gcnv_log_mean_bias_standard_deviation: float?
  gcnv_init_ard_rel_unexplained_variance: float?
  gcnv_num_gc_bins: int?
  gcnv_gc_curve_standard_deviation: float?
  gcnv_copy_number_posterior_expectation_mode: string?
  gcnv_enable_bias_factors: boolean?
  gcnv_active_class_padding_hybrid_mode: int?
  gcnv_learning_rate: float?
  gcnv_adamax_beta_1: float?
  gcnv_adamax_beta_2: float?
  gcnv_log_emission_samples_per_round: int?
  gcnv_log_emission_sampling_median_rel_error: float?
  gcnv_log_emission_sampling_rounds: int?
  gcnv_max_advi_iter_first_epoch: int?
  gcnv_max_advi_iter_subsequent_epochs: int?
  gcnv_min_training_epochs: int?
  gcnv_max_training_epochs: int?
  gcnv_initial_temperature: float?
  gcnv_num_thermal_advi_iters: int?
  gcnv_convergence_snr_averaging_window: int?
  gcnv_convergence_snr_trigger_threshold: float?
  gcnv_convergence_snr_countdown_window: int?
  gcnv_max_calling_iters: int?
  gcnv_caller_update_convergence_threshold: float?
  gcnv_caller_internal_admixing_rate: float?
  gcnv_caller_external_admixing_rate: float?
  gcnv_disable_annealing: boolean?

  # PostprocessGermlineCNVCalls
  ref_copy_number_autosomal_contigs: int
  allosomal_contigs_args: string[]?

  # arguments for QC
  maximum_number_events_per_sample: int

  # Resource Control
  preprocess_intervals_max_memory: int?
  preprocess_intervals_cores: int?
  annotate_intervals_max_memory: int?
  annotate_intervals_cores: int?
  collect_read_counts_max_memory: int?
  collect_read_counts_cores: int?
  filter_intervals_max_memory: int?
  filter_intervals_cores: int?
  dgcp_max_memory: int?
  dgcp_cores: int?
  scatter_intervals_max_memory: int?
  scatter_intervals_cores: int?
  germline_cnv_caller_max_memory: int?
  germline_cnv_caller_cores: int?
  postprocess_max_memory: int?
  postporcess_cores: int?
  collect_sample_metrics_ram: int?
  collect_sample_metrics_cores: int?
  collect_model_metrics_ram: int?
  collect_model_metrics_cores: int?

outputs:
  preprocessed_intervals: { type: 'File', outputSource: preprocess_intervals/preprocessed_intervals}
  read_counts_entity_ids: { type: 'string[]', outputSource: collect_read_counts/entity_id}
  read_counts: { type: 'File[]', outputSource: collect_read_counts/counts}
  annotated_intervals: { type: 'File?', outputSource: annotate_intervals/annotated_intervals}
  filtered_intervals: { type: 'File', outputSource: filter_intervals/filtered_intervals}
  contig_ploidy_model_tar: { type: 'File', outputSource: determine_germline_contig_ploidy_cohort/contig_ploidy_model_tar}
  contig_ploidy_calls_tar: { type: 'File', outputSource: determine_germline_contig_ploidy_cohort/contig_ploidy_calls_tar}
  gcnv_model_tars: { type: 'File[]', outputSource: germline_cnv_caller_cohort/gcnv_model_tar}
  gcnv_calls_tars: { type: { type: array, items: { type: array, items: File } }, outputSource: germline_cnv_caller_cohort/gcnv_call_tars}
  gcnv_tracking_tars: { type: 'File[]', outputSource: germline_cnv_caller_cohort/gcnv_tracking_tar}
  genotyped_intervals_vcfs: { type: 'File[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/genotyped_intervals_vcf}
  genotyped_segments_vcfs: { type: 'File[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/genotyped_segments_vcf}
  denoised_copy_ratios: { type: 'File[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/denoised_copy_ratios}
  sample_qc_status_files: { type: 'File[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/qc_status_file}
  sample_qc_status_strings: { type: 'string[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/qc_status_string}
  model_qc_status_file: { type: 'File', outputSource: collect_model_quality_metrics/qc_status_file}
  model_qc_string: { type: 'string', outputSource: collect_model_quality_metrics/qc_status_string}

steps:
  untar_reference:
    run: ../tools/untar_indexed_reference.cwl
    in:
      reference_tar: reference_tar
    out: [fasta, fai, dict, alt, amb, ann, bwt, pac, sa]

  bundle_secondaries:
    run: ../tools/bundle_secondaryfiles.cwl
    in:
      primary_file: untar_reference/fasta
      secondary_files:
        source: [untar_reference/fai, untar_reference/dict, untar_reference/alt, untar_reference/amb,
          untar_reference/ann, untar_reference/bwt, untar_reference/pac, untar_reference/sa]
        linkMerge: merge_flattened
    out: [output]

  index_mappability_track:
    run: ../tools/gatk_indexfeaturefile.cwl
    in:
      input_file: mappability_track_bed
      input_index: mappability_track_bed_idx
    out: [output]

  index_segmental_duplication_track:
    run: ../tools/gatk_indexfeaturefile.cwl
    in:
      input_file: segmental_duplication_track_bed
      input_index: segmental_duplication_track_bed_idx
    out: [output]

  preprocess_intervals:
    run: ../tools/gatk_preprocessintervals.cwl
    in:
      reference: bundle_secondaries/output
      sequence_dictionary: untar_reference/dict
      intervals_list: intervals
      blacklist_intervals_list: blacklist_intervals
      padding: padding
      bin_length: bin_length
      max_memory: preprocess_intervals_max_memory
      cores: preprocess_intervals_cores
    out: [preprocessed_intervals]

  annotate_intervals:
    run: ../tools/gatk_annotateintervals.cwl
    in:
      do_explicit_gc_correction: do_explicit_gc_correction
      reference: bundle_secondaries/output
      sequence_dictionary: untar_reference/dict
      intervals_list: preprocess_intervals/preprocessed_intervals
      mappability_track: index_mappability_track/output
      segmental_duplication_track: index_segmental_duplication_track/output
      feature_query_lookahead: feature_query_lookahead
      max_memory: annotate_intervals_max_memory
      cores: annotate_intervals_cores
    out: [annotated_intervals]

  collect_read_counts:
    hints:
    - class: sbg:AWSInstanceType
      value: c5.9xlarge
    run: ../tools/gatk_collectreadcounts.cwl
    scatter: bam
    in:
      reference: bundle_secondaries/output
      sequence_dictionary: untar_reference/dict
      bam: normal_bams
      intervals_list: preprocess_intervals/preprocessed_intervals
      disabled_read_filters: disabled_read_filters_for_collect_counts
      max_memory: collect_read_counts_max_memory
      cores: collect_read_counts_cores
    out: [entity_id, counts]

  filter_intervals:
    run: ../tools/gatk_filterintervals.cwl
    in:
      intervals_list: preprocess_intervals/preprocessed_intervals
      blacklist_intervals_list: blacklist_intervals_for_filter_intervals
      read_count_files: collect_read_counts/counts
      annotated_intervals: annotate_intervals/annotated_intervals
      ec_filter_max: extreme_count_filter_maximum_percentile
      ec_filter_min: extreme_count_filter_minimum_percentile
      ec_filter_percent: extreme_count_filter_percentage_of_samples
      gc_content_max: maximum_gc_content
      gc_content_min: minimum_gc_content
      lc_filter_count: low_count_filter_count_threshold
      lc_filter_percent: low_count_filter_percentage_of_samples
      mappability_max: maximum_mappability
      mappability_min: minimum_mappability
      sd_content_max: maximum_segmental_duplication_content
      sd_content_min: minimum_segmental_duplication_content
      max_memory: filter_intervals_max_memory
      cores: filter_intervals_cores
    out: [filtered_intervals]

  determine_germline_contig_ploidy_cohort:
    run: ../tools/gatk_determinegermlinecontigploidy_cohort.cwl
    in:
      cohort_entity_id: cohort_entity_id
      intervals_list: filter_intervals/filtered_intervals
      read_count_files: collect_read_counts/counts
      contig_ploidy_priors: contig_ploidy_priors
      mapping_error: ploidy_mapping_error_rate
      mean_bias_sd: ploidy_mean_bias_standard_deviation
      psi_scale_global: ploidy_global_psi_scale
      psi_scale_sample: ploidy_sample_psi_scale
      max_memory: dgcp_max_memory
      cores: dgcp_cores
    out: [contig_ploidy_model_tar, contig_ploidy_calls_tar]

  scatter_intervals:
    run: ../tools/gatk_scatter_intervals.cwl
    in:
      intervals_list: filter_intervals/filtered_intervals
      num_intervals_per_scatter: num_intervals_per_scatter
      max_memory: scatter_intervals_max_memory
      cores: scatter_intervals_cores
    out: [scattered_intervals_lists]

  index_scattered_intervals_list_array:
    run: ../tools/expression_create_index_array.cwl
    in:
      array: scatter_intervals/scattered_intervals_lists
    out: [index_array]

  germline_cnv_caller_cohort:
    hints:
    - class: sbg:AWSInstanceType
      value: c5.9xlarge
    run: ../tools/gatk_germlinecnvcaller_cohort.cwl
    scatter: [scatter_index,intervals_list]
    scatterMethod: dotproduct
    in:
      scatter_index: index_scattered_intervals_list_array/index_array
      cohort_entity_id: cohort_entity_id
      intervals_list: scatter_intervals/scattered_intervals_lists
      contig_ploidy_calls_tar: determine_germline_contig_ploidy_cohort/contig_ploidy_calls_tar
      read_count_files: collect_read_counts/counts
      annotated_intervals: annotate_intervals/annotated_intervals
      p_alt: gcvn_p_alt
      p_active: gcnv_p_active
      cnv_coherence_length: gcnv_cnv_coherence_length
      class_coherence_length: gcnv_class_coherence_length
      max_copy_number: gcnv_max_copy_number
      max_bias_factors: gcnv_max_bias_factors
      mapping_error_rate: gcnv_mapping_error_rate
      interval_psi_scale: gcnv_interval_psi_scale
      sample_psi_scale: gcnv_sample_psi_scale
      depth_correction_tau: gcnv_depth_correction_tau
      log_mean_bias_standard_deviation: gcnv_log_mean_bias_standard_deviation
      init_ard_rel_unexplained_variance: gcnv_init_ard_rel_unexplained_variance
      num_gc_bins: gcnv_num_gc_bins
      gc_curve_standard_deviation: gcnv_gc_curve_standard_deviation
      copy_number_posterior_expectation_mode: gcnv_copy_number_posterior_expectation_mode
      enable_bias_factors: gcnv_enable_bias_factors
      active_class_padding_hybrid_mode: gcnv_active_class_padding_hybrid_mode
      learning_rate: gcnv_learning_rate
      adamax_beta_1: gcnv_adamax_beta_1
      adamax_beta_2: gcnv_adamax_beta_2
      log_emission_samples_per_round: gcnv_log_emission_samples_per_round
      log_emission_sampling_median_rel_error: gcnv_log_emission_sampling_median_rel_error
      log_emission_sampling_rounds: gcnv_log_emission_sampling_rounds
      max_advi_iter_first_epoch: gcnv_max_advi_iter_first_epoch
      max_advi_iter_subsequent_epochs: gcnv_max_advi_iter_subsequent_epochs
      min_training_epochs: gcnv_min_training_epochs
      max_training_epochs: gcnv_max_training_epochs
      initial_temperature: gcnv_initial_temperature
      num_thermal_advi_iters: gcnv_num_thermal_advi_iters
      convergence_snr_averaging_window: gcnv_convergence_snr_averaging_window
      convergence_snr_trigger_threshold: gcnv_convergence_snr_trigger_threshold
      convergence_snr_countdown_window: gcnv_convergence_snr_countdown_window
      max_calling_iters: gcnv_max_calling_iters
      caller_update_convergence_threshold: gcnv_caller_update_convergence_threshold
      caller_internal_admixing_rate: gcnv_caller_internal_admixing_rate
      caller_external_admixing_rate: gcnv_caller_external_admixing_rate
      disable_annealing: gcnv_disable_annealing
      max_memory: germline_cnv_caller_max_memory
      cores: germline_cnv_caller_cores
    out: [gcnv_model_tar, gcnv_call_tars, gcnv_tracking_tar, calling_config_json, denoising_config_json, gcnvkernel_version_json, sharded_interval_list]

  organize_call_tars_by_sample:
    run: ../tools/expression_transpose_two_dimension_array.cwl
    in:
      array: germline_cnv_caller_cohort/gcnv_call_tars
    out: [transposed_array]

  index_entity_id_array:
    run: ../tools/expression_create_index_array.cwl
    in:
      array: collect_read_counts/entity_id
    out: [index_array]

  postprocess_gcnv_and_collectsamplequalitymetrics:
    hints:
    - class: sbg:AWSInstanceType
      value: c5.9xlarge
    run: ../subworkflows/postprocess_gcnv_and_collectsamplequalitymetrics.cwl
    scatter: [sample_index,entity_id,gcnv_calls_tars]
    scatterMethod: dotproduct
    in:
      entity_id: collect_read_counts/entity_id
      gcnv_calls_tars: organize_call_tars_by_sample/transposed_array
      calling_configs: germline_cnv_caller_cohort/calling_config_json
      denoising_configs: germline_cnv_caller_cohort/denoising_config_json
      gcnv_model_tars: germline_cnv_caller_cohort/gcnv_model_tar
      gcnvkernel_versions: germline_cnv_caller_cohort/gcnvkernel_version_json
      sharded_interval_lists: germline_cnv_caller_cohort/sharded_interval_list
      contig_ploidy_calls_tar: determine_germline_contig_ploidy_cohort/contig_ploidy_calls_tar
      ref_copy_number_autosomal_contigs: ref_copy_number_autosomal_contigs
      allosomal_contigs_args: allosomal_contigs_args
      sample_index: index_entity_id_array/index_array
      maximum_number_events_per_sample: maximum_number_events_per_sample
      postprocess_max_memory: postprocess_max_memory
      postporcess_cores: postporcess_cores
      collect_sample_metrics_ram: collect_sample_metrics_ram
      collect_sample_metrics_cores: collect_sample_metrics_cores
    out: [genotyped_intervals_vcf, genotyped_segments_vcf, denoised_copy_ratios, qc_status_file, qc_status_string]

  collect_model_quality_metrics:
    run: ../tools/collect_model_quality_metrics.cwl
    in:
      gcnv_model_tars: germline_cnv_caller_cohort/gcnv_model_tar
      ram: collect_model_metrics_ram
      cores: collect_model_metrics_cores
    out: [qc_status_file, qc_status_string]

$namespaces:
  sbg: https://sevenbridges.com
