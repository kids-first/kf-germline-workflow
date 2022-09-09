cwlVersion: v1.2
class: Workflow
id: kfdrc-germline-snv--annot-wf
label: Kids First DRC Germline SNV Annotation Workflow

requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  indexed_reference_fasta: {type: 'File', secondaryFiles: [.fai, ^.dict]}
  input_vcf: {type: 'File', secondaryFiles: ['.tbi'], doc: "Input vcf to annotate and soft filter"}
  output_basename: string
  tool_name: string

  # bcftools strip, if needed
  bcftools_strip_columns: {type: 'string?', doc: "csv string of columns to strip if needed to avoid conflict, i.e INFO/AF"}
  # bcftools annotate if more to do
  bcftools_annot_gnomad_columns: {type: 'string?', doc: "csv string of columns from annotation to port into the input vcf, i.e INFO/AF"}
  bcftools_annot_clinvar_columns: {type: 'string?', doc: "csv string of columns from annotation to port into the input vcf, i.e INFO/CLNSIG,INFO/CLNREVSTAT"}
  gnomad_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional bgzipped annotation vcf file"}
  clinvar_annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional bgzipped annotation vcf file"}
  # VEP-specific
  vep_ram: {type: 'int?', default: 48, doc: "In GB, may need to increase this value depending on the size/complexity of input"}
  vep_cores: {type: 'int?', default: 36, doc: "Number of cores to use. May need to increase for really large inputs"}
  vep_buffer_size: {type: 'int?', default: 100000, doc: "Increase or decrease to balance speed and memory usage"}
  vep_cache: {type: 'File', doc: "tar gzipped cache from ensembl/local converted cache"}
  vep_verbose: { type: 'boolean?', doc: "Turn on verbose logging for debug purposes", default: false }
  dbnsfp: { type: 'File?', secondaryFiles: [.tbi,^.readme.txt], doc: "VEP-formatted plugin file, index, and readme file containing dbNSFP annotations" }
  dbnsfp_fields: { type: 'string?', doc: "csv string with desired fields to annotate. Use ALL to grab all",
    default: 'SIFT4G_pred,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,VEST4_score,VEST4_rankscore,MetaSVM_pred,MetaLR_pred,MetaRNN_pred,M-CAP_pred,REVEL_score,REVEL_rankscore,PrimateAI_pred,DEOGEN2_pred,BayesDel_noAF_pred,ClinPred_pred,LIST-S2_pred,Aloft_pred,fathmm-MKL_coding_pred,fathmm-XF_coding_pred,Eigen-phred_coding,Eigen-PC-phred_coding,phyloP100way_vertebrate,phyloP100way_vertebrate_rankscore,phastCons100way_vertebrate,phastCons100way_vertebrate_rankscore,TWINSUK_AC,TWINSUK_AF,ALSPAC_AC,ALSPAC_AF,UK10K_AC,UK10K_AF,gnomAD_exomes_controls_AC,gnomAD_exomes_controls_AN,gnomAD_exomes_controls_AF,gnomAD_exomes_controls_nhomalt,gnomAD_exomes_controls_POPMAX_AC,gnomAD_exomes_controls_POPMAX_AN,gnomAD_exomes_controls_POPMAX_AF,gnomAD_exomes_controls_POPMAX_nhomalt,gnomAD_genomes_flag,gnomAD_genomes_AC,gnomAD_genomes_AN,gnomAD_genomes_AF,gnomAD_genomes_nhomalt,gnomAD_genomes_POPMAX_AC,gnomAD_genomes_POPMAX_AN,gnomAD_genomes_POPMAX_AF,gnomAD_genomes_POPMAX_nhomalt,gnomAD_genomes_controls_and_biobanks_AC,gnomAD_genomes_controls_and_biobanks_AN,gnomAD_genomes_controls_and_biobanks_AF,gnomAD_genomes_controls_and_biobanks_nhomalt,clinvar_id,clinvar_clnsig,clinvar_trait,clinvar_review,clinvar_hgvs,clinvar_var_source,clinvar_MedGen_id,clinvar_OMIM_id,clinvar_Orphanet_id,Interpro_domain,GTEx_V8_gene,GTEx_V8_tissue'
    }
  merged: { type: 'boolean?', doc: "Set to true if merged cache used", default: true }
  run_cache_existing: { type: boolean, doc: "Run the check_existing flag for cache" }
  run_cache_af: { type: boolean, doc: "Run the allele frequency flags for cache" }
  run_stats: { type: boolean, doc: "Create stats file? Disable for speed", default: false }
  cadd_indels: { type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file and index containing CADD indel annotations" }
  cadd_snvs: { type: 'File?', secondaryFiles: [.tbi], doc: "VEP-formatted plugin file and index containing CADD SNV annotations" }
  intervar: { type: 'File?', doc: "Intervar vcf-formatted file. See docs for custom build instructions", secondaryFiles: [.tbi] }

outputs:
  annotated_vcf: {type: 'File[]', outputSource: rename_output/renamed_files}

steps:
  normalize_vcf:
    run: ../tools/normalize_vcf.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_vcf: input_vcf
      output_basename: output_basename
      tool_name: tool_name
    out: [normalized_vcf]

  bcftools_strip_info:
    when: $(inputs.strip_info != null)
    run: ../tools/bcftools_strip_ann.cwl
    in:
      input_vcf: normalize_vcf/normalized_vcf
      output_basename: output_basename
      tool_name: tool_name
      strip_info: bcftools_strip_columns
    out: [stripped_vcf]

  vep_annotate_vcf:
    run: ../tools/variant_effect_predictor_105.cwl
    in:
      reference: indexed_reference_fasta
      cores: vep_cores
      ram: vep_ram
      verbose: vep_verbose
      buffer_size: vep_buffer_size
      input_vcf:
        source: [bcftools_strip_info/stripped_vcf, normalize_vcf/normalized_vcf]
        pickValue: first_non_null
      output_basename: output_basename
      tool_name: tool_name
      cache: vep_cache
      merged: merged
      run_cache_existing: run_cache_existing
      run_cache_af: run_cache_af
      run_stats: run_stats
      cadd_indels: cadd_indels
      cadd_snvs: cadd_snvs
      dbnsfp: dbnsfp
      dbnsfp_fields: dbnsfp_fields
      intervar: intervar
    out: [output_vcf]

  bcftools_gnomad_annotate:
    when: $(inputs.annotation_vcf != null)
    run: ../tools/bcftools_annotate.cwl
    in:
      input_vcf: vep_annotate_vcf/output_vcf
      annotation_vcf: gnomad_annotation_vcf
      columns: bcftools_annot_gnomad_columns
      output_basename: output_basename
      tool_name: tool_name
    out: [bcftools_annotated_vcf]

  bcftools_clinvar_annotate:
    when: $(inputs.annotation_vcf != null)
    run: ../tools/bcftools_annotate.cwl
    in:
      input_vcf:
        source: [bcftools_gnomad_annotate/bcftools_annotated_vcf, vep_annotate_vcf/output_vcf]
        pickValue: first_non_null
      annotation_vcf: clinvar_annotation_vcf
      columns: bcftools_annot_clinvar_columns
      output_basename: output_basename
      tool_name: tool_name
    out: [bcftools_annotated_vcf]

  rename_output:
    run: ../tools/generic_rename_outputs.cwl
    label: Rename Outputs
    in:
      input_files:
        source: [bcftools_clinvar_annotate/bcftools_annotated_vcf, bcftools_gnomad_annotate/bcftools_annotated_vcf, vep_annotate_vcf/output_vcf]
        valueFrom: "${ for(var i = 0; i < self.length; i++){
            if (self[i] != null){
                return [self[i],self[i].secondaryFiles[0]];
            }
            }
            }"
      rename_to:
        source: [output_basename, tool_name]
        valueFrom: "${var pro_vcf=self[0] + '.' + self[1] + '.norm.annot.vcf.gz'; \
        var pro_tbi=self[0] + '.' + self[1] + '.norm.annot.vcf.gz.tbi'; \
        return [pro_vcf, pro_tbi];}"
    out: [renamed_files]
