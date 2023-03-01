cwlVersion: v1.2
class: Workflow
id: postprocess_gcnv_and_collectsamplequalitymetrics
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  entity_id: string
  gcnv_calls_tars: File[]
  calling_configs: File[]
  denoising_configs: File[]
  gcnv_model_tars: File[]
  gcnvkernel_versions: File[]
  sharded_interval_lists: File[]
  contig_ploidy_calls_tar: File
  ref_copy_number_autosomal_contigs: int?
  allosomal_contigs_args: string[]?
  sample_index: int
  maximum_number_events_per_sample: int
  postprocess_max_memory: int?
  postprocess_cores: int?
  collect_sample_metrics_ram: int?
  collect_sample_metrics_cores: int?

outputs:
  genotyped_intervals_vcf: { type: File, outputSource: postprocess_germline_cnv_calls/genotyped_intervals_vcf }
  genotyped_segments_vcf: { type: File, outputSource: postprocess_germline_cnv_calls/genotyped_segments_vcf }
  denoised_copy_ratios: { type: File, outputSource: postprocess_germline_cnv_calls/denoised_copy_ratios }
  qc_status_file: { type: File, outputSource: collect_sample_quality_metrics/qc_status_file }
  qc_status_string: { type: string, outputSource: collect_sample_quality_metrics/qc_status_string }

steps:
  postprocess_germline_cnv_calls:
    run: ../tools/gatk_postprocessgermlinecnvcalls.cwl
    in:
      calling_configs: calling_configs
      denoising_configs: denoising_configs
      gcnv_calls_tars: gcnv_calls_tars
      gcnv_model_tars: gcnv_model_tars
      gcnvkernel_versions: gcnvkernel_versions
      sharded_interval_lists: sharded_interval_lists
      contig_ploidy_calls_tar: contig_ploidy_calls_tar
      ref_copy_number_autosomal_contigs: ref_copy_number_autosomal_contigs
      allosomal_contigs_args: allosomal_contigs_args
      sample_index: sample_index
      entity_id: entity_id
      max_memory: postprocess_max_memory
      cores: postprocess_cores
    out: [genotyped_intervals_vcf, genotyped_segments_vcf, denoised_copy_ratios]
  collect_sample_quality_metrics:
    run: ../tools/collect_sample_quality_metrics.cwl
    in:
      genotyped_segments_vcf: postprocess_germline_cnv_calls/genotyped_segments_vcf
      maximum_number_events: maximum_number_events_per_sample
      entity_id: entity_id
      ram: collect_sample_metrics_ram
      cores: collect_sample_metrics_cores
    out: [qc_status_file, qc_status_string]

$namespaces:
  sbg: https://sevenbridges.com
