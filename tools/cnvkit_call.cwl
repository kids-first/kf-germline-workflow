cwlVersion: v1.0
class: CommandLineTool
id: cnvkit-call
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'etal/cnvkit:0.9.8'
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)

baseCommand: [cnvkit.py,call]

inputs:
  input_copy_ratios: { type: 'File', inputBinding: { position: 99 }, doc: "Copy ratios (.cnr or .cns)." }
  center: { type: ['null', { type: 'enum', symbols: ["mean","median","mode","biweight"], name: "center" } ], inputBinding: { prefix: "--center" }, doc: "Re-center the log2 ratio values using this estimator of the center or average value. ('median' if no argument given.)" }
  center_at: { type: 'float?', inputBinding: { prefix: "--center-at" }, doc: "Subtract a constant number from all log2 ratios. For 'manual' re-centering, in case the --center option gives unsatisfactory results." }
  filter: { type: ['null', { type: 'enum', symbols: ["ampdel","cn","ci","sem"], name: "filter" } ], inputBinding: { prefix: "--filter" }, doc: "Merge segments flagged by the specified filter(s) with the adjacent segment(s)." }
  calling_method: { type: ['null', { type: 'enum', symbols: ["threshold","clonal","none"], name: "calling_method" } ], inputBinding: { prefix: "--method" }, doc: "Calling method. [Default: threshold]" }
  thresholds: { type: 'string?', inputBinding: { prefix: "--thresholds=", separate: false }, doc: "Hard thresholds for calling each integer copy number, separated by commas (e.g. -1,0,1). [Default: -1.1,-0.25,0.2,0.7]" }
  ploidy: { type: 'int?', inputBinding: { prefix: "--ploidy" }, doc: "Ploidy of the sample cells. [Default: 2]" }
  purity: { type: 'int?', inputBinding: { prefix: "--purity" }, doc: "Estimated tumor cell fraction, a.k.a. purity or cellularity." }
  drop_low_coverage: { type: 'boolean?', inputBinding: { prefix: "--drop-low-coverage" }, doc: "Drop very-low-coverage bins before segmentation to avoid false-positive deletions in poor-quality tumor samples." }
  sample_sex: { type: ['null', { type: 'enum', symbols: ["male","female"], name: "sample_sex" } ], inputBinding: { prefix: "--sample-sex" }, doc: "Specify the sample's chromosomal sex as male or female. (Otherwise guessed from X and Y coverage)." }
  male_ref: { type: 'boolean?', inputBinding: { prefix: "--male-reference" }, doc: "Use or assume a male reference" }
  output_filename: { type: 'string?', inputBinding: { prefix: "--output" }, doc: "Output table file name (CNR-like table of segments, .cns)." }

  # Options to additionally process SNP b-allele frequencies for allelic copy number
  input_b_allele: { type: 'File?', inputBinding: { prefix: "--vcf" }, secondaryFiles: [.tbi], doc: "VCF file name containing variants for calculation of b-allele frequencies." }
  sample_id: { type: 'string?', inputBinding: { prefix: "--sample-id" }, doc: "Name of the sample in the VCF (-v/--vcf) to use for b-allele frequency extraction." }
  normal_id: { type: 'string?', inputBinding: { prefix: "--normal-id" }, doc: "Corresponding normal sample ID in the input VCF (-v/--vcf). This sample is used to select only germline SNVs to calculate b-allele frequencies." }
  min_variant_depth: { type: 'int?', inputBinding: { prefix: "--min-variant-depth" }, doc: "Minimum read depth for a SNV to be used in the b-allele frequency calculation. [Default: 20]" }
  zygosity_freq: { type: 'float?', inputBinding: { prefix: "--zygosity-freq" }, doc: "Ignore VCF's genotypes (GT field) and instead infer zygosity from allele frequencies. [Default if used without a number: 0.25]" }

  # Resource Control
  cpu: { type: 'int?', default: 16, doc: "CPU cores to allocate to this task" }
  ram: { type: 'int?', default: 32, doc: "GB of RAM to allocate to this task" }

outputs:
  output:
    type: 'File'
    outputBinding:
      glob: '$(inputs.output_filename ? inputs.output_filename : "*.call.cns")'
    doc: "Called copy number variants from segmented log2 ratios"
