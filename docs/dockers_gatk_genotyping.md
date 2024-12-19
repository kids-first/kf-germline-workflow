# Dockers of kfdrc-single-sample-genotyping-wf.cwl

TOOL|DOCKER
-|-
bcftools_annotate.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
bcftools_concat.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
bcftools_filter_vcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/bcftools:1.20
bcftools_strip_ann.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
echtvar_anno.cwl|pgc-images.sbgenomics.com/d3b-bixu/echtvar:0.2.0
gatk_applyrecalibration.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_gatherfinalvcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_gathertranches.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_gathervcfs.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_import_genotype_filtergvcf_merge.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_indelsvariantrecalibrator.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_selectvariants.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R
gatk_snpsvariantrecalibratorcreatemodel.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_snpsvariantrecalibratorscattered.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_variantfiltration.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R
generic_rename_outputs.cwl|None
kfdrc_peddy_tool.cwl|pgc-images.sbgenomics.com/d3b-bixu/peddy:latest
normalize_vcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
picard_collectvariantcallingmetrics.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
script_dynamicallycombineintervals.cwl|pgc-images.sbgenomics.com/d3b-bixu/python:2.7.13
variant_effect_predictor_105.cwl|ensemblorg/ensembl-vep:release_105.0
