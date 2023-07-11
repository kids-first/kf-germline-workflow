cwlVersion: v1.2
class: Workflow
id: kfdrc-germline-snv-scatter-annot-wf
label: Kids First DRC Germline SNV Scatter Annotation Workflow

doc: "Run germline annot wf with scatter-gather. Good for larger inputs"

requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  unpadded_intervals_file: {type: File, doc: 'hg38.even.handcurated.20k.intervals',
    "sbg:suggestedValue": {class: File, path: 5f500135e4b0370371c051b1, name: hg38.even.handcurated.20k.intervals}}
  indexed_reference_fasta: {type: 'File', secondaryFiles: [.fai, ^.dict], "sbg:suggestedValue": {
      class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [{class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict},
        {class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai}]}}
  input_vcf: {type: 'File', secondaryFiles: ['.tbi'], doc: "Input vcf to annotate"}
  output_basename: string
  tool_name: { type: string, doc: "File name string suffx to use for output files" }

  # bcftools annotate if more to do
  bcftools_annot_gnomad_columns: {type: 'string?', doc: "csv string of columns from\
      \ annotation to port into the input vcf, i.e", default: "INFO/gnomad_3_1_1_AC:=INFO/AC,INFO/gnomad_3_1_1_AN:=INFO/AN,INFO/gnomad_3_1_1_AF:=INFO/AF,INFO/gnomad_3_1_1_nhomalt:=INFO/nhomalt,INFO/gnomad_3_1_1_AC_popmax:=INFO/AC_popmax,INFO/gnomad_3_1_1_AN_popmax:=INFO/AN_popmax,INFO/gnomad_3_1_1_AF_popmax:=INFO/AF_popmax,INFO/gnomad_3_1_1_nhomalt_popmax:=INFO/nhomalt_popmax,INFO/gnomad_3_1_1_AC_controls_and_biobanks:=INFO/AC_controls_and_biobanks,INFO/gnomad_3_1_1_AN_controls_and_biobanks:=INFO/AN_controls_and_biobanks,INFO/gnomad_3_1_1_AF_controls_and_biobanks:=INFO/AF_controls_and_biobanks,INFO/gnomad_3_1_1_AF_non_cancer:=INFO/AF_non_cancer,INFO/gnomad_3_1_1_primate_ai_score:=INFO/primate_ai_score,INFO/gnomad_3_1_1_splice_ai_consequence:=INFO/splice_ai_consequence"}
  bcftools_annot_clinvar_columns: {type: 'string?', doc: "csv string of columns from\
      \ annotation to port into the input vcf", default: "INFO/ALLELEID,INFO/CLNDN,INFO/CLNDNINCL,INFO/CLNDISDB,INFO/CLNDISDBINCL,INFO/CLNHGVS,INFO/CLNREVSTAT,INFO/CLNSIG,INFO/CLNSIGCONF,INFO/CLNSIGINCL,INFO/CLNVC,INFO/CLNVCSO,INFO/CLNVI"}
  gnomad_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional\
      \ bgzipped annotation vcf file", "sbg:suggestedValue": {class: File, path: 6324ef5ad01163633daa00d8,
      name: gnomad_3.1.1.vwb_subset.vcf.gz, secondaryFiles: [{class: File, path: 6324ef5ad01163633daa00d7,
          name: gnomad_3.1.1.vwb_subset.vcf.gz.tbi}]}}
  clinvar_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional\
      \ bgzipped annotation vcf file", "sbg:suggestedValue": {class: File, path: 632c6cbb2a5194517cff1593,
      name: clinvar_20220507_chr.vcf.gz, secondaryFiles: [{class: File, path: 632c6cbb2a5194517cff1592,
          name: clinvar_20220507_chr.vcf.gz.tbi}]}}
  # VEP-specific
  vep_ram: {type: 'int?', default: 48, doc: "In GB, may need to increase this value\
      \ depending on the size/complexity of input"}
  vep_cores: {type: 'int?', default: 32, doc: "Number of cores to use. May need to\
      \ increase for really large inputs"}
  vep_buffer_size: {type: 'int?', default: 100000, doc: "Increase or decrease to balance\
      \ speed and memory usage"}
  vep_cache: {type: 'File', doc: "tar gzipped cache from ensembl/local converted cache",
    "sbg:suggestedValue": {class: File, path: 6332f8e47535110eb79c794f, name: homo_sapiens_merged_vep_105_indexed_GRCh38.tar.gz}}
  dbnsfp: {type: 'File?', secondaryFiles: [.tbi, ^.readme.txt], doc: "VEP-formatted\
      \ plugin file, index, and readme file containing dbNSFP annotations", "sbg:suggestedValue": {
      class: File, path: 63d97e944073196d123db264, name: dbNSFP4.3a_grch38.gz, secondaryFiles: [
        {class: File, path: 63d97e944073196d123db262, name: dbNSFP4.3a_grch38.gz.tbi},
        {class: File, path: 63d97e944073196d123db263, name: dbNSFP4.3a_grch38.readme.txt}]}}
  dbnsfp_fields: {type: 'string?', doc: "csv string with desired fields to annotate.\
      \ Use ALL to grab all", default: 'SIFT4G_pred,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,VEST4_score,VEST4_rankscore,MetaSVM_pred,MetaLR_pred,MetaRNN_pred,M-CAP_pred,REVEL_score,REVEL_rankscore,PrimateAI_pred,DEOGEN2_pred,BayesDel_noAF_pred,ClinPred_pred,LIST-S2_pred,Aloft_pred,fathmm-MKL_coding_pred,fathmm-XF_coding_pred,Eigen-phred_coding,Eigen-PC-phred_coding,phyloP100way_vertebrate,phyloP100way_vertebrate_rankscore,phastCons100way_vertebrate,phastCons100way_vertebrate_rankscore,TWINSUK_AC,TWINSUK_AF,ALSPAC_AC,ALSPAC_AF,UK10K_AC,UK10K_AF,gnomAD_exomes_controls_AC,gnomAD_exomes_controls_AN,gnomAD_exomes_controls_AF,gnomAD_exomes_controls_nhomalt,gnomAD_exomes_controls_POPMAX_AC,gnomAD_exomes_controls_POPMAX_AN,gnomAD_exomes_controls_POPMAX_AF,gnomAD_exomes_controls_POPMAX_nhomalt,Interpro_domain,GTEx_V8_gene,GTEx_V8_tissue'}
  merged: {type: 'boolean?', doc: "Set to true if merged cache used", default: true}
  cadd_indels: {type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin\
      \ file and index containing CADD indel annotations", "sbg:suggestedValue": {
      class: File, path: 632a2b417535110eb78312a6, name: CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz,
      secondaryFiles: [{class: File, path: 632a2b417535110eb78312a5, name: CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz.tbi}]}}
  cadd_snvs: {type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file\
      \ and index containing CADD SNV annotations", "sbg:suggestedValue": {class: File,
      path: 632a2b417535110eb78312a4, name: CADDv1.6-38-whole_genome_SNVs.tsv.gz,
      secondaryFiles: [{class: File, path: 632a2b417535110eb78312a3, name: CADDv1.6-38-whole_genome_SNVs.tsv.gz.tbi}]}}
  intervar: {type: 'File?', doc: "Intervar vcf-formatted file. Exonic SNVs only -\
      \ for more comprehensive run InterVar. See docs for custom build instructions",
    secondaryFiles: [.tbi], "sbg:suggestedValue": {class: File, path: 633348619968f3738e4ec4b5,
      name: Exons.all.hg38.intervar.2021-07-31.vcf.gz, secondaryFiles: [{class: File,
          path: 633348619968f3738e4ec4b6, name: Exons.all.hg38.intervar.2021-07-31.vcf.gz.tbi}]}}
  bcftools_cores: { type: 'int?', default: 4}
  bcftools_ram: { type: 'int?', default: 8}

