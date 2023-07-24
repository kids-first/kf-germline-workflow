cwlVersion: v1.2
class: Workflow
id: kfdrc-germline-snv-wf
label: Kids First DRC Germline Single Nucleotide Variant Workflow
doc: |
  Germline Single Nucleotide Variant (SNV) Workflow
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: StepInputExpressionRequirement
inputs:
  # Required
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
  output_basename: {type: 'string', doc: "String to use as the base for output filenames"}
  biospecimen_name: {type: 'string', doc: "String name of biospcimen"}
  input_reads: {type: 'File', secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}], doc: "Aligned reads files to be analyzed", "sbg:fileTypes": "BAM,CRAM"}
  input_gvcf: {type: 'File?', secondaryFiles: [{pattern: '.tbi', required: true}], doc: "gVCF associated with input_reads. Providing this value will skip gVCF creation for the GATK pipeline.", "sbg:fileTypes": "VCF.GZ"}

  # Regions of Interest
  calling_regions: { type: 'File', doc: "File, in BED or INTERVALLIST format, containing a set of genomic regions over which variants will be called.", "sbg:suggestedValue": {class: File, path: 60639018357c3a53540ca7df, name: wgs_calling_regions.hg38.interval_list} }
  unpadded_intervals_file: {type: File, doc: "Handcurated intervals over which the gVCF will be genotyped to create a VCF.", "sbg:suggestedValue": {class: File, path: 5f500135e4b0370371c051b1, name: hg38.even.handcurated.20k.intervals}}
  wgs_evaluation_interval_list: {type: File, doc: 'wgs_evaluation_regions.hg38.interval_list', "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}

  # Scatter regions
  break_bands_at_multiples_of: { type: 'int?', default: 1000000, doc: "If set to a positive value will create a new interval list with the original intervals broken up at integer multiples of this value. Set to 0 to NOT break up intervals." }
  scatter_count: { type: 'int?', default: 50, doc: "Total number of scatter intervals and beds to make" }
  subdivision_mode:
    type:
      - 'null'
      - type: enum
        name: subdivision_mode
        symbols: [ "INTERVAL_SUBDIVISION", "BALANCING_WITHOUT_INTERVAL_SUBDIVISION", "BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW", "INTERVAL_COUNT", "INTERVAL_COUNT_WITH_DISTRIBUTED_REMAINDER" ]
    default: "BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW"
    doc: |
      The mode used to scatter the interval list:
      - INTERVAL_SUBDIVISION (Scatter the interval list into similarly sized interval
        lists (by base count), breaking up intervals as needed.)
      - BALANCING_WITHOUT_INTERVAL_SUBDIVISION (Scatter the interval list into
        similarly sized interval lists (by base count), but without breaking up
        intervals.)
      - BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW (Scatter the interval
        list into similarly sized interval lists (by base count), but without
        breaking up intervals. Will overflow current interval list so that the
        remaining lists will not have too many bases to deal with.)
      - INTERVAL_COUNT (Scatter the interval list into similarly sized interval lists
        (by interval count, not by base count). Resulting interval lists will contain
        the same number of intervals except for the last, which contains the
        remainder.)
      - INTERVAL_COUNT_WITH_DISTRIBUTED_REMAINDER (Scatter the interval list into
        similarly sized interval lists (by interval count, not by base count).
        Resulting interval lists will contain similar number of intervals.)

  # GATK
  contamination: {type: 'float?', doc: "Precalculated contamination value. Providing the value here will skip the run of VerifyBAMID and use the provided value as ground truth."}
  contamination_sites_bed: {type: 'File', doc: ".bed file for markers used in this analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)", "sbg:suggestedValue": { class: File, path: 6063901e357c3a53540ca833, name: Homo_sapiens_assembly38.contam.bed}}
  contamination_sites_mu: {type: 'File', doc: ".mu matrix file of genotype matrix", "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7cd, name: Homo_sapiens_assembly38.contam.mu}}
  contamination_sites_ud: {type: 'File', doc: ".UD matrix file from SVD result of genotype matrix", "sbg:suggestedValue": {class: File, path: 6063901f357c3a53540ca84f, name: Homo_sapiens_assembly38.contam.UD}}

  axiomPoly_resource_vcf: {type: File, secondaryFiles: [{ pattern: '.tbi', required: true }], doc: 'Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz', "sbg:suggestedValue": {class: File, path: 60639016357c3a53540ca7c7, name: Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz, secondaryFiles: [{class: File, path: 6063901d357c3a53540ca81b, name: Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz.tbi}]}}
  dbsnp_vcf: {type: File, doc: 'Homo_sapiens_assembly38.dbsnp138.vcf', secondaryFiles: [{ pattern: '.idx', required: true }], "sbg:suggestedValue": { class: File, path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf, secondaryFiles: [{class: File, path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}]}}
  hapmap_resource_vcf: {type: File, secondaryFiles: [{ pattern: '.tbi', required: true }], doc: 'Hapmap genotype SNP input vcf', "sbg:suggestedValue": { class: File, path: 60639016357c3a53540ca7be, name: hapmap_3.3.hg38.vcf.gz, secondaryFiles: [{class: File, path: 60639016357c3a53540ca7c5, name: hapmap_3.3.hg38.vcf.gz.tbi}]}}
  mills_resource_vcf: {type: File, secondaryFiles: [{ pattern: '.tbi', required: true }], doc: 'Mills_and_1000G_gold_standard.indels.hg38.vcf.gz', "sbg:suggestedValue": {class: File, path: 6063901a357c3a53540ca7f3, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz, secondaryFiles: [{class: File, path: 6063901c357c3a53540ca806, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi}]}}
  omni_resource_vcf: {type: File, secondaryFiles: [{ pattern: '.tbi', required: true }], doc: '1000G_omni2.5.hg38.vcf.gz', "sbg:suggestedValue": { class: File, path: 6063901e357c3a53540ca835, name: 1000G_omni2.5.hg38.vcf.gz, secondaryFiles: [{class: File, path: 60639016357c3a53540ca7b1, name: 1000G_omni2.5.hg38.vcf.gz.tbi}]}}
  one_thousand_genomes_resource_vcf: {type: File, secondaryFiles: [{ pattern: '.tbi', required: true }], doc: '1000G_phase1.snps.high_confidence.hg38.vcf.gz, high confidence snps', "sbg:suggestedValue": {class: File, path: 6063901c357c3a53540ca80f, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz, secondaryFiles: [{class: File, path: 6063901e357c3a53540ca845, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi}]}}

  ped: {type: File, doc: 'Ped file for the family relationship'}
  snp_max_gaussians: {type: 'int?', doc: "Interger value for max gaussians in SNP\
      \ VariantRecalibration. If a dataset gives fewer variants than the expected\
      \ scale, the number of Gaussians for training should be turned down. Lowering\
      \ the max-Gaussians forces the program to group variants into a smaller number\
      \ of clusters, which results in more variants per cluster."}
  indel_max_gaussians: {type: 'int?', doc: "Interger value for max gaussians in INDEL\
      \ VariantRecalibration. If a dataset gives fewer variants than the expected\
      \ scale, the number of Gaussians for training should be turned down. Lowering\
      \ the max-Gaussians forces the program to group variants into a smaller number\
      \ of clusters, which results in more variants per cluster."}

  # Annotation
  bcftools_annot_gnomad_columns: {type: 'string?', doc: "csv string of columns from\
      \ annotation to port into the input vcf, i.e", default: "INFO/gnomad_3_1_1_AC:=INFO/AC,INFO/gnomad_3_1_1_AN:=INFO/AN,INFO/gnomad_3_1_1_AF:=INFO/AF,INFO/gnomad_3_1_1_nhomalt:=INFO/nhomalt,INFO/gnomad_3_1_1_AC_popmax:=INFO/AC_popmax,INFO/gnomad_3_1_1_AN_popmax:=INFO/AN_popmax,INFO/gnomad_3_1_1_AF_popmax:=INFO/AF_popmax,INFO/gnomad_3_1_1_nhomalt_popmax:=INFO/nhomalt_popmax,INFO/gnomad_3_1_1_AC_controls_and_biobanks:=INFO/AC_controls_and_biobanks,INFO/gnomad_3_1_1_AN_controls_and_biobanks:=INFO/AN_controls_and_biobanks,INFO/gnomad_3_1_1_AF_controls_and_biobanks:=INFO/AF_controls_and_biobanks,INFO/gnomad_3_1_1_AF_non_cancer:=INFO/AF_non_cancer,INFO/gnomad_3_1_1_primate_ai_score:=INFO/primate_ai_score,INFO/gnomad_3_1_1_splice_ai_consequence:=INFO/splice_ai_consequence"}
  bcftools_annot_clinvar_columns: {type: 'string?', doc: "csv string of columns from\
      \ annotation to port into the input vcf", default: "INFO/ALLELEID,INFO/CLNDN,INFO/CLNDNINCL,INFO/CLNDISDB,INFO/CLNDISDBINCL,INFO/CLNHGVS,INFO/CLNREVSTAT,INFO/CLNSIG,INFO/CLNSIGCONF,INFO/CLNSIGINCL,INFO/CLNVC,INFO/CLNVCSO,INFO/CLNVI"}
  gnomad_annotation_vcf: {type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: true }], doc: "additional\
      \ bgzipped annotation vcf file", "sbg:suggestedValue": {class: File, path: 6324ef5ad01163633daa00d8,
      name: gnomad_3.1.1.vwb_subset.vcf.gz, secondaryFiles: [{class: File, path: 6324ef5ad01163633daa00d7,
          name: gnomad_3.1.1.vwb_subset.vcf.gz.tbi}]}}
  clinvar_annotation_vcf: {type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: true }], doc: "additional\
      \ bgzipped annotation vcf file", "sbg:suggestedValue": {class: File, path: 632c6cbb2a5194517cff1593,
      name: clinvar_20220507_chr.vcf.gz, secondaryFiles: [{class: File, path: 632c6cbb2a5194517cff1592,
          name: clinvar_20220507_chr.vcf.gz.tbi}]}}

  # VEP-specific
  vep_buffer_size: {type: 'int?', default: 100000, doc: "Increase or decrease to balance\
      \ speed and memory usage"}
  vep_cache: {type: 'File', doc: "tar gzipped cache from ensembl/local converted cache",
    "sbg:suggestedValue": {class: File, path: 6332f8e47535110eb79c794f, name: homo_sapiens_merged_vep_105_indexed_GRCh38.tar.gz}}
  dbnsfp: {type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: true }, { pattern: '^.readme.txt', required: true }], doc: "VEP-formatted\
      \ plugin file, index, and readme file containing dbNSFP annotations", "sbg:suggestedValue": {
      class: File, path: 63d97e944073196d123db264, name: dbNSFP4.3a_grch38.gz, secondaryFiles: [
        {class: File, path: 63d97e944073196d123db262, name: dbNSFP4.3a_grch38.gz.tbi},
        {class: File, path: 63d97e944073196d123db263, name: dbNSFP4.3a_grch38.readme.txt}]}}
  dbnsfp_fields: {type: 'string?', doc: "csv string with desired fields to annotate.\
      \ Use ALL to grab all", default: 'SIFT4G_pred,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,VEST4_score,VEST4_rankscore,MetaSVM_pred,MetaLR_pred,MetaRNN_pred,M-CAP_pred,REVEL_score,REVEL_rankscore,PrimateAI_pred,DEOGEN2_pred,BayesDel_noAF_pred,ClinPred_pred,LIST-S2_pred,Aloft_pred,fathmm-MKL_coding_pred,fathmm-XF_coding_pred,Eigen-phred_coding,Eigen-PC-phred_coding,phyloP100way_vertebrate,phyloP100way_vertebrate_rankscore,phastCons100way_vertebrate,phastCons100way_vertebrate_rankscore,TWINSUK_AC,TWINSUK_AF,ALSPAC_AC,ALSPAC_AF,UK10K_AC,UK10K_AF,gnomAD_exomes_controls_AC,gnomAD_exomes_controls_AN,gnomAD_exomes_controls_AF,gnomAD_exomes_controls_nhomalt,gnomAD_exomes_controls_POPMAX_AC,gnomAD_exomes_controls_POPMAX_AN,gnomAD_exomes_controls_POPMAX_AF,gnomAD_exomes_controls_POPMAX_nhomalt,Interpro_domain,GTEx_V8_gene,GTEx_V8_tissue'}
  merged: {type: 'boolean?', doc: "Set to true if merged cache used", default: true}
  cadd_indels: {type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: true }], doc: "VEP-formatted plugin\
      \ file and index containing CADD indel annotations", "sbg:suggestedValue": {
      class: File, path: 632a2b417535110eb78312a6, name: CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz,
      secondaryFiles: [{class: File, path: 632a2b417535110eb78312a5, name: CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz.tbi}]}}
  cadd_snvs: {type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: true }], doc: "VEP-formatted plugin file\
      \ and index containing CADD SNV annotations", "sbg:suggestedValue": {class: File,
      path: 632a2b417535110eb78312a4, name: CADDv1.6-38-whole_genome_SNVs.tsv.gz,
      secondaryFiles: [{class: File, path: 632a2b417535110eb78312a3, name: CADDv1.6-38-whole_genome_SNVs.tsv.gz.tbi}]}}
  intervar: {type: 'File?', doc: "Intervar vcf-formatted file. Exonic SNVs only -\
      \ for more comprehensive run InterVar. See docs for custom build instructions",
    secondaryFiles: [{ pattern: '.tbi', required: true }], "sbg:suggestedValue": {class: File, path: 633348619968f3738e4ec4b5,
      name: Exons.all.hg38.intervar.2021-07-31.vcf.gz, secondaryFiles: [{class: File,
          path: 633348619968f3738e4ec4b6, name: Exons.all.hg38.intervar.2021-07-31.vcf.gz.tbi}]}}

  # Resource Requirements
  vep_ram: {type: 'int?', default: 32, doc: "In GB, may need to increase this value depending on the size/complexity of input"}
  vep_cpu: {type: 'int?', default: 16, doc: "Number of cores to use. May need to increase for really large inputs"}
  freebayes_cpu: {type: 'int?', doc: "CPUs to allocate to freebayes"}
  freebayes_ram: {type: 'int?', doc: "RAM in GB to allocate to freebayes"}
  strelka2_cpu: { type: 'int?', default: 32, doc: "Number of cores to allocate to this task." }
  strelka2_ram: { type: 'int?', default: 64, doc: "GB of memory to allocate to this task." }

  # Conditionals
  run_gatk: { type: 'boolean?', default: true, doc: "Run the GATK module?" }
  run_freebayes: { type: 'boolean?', default: true, doc: "Run the Freebayes module?" }
  run_strelka: { type: 'boolean?', default: true, doc: "Run the Strelka module?" }

