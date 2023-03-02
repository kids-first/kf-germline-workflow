cwlVersion: v1.2
class: Workflow
id: kfdrc-cnvnator-wf
label: Kids First DRC CNVnator Workflow
doc: |
  # KFDRC CNVnator Workflow

  The Kids First Data Resource Center CNVnator Workflow uses [CNVnator](https://github.com/abyzovlab/CNVnator).
  CNVnator is a tool for CNV discovery and genotyping from depth-of-coverage by mapped reads.

  This pipeline represents an update the existing CNVnator public app on Cavatica with the following steps:
  - Extract reads
  - Generate RD Histograms
  - Calculate statistics
  - Partition
  - Call
  - Generate VCF

  The pipeline can take one or more input reads files.

  ![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

  ### Runtime Estimates
  8 GB BAM: 30 min & $0.25

  ### Tips To Run

  ## Other Resources
  - dockerfiles: https://github.com/d3b-center/bixtools

requirements:
- class: ScatterFeatureRequirement

inputs:
  # Multistep
  output_basename: {type: 'string', doc: "String value to use for the basename of\
      \ all outputs"}
  calling_contigs: { type: 'File', doc: "File containing the names of contigs/chromosomes on which to perform analysis" }
  bin_size: {type: 'int', doc: "Size of bins to use for analysis. Bin size should\
      \ be equal to a whole number of 100 bases (e.g., 2500, 3700,\u2026)"}
  disable_gc_correction: {type: 'boolean?', doc: "Do not to use GC corrected RD signal"}

  # Extract
  aligned_reads: {type: 'File[]', secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}], doc: "Aligned Reads file(s) from which CNVs will be discovered", "sbg:fileTypes": "BAM, CRAM"}
  light_root: {type: 'boolean?', doc: "Create a smaller root file?"}

  # RD Histogram
  reference_fasta: {type: 'File', secondaryFiles: [{pattern: '.fai', required: true}], doc: "Reference fasta file", "sbg:suggestedValue": {
      class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta},
    "sbg:fileTypes": "FASTA, FA"}

  # Memory Control
  extract_max_memory: {type: 'int?', doc: "Max memory to allocate to extract reads"}
  his_max_memory: {type: 'int?', doc: "Max memory to allocate to rd histogram generation"}
  stat_max_memory: {type: 'int?', doc: "Max memory to allocate to calculate statistics"}
  eval_max_memory: {type: 'int?', doc: "Max memory to allocate to evaluation"}
  partition_max_memory: {type: 'int?', doc: "Max memory to allocate to partition"}
  call_max_memory: {type: 'int?', doc: "Max memory to allocate to call"}
  vcf_max_memory: {type: 'int?', doc: "Max memory to allocate to vcf creation"}
  # Core control
  extract_cores: {type: 'int?', doc: "Cores to allocate to extract reads"}
  his_cores: {type: 'int?', doc: "Cores to allocate to rd histogram generation"}
  stat_cores: {type: 'int?', doc: "Cores to allocate to calculate statistics"}
  eval_cores: {type: 'int?', doc: "Cores to allocate to evaluation"}
  partition_cores: {type: 'int?', doc: "Cores to allocate to partition"}
  call_cores: {type: 'int?', doc: "Cores to allocate to call"}
  vcf_cores: {type: 'int?', doc: "Cores to allocate to vcf creation"}

outputs:
  vcf: {type: 'File', outputSource: cnvnator2vcf/output, doc: "Called CNVs in VCF\
      \ format"}
  called_cnvs: {type: 'File', outputSource: cnvnator_call/output, doc: "Called CNVs\
      \ from aligned_reads"}
  average_rd: {type: 'File', outputSource: cnvnator_evaluation/output, doc: "Average\
      \ RD stats"}

steps:
  cnvnator_scatter_contigs:
    run: ../tools/cnvnator_scatter_contigs.cwl
    in:
      cnv_contigs: calling_contigs
    out: [scattered_contigs]
  cnvnator_extract_reads:
    run: ../tools/cnvnator_extract_reads.cwl
    in:
      input_reads: aligned_reads
      reference: reference_fasta
      chrom: cnvnator_scatter_contigs/scattered_contigs
      output_root: {source: output_basename, valueFrom: $(self).root}
      lite: light_root
      max_memory: extract_max_memory
      cpu: extract_cores
    out: [output]
  cnvnator_rd_histogram:
    run: ../tools/cnvnator_rd_histogram.cwl
    in:
      input_root: cnvnator_extract_reads/output
      bin_size: bin_size
      ref_fasta: reference_fasta
      chrom: cnvnator_scatter_contigs/scattered_contigs
      max_memory: his_max_memory
      cpu: his_cores
    out: [output]
  cnvnator_calculate_statistics:
    run: ../tools/cnvnator_calculate_statistics.cwl
    in:
      input_root: cnvnator_rd_histogram/output
      bin_size: bin_size
      max_memory: stat_max_memory
      cpu: stat_cores
    out: [output]
  cnvnator_evaluation:
    run: ../tools/cnvnator_evaluation.cwl
    in:
      input_root: cnvnator_calculate_statistics/output
      bin_size: bin_size
      max_memory: eval_max_memory
      cpu: eval_cores
    out: [output]
  cnvnator_partition:
    run: ../tools/cnvnator_partition.cwl
    in:
      input_root: cnvnator_calculate_statistics/output
      bin_size: bin_size
      disable_gc_correction: disable_gc_correction
      chrom: cnvnator_scatter_contigs/scattered_contigs
      max_memory: partition_max_memory
      cpu: partition_cores
    out: [output]
  cnvnator_call:
    run: ../tools/cnvnator_call.cwl
    in:
      input_root: cnvnator_partition/output
      bin_size: bin_size
      disable_gc_correction: disable_gc_correction
      chrom: cnvnator_scatter_contigs/scattered_contigs
      max_memory: call_max_memory
      cpu: call_cores
    out: [output]
  cnvnator2vcf:
    run: ../tools/cnvnator2vcf.cwl
    in:
      input_calls: cnvnator_call/output
      reference_name: {source: reference_fasta, valueFrom: $(self.nameroot)}
      prefix: output_basename
      max_memory: vcf_max_memory
      cpu: vcf_cores
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 2
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- BAM
- CNV
- CNVNATOR
- CRAM
- GERMLINE
- SINGLE
- VCF
