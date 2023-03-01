cwlVersion: v1.1
class: Workflow
id: kfdrc-gatk-cnv-germline-cohort-workflow
label: Kids First DRC GATK Germline CNV Cohort Workflow
doc: |
  # Kids First DRC GATK gCNV Cohort Workflow
  Kids First Data Resource Center gCNV Cohort Workflow. This workflow is a direct liftover of the [Broad WDL](https://github.com/broadinstitute/gatk/tree/4.2.0.0/scripts/cnv_wdl/germline).

  ![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

  ### Runtime Estimates
  1. 23 ~6 GB BAMs on chr20, X, and Y: 150 minutes & $1.75

  ### Tips To Run:
  1. Additional documentation about the workflow from Broad can be found here: https://github.com/broadinstitute/gatk/tree/4.2.0.0/scripts/cnv_wdl/germline
  1. Additional documentation about the gCNV calling process fro Broad can be found here: https://gatk.broadinstitute.org/hc/en-us/articles/360035531152--How-to-Call-common-and-rare-germline-copy-number-variants

  ## Other Resources
  - DOCKERFILEs: https://github.com/d3b-center/bixtools
  - Broad GATK Docker: https://github.com/broadinstitute/gatk/blob/master/Dockerfile


requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement

inputs:
  # Multistep
  reference_tar: {type: 'File', doc: "TAR containing reference fasta and associated\
      \ indecies. Must include FAI and DICT!", "sbg:fileTypes": "TAR, TAR.GZ, TGZ"}
  intervals: {type: 'File?', doc: "Picard or GATK-style interval list of regions to\
      \ process. For WGS, this should typically only include the chromosomes of interest.",
    "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, LIST"}
  blacklist_intervals: {type: 'File?', doc: "Picard or GATK-style interval list of\
      \ regions to ignore", "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, LIST"}
  normal_reads: {type: 'File[]', secondaryFiles: [{pattern: ".bai", required: false},
      {pattern: "^.bai", required: false}, {pattern: ".crai", required: false}, {
        pattern: "^.crai", required: false}], doc: "List of normal reads, and their\
      \ associated indecies, that comprise the cohort.", "sbg:fileTypes": "BAM,CRAM"}
  cohort_entity_id: {type: 'string', doc: "Name of the cohort. Will be used as a prefix\
      \ for output filenames."}
  contig_ploidy_priors: {type: 'File', doc: "TSV file containing prior probabilities\
      \ for the ploidy of each contig, with column headers: CONTIG_NAME, PLOIDY_PRIOR_0,\
      \ PLOIDY_PRIOR_1, ...", "sbg:fileTypes": "TSV"}
  num_intervals_per_scatter: {type: 'int', doc: "Number of intervals (i.e., targets\
      \ or bins) in each scatter for GermlineCNVCaller. If total number of intervals\
      \ is not divisible by the value provided, the last scatter will contain the\
      \ remainder."}

  # Preprocess intervals
  padding: {type: 'int?', doc: "Length (in bp) of the padding regions on each side\
      \ of the intervals. This must be the same value used for all case samples. Defaults\
      \ to 250 for use in targetted analysis. For WGS, set to 0"}
  bin_length: {type: 'int?', doc: "Length (in bp) of the bins. If zero, no binning\
      \ will be performed. Defaults to 0 for use in targetted analysis. For WGS, set\
      \ to 1000."}

  # Annotate intervals
  do_explicit_gc_correction: {type: 'boolean?', doc: "If true, perform explicit GC-bias\
      \ correction when creating PoN and in subsequent denoising of case samples.\
      \ If false, rely on PCA-based denoising to correct for GC bias. Tool will default\
      \ to true."}
  mappability_track_bed: {type: 'File?', doc: "Umap single-read mappability track\
      \ in .bed format. Overlapping intervals must be merged.", "sbg:fileTypes": "BED"}
  mappability_track_bed_idx: {type: 'File?', doc: "IDX index for mappability_track_bed.",
    "sbg:fileTypes": "IDX"}
  segmental_duplication_track_bed: {type: 'File?', doc: "Segmental-duplication track\
      \ in .bed format. Overlapping intervals must be merged.", "sbg:fileTypes": "BED"}
  segmental_duplication_track_bed_idx: {type: 'File?', doc: "IDX index for segmental_duplication_track_bed.",
    "sbg:fileTypes": "IDX"}
  feature_query_lookahead: {type: 'int?', doc: "Number of bases to cache when querying\
      \ feature tracks."}

  # Collect read counts
  disabled_read_filters_for_collect_counts: {type: 'string[]?', doc: "Read filters\
      \ to be disabled before analysis by GATK CollectReadCounts."}

  # Filter intervals
  blacklist_intervals_for_filter_intervals: {type: 'File?', doc: "File containing\
      \ one or more genomic intervals to exclude from processing."}
  extreme_count_filter_maximum_percentile: {type: 'float?', doc: "Maximum-percentile\
      \ parameter for the extreme-count filter. Intervals with a count that has a\
      \ percentile strictly greater than this in a percentage of samples strictly\
      \ greater than extreme-count-filter-percentage-of-samples will be filtered out.\
      \ (This is the second count-based filter applied.)"}
  extreme_count_filter_minimum_percentile: {type: 'float?', doc: "Minimum-percentile\
      \ parameter for the extreme-count filter. Intervals with a count that has a\
      \ percentile strictly less than this in a percentage of samples strictly greater\
      \ than extreme-count-filter-percentage-of-samples will be filtered out. (This\
      \ is the second count-based filter applied.)"}
  extreme_count_filter_percentage_of_samples: {type: 'float?', doc: "Percentage-of-samples\
      \ parameter for the extreme-count filter. Intervals with a count that has a\
      \ percentile outside of [extreme-count-filter-minimum-percentile, extreme-count-filter-maximum-percentile]\
      \ in a percentage of samples strictly greater than this will be filtered out.\
      \ (This is the second count-based filter applied.)"}
  maximum_gc_content: {type: 'float?', doc: "Maximum allowed value for GC-content\
      \ annotation (inclusive)."}
  minimum_gc_content: {type: 'float?', doc: "Minimum allowed value for GC-content\
      \ annotation (inclusive)."}
  low_count_filter_count_threshold: {type: 'int?', doc: "Count-threshold parameter\
      \ for the low-count filter. Intervals with a count strictly less than this threshold\
      \ in a percentage of samples strictly greater than low-count-filter-percentage-of-samples\
      \ will be filtered out. (This is the first count-based filter applied.)"}
  low_count_filter_percentage_of_samples: {type: 'float?', doc: "Percentage-of-samples\
      \ parameter for the low-count filter. Intervals with a count strictly less than\
      \ low-count-filter-count-threshold in a percentage of samples strictly greater\
      \ than this will be filtered out. (This is the first count-based filter applied.)"}
  maximum_mappability: {type: 'float?', doc: "Maximum allowed value for mappability\
      \ annotation (inclusive)."}
  minimum_mappability: {type: 'float?', doc: "Minimum allowed value for mappability\
      \ annotation (inclusive)."}
  maximum_segmental_duplication_content: {type: 'float?', doc: "Maximum allowed value\
      \ for segmental-duplication-content annotation (inclusive)."}
  minimum_segmental_duplication_content: {type: 'float?', doc: "Minimum allowed value\
      \ for segmental-duplication-content annotation (inclusive)."}

  # Determine Germline Contig Ploidy
  ploidy_mapping_error_rate: {type: 'float?', doc: "Typical mapping error rate."}
  ploidy_mean_bias_standard_deviation: {type: 'float?', doc: "Prior standard deviation\
      \ of the contig-level mean coverage bias. If a single sample is provided, this\
      \ input will be ignored."}
  ploidy_global_psi_scale: {type: 'float?', doc: "Prior scale of contig coverage unexplained\
      \ variance. If a single sample is provided, this input will be ignored."}
  ploidy_sample_psi_scale: {type: 'float?', doc: "Prior scale of the sample-specific\
      \ correction to the coverage unexplained variance."}

  # Germline CNV Caller
  gcvn_p_alt: {type: 'float?', doc: "Total prior probability of alternative copy-number\
      \ states (the reference copy-number is set to the contig integer ploidy)"}
  gcnv_p_active: {type: 'float?', doc: "Prior probability of treating an interval\
      \ as CNV-active (in a CNV-active domains, all copy-number states are equally\
      \ likely to be called)."}
  gcnv_cnv_coherence_length: {type: 'float?', doc: "Coherence length of CNV events\
      \ (in the units of bp)."}
  gcnv_class_coherence_length: {type: 'float?', doc: "Coherence length of CNV-active\
      \ and CNV-silent domains (in the units of bp)."}
  gcnv_max_copy_number: {type: 'int?', doc: "Highest allowed copy-number state."}
  gcnv_max_bias_factors: {type: 'int?', doc: "Maximum number of bias factors."}
  gcnv_mapping_error_rate: {type: 'float?', doc: "Typical mapping error rate."}
  gcnv_interval_psi_scale: {type: 'float?', doc: "Typical scale of interval-specific\
      \ unexplained variance."}
  gcnv_sample_psi_scale: {type: 'float?', doc: "Typical scale of sample-specific correction\
      \ to the unexplained variance."}
  gcnv_depth_correction_tau: {type: 'float?', doc: "Precision of read depth pinning\
      \ to its global value."}
  gcnv_log_mean_bias_standard_deviation: {type: 'float?', doc: "Standard deviation\
      \ of log mean bias."}
  gcnv_init_ard_rel_unexplained_variance: {type: 'float?', doc: "Initial value of\
      \ ARD prior precisions relative to the scale of interval-specific unexplained\
      \ variance."}
  gcnv_num_gc_bins: {type: 'int?', doc: "Number of bins used to represent the GC-bias\
      \ curves."}
  gcnv_gc_curve_standard_deviation: {type: 'float?', doc: "Prior standard deviation\
      \ of the GC curve from flat."}
  gcnv_copy_number_posterior_expectation_mode: {type: 'string?', doc: "The strategy\
      \ for calculating copy number posterior expectations in the coverage denoising\
      \ model."}
  gcnv_enable_bias_factors: {type: 'boolean?', doc: "Enable discovery of bias factors."}
  gcnv_active_class_padding_hybrid_mode: {type: 'int?', doc: "If copy-number-posterior-expectation-mode\
      \ is set to HYBRID, CNV-active intervals determined at any time will be padded\
      \ by this value (in the units of bp) in order to obtain the set of intervals\
      \ on which copy number posterior expectation is performed exactly."}
  gcnv_learning_rate: {type: 'float?', doc: "Adamax optimizer learning rate."}
  gcnv_adamax_beta_1: {type: 'float?', doc: "Adamax optimizer first moment estimation\
      \ forgetting factor."}
  gcnv_adamax_beta_2: {type: 'float?', doc: "Adamax optimizer second moment estimation\
      \ forgetting factor."}
  gcnv_log_emission_samples_per_round: {type: 'int?', doc: "Log emission samples drawn\
      \ per round of sampling."}
  gcnv_log_emission_sampling_median_rel_error: {type: 'float?', doc: "Maximum tolerated\
      \ median relative error in log emission sampling."}
  gcnv_log_emission_sampling_rounds: {type: 'int?', doc: "Log emission maximum sampling\
      \ rounds."}
  gcnv_max_advi_iter_first_epoch: {type: 'int?', doc: "Maximum ADVI iterations in\
      \ the first epoch."}
  gcnv_max_advi_iter_subsequent_epochs: {type: 'int?', doc: "Maximum ADVI iterations\
      \ in subsequent epochs."}
  gcnv_min_training_epochs: {type: 'int?', doc: "Minimum number of training epochs."}
  gcnv_max_training_epochs: {type: 'int?', doc: "Maximum number of training epochs."}
  gcnv_initial_temperature: {type: 'float?', doc: "Initial temperature (for DA-ADVI)."}
  gcnv_num_thermal_advi_iters: {type: 'int?', doc: "Number of thermal ADVI iterations\
      \ (for DA-ADVI)."}
  gcnv_convergence_snr_averaging_window: {type: 'int?', doc: "Averaging window for\
      \ calculating training signal-to-noise ratio (SNR) for convergence checking."}
  gcnv_convergence_snr_trigger_threshold: {type: 'float?', doc: "The number of ADVI\
      \ iterations during which the SNR is required to stay below the set threshold\
      \ for convergence."}
  gcnv_convergence_snr_countdown_window: {type: 'int?', doc: "The SNR threshold to\
      \ be reached before triggering the convergence countdown."}
  gcnv_max_calling_iters: {type: 'int?', doc: "Maximum number of internal self-consistency\
      \ iterations within each calling step."}
  gcnv_caller_update_convergence_threshold: {type: 'float?', doc: "Maximum tolerated\
      \ calling update size for convergence."}
  gcnv_caller_internal_admixing_rate: {type: 'float?', doc: "Admixing ratio of new\
      \ and old called posteriors (between 0 and 1; larger values implies using more\
      \ of the new posterior and less of the old posterior) for internal convergence\
      \ loops."}
  gcnv_caller_external_admixing_rate: {type: 'float?', doc: "Admixing ratio of new\
      \ and old called posteriors (between 0 and 1; larger values implies using more\
      \ of the new posterior and less of the old posterior) after convergence."}
  gcnv_disable_annealing: {type: 'boolean?', doc: "(advanced) Disable annealing."}

  # PostprocessGermlineCNVCalls
  ref_copy_number_autosomal_contigs: {type: 'int?', doc: "Reference copy-number on\
      \ autosomal intervals."}
  allosomal_contigs_args: {type: 'string[]?', doc: "Contigs to treat as allosomal\
      \ (i.e. choose their reference copy-number allele according to the sample karyotype)."}

  # arguments for QC
  maximum_number_events_per_sample: {type: 'int', doc: "Maximum number of events threshold\
      \ for doing sample QC (recommended for WES is ~100)"}

  # Resource Control
  preprocess_intervals_max_memory: {type: 'int?', doc: "GB of RAM to allocate to preprocess\
      \ intervals"}
  preprocess_intervals_cores: {type: 'int?', doc: "Minimum reserved number of CPU\
      \ cores for preprocess intervals"}
  annotate_intervals_max_memory: {type: 'int?', doc: "GB of RAM to allocate to annotate\
      \ intervals"}
  annotate_intervals_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores\
      \ for annotate intervals"}
  collect_read_counts_max_memory: {type: 'int?', doc: "GB of RAM to allocate to collect\
      \ read counts"}
  collect_read_counts_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores\
      \ for collect read counts"}
  filter_intervals_max_memory: {type: 'int?', doc: "GB of RAM to allocate to filter\
      \ intervals"}
  filter_intervals_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores\
      \ for filter intervals"}
  dgcp_max_memory: {type: 'int?', doc: "GB of RAM to allocate to determine germline\
      \ contig ploidy"}
  dgcp_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for determine\
      \ germline contig ploidy"}
  scatter_intervals_max_memory: {type: 'int?', doc: "GB of RAM to allocate to scatter\
      \ intervals"}
  scatter_intervals_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores\
      \ for scatter intervals"}
  germline_cnv_caller_max_memory: {type: 'int?', doc: "GB of RAM to allocate to gCNV\
      \ caller"}
  germline_cnv_caller_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores\
      \ for gCNV caller"}
  postprocess_max_memory: {type: 'int?', doc: "GB of RAM to allocate to postprocess\
      \ gCNV"}
  postprocess_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for\
      \ postprocess gCNV"}
  collect_sample_metrics_ram: {type: 'int?', doc: "GB of RAM to allocate to collect\
      \ sample metrics"}
  collect_sample_metrics_cores: {type: 'int?', doc: "Minimum reserved number of CPU\
      \ cores for collect sample metrics"}
  collect_model_metrics_ram: {type: 'int?', doc: "GB of RAM to allocate to collect\
      \ model metrics"}
  collect_model_metrics_cores: {type: 'int?', doc: "Minimum reserved number of CPU\
      \ cores for collect model metrics"}

outputs:
  preprocessed_intervals: {type: 'File', outputSource: preprocess_intervals/preprocessed_intervals,
    doc: "Preprocessed Picard interval-list file."}
  read_counts_entity_ids: {type: 'string[]', outputSource: collect_read_counts/entity_id,
    doc: "List of file basename that were processed by CollectReadCounts"}
  read_counts: {type: 'File[]', outputSource: collect_read_counts/counts, doc: "Counts\
      \ file for each normal BAM input. This workflow produces HDF5 format results."}
  annotated_intervals: {type: 'File?', outputSource: annotate_intervals/annotated_intervals,
    doc: "Annotated-intervals file. This is a tab-separated values (TSV) file with\
      \ a SAM-style header containing a sequence dictionary, a row specifying the\
      \ column headers for the contained annotations, and the corresponding entry\
      \ rows."}
  filtered_intervals: {type: 'File', outputSource: filter_intervals/filtered_intervals,
    doc: "Filtered Picard interval-list file."}
  contig_ploidy_model_tar: {type: 'File', outputSource: determine_germline_contig_ploidy_cohort/contig_ploidy_model_tar,
    doc: "TAR.GZ file of the model directory output by DetermineGermlineContigPloidy"}
  contig_ploidy_calls_tar: {type: 'File', outputSource: determine_germline_contig_ploidy_cohort/contig_ploidy_calls_tar,
    doc: "TAR.GZ file of the calls directory output by DetermineGermlineContigPloidy"}
  gcnv_model_tars: {type: 'File[]', outputSource: germline_cnv_caller_cohort/gcnv_model_tar,
    doc: "TAR.GZ files containing the model directory output by each shard of GermlineCNVCaller"}
  gcnv_calls_tars: {type: {type: 'array', items: {type: 'array', items: File}}, outputSource: germline_cnv_caller_cohort/gcnv_call_tars,
    doc: "TAR.GZ files containing the calls for each sample in each shard of GermlineCNVCaller"}
  gcnv_tracking_tars: {type: 'File[]', outputSource: germline_cnv_caller_cohort/gcnv_tracking_tar,
    doc: "TAR.GZ files containing the tracking directory output by each shard of GermlineCNVCaller"}
  genotyped_intervals_vcfs: {type: 'File[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/genotyped_intervals_vcf,
    doc: "Per sample VCF files provides a detailed listing of the most likely copy-number\
      \ call for each genomic interval included in the call-set, along with call quality,\
      \ call genotype, and the phred-scaled posterior probability vector for all integer\
      \ copy-number states."}
  genotyped_segments_vcfs: {type: 'File[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/genotyped_segments_vcf,
    doc: "Per sample VCF files containing coalesced contiguous intervals that share\
      \ the same copy-number call"}
  denoised_copy_ratios: {type: 'File[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/denoised_copy_ratios,
    doc: "Per sample files concatenates posterior means for denoised copy ratios from\
      \ all the call shards produced by the GermlineCNVCaller."}
  sample_qc_status_files: {type: 'File[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/qc_status_file,
    doc: "Per sample files containing the sample's QC status. Either PASS or EXCESSIVE_NUMBER_OF_EVENTS\
      \ as determined by maximum_number_events_per_sample input"}
  sample_qc_status_strings: {type: 'string[]', outputSource: postprocess_gcnv_and_collectsamplequalitymetrics/qc_status_string,
    doc: "String value contained within the sample_qc_status_files outputs"}
  model_qc_status_file: {type: 'File', outputSource: collect_model_quality_metrics/qc_status_file,
    doc: "File containing the QC status for the model. Either PASS or ALL_PRINCIPAL_COMPONENTS_USED."}
  model_qc_string: {type: 'string', outputSource: collect_model_quality_metrics/qc_status_string,
    doc: "String value contained within the model_qc_status_file output."}

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
    scatter: reads
    in:
      reference: bundle_secondaries/output
      sequence_dictionary: untar_reference/dict
      reads: normal_reads
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
      output_basename: cohort_entity_id
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
    scatter: [scatter_index, intervals_list]
    scatterMethod: dotproduct
    in:
      scatter_index: index_scattered_intervals_list_array/index_array
      output_basename: cohort_entity_id
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
    out: [gcnv_model_tar, gcnv_call_tars, gcnv_tracking_tar, calling_config_json,
      denoising_config_json, gcnvkernel_version_json, sharded_interval_list]

  organize_call_tars_by_sample:
    run: ../tools/expression_transpose_two_dimension_array.cwl
    in:
      array: germline_cnv_caller_cohort/gcnv_call_tars
    out: [transposed_array]

  index_entity_id_array:
    run: ../tools/expression_create_index_array_string.cwl
    in:
      array: collect_read_counts/entity_id
    out: [index_array]

  postprocess_gcnv_and_collectsamplequalitymetrics:
    hints:
    - class: sbg:AWSInstanceType
      value: c5.9xlarge
    run: ../subworkflows/postprocess_gcnv_and_collectsamplequalitymetrics.cwl
    scatter: [sample_index, entity_id, gcnv_calls_tars]
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
      postprocess_cores: postprocess_cores
      collect_sample_metrics_ram: collect_sample_metrics_ram
      collect_sample_metrics_cores: collect_sample_metrics_cores
    out: [genotyped_intervals_vcf, genotyped_segments_vcf, denoised_copy_ratios, qc_status_file,
      qc_status_string]

  collect_model_quality_metrics:
    run: ../tools/collect_model_quality_metrics.cwl
    in:
      gcnv_model_tars: germline_cnv_caller_cohort/gcnv_model_tar
      ram: collect_model_metrics_ram
      cores: collect_model_metrics_cores
    out: [qc_status_file, qc_status_string]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 4
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- BAM
- CNV
- COHORT
- GATK
- GCNV
- GERMLINE
- INTERVALS
- SEGMENTS
- VCF
