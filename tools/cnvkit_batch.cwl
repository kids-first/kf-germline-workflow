cwlVersion: v1.0
class: CommandLineTool
id: cnvkit-batch
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'etal/cnvkit:0.9.8'
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing: [$(inputs.cn_reference)]

baseCommand: [cnvkit.py,batch]

inputs:
  input_bam: { type: 'File[]?', inputBinding: { position: 99 }, secondaryFiles: [.bai], doc: "Mapped sequence reads" }
  input_cram: { type: 'File[]?', inputBinding: { position: 99 }, secondaryFiles: [.crai], doc: "Mapped sequence reads" }
  sequencing_method: { type: ['null', { type: enum, symbols: ["hybrid","amplicon","wgs"], name: "sequencing_method" } ], inputBinding: { prefix: "--seq-method" }, doc: "Sequencing assay type: hybridization capture ('hybrid'), targeted amplicon sequencing ('amplicon'), or whole genome sequencing ('wgs'). Determines whether and how to use antitarget bins. [Default: hybrid]" }
  segmentation_method: { type: ['null', { type: enum, symbols: ["cbs","flasso","haar","none","hmm","hmm-tumor","hmm-germline"], name: "segmentation_method" } ], inputBinding: { prefix: "--segment-method" }, doc: "Method used in the 'segment' step. [Default: cbs]" }
  male_ref: { type: boolean?, inputBinding: { prefix: "--male-reference" }, doc: "Use or assume a male reference" }
  count_reads: { type: boolean?, inputBinding: { prefix: "--count-reads" }, doc: "Get read depths by counting read midpoints within each bin." }
  drop_low_coverage: { type: boolean?, inputBinding: { prefix: "--drop-low-coverage" }, doc: "Drop very-low-coverage bins before segmentation to avoid false-positive deletions in poor-quality tumor samples." }

  # Build your own Copy Number Reference
  input_normal_bams: { type: 'File[]?', inputBinding: { prefix: "--normal" }, secondaryFiles: [.bai], doc: "Normal samples (.bam) used to construct the pooled, paired, or flat reference. If this option is used but no filenames are given, a 'flat' reference will be built. Otherwise, all filenames following this option will be used." }
  input_normal_crams: { type: 'File[]?', inputBinding: { prefix: "--normal" }, secondaryFiles: [.crai], doc: "Normal samples (.bam) used to construct the pooled, paired, or flat reference. If this option is used but no filenames are given, a 'flat' reference will be built. Otherwise, all filenames following this option will be used." }
  reference_fasta: { type: 'File?', inputBinding: { prefix: "--fasta" }, secondaryFiles: [.fai], doc: "Reference genome, FASTA format; needed if cnv kit cnn not already built" }
  targets_file: { type: 'File?', inputBinding: { prefix: "--targets" }, doc: "Target intervals (.bed or .list)" }
  antitargets_file: { type: 'File?', inputBinding: { prefix: "--antitargets" }, doc: "Antitarget intervals (.bed or .list)" }
  annotation_file: { type: 'File?', inputBinding: { prefix: "--annotate" }, doc: "Use gene models from this file to assign names to the target regions. Format: UCSC refFlat.txt or ensFlat.txt file (preferred), or BED, interval list, GFF, or similar." }
  short_names: { type: 'boolean?', inputBinding: { prefix: "--short-names" }, doc: "Reduce multi-accession bait labels to be short and consistent." }
  accessible_regions: { type: 'File?', inputBinding: { prefix: "--access" }, doc: "Regions of accessible sequence on chromosomes (.bed), as output by the 'access' command." }
  target_average_size: { type: 'int?', inputBinding: { prefix: "--target-avg-size" }, doc: "Average size of split target bins (results are approximate)." }
  antitarget_average_size: { type: 'int?', inputBinding: { prefix: "--antitarget-avg-size" }, doc: "Average size of antitarget bins (results are approximate)." }
  antitarget_minimum_size: { type: 'int?', inputBinding: { prefix: "--antitarget-min-size" }, doc: "Minimum size of antitarget bins (smaller regions are dropped)." }
  output_reference: { type: 'string?', inputBinding: { prefix: "--output-reference" }, doc: "Output filename/path for the new reference file being created." }
  cluster: { type: 'boolean?', inputBinding: { prefix: "--cluster" }, doc: "Calculate and use cluster-specific summary stats in the reference pool to normalize samples." }

  # Reuse and existing Copy Number Reference
  cn_reference: { type: 'File?', inputBinding: { prefix: "--reference" }, doc: "Copy number reference file (.cnn)." }

  # Additional Outputs
  scatter_plot: { type: 'boolean?', inputBinding: { prefix: "--scatter" }, doc: "Create a whole-genome copy ratio profile as a PDF scatter plot." }
  diagram_plot: { type: 'boolean?', inputBinding: { prefix: "--diagram" }, doc: "Create an ideogram of copy ratios on chromosomes as a PDF." }

  # Resource Control
  cpu: { type: int?, inputBinding: { prefix: "--processes" }, default: 16, doc: "Number of subprocesses used to running each of the BAM files in parallel. Without an argument, use the maximum number of available CPUs." }
  ram: { type: int?, default: 32, doc: "GB of RAM to allocate to this task" }

outputs:
  output_cnr:
    type: 'File[]?'
    outputBinding:
      glob: '*.cnr'
    doc: "Per-sample CNR file"
  output_filtered_calls:
    type: 'File[]?'
    outputBinding:
      glob: '*.call.cns'
    doc: "Per-sample filtered CNS file"
  output_bintest:
    type: 'File[]?'
    outputBinding:
      glob: '*.bintest.cns'
    doc: "Binned filtered CNS file"
  output_cnn:
    type: 'File'
    outputBinding:
      glob: '$(inputs.cn_refernce ? inputs.cn_reference.basename : inputs.output_reference ? inputs.output_reference : "*reference.cnn")'
    doc: "Returns the cnn"
  output_scatter:
    type: 'File[]?'
    outputBinding:
      glob: '*scatter.png'
    doc: "Per-sample PNG scatter plot of copy ratios."
  output_diagram:
    type: 'File[]?'
    outputBinding:
      glob: '*diagram.pdf'
    doc: "Per-sample ideogram of copy ratios on chromosomes as a PDF."
