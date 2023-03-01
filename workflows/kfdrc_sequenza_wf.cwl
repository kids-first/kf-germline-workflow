cwlVersion: v1.2
class: Workflow
id: kfdrc_sequenza_wf
doc: "KFDRC Sequenza Workflow"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  # Killswitch
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }], doc: "Reference fasta with FAI index" }
  calling_contigs: { type: 'string[]?', default: ["chr1"
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false }], doc: "BAM file containing mapped reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false }], doc: "BAM file containing mapped reads from the normal sample" }
  gc_content_wiggle: { type: 'File', doc: "The GC-content wiggle file. Can be gzipped" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

  # Resource Control
  bam2seqz_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza bam2seqz." }
  bam2seqz_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza bam2seqz." }
  seqz_binning_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza seqz binning." }
  seqz_binning_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza seqz binning." }
  sequenza_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza R." }
  sequenza_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza R." }

outputs:
  seqz: { type: 'File', outputSource: sequenza_combine_seqz/output }
  small_seqz: { type: 'File', outputSource: sequenza_seqz_binning/seqz }
  cn_bars: { type: 'File', outputSource: sequenza_coyote/cn_bars }
  cp_contours: { type: 'File', outputSource: sequenza_coyote/cp_contours }
  alt_fit: { type: 'File', outputSource: sequenza_coyote/alt_fit }
  alt_solutions: { type: 'File', outputSource: sequenza_coyote/alt_solutions }
  chr_depths: { type: 'File', outputSource: sequenza_coyote/chr_depths }
  chr_view: { type: 'File', outputSource: sequenza_coyote/chr_view }
  confints_cp: { type: 'File', outputSource: sequenza_coyote/confints_cp }
  gc_plots: { type: 'File', outputSource: sequenza_coyote/gc_plots }
  genome_view: { type: 'File', outputSource: sequenza_coyote/genome_view }
  model_fit: { type: 'File', outputSource: sequenza_coyote/model_fit }
  mutations: { type: 'File', outputSource: sequenza_coyote/mutations }
  segments: { type: 'File', outputSource: sequenza_coyote/segments }
  sequenza_cp_table: { type: 'File', outputSource: sequenza_coyote/sequenza_cp_table }
  sequenza_extract: { type: 'File', outputSource: sequenza_coyote/sequenza_extract }
  sequenza_log: { type: 'File', outputSource: sequenza_coyote/sequenza_log }
  max_likelihood: { type: 'File', outputSource: sequenza_coyote/max_likelihood }

steps:
  sequenza_bam2seqz:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/sequenza_bam2seqz.cwl
    scatter: [chromosome]
    in:
      input_normal: input_normal_reads
      input_tumor: input_tumor_reads
      indexed_reference: indexed_reference_fasta
      input_wiggle: gc_content_wiggle
      chromosome: calling_contigs 
      output_filename:
        source: disable_workflow # Sinking this someplace it will do nothing
        valueFrom: $(inputs.chromosome).seqz
      cpu: bam2seqz_cpu
      ram: bam2seqz_ram
    out: [seqz]

  sequenza_combine_seqz:
    run: ../tools/sequenza_combine_seqz.cwl
    in:
      input_seqzs: sequenza_bam2seqz/seqz
      output_filename:
        source: output_basename
        valueFrom: $(self).sequenza.seqz.gz
    out: [output]

  sequenza_seqz_binning:
    run: ../tools/sequenza_seqz_binning.cwl
    in:
      input_seqz: sequenza_combine_seqz/output
      window:
        valueFrom: $(50)
      output_filename:
        source: output_basename
        valueFrom: $(self).sequenza.small.seqz.gz
      cpu: seqz_binning_cpu
      ram: seqz_binning_ram
    out: [seqz]

  sequenza_coyote:
    # This is a long running low core/high ram job. Ideally runs alone on the least costly instance.
    hints:
      - class: 'sbg:AWSInstanceType'
        value: r5.2xlarge
    run: ../tools/sequenza_coyote.cwl
    in:
      input_seqz: sequenza_seqz_binning/seqz
      sample_name: output_basename
      cpu: sequenza_cpu
      ram: sequenza_ram
    out: [cn_bars, cp_contours, alt_fit, alt_solutions, chr_depths, chr_view, confints_cp, gc_plots, genome_view, model_fit, mutations, segments, sequenza_cp_table, sequenza_extract, sequenza_log, max_likelihood]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