outputs:
  gatk_gvcf: { type: 'File', doc: "gVCF created by GATK HaplotypeCaller", outputSource: bam_to_gvcf/gvcf }
  gatk_gvcf_metrics: { type: 'File[]?', doc: "Metrics for GATK HaplotypeCaller gVCF", outputSource: bam_to_gvcf/gvcf_calling_metrics }
  verifybamid_output: { type: 'File', doc: "VerifyBAMID output, including contamination score", outputSource: bam_to_gvcf/verifybamid_output }
  gatk_vcf_metrics: {type: 'File[]', doc: 'Variant calling summary and detailed metrics files', outputSource: single_sample_genotyping/collectvariantcallingmetrics}
  peddy_html: {type: 'File[]', doc: 'html summary of peddy results', outputSource: single_sample_genotyping/peddy_html}
  peddy_csv: {type: 'File[]', doc: 'csv details of peddy results', outputSource: single_sample_genotyping/peddy_csv}
  peddy_ped: {type: 'File[]', doc: 'ped format summary of peddy results', outputSource: single_sample_genotyping/peddy_ped}
  freebayes_unfiltered_vcf: {type: 'File', outputSource: freebayes/unfiltered_vcf}
  strelka2_prepass_variants: {type: 'File', outputSource: strelka2/prepass_variants_vcf}
  strelka2_gvcfs: {type: 'File[]', outputSource: strelka2/genome_vcfs}
  vep_annotated_gatk_vcf: {type: 'File[]', outputSource: single_sample_genotyping/vep_annotated_vcf}
  vep_annotated_freebayes_vcf: {type: 'File[]', outputSource: freebayes/annotated_filtered_vcf}
  vep_annotated_strelka_vcf: {type: 'File[]', outputSource: strelka2/annotated_pass_variants_vcf}