outputs:
  annotated_vcf: {type: File, outputSource: gatk_gatherfinalvcf/output}

steps:
  dynamicallycombineintervals:
    run: ../tools/script_dynamicallycombineintervals.cwl
    doc: 'Merge interval lists based on number of gVCF inputs'
    in:
      input_vcfs: 
        source: input_vcf
        valueFrom: "${ return [self] }"
      interval: unpadded_intervals_file
    out: [out_intervals]

  output_region_str:
    run: ../tools/output_region_str.cwl
    in: 
      intervals_file: dynamicallycombineintervals/out_intervals
    scatter: intervals_file
    out: [output]

  bcftools_region_subset:
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c5.4xlarge
    run: ../tools/bcftools_region_subset.cwl
    in:
      input_vcf: input_vcf
      regions: output_region_str/output
      cpu: bcftools_cores
      ram: bcftools_ram
      output_basename: output_basename
    scatter: [regions]
    out: [output]

  annotate_vcf:
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c5.9xlarge
    run: ../workflows/kfdrc-germline-snv-annot-workflow.cwl
    doc: 'annotate variants'
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_vcf: bcftools_region_subset/output
      output_basename: output_basename
      tool_name: tool_name
      bcftools_annot_gnomad_columns: bcftools_annot_gnomad_columns
      bcftools_annot_clinvar_columns: bcftools_annot_clinvar_columns
      gnomad_annotation_vcf: gnomad_annotation_vcf
      clinvar_annotation_vcf: clinvar_annotation_vcf
      vep_ram: vep_ram
      vep_cores: vep_cores
      vep_buffer_size: vep_buffer_size
      vep_cache: vep_cache
      dbnsfp: dbnsfp
      dbnsfp_fields: dbnsfp_fields
      cadd_indels: cadd_indels
      cadd_snvs: cadd_snvs
      merged: merged
      intervar: intervar
    scatter: [input_vcf]
    out: [annotated_vcf]

  gatk_gatherfinalvcf:
    run: ../tools/gatk_gatherfinalvcf.cwl
    doc: 'Combine annotated VCFs'
    in:
      input_vcfs: 
        source: annotate_vcf/annotated_vcf
        valueFrom: |
            $(self.map( function(e) { var out = e[0]; out.secondaryFiles = [e[1]]; return out; }))
      output_basename: output_basename
    out: [output]
$namespaces:
  sbg: https://sevenbridges.com

sbg:license: Apache License 2.0
sbg:publisher: KFDRC

"sbg:links":
- id: 'https://github.com/kids-first/kf-germline-workflow/releases/tag/v0.5.0'
  label: github-release
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 4
