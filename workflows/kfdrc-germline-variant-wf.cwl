cwlVersion: v1.2
class: Workflow
id: kfdrc-germline-variant-wf
label: Kids First DRC Germline Variant Workflow
doc: |
  Germline Variant (SNV, CNV, SV) Workflow
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  # Universal
  indexed_reference_fasta:
    type: 'File'
    secondaryFiles:
    - {pattern: '^.dict', required: true}
    - {pattern: '.fai', required: true}
    - {pattern: '.64.alt', required: false}
    - {pattern: '.64.amb', required: false}
    - {pattern: '.64.ann', required: false}
    - {pattern: '.64.bwt', required: false}
    - {pattern: '.64.pac', required: false}
    - {pattern: '.64.sa', required: false}
    - {pattern: '.alt', required: false}
    - {pattern: '.amb', required: false}
    - {pattern: '.ann', required: false}
    - {pattern: '.bwt', required: false}
    - {pattern: '.pac', required: false}
    - {pattern: '.sa', required: false}
    doc: |
      The reference genome fasta (and associated indicies) to which the germline BAM was aligned.
    "sbg:fileTypes": "FASTA, FA"
    "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [{class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict},
        {class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai},
        {class: File, path: 60639019357c3a53540ca7eb, name: Homo_sapiens_assembly38.fasta.64.alt},
        {class: File, path: 6063901f357c3a53540ca84d, name: Homo_sapiens_assembly38.fasta.64.amb},
        {class: File, path: 6063901f357c3a53540ca849, name: Homo_sapiens_assembly38.fasta.64.ann},
        {class: File, path: 6063901d357c3a53540ca81e, name: Homo_sapiens_assembly38.fasta.64.bwt},
        {class: File, path: 6063901c357c3a53540ca801, name: Homo_sapiens_assembly38.fasta.64.pac},
        {class: File, path: 60639015357c3a53540ca7a9, name: Homo_sapiens_assembly38.fasta.64.sa}]}
  aligned_reads: {type: 'File', secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}], doc: "Aligned Reads file(s) from which Germline Variants will be discovered", "sbg:fileTypes": "BAM, CRAM"}
  output_basename: {type: 'string', doc: "String value to use for the basename of all outputs"}

  # Intervals
  ## CNV Preprocess intervals
  cnv_intervals_padding: {type: 'int?', doc: "Length (in bp) of the padding regions on each side\
      \ of the intervals. This must be the same value used for all case samples."}
  cnv_intervals_bin_length: {type: 'int?', doc: "Length (in bp) of the bins. If zero, no binning\
      \ will be performed."}
  cnv_intervals: {type: 'File', doc: "Picard or GATK-style interval list of regions to\
      \ process. For WGS, this should typically only include the chromosomes of interest.",
    "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, LIST"}
  cnv_blacklist_intervals: {type: 'File?', doc: "Picard or GATK-style interval list of\
      \ regions to ignore.", "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, LIST"}
  ## SNV Regions of Interest
  snv_calling_regions: { type: 'File', doc: "File, in BED or INTERVALLIST format, containing a set of genomic regions over which variants will be called.", "sbg:suggestedValue": {class: File, path: 60639018357c3a53540ca7df, name: wgs_calling_regions.hg38.interval_list} }
  snv_unpadded_intervals_file: {type: File, doc: "Handcurated intervals over which the gVCF will be genotyped to create a VCF.", "sbg:suggestedValue": {class: File, path: 5f500135e4b0370371c051b1, name: hg38.even.handcurated.20k.intervals}}
  snv_evaluation_interval_list: {type: File, doc: 'wgs_evaluation_regions.hg38.interval_list', "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  ## SNV Scatter regions
  snv_intervals_break_bands_at_multiples_of: { type: 'int?', default: 1000000, doc: "If set to a positive value will create a new interval list with the original intervals broken up at integer multiples of this value. Set to 0 to NOT break up intervals." }
  snv_intervals_scatter_count: { type: 'int?', default: 50, doc: "Total number of scatter intervals and beds to make" }
  snv_intervals_subdivision_mode:
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

  # SV
  annotsv_annotations_dir: {type: 'File', doc: "TAR.GZ'd Directory containing AnnotSV\
      \ annotations", "sbg:fileTypes": "TAR, TAR.GZ, TGZ", "sbg:suggestedValue": {
      class: File, path: 6245fde8274f85577d646da0, name: annotsv_311_annotations_dir.tgz}}
  annotsv_genome_build:
    type:
    - 'null'
    - type: enum
      name: annotsv_genome_build
      symbols: ["GRCh37", "GRCh38", "mm9", "mm10"]
    doc: |
      The genome build of the reference fasta. AnnotSV is capable of annotating the following genomes: "GRCh37","GRCh38","mm9","mm10".

  # SNV Required
  biospecimen_name: {type: 'string', doc: "String name of biospcimen"}

  # CNVnator
  cnvnator_bin_sizes: {type: 'int[]?', default: [100, 200, 300, 400, 500], doc: "Candidate bin sizes for analysis. Workflow will evaluate the bin sizes and select the best performing bin. Bin size should be equal to a whole number of 100 bases (e.g., 2500, 3700,\u2026)"}
  cnvnator_disable_gc_correction: {type: 'boolean?', doc: "Do not to use GC corrected RD signal"}

  # GATK CNV Models
  contig_ploidy_model_tar: {type: 'File', doc: "The contig-ploidy model directory generated by the DetermineGermlineContigPloidyCohortMode task in the Cohort workflow.", "sbg:fileTypes": "TAR.GZ"}
  gcnv_model_tars: {type: 'File[]', doc: "Array of tars of the contig-ploidy model directories generated by the GermlineCNVCallerCohortMode tasks in the Cohort workflow.", "sbg:fileTypes": "TAR.GZ"}

  # GATK CNV Collect read counts
  disabled_read_filters_for_collect_counts: {type: 'string[]?', doc: "Read filters to be disabled before analysis by GATK CollectReadCounts."}

  # Determine Germline Contig Ploidy
  ploidy_mapping_error_rate: {type: 'float?', doc: "Typical mapping error rate."}
  ploidy_sample_psi_scale: {type: 'float?', doc: "Prior scale of the sample-specific correction to the coverage unexplained variance."}

  # GATK Germline CNV Caller
  gcnv_p_alt: {type: 'float?', doc: "Total prior probability of alternative copy-number states (the reference copy-number is set to the contig integer ploidy)"}
  gcnv_cnv_coherence_length: {type: 'float?', doc: "Coherence length of CNV events (in the units of bp)."}
  gcnv_max_copy_number: {type: 'int?', doc: "Highest allowed copy-number state."}
  gcnv_mapping_error_rate: {type: 'float?', doc: "Typical mapping error rate."}
  gcnv_sample_psi_scale: {type: 'float?', doc: "Typical scale of sample-specific correction to the unexplained variance."}
  gcnv_depth_correction_tau: {type: 'float?', doc: "Precision of read depth pinning to its global value."}
  gcnv_copy_number_posterior_expectation_mode: {type: 'string?', doc: "The strategy for calculating copy number posterior expectations in the coverage denoising model."}
  gcnv_active_class_padding_hybrid_mode: {type: 'int?', doc: "If copy-number-posterior-expectation-mode is set to HYBRID, CNV-active intervals determined at any time will be padded by this value (in the units of bp) in order to obtain the set of intervals on which copy number posterior expectation is performed exactly."}
  gcnv_learning_rate: {type: 'float?', doc: "Adamax optimizer learning rate."}
  gcnv_adamax_beta_1: {type: 'float?', doc: "Adamax optimizer first moment estimation forgetting factor."}
  gcnv_adamax_beta_2: {type: 'float?', doc: "Adamax optimizer second moment estimation forgetting factor."}
  gcnv_log_emission_samples_per_round: {type: 'int?', doc: "Log emission samples drawn per round of sampling."}
  gcnv_log_emission_sampling_median_rel_error: {type: 'float?', doc: "Maximum tolerated median relative error in log emission sampling."}
  gcnv_log_emission_sampling_rounds: {type: 'int?', doc: "Log emission maximum sampling rounds."}
  gcnv_max_advi_iter_first_epoch: {type: 'int?', doc: "Maximum ADVI iterations in the first epoch."}
  gcnv_max_advi_iter_subsequent_epochs: {type: 'int?', doc: "Maximum ADVI iterations in subsequent epochs."}
  gcnv_min_training_epochs: {type: 'int?', doc: "Minimum number of training epochs."}
  gcnv_max_training_epochs: {type: 'int?', doc: "Maximum number of training epochs."}
  gcnv_initial_temperature: {type: 'float?', doc: "Initial temperature (for DA-ADVI)."}
  gcnv_num_thermal_advi_iters: {type: 'int?', doc: "Number of thermal ADVI iterations (for DA-ADVI)."}
  gcnv_convergence_snr_averaging_window: {type: 'int?', doc: "Averaging window for calculating training signal-to-noise ratio (SNR) for convergence checking."}
  gcnv_convergence_snr_trigger_threshold: {type: 'float?', doc: "The number of ADVI iterations during which the SNR is required to stay below the set threshold for convergence."}
  gcnv_convergence_snr_countdown_window: {type: 'int?', doc: "The SNR threshold to be reached before triggering the convergence countdown."}
  gcnv_max_calling_iters: {type: 'int?', doc: "Maximum number of internal self-consistency iterations within each calling step."}
  gcnv_caller_update_convergence_threshold: {type: 'float?', doc: "Maximum tolerated calling update size for convergence."}
  gcnv_caller_internal_admixing_rate: {type: 'float?', doc: "Admixing ratio of new and old called posteriors (between 0 and 1; larger values implies using more of the new posterior and less of the old posterior) for internal convergence loops."}
  gcnv_caller_external_admixing_rate: {type: 'float?', doc: "Admixing ratio of new and old called posteriors (between 0 and 1; larger values implies using more of the new posterior and less of the old posterior) after convergence."}

  # PostprocessGermlineCNVCalls
  ref_copy_number_autosomal_contigs: {type: 'int?', doc: "Reference copy-number on autosomal intervals."}
  allosomal_contigs_args: {type: 'string[]?', doc: "Contigs to treat as allosomal (i.e. choose their reference copy-number allele according to the sample karyotype)."}

  # arguments for QC
  maximum_number_events_per_sample: {type: 'int?', default: 120, doc: "Maximum number of events threshold for doing sample QC (recommended for WES is ~100)"}

  # GATK SNV
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
  tool_name: { type: 'string?', default: "single.vqsr.filtered.vep_105", doc: "File name string suffx to use for output files" }

  # SNV Annotation
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

  # SNV VEP-specific
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
  ## CNV
  cnvnator_extract_cores: {type: 'int?', doc: "Cores to allocate to extract reads"}
  cnvnator_extract_max_memory: {type: 'int?', doc: "Max memory to allocate to extract reads"}
  cnvnator_his_cores: {type: 'int?', doc: "Cores to allocate to rd histogram generation"}
  cnvnator_his_max_memory: {type: 'int?', doc: "Max memory to allocate to rd histogram generation"}
  cnvnator_stat_cores: {type: 'int?', doc: "Cores to allocate to calculate statistics"}
  cnvnator_stat_max_memory: {type: 'int?', doc: "Max memory to allocate to calculate statistics"}
  cnvnator_eval_cores: {type: 'int?', doc: "Cores to allocate to evaluation"}
  cnvnator_eval_max_memory: {type: 'int?', doc: "Max memory to allocate to evaluation"}
  cnvnator_partition_cores: {type: 'int?', doc: "Cores to allocate to partition"}
  cnvnator_partition_max_memory: {type: 'int?', doc: "Max memory to allocate to partition"}
  cnvnator_call_cores: {type: 'int?', doc: "Cores to allocate to call"}
  cnvnator_call_max_memory: {type: 'int?', doc: "Max memory to allocate to call"}
  cnvnator_vcf_cores: {type: 'int?', doc: "Cores to allocate to vcf creation"}
  cnvnator_vcf_max_memory: {type: 'int?', doc: "Max memory to allocate to vcf creation"}
  gatk_preprocess_intervals_max_memory: {type: 'int?', doc: "GB of RAM to allocate to preprocess intervals"}
  gatk_preprocess_intervals_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for preprocess intervals"}
  gatk_collect_read_counts_max_memory: {type: 'int?', doc: "GB of RAM to allocate to collect read counts"}
  gatk_collect_read_counts_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for collect read counts"}
  gatk_dgcp_max_memory: {type: 'int?', doc: "GB of RAM to allocate to determine germline contig ploidy"}
  gatk_dgcp_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for determine germline contig ploidy"}
  gatk_scatter_intervals_max_memory: {type: 'int?', doc: "GB of RAM to allocate to scatter intervals"}
  gatk_scatter_intervals_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for scatter intervals"}
  gatk_germline_cnv_caller_max_memory: {type: 'int?', doc: "GB of RAM to allocate to gCNV caller"}
  gatk_germline_cnv_caller_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for gCNV caller"}
  gatk_postprocess_max_memory: {type: 'int?', doc: "GB of RAM to allocate to postprocess gCNV"}
  gatk_postprocess_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for postprocess gCNV"}
  gatk_collect_sample_metrics_ram: {type: 'int?', doc: "GB of RAM to allocate to collect sample metrics"}
  gatk_collect_sample_metrics_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for collect sample metrics"}
  gatk_scatter_ploidy_calls_ram: {type: 'int?', doc: "GB of RAM to allocate to scatter ploidy calls"}
  gatk_scatter_ploidy_calls_cores: {type: 'int?', doc: "Minimum reserved number of CPU cores for scatter ploidy calls"}
  ## SNV
  vep_ram: {type: 'int?', default: 32, doc: "In GB, may need to increase this value depending on the size/complexity of input"}
  vep_cpu: {type: 'int?', default: 16, doc: "Number of cores to use. May need to increase for really large inputs"}
  freebayes_cpu: {type: 'int?', doc: "CPUs to allocate to freebayes"}
  freebayes_ram: {type: 'int?', doc: "RAM in GB to allocate to freebayes"}
  strelka2_cpu: { type: 'int?', default: 32, doc: "Number of cores to allocate to this task." }
  strelka2_ram: { type: 'int?', default: 64, doc: "GB of memory to allocate to this task." }
  ## SV
  svaba_cpu: {type: 'int?', doc: "CPUs to allocate to SVaba"}
  svaba_ram: {type: 'int?', doc: "GB of RAM to allocate to SVava"}
  manta_cpu: {type: 'int?', doc: "CPUs to allocate to Manta"}
  manta_ram: {type: 'int?', doc: "GB of RAM to allocate to Manta"}

  # Conditionals
  run_gatk_gcnv: { type: 'boolean?', default: true, doc: "Run the GATK Germline CNV module?" }
  run_cnvnator: { type: 'boolean?', default: true, doc: "Run the CNVnator module?" }
  run_gatk_gsnv: { type: 'boolean?', default: true, doc: "Run the GATK Germline SNV module?" }
  run_freebayes: { type: 'boolean?', default: true, doc: "Run the Freebayes module?" }
  run_strelka: { type: 'boolean?', default: true, doc: "Run the Strelka module?" }
  run_svaba: { type: 'boolean?', default: true, doc: "Run the SVaba module?" }
  run_manta: { type: 'boolean?', default: true, doc: "Run the Manta module?" }

outputs:
  gatk_gcnv_preprocessed_intervals: {type: 'File?', outputSource: cnv/gatk_gcnv_preprocessed_intervals, doc: "Preprocessed Picard interval-list file."}
  gatk_gcnv_read_counts_entity_ids: {type: 'string[]?', outputSource: cnv/gatk_gcnv_read_counts_entity_ids, doc: "List of file basename that were processed by CollectReadCounts"}
  gatk_gcnv_read_counts: {type: 'File[]?', outputSource: cnv/gatk_gcnv_read_counts, doc: "Counts file for each normal BAM input. This workflow produces HDF5 format results."}
  gatk_gcnv_sample_contig_ploidy_calls_tars: {type: 'File[]?', outputSource: cnv/gatk_gcnv_sample_contig_ploidy_calls_tars, doc: "Per sample TAR.GZ files containing the calls directory output by DetermineGermlineContigPloidy"}
  gatk_gcnv_calls_tars: {type: ['null', {type: 'array', items: {type: 'array', items: File}}], outputSource: cnv/gatk_gcnv_calls_tars, doc: "TAR.GZ files containing the calls for each sample in each shard of GermlineCNVCaller"}
  gatk_gcnv_tracking_tars: {type: 'File[]?', outputSource: cnv/gatk_gcnv_tracking_tars, doc: "TAR.GZ files containing the tracking directory output by each shard of GermlineCNVCaller"}
  gatk_gcnv_genotyped_intervals_vcfs: {type: 'File[]?', outputSource: cnv/gatk_gcnv_genotyped_intervals_vcfs, doc: "Per sample VCF files provides a detailed listing of the most likely copy-number call for each genomic interval included in the call-set, along with call quality, call genotype, and the phred-scaled posterior probability vector for all integer copy-number states."}
  gatk_gcnv_genotyped_segments_vcfs: {type: 'File[]?', outputSource: cnv/gatk_gcnv_genotyped_segments_vcfs, doc: "Per sample VCF files containing coalesced contiguous intervals that share the same copy-number call"}
  gatk_gcnv_denoised_copy_ratios: {type: 'File[]?', outputSource: cnv/gatk_gcnv_denoised_copy_ratios, doc: "Per sample files concatenates posterior means for denoised copy ratios from all the call shards produced by the GermlineCNVCaller."}
  gatk_gcnv_sample_qc_status_files: {type: 'File[]?', outputSource: cnv/gatk_gcnv_sample_qc_status_files, doc: "Per sample files containing the sample's QC status. Either PASS or EXCESSIVE_NUMBER_OF_EVENTS as determined by maximum_number_events_per_sample input"}
  gatk_gcnv_sample_qc_status_strings: {type: 'string[]?', outputSource: cnv/gatk_gcnv_sample_qc_status_strings, doc: "String value contained within the sample_qc_status_files outputs"}
  cnvnator_vcf: {type: 'File?', outputSource: cnv/cnvnator_vcf, doc: "Called CNVs in VCF format"}
  cnvnator_called_cnvs: {type: 'File?', outputSource: cnv/cnvnator_called_cnvs, doc: "Called CNVs from aligned_reads"}
  cnvnator_average_rd: {type: 'File?', outputSource: cnv/cnvnator_average_rd, doc: "Average RD stats"}
  gatk_gvcf: { type: 'File?', doc: "gVCF created by GATK HaplotypeCaller", outputSource: snv/gatk_gvcf }
  gatk_gvcf_metrics: { type: 'File[]?', doc: "Metrics for GATK HaplotypeCaller gVCF", outputSource: snv/gatk_gvcf_metrics }
  gatk_vcf_metrics: {type: 'File[]?', doc: 'Variant calling summary and detailed metrics files', outputSource: snv/gatk_vcf_metrics}
  verifybamid_output: { type: 'File?', doc: "VerifyBAMID output, including contamination score", outputSource: snv/verifybamid_output }
  peddy_html: {type: 'File[]?', doc: 'html summary of peddy results', outputSource: snv/peddy_html}
  peddy_csv: {type: 'File[]?', doc: 'csv details of peddy results', outputSource: snv/peddy_csv}
  peddy_ped: {type: 'File[]?', doc: 'ped format summary of peddy results', outputSource: snv/peddy_ped}
  vep_annotated_gatk_vcf: {type: 'File[]?', outputSource: snv/vep_annotated_gatk_vcf}
  freebayes_merged_vcf: {type: 'File?', outputSource: snv/freebayes_merged_vcf}
  strelka2_variants: {type: 'File?', outputSource: snv/strelka2_variants}
  strelka2_gvcfs: {type: 'File[]?', outputSource: snv/strelka2_gvcfs}
  svaba_indels: {type: 'File?', outputSource: sv/svaba_indels, doc: "VCF containing INDEL variants called by SvABA"}
  svaba_svs: {type: 'File?', outputSource: sv/svaba_svs, doc: "VCF containing SV called by SvABA"}
  svaba_annotated_svs: {type: 'File?', outputSource: sv/svaba_annotated_svs, doc: "TSV containing annotated variants from the svaba_svs output"}
  manta_indels: {type: 'File?', outputSource: sv/manta_indels, doc: "VCF containing INDEL variants called by Manta"}
  manta_svs: {type: 'File?', outputSource: sv/manta_svs, doc: "VCF containing SV called by Manta"}
  manta_annotated_svs: {type: 'File?', outputSource: sv/manta_annotated_svs, doc: "TSV containing annotated variants from the manta_svs output"}

steps:
  cnv:
    run: ../workflows/kfdrc-germline-cnv-wf.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      aligned_reads: aligned_reads
      output_basename: output_basename
      cnvnator_bin_sizes: cnvnator_bin_sizes
      cnvnator_disable_gc_correction: cnvnator_disable_gc_correction
      contig_ploidy_model_tar: contig_ploidy_model_tar
      gcnv_model_tars: gcnv_model_tars
      padding: cnv_intervals_padding
      bin_length: cnv_intervals_bin_length
      intervals: cnv_intervals
      blacklist_intervals: cnv_blacklist_intervals
      disabled_read_filters_for_collect_counts: disabled_read_filters_for_collect_counts
      ploidy_mapping_error_rate: ploidy_mapping_error_rate
      ploidy_sample_psi_scale: ploidy_sample_psi_scale
      gcnv_p_alt: gcnv_p_alt
      gcnv_cnv_coherence_length: gcnv_cnv_coherence_length
      gcnv_max_copy_number: gcnv_max_copy_number
      gcnv_mapping_error_rate: gcnv_mapping_error_rate
      gcnv_sample_psi_scale: gcnv_sample_psi_scale
      gcnv_depth_correction_tau: gcnv_depth_correction_tau
      gcnv_copy_number_posterior_expectation_mode: gcnv_copy_number_posterior_expectation_mode
      gcnv_active_class_padding_hybrid_mode: gcnv_active_class_padding_hybrid_mode
      gcnv_learning_rate: gcnv_learning_rate
      gcnv_adamax_beta_1: gcnv_adamax_beta_1
      gcnv_adamax_beta_2: gcnv_adamax_beta_2
      gcnv_log_emission_samples_per_round: gcnv_log_emission_samples_per_round
      gcnv_log_emission_sampling_median_rel_error: gcnv_log_emission_sampling_median_rel_error
      gcnv_log_emission_sampling_rounds: gcnv_log_emission_sampling_rounds
      gcnv_max_advi_iter_first_epoch: gcnv_max_advi_iter_first_epoch
      gcnv_max_advi_iter_subsequent_epochs: gcnv_max_advi_iter_subsequent_epochs
      gcnv_min_training_epochs: gcnv_min_training_epochs
      gcnv_max_training_epochs: gcnv_max_training_epochs
      gcnv_initial_temperature: gcnv_initial_temperature
      gcnv_num_thermal_advi_iters: gcnv_num_thermal_advi_iters
      gcnv_convergence_snr_averaging_window: gcnv_convergence_snr_averaging_window
      gcnv_convergence_snr_trigger_threshold: gcnv_convergence_snr_trigger_threshold
      gcnv_convergence_snr_countdown_window: gcnv_convergence_snr_countdown_window
      gcnv_max_calling_iters: gcnv_max_calling_iters
      gcnv_caller_update_convergence_threshold: gcnv_caller_update_convergence_threshold
      gcnv_caller_internal_admixing_rate: gcnv_caller_internal_admixing_rate
      gcnv_caller_external_admixing_rate: gcnv_caller_external_admixing_rate
      ref_copy_number_autosomal_contigs: ref_copy_number_autosomal_contigs
      allosomal_contigs_args: allosomal_contigs_args
      maximum_number_events_per_sample: maximum_number_events_per_sample
      cnvnator_extract_cores: cnvnator_extract_cores
      cnvnator_extract_max_memory: cnvnator_extract_max_memory
      cnvnator_his_cores: cnvnator_his_cores
      cnvnator_his_max_memory: cnvnator_his_max_memory
      cnvnator_stat_cores: cnvnator_stat_cores
      cnvnator_stat_max_memory: cnvnator_stat_max_memory
      cnvnator_eval_cores: cnvnator_eval_cores
      cnvnator_eval_max_memory: cnvnator_eval_max_memory
      cnvnator_partition_cores: cnvnator_partition_cores
      cnvnator_partition_max_memory: cnvnator_partition_max_memory
      cnvnator_call_cores: cnvnator_call_cores
      cnvnator_call_max_memory: cnvnator_call_max_memory
      cnvnator_vcf_cores: cnvnator_vcf_cores
      cnvnator_vcf_max_memory: cnvnator_vcf_max_memory
      gatk_preprocess_intervals_max_memory: gatk_preprocess_intervals_max_memory
      gatk_preprocess_intervals_cores: gatk_preprocess_intervals_cores
      gatk_collect_read_counts_max_memory: gatk_collect_read_counts_max_memory
      gatk_collect_read_counts_cores: gatk_collect_read_counts_cores
      gatk_dgcp_max_memory: gatk_dgcp_max_memory
      gatk_dgcp_cores: gatk_dgcp_cores
      gatk_scatter_intervals_max_memory: gatk_scatter_intervals_max_memory
      gatk_scatter_intervals_cores: gatk_scatter_intervals_cores
      gatk_germline_cnv_caller_max_memory: gatk_germline_cnv_caller_max_memory
      gatk_germline_cnv_caller_cores: gatk_germline_cnv_caller_cores
      gatk_postprocess_max_memory: gatk_postprocess_max_memory
      gatk_postprocess_cores: gatk_postprocess_cores
      gatk_collect_sample_metrics_ram: gatk_collect_sample_metrics_ram
      gatk_collect_sample_metrics_cores: gatk_collect_sample_metrics_cores
      gatk_scatter_ploidy_calls_ram: gatk_scatter_ploidy_calls_ram
      gatk_scatter_ploidy_calls_cores: gatk_scatter_ploidy_calls_cores
      run_gatk_gcnv: run_gatk_gcnv
      run_cnvnator: run_cnvnator
    out: [ gatk_gcnv_preprocessed_intervals, gatk_gcnv_read_counts_entity_ids, gatk_gcnv_read_counts, gatk_gcnv_sample_contig_ploidy_calls_tars, gatk_gcnv_calls_tars, gatk_gcnv_tracking_tars, gatk_gcnv_genotyped_intervals_vcfs, gatk_gcnv_genotyped_segments_vcfs, gatk_gcnv_denoised_copy_ratios, gatk_gcnv_sample_qc_status_files, gatk_gcnv_sample_qc_status_strings, cnvnator_vcf, cnvnator_called_cnvs, cnvnator_average_rd ]
  snv:
    run: ../workflows/kfdrc-germline-snv-wf.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_reads: aligned_reads
      output_basename: output_basename
      biospecimen_name: biospecimen_name
      calling_regions: snv_calling_regions
      unpadded_intervals_file: snv_unpadded_intervals_file
      wgs_evaluation_interval_list: snv_evaluation_interval_list
      break_bands_at_multiples_of: snv_intervals_break_bands_at_multiples_of
      scatter_count: snv_intervals_scatter_count
      subdivision_mode: snv_intervals_subdivision_mode
      contamination: contamination
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_vcf: dbsnp_vcf
      hapmap_resource_vcf: hapmap_resource_vcf
      mills_resource_vcf: mills_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      ped: ped
      snp_max_gaussians: snp_max_gaussians
      indel_max_gaussians: indel_max_gaussians
      tool_name: tool_name
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
      vep_cpu: vep_cpu
      freebayes_cpu: freebayes_cpu
      freebayes_ram: freebayes_ram
      strelka2_cpu: strelka2_cpu
      strelka2_ram: strelka2_ram
      run_gatk: run_gatk_gsnv
      run_freebayes: run_freebayes
      run_strelka: run_strelka
    out: [ gatk_gvcf, gatk_gvcf_metrics, verifybamid_output, gatk_vcf_metrics, peddy_html, peddy_csv, peddy_ped, vep_annotated_gatk_vcf, freebayes_merged_vcf, strelka2_variants, strelka2_gvcfs ]
  sv:
    run: ../workflows/kfdrc-germline-sv-wf.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      germline_reads: aligned_reads
      output_basename: output_basename
      annotsv_annotations_dir: annotsv_annotations_dir
      annotsv_genome_build: annotsv_genome_build
      svaba_cpu: svaba_cpu
      svaba_ram: svaba_ram
      manta_cpu: manta_cpu
      manta_ram: manta_ram
      run_svaba: run_svaba
      run_manta: run_manta
    out: [ svaba_indels, svaba_svs, svaba_annotated_svs, manta_indels, manta_svs, manta_annotated_svs ]

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 4
$namespaces:
  sbg: https://sevenbridges.com
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- ANNOTATION
- ANNOTSV
- CNV
- CNVNATOR
- FREEBAYES
- GATK
- GERMLINE
- GVCF
- MANTA
- PEDDY
- STRUCTURAL
- SV
- SVABA
- SNV
- STRELKA2
- VCF
- VEP
"sbg:links":
- id: 'https://github.com/kids-first/kf-germline-workflow/releases/tag/v0.3.0'
  label: github-release