steps:
  file_to_file_array:
    run: ../tools/file_to_file_array.cwl
    when: $(inputs.run_freebayes || inputs.run_strelka)
    in:
      run_freebayes: run_freebayes
      run_strelka: run_strelka
      in_file: input_reads
    out: [out_file_array]
  samtools_view:
    run: ../tools/samtools_view.cwl
    when: $(inputs.input_reads.nameext == '.cram' && inputs.run_gatk)
    in:
      run_gatk: run_gatk
      input_reads: input_reads
      reference_fasta: indexed_reference_fasta
      output_bam:
        valueFrom: $(1 == 1)
      write_index:
        valueFrom: $(1 == 1)
      output_filename:
        valueFrom: |
          $(inputs.input_reads.nameroot).bam##idx##$(inputs.input_reads.nameroot).bam.bai
      cpu:
        valueFrom: $(8)
      ram:
        valueFrom: $(16)
    out: [output]
  gatk_intervallisttobed:
    run: ../tools/gatk_intervallisttobed.cwl
    when: $(inputs.input_intervallist.nameext == '.interval_list' && inputs.run_strelka)
    in:
      run_strelka: run_strelka
      input_intervallist: calling_regions
      output_filename:
        valueFrom: $(inputs.input_intervallist.nameroot).bed
    out: [output]
  bgzip_tabix:
    run: ../tools/bgzip_tabix.cwl
    when: $(inputs.input_file.nameext == '.bed' && inputs.run_strelka)
    in:
      run_strelka: run_strelka
      input_file:
        source: [gatk_intervallisttobed/output, calling_regions]
        pickValue: first_non_null
      output_filename:
        valueFrom: $(inputs.input_file.basename).gz
      preset:
        valueFrom: "bed"
    out: [output]
  boolean_to_boolean_scatter:
    run: ../tools/boolean_to_boolean.cwl
    in:
      in_bool:
        source: [run_gatk, run_freebayes]
        valueFrom: $(self[0] || self[1])
    out: [out_bool]
  scatter_regions:
    run: ../subworkflows/scatter_regions.cwl
    when: $(inputs.run_scatter_regions)
    in:
      run_scatter_regions: boolean_to_boolean_scatter/out_bool
      input_regions: calling_regions
      reference_dict:
        source: indexed_reference_fasta
        valueFrom: |
          $(self ? self.secondaryFiles.filter(function(e) { return e.nameext == '.dict' })[0] : self)
      break_bands_at_multiples_of: break_bands_at_multiples_of
      scatter_count: scatter_count
      subdivision_mode: subdivision_mode
    out: [scattered_intervallists, scattered_beds]
  freebayes:
    run: ../subworkflows/freebayes.cwl
    when: $(inputs.run_freebayes)
    in:
      run_freebayes: run_freebayes
      input_reads: file_to_file_array/out_file_array
      indexed_reference_fasta: indexed_reference_fasta
      scattered_calling_beds: scatter_regions/scattered_beds
      output_basename: output_basename
      bcftools_annot_gnomad_columns: bcftools_annot_gnomad_columns
      bcftools_annot_clinvar_columns: bcftools_annot_clinvar_columns
      gnomad_annotation_vcf: gnomad_annotation_vcf
      clinvar_annotation_vcf: clinvar_annotation_vcf
      vep_buffer_size: vep_buffer_size
      vep_cache: vep_cache
      dbnsfp: dbnsfp
      dbnsfp_fields: dbnsfp_fields
      merged: merged
      cadd_indels: cadd_indels
      cadd_snvs: cadd_snvs
      intervar: intervar
      vep_ram: vep_ram
      vep_cores: vep_cpu
      freebayes_cpu: freebayes_cpu
      freebayes_ram: freebayes_ram
    out: [unfiltered_vcf, annotated_filtered_vcf]
  strelka2:
    run: ../subworkflows/strelka2_germline.cwl
    when: $(inputs.run_strelka)
    in:
      run_strelka: run_strelka
      input_reads: file_to_file_array/out_file_array
      indexed_reference_fasta: indexed_reference_fasta
      call_regions:
        source: [bgzip_tabix/output, calling_regions]
        pickValue: first_non_null
      output_basename: output_basename
      bcftools_annot_gnomad_columns: bcftools_annot_gnomad_columns
      bcftools_annot_clinvar_columns: bcftools_annot_clinvar_columns
      gnomad_annotation_vcf: gnomad_annotation_vcf
      clinvar_annotation_vcf: clinvar_annotation_vcf
      vep_buffer_size: vep_buffer_size
      vep_cache: vep_cache
      dbnsfp: dbnsfp
      dbnsfp_fields: dbnsfp_fields
      merged: merged
      cadd_indels: cadd_indels
      cadd_snvs: cadd_snvs
      intervar: intervar
      vep_ram: vep_ram
      vep_cores: vep_cpu
      strelka2_cpu: strelka2_cpu
      strelka2_ram: strelka2_ram
    out: [genome_vcfs, prepass_variants_vcf, annotated_pass_variants_vcf]
  boolean_to_boolean_gvcf:
    run: ../tools/boolean_to_boolean.cwl
    in:
      in_bool:
        source: [run_gatk, input_gvcf]
        valueFrom: $(self[0] && self[1] == null)
    out: [out_bool]
  bam_to_gvcf:
    run: ../subworkflows/bam_to_gvcf.cwl
    when: $(inputs.run_gatk)
    in:
      run_gatk: boolean_to_boolean_gvcf/out_bool
      input_bam:
        source: [samtools_view/output, input_reads]
        pickValue: first_non_null
      indexed_reference_fasta: indexed_reference_fasta
      scattered_calling_interval_lists: scatter_regions/scattered_intervallists
      biospecimen_name: biospecimen_name
      contamination: contamination
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
      output_basename: output_basename
    out: [verifybamid_output, gvcf, gvcf_calling_metrics]
  file_to_file_array_gvcf:
    run: ../tools/file_to_file_array.cwl
    when: $(inputs.run_gatk)
    in:
      run_gatk: run_gatk
      in_file:
        source: [input_gvcf, bam_to_gvcf/gvcf]
        pickValue: first_non_null
    out: [out_file_array]
  single_sample_genotyping:
    run: ../workflows/kfdrc-single-sample-genotyping-wf.cwl
    when: $(inputs.run_gatk)
    in:
      run_gatk: run_gatk
      input_vcfs: file_to_file_array_gvcf/out_file_array
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_vcf: dbsnp_vcf
      hapmap_resource_vcf: hapmap_resource_vcf
      mills_resource_vcf: mills_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      ped: ped
      indexed_reference_fasta: indexed_reference_fasta
      unpadded_intervals_file: unpadded_intervals_file
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
      snp_max_gaussians: snp_max_gaussians
      indel_max_gaussians: indel_max_gaussians
      output_basename: output_basename
      tool_name:
        valueFrom: "single.vqsr.filtered.vep_105"
      bcftools_annot_gnomad_columns: bcftools_annot_gnomad_columns
      bcftools_annot_clinvar_columns: bcftools_annot_clinvar_columns
      gnomad_annotation_vcf: gnomad_annotation_vcf
      clinvar_annotation_vcf: clinvar_annotation_vcf
      vep_ram: vep_ram
      vep_cores: vep_cpu
      vep_buffer_size: vep_buffer_size
      vep_cache: vep_cache
      dbnsfp: dbnsfp
      dbnsfp_fields: dbnsfp_fields
      merged: merged
      cadd_indels: cadd_indels
      cadd_snvs: cadd_snvs
      intervar: intervar
    out: [collectvariantcallingmetrics, peddy_html, peddy_csv, peddy_ped, vep_annotated_vcf]

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 3
$namespaces:
  sbg: https://sevenbridges.com
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- ANNOTATION
- ANNOTSV
- GATK
- GERMLINE
- GVCF
- PEDDY
- SNV
- STRELKA2
- VCF
- VEP
"sbg:links":
- id: 'https://github.com/kids-first/kf-germline-workflow/releases/tag/v0.3.0'
  label: github-release
