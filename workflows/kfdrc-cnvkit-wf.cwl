cwlVersion: v1.0
class: Workflow
id: kfdrc-cnvkit-wf
label: Kids First DRC CNVKit Workflow 
doc: |
  # Kids First DRC CNVKit Workflow 

  ![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

  ### Runtime Estimates

  ### Tips To Run:

  ## Other Resources
  - tool images: https://hub.docker.com/r/kfdrc/
  - dockerfiles: https://github.com/d3b-center/bixtools

  ![pipeline flowchart]()

requirements:
- class: ScatterFeatureRequirement
- class: SubworkflowFeatureRequirement

inputs:
  output_basename: { type: 'string', doc: "Basename to use for outputs" }

  # Batch
  input_bams: { type: 'File[]?', secondaryFiles: [.bai], doc: "Mapped sequence reads in BAM format" }
  input_crams: { type: 'File[]?', secondaryFiles: [.crai], doc: "Mapped sequence reads in CRAM format" }
  input_normal_bams: { type: 'File[]?', secondaryFiles: [.bai], doc: "Normal samples (.bam) used to construct the pooled, paired, or flat reference. If this option is used but no filenames are given, a 'flat' reference will be built. Otherwise, all filenames following this option will be used." }
  input_normal_crams: { type: 'File[]?', secondaryFiles: [.crai], doc: "Normal samples (.cram) used to construct the pooled, paired, or flat reference. If this option is used but no filenames are given, a 'flat' reference will be built. Otherwise, all filenames following this option will be used." }
  reference_fasta: { type: 'File?', secondaryFiles: [.fai], doc: "Reference genome, FASTA format; needed if cnv kit cnn not already built" }
  targets_file: { type: 'File?', doc: "Target intervals (.bed or .list)" }
  antitargets_file: { type: 'File?', doc: "Antitarget intervals (.bed or .list)" }
  annotation_file: { type: 'File?', doc: "Use gene models from this file to assign names to the target regions. Format: UCSC refFlat.txt or ensFlat.txt file (preferred), or BED, interval list, GFF, or similar." }
  cn_reference: { type: 'File?', doc: "Copy number reference file (.cnn)." }
  accessible_regions: { type: 'File?', doc: "Regions of accessible sequence on chromosomes (.bed), as output by the 'access' command." } 

  sequencing_method: { type: ['null', { type: 'enum', symbols: ["hybrid","amplicon","wgs"], name: "sequencing_method" } ], doc: "Sequencing assay type: hybridization capture ('hybrid'), targeted amplicon sequencing ('amplicon'), or whole genome sequencing ('wgs'). Determines whether and how to use antitarget bins. [Default: hybrid]" }
  segmentation_method: { type: ['null', { type: 'enum', symbols: ["cbs","flasso","haar","none","hmm","hmm-tumor","hmm-germline"], name: "segmentation_method" } ], doc: "Method used in the 'segment' step. [Default: cbs]" }
  count_reads: { type: 'boolean?', doc: "Get read depths by counting read midpoints within each bin." }
  drop_low_coverage: { type: 'boolean?', doc: "Drop very-low-coverage bins before segmentation to avoid false-positive deletions in poor-quality tumor samples." }
  short_names: { type: 'boolean?', doc: "Reduce multi-accession bait labels to be short and consistent." }
  target_average_size: { type: 'int?', doc: "Average size of split target bins (results are approximate)." }
  antitarget_average_size: { type: 'int?', doc: "Average size of antitarget bins (results are approximate)." }
  antitarget_minimum_size: { type: 'int?', doc: "Minimum size of antitarget bins (smaller regions are dropped)." }
  cluster_plot: { type: 'boolean?', doc: "Calculate and use cluster-specific summary stats in the reference pool to normalize samples." }
  scatter_plot: { type: 'boolean?', doc: "Create a whole-genome copy ratio profile as a PDF scatter plot." }
  diagram: { type: 'boolean?', doc: "Create an ideogram of copy ratios on chromosomes as a PDF." }

  # Call
  input_b_allele: { type: 'File?', secondaryFiles: [.tbi], doc: "VCF file name containing variants for calculation of b-allele frequencies." }
  center: { type: ['null', { type: 'enum', symbols: ["mean","median","mode","biweight"], name: "center" } ], doc: "Re-center the log2 ratio values using this estimator of the center or average value. ('median' if no argument given.)" }
  center_at: { type: 'float?', doc: "Subtract a constant number from all log2 ratios. For 'manual' re-centering, in case the --center option gives unsatisfactory results." }
  filter: { type: ['null', { type: 'enum', symbols: ["ampdel","cn","ci","sem"], name: "filter" } ], doc: "Merge segments flagged by the specified filter(s) with the adjacent segment(s)." }
  calling_method: { type: ['null', { type: 'enum', symbols: ["threshold","clonal","none"], name: "calling_method" } ], doc: "Calling method. [Default: threshold]" }
  thresholds: { type: 'string?', doc: "Hard thresholds for calling each integer copy number, separated by commas (e.g. -1,0,1). [Default: -1.1,-0.25,0.2,0.7]" }
  ploidy: { type: 'int?', doc: "Ploidy of the sample cells. [Default: 2]" }
  purity: { type: 'int?', doc: "Estimated tumor cell fraction, a.k.a. purity or cellularity." }
  sample_sex: { type: ['null', { type: 'enum', symbols: ["male","female"], name: "sample_sex" } ], doc: "Specify the sample's chromosomal sex as male or female. (Otherwise guessed from X and Y coverage)." }
  sample_id: { type: 'string?', doc: "Name of the sample in the VCF (-v/--vcf) to use for b-allele frequency extraction." }
  normal_id: { type: 'string?', doc: "Corresponding normal sample ID in the input VCF (-v/--vcf). This sample is used to select only germline SNVs to calculate b-allele frequencies." }
  min_variant_depth: { type: 'int?', doc: "Minimum read depth for a SNV to be used in the b-allele frequency calculation. [Default: 20]" }
  zygosity_freq: { type: 'float?', doc: "Ignore VCF's genotypes (GT field) and instead infer zygosity from allele frequencies. [Default if used without a number: 0.25]" }

  # Export Seg
  enumerate_chroms: { type: 'boolean?', doc: "Replace chromosome names with sequential integer IDs." }

  # Metrics

  # Genemetrics
  threshold: { type: 'float?', doc: "Copy number change threshold to report a gene gain/loss. [Default: 0.2]" } 
  min_probes: { type: 'int?', doc: "Minimum number of covered probes to report a gain/loss. [Default: 3]" }

  # Resource Control
  batch_cpu: { type: 'int?', default: 16, doc: "CPUs to allocate to batch task" }
  batch_ram: { type: 'int?', default: 32, doc: "RAM in GB to allocate to batch task" }
  call_cpu: { type: 'int?', default: 4, doc: "CPUs to allocate to call task" }
  call_ram: { type: 'int?', default: 8, doc: "RAM in GB to allocate to call task" }
  export_seg_cpu: { type: 'int?', default: 2, doc: "CPUs to allocate to export seg task" }
  export_seg_ram: { type: 'int?', default: 1, doc: "RAM in GB to allocate to export seg task" }
  metrics_cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to metrics task" }
  metrics_ram: { type: 'int?', default: 2, doc: "RAM in GB to allocate to metrics task" }
  genemetrics_cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to genemetrics task" }
  genemetrics_ram: { type: 'int?', default: 2, doc: "RAM in GB to allocate to genemetrics task" }

outputs:
  cnr: {type: 'File[]?', outputSource: cnvkit_batch/output_cnr}
  cnn: {type: 'File', outputSource: cnvkit_batch/output_cnn}
  cns_filtered: {type: 'File[]?', outputSource: cnvkit_batch/output_filtered_calls}
  scatter_png: {type: 'File[]?', outputSource: cnvkit_batch/output_scatter}
  diagram_pdf: {type: 'File[]?', outputSource: cnvkit_batch/output_diagram}
  cns_ballele: {type: 'File[]?', outputSource: cnvkit_call_ballele/output}
  seg: {type: 'File[]?', outputSource: cnvkit_export_seg/output}
  metrics: {type: 'File?', outputSource: cnvkit_metrics/output}
  genemetrics: {type: 'File[]?', outputSource: cnvkit_genemetrics/output}

steps:
  cnvkit_batch:
    run: ../tools/cnvkit_batch.cwl
    in:
      input_bam: input_bams
      input_cram: input_crams
      sequencing_method: sequencing_method
      segmentation_method: segmentation_method
      male_ref: { source: sample_sex, valueFrom: '$(self == "male")' }
      count_reads: count_reads
      drop_low_coverage: drop_low_coverage
      input_normal_bams: input_normal_bams
      input_normal_crams: input_normal_crams
      reference_fasta: reference_fasta
      targets_file: targets_file
      antitargets_file: antitargets_file
      annotation_file: annotation_file
      short_names: short_names
      accessible_regions: accessible_regions
      target_average_size: target_average_size
      antitarget_average_size: antitarget_average_size
      antitarget_minimum_size: antitarget_minimum_size
      output_reference: { source: output_basename, valueFrom: '$(self)_cnvkit_reference.cnn' } 
      cluster: cluster
      cn_reference: cn_reference
      scatter_plot: scatter_plot
      diagram_plot: diagram_plot
      cpu: batch_cpu
      ram: batch_ram
    out: [output_cnr,output_filtered_calls,output_bintest,output_cnn,output_scatter,output_diagram]
  cnvkit_call_ballele:
    run: ../tools/cnvkit_call.cwl
    scatter: [input_copy_ratios,output_filename]
    scatterMethod: dotproduct
    in:
      input_copy_ratios: cnvkit_batch/output_filtered_calls
      center: center
      center_at: center_at
      filter: filter
      calling_method: calling_method
      thresholds: thresholds
      ploidy: ploidy
      purity: purity
      drop_low_coverage: drop_low_coverage
      sample_sex: sample_sex 
      male_ref: { source: sample_sex, valueFrom: '$(self == "male")' }
      output_filename: { source: cnvkit_batch/output_filtered_calls, valueFrom: '$(self.nameroot).ballele_call.cns' } 
      input_b_allele: input_b_allele
      sample_id: sample_id
      normal_id: normal_id
      min_variant_depth: min_variant_depth
      zygosity_freq: zygosity_freq
      cpu: call_cpu
      ram: call_ram
    out: [output]
  cnvkit_export_seg:
    run: ../tools/cnvkit_export_seg.cwl
    scatter: [input_copy_ratios,output_filename]
    scatterMethod: dotproduct
    in:
      input_copy_ratios: cnvkit_call_ballele/output
      enumerate_chroms: enumerate_chroms
      output_filename: { source: cnvkit_call_ballele/output, valueFrom: '$(self.nameroot).seg' } 
      cpu: export_seg_cpu
      ram: export_seg_ram
    out: [output]
  cnvkit_metrics:
    run: ../tools/cnvkit_metrics.cwl
    in:
      input_coverage_files: cnvkit_batch/output_cnr
      segments: cnvkit_batch/output_filtered_calls
      drop_low_coverage: drop_low_coverage
      output_filename: { source: output_basename, valueFrom: '$(self).metrics.txt' }
      cpu: metrics_cpu
      ram: metrics_ram
    out: [output]
  cnvkit_genemetrics:
    run: ../tools/cnvkit_genemetrics.cwl
    scatter: [input_copy_ratios,output_filename]
    scatterMethod: dotproduct
    in:
      input_copy_ratios: cnvkit_batch/output_cnr
      # segment: cnvkit_batch/output_filtered_calls # not sure if we're gonna use this yet
      threshold: threshold
      min_probes: min_probes
      drop_low_coverage: drop_low_coverage
      sample_sex: sample_sex
      male_ref: { source: sample_sex, valueFrom: '$(self == "male")' } 
      output_filename: { source: cnvkit_batch/output_cnr, valueFrom: '$(self.nameroot).genemetrics.txt' } 
      cpu: genemetrics_cpu
      ram: genemetrics_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 2
sbg:license: Apache License 2.0
sbg:publisher: KFDRC
sbg:categories:
- CNN
- CNR
- CNS
- CNV 
- CNVKIT 
- GERMLINE
- SOMATIC 
