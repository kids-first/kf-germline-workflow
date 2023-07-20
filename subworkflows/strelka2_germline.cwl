cwlVersion: v1.2
class: Workflow
id: strelka2_germline
doc: |
  Strelka2 Germline Workflow
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: StepInputExpressionRequirement
- class: SubworkflowFeatureRequirement
inputs:
  indexed_reference_fasta:
    type: 'File'
    secondaryFiles:
    - {pattern: '^.dict', required: true}
    - {pattern: '.fai', required: true}
    doc: |
      The reference genome fasta (and associated indicies) to which the germline BAM was aligned.
    "sbg:fileTypes": "FASTA, FA"
    "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [{class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict},
        {class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai}]}

  input_reads: {type: 'File[]', secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}], doc: "Aligned reads files to be analyzed", "sbg:fileTypes": "BAM,CRAM"}
  call_regions: { type: 'File' }
  output_basename: {type: 'string', doc: "String value to use as basename for outputs"}

  # Annotation
  bcftools_annot_gnomad_columns: {type: 'string?', doc: "csv string of columns from annotation to port into the input vcf, i.e", default: "INFO/gnomad_3_1_1_AC:=INFO/AC,INFO/gnomad_3_1_1_AN:=INFO/AN,INFO/gnomad_3_1_1_AF:=INFO/AF,INFO/gnomad_3_1_1_nhomalt:=INFO/nhomalt,INFO/gnomad_3_1_1_AC_popmax:=INFO/AC_popmax,INFO/gnomad_3_1_1_AN_popmax:=INFO/AN_popmax,INFO/gnomad_3_1_1_AF_popmax:=INFO/AF_popmax,INFO/gnomad_3_1_1_nhomalt_popmax:=INFO/nhomalt_popmax,INFO/gnomad_3_1_1_AC_controls_and_biobanks:=INFO/AC_controls_and_biobanks,INFO/gnomad_3_1_1_AN_controls_and_biobanks:=INFO/AN_controls_and_biobanks,INFO/gnomad_3_1_1_AF_controls_and_biobanks:=INFO/AF_controls_and_biobanks,INFO/gnomad_3_1_1_AF_non_cancer:=INFO/AF_non_cancer,INFO/gnomad_3_1_1_primate_ai_score:=INFO/primate_ai_score,INFO/gnomad_3_1_1_splice_ai_consequence:=INFO/splice_ai_consequence"}
  bcftools_annot_clinvar_columns: {type: 'string?', doc: "csv string of columns from annotation to port into the input vcf", default: "INFO/ALLELEID,INFO/CLNDN,INFO/CLNDNINCL,INFO/CLNDISDB,INFO/CLNDISDBINCL,INFO/CLNHGVS,INFO/CLNREVSTAT,INFO/CLNSIG,INFO/CLNSIGCONF,INFO/CLNSIGINCL,INFO/CLNVC,INFO/CLNVCSO,INFO/CLNVI"}
  gnomad_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional bgzipped annotation vcf file", "sbg:suggestedValue": {class: File, path: 6324ef5ad01163633daa00d8, name: gnomad_3.1.1.vwb_subset.vcf.gz, secondaryFiles: [{class: File, path: 6324ef5ad01163633daa00d7, name: gnomad_3.1.1.vwb_subset.vcf.gz.tbi}]}}
  clinvar_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional bgzipped annotation vcf file", "sbg:suggestedValue": {class: File, path: 632c6cbb2a5194517cff1593, name: clinvar_20220507_chr.vcf.gz, secondaryFiles: [{class: File, path: 632c6cbb2a5194517cff1592, name: clinvar_20220507_chr.vcf.gz.tbi}]}}
  # VEP-specific
  vep_buffer_size: {type: 'int?', default: 100000, doc: "Increase or decrease to balance speed and memory usage"}
  vep_cache: {type: 'File', doc: "tar gzipped cache from ensembl/local converted cache", "sbg:suggestedValue": {class: File, path: 6332f8e47535110eb79c794f, name: homo_sapiens_merged_vep_105_indexed_GRCh38.tar.gz}}
  dbnsfp: {type: 'File?', secondaryFiles: [.tbi, ^.readme.txt], doc: "VEP-formatted plugin file, index, and readme file containing dbNSFP annotations", "sbg:suggestedValue": { class: File, path: 63d97e944073196d123db264, name: dbNSFP4.3a_grch38.gz, secondaryFiles: [ {class: File, path: 63d97e944073196d123db262, name: dbNSFP4.3a_grch38.gz.tbi}, {class: File, path: 63d97e944073196d123db263, name: dbNSFP4.3a_grch38.readme.txt}]}}
  dbnsfp_fields: {type: 'string?', doc: "csv string with desired fields to annotate. Use ALL to grab all", default: 'SIFT4G_pred,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,VEST4_score,VEST4_rankscore,MetaSVM_pred,MetaLR_pred,MetaRNN_pred,M-CAP_pred,REVEL_score,REVEL_rankscore,PrimateAI_pred,DEOGEN2_pred,BayesDel_noAF_pred,ClinPred_pred,LIST-S2_pred,Aloft_pred,fathmm-MKL_coding_pred,fathmm-XF_coding_pred,Eigen-phred_coding,Eigen-PC-phred_coding,phyloP100way_vertebrate,phyloP100way_vertebrate_rankscore,phastCons100way_vertebrate,phastCons100way_vertebrate_rankscore,TWINSUK_AC,TWINSUK_AF,ALSPAC_AC,ALSPAC_AF,UK10K_AC,UK10K_AF,gnomAD_exomes_controls_AC,gnomAD_exomes_controls_AN,gnomAD_exomes_controls_AF,gnomAD_exomes_controls_nhomalt,gnomAD_exomes_controls_POPMAX_AC,gnomAD_exomes_controls_POPMAX_AN,gnomAD_exomes_controls_POPMAX_AF,gnomAD_exomes_controls_POPMAX_nhomalt,Interpro_domain,GTEx_V8_gene,GTEx_V8_tissue'}
  merged: {type: 'boolean?', doc: "Set to true if merged cache used", default: true}
  cadd_indels: {type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file and index containing CADD indel annotations", "sbg:suggestedValue": { class: File, path: 632a2b417535110eb78312a6, name: CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz, secondaryFiles: [{class: File, path: 632a2b417535110eb78312a5, name: CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz.tbi}]}}
  cadd_snvs: {type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file and index containing CADD SNV annotations", "sbg:suggestedValue": {class: File, path: 632a2b417535110eb78312a4, name: CADDv1.6-38-whole_genome_SNVs.tsv.gz, secondaryFiles: [{class: File, path: 632a2b417535110eb78312a3, name: CADDv1.6-38-whole_genome_SNVs.tsv.gz.tbi}]}}
  intervar: {type: 'File?', doc: "Intervar vcf-formatted file. Exonic SNVs only - for more comprehensive run InterVar. See docs for custom build instructions", secondaryFiles: [.tbi], "sbg:suggestedValue": {class: File, path: 633348619968f3738e4ec4b5, name: Exons.all.hg38.intervar.2021-07-31.vcf.gz, secondaryFiles: [{class: File, path: 633348619968f3738e4ec4b6, name: Exons.all.hg38.intervar.2021-07-31.vcf.gz.tbi}]}}

  # Resource Requirements
  strelka2_cpu: {type: 'int?', doc: "CPUs to allocate to freebayes"}
  strelka2_ram: {type: 'int?', doc: "RAM in GB to allocate to freebayes"}
  vep_ram: {type: 'int?', default: 32, doc: "In GB, may need to increase this value depending on the size/complexity of input"}
  vep_cores: {type: 'int?', default: 16, doc: "Number of cores to use. May need to increase for really large inputs"}

outputs:
  genome_vcfs: { type: 'File[]', outputSource: strelka2/genome_vcf_gzs }
  prepass_variants_vcf: { type: 'File', outputSource: strelka2/variants_vcf_gz }
  annotated_pass_variants_vcf: { type: 'File[]', outputSource: annotate_vcf/annotated_vcf }

steps:
  strelka2:
    run: ../tools/strelka2_germline.cwl
    in:
      input_reads: input_reads
      reference: indexed_reference_fasta
      call_regions: call_regions
      output_basename: output_basename
      cpu: strelka2_cpu
      ram: strelka2_ram
    out: [variants_vcf_gz, genome_vcf_gzs]
  bcftools_view_index:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: strelka2/variants_vcf_gz
      output_filename:
        valueFrom: $(inputs.input_vcf.basename.replace(".vcf.gz",".pass.vcf.gz"))
      output_type:
        valueFrom: "z"
      apply_filters:
        valueFrom: "PASS"
      tbi:
        valueFrom: $(1 == 1)
    out: [output]
  annotate_vcf:
    run: ../workflows/kfdrc-germline-snv-annot-workflow.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_vcf: bcftools_view_index/output
      output_basename: output_basename
      tool_name:
        valueFrom: "strelka2.pass.vep_105"
      bcftools_annot_gnomad_columns: bcftools_annot_gnomad_columns
      bcftools_annot_clinvar_columns: bcftools_annot_clinvar_columns
      gnomad_annotation_vcf: gnomad_annotation_vcf
      clinvar_annotation_vcf: clinvar_annotation_vcf
      vep_buffer_size: vep_buffer_size
      vep_cache: vep_cache
      dbnsfp: dbnsfp
      dbnsfp_fields: dbnsfp_fields
      cadd_indels: cadd_indels
      cadd_snvs: cadd_snvs
      merged: merged
      intervar: intervar
      vep_ram: vep_ram
      vep_cores: vep_cores
    out: [annotated_vcf]


$namespaces:
  sbg: https://sevenbridges.com
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
