# Dockers of kfdrc-germline-variant-wf.cwl

TOOL|DOCKER
-|-
annotsv.cwl|pgc-images.sbgenomics.com/d3b-bixu/annotsv:3.1.1
awk_parse_interval_list_contigs.cwl|None
bcftools_annotate.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
bcftools_concat.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
bcftools_filter_vcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/bcftools:1.20
bcftools_strip_ann.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
bcftools_view_index.cwl|staphb/bcftools:1.17
bgzip_tabix.cwl|broadinstitute/gatk:4.4.0.0
boolean_to_boolean.cwl|None
clt_string_array.cwl|None
cnvnator2vcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1
cnvnator_calculate_statistics.cwl|pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1
cnvnator_call.cwl|pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1
cnvnator_evaluation.cwl|pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1
cnvnator_extract_reads.cwl|pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1
cnvnator_partition.cwl|pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1
cnvnator_rd_histogram.cwl|pgc-images.sbgenomics.com/d3b-bixu/cnvnator:v0.4.1
collect_sample_quality_metrics.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R
echtvar_anno.cwl|pgc-images.sbgenomics.com/d3b-bixu/echtvar:0.2.0
expression_create_index_array.cwl|None
expression_transpose_two_dimension_array.cwl|None
file_to_file_array.cwl|None
filtering_defaults.cwl|None
freebayes.cwl|staphb/freebayes:1.3.6
gatk_applyrecalibration.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_bedtointervallist.cwl|broadinstitute/gatk:4.4.0.0
gatk_collectreadcounts.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R
gatk_determinegermlinecontigploidy_case.cwl|broadinstitute/gatk:4.2.0.0
gatk_gathertranches.cwl|broadinstitute/gatk:4.6.1.0
gatk_gathervcfscloud.cwl|broadinstitute/gatk:4.6.1.0
gatk_genomicsdbimport_genotypegvcfs.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_germlinecnvcaller_case.cwl|broadinstitute/gatk:4.2.0.0
gatk_haplotypecaller.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.beta.1-3.5
gatk_indelsvariantrecalibrator.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_intervallisttobed.cwl|broadinstitute/gatk:4.4.0.0
gatk_intervallisttools.cwl|broadinstitute/gatk:4.4.0.0
gatk_makesitesonlyvcf.cwl|broadinstitute/gatk:4.6.1.0
gatk_mergevcfs.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.1.0
gatk_plot_annotations.cwl|pgc-images.sbgenomics.com/d3b-bixu/tidyverse:4.4.2-gatk-plotter
gatk_postprocessgermlinecnvcalls.cwl|broadinstitute/gatk:4.2.0.0
gatk_preprocessintervals.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R
gatk_selectvariants.cwl|broadinstitute/gatk:4.6.1.0
gatk_snpsvariantrecalibratorcreatemodel.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_snpsvariantrecalibratorscattered.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_variantfiltration.cwl|broadinstitute/gatk:4.6.1.0
gatk_variantstotable.cwl|broadinstitute/gatk:4.6.1.0
generic_rename_outputs.cwl|None
guess_bin_size.cwl|None
kfdrc_peddy_tool.cwl|pgc-images.sbgenomics.com/d3b-bixu/peddy:latest
manta.cwl|pgc-images.sbgenomics.com/d3b-bixu/manta:1.6.0
normalize_vcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
picard_collectgvcfcallingmetrics.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_collectvariantcallingmetrics.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
picard_mergevcfs_python_renamesample.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
samtools_view.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.15.1
scatter_ploidy_calls_by_sample.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R
script_dynamicallycombineintervals.cwl|pgc-images.sbgenomics.com/d3b-bixu/python:2.7.13
strelka2_germline.cwl|pgc-images.sbgenomics.com/d3b-bixu/strelka:v2.9.10
svaba.cwl|pgc-images.sbgenomics.com/d3b-bixu/svaba:1.1.0
tar.cwl|None
variant_effect_predictor_105.cwl|ensemblorg/ensembl-vep:release_105.0
verifybamid_contamination_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/verifybamid:1.0.2
