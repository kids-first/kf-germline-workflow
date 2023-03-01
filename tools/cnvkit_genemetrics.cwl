cwlVersion: v1.0
class: CommandLineTool
id: cnvkit-genemetrics
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'etal/cnvkit:0.9.8'
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)

baseCommand: [cnvkit.py,genemetrics]

arguments:
  - position: 99
    shellQuote: false
    valueFrom: |
      1>&2

inputs:
  input_copy_ratios: { type: 'File', inputBinding: { position: 9 }, doc: "Processed sample coverage data file (*.cnr), the output of the 'fix' sub-command" }
  segment: { type: 'File?', inputBinding: { prefix: "--segment" }, doc: "Segmentation calls (.cns), the output of the 'segment' command)" }
  threshold: { type: 'float?', inputBinding: { prefix: "--threshold" }, doc: "Copy number change threshold to report a gene gain/loss. [Default: 0.2]" }
  min_probes: { type: 'int?', inputBinding: { prefix: "--min-probes" }, doc: "Minimum number of covered probes to report a gain/loss. [Default: 3]" }
  drop_low_coverage: { type: 'boolean?', inputBinding: { prefix: "--drop-low-coverage" }, doc: "Drop very-low-coverage bins before segmentation to avoid false-positive deletions in poor-quality tumor samples." }
  sample_sex: { type: ['null', { type: 'enum', symbols: ["male","female"], name: "sample_sex" } ], inputBinding: { prefix: "--sample-sex" }, doc: "Specify the sample's chromosomal sex as male or female. (Otherwise guessed from X and Y coverage)." }
  male_ref: { type: 'boolean?', inputBinding: { prefix: "--male-reference" }, doc: "Use or assume a male reference" }
  output_filename: { type: 'string', inputBinding: { prefix: "--output", position: 98 }, doc: "Output table file name" }

  # Statistics Options (NONE OF THESE DO ANYTHING YET!)
#  mean: { type: 'boolean?', inputBinding: { prefix: "--mean" }, doc: "Mean log2-ratio (unweighted)" }
#  median: { type: 'boolean?', inputBinding: { prefix: "--median" }, doc: "Median" }
#  mode: { type: 'boolean?', inputBinding: { prefix: "--mode" }, doc: "Mode (i.e. peak density of log2 ratios)" }
#  ttest: { type: 'boolean?', inputBinding: { prefix: "--ttest" }, doc: "One-sample t-test of bin log2 ratios versus 0.0" }
#  stdev: { type: 'boolean?', inputBinding: { prefix: "--stdev" }, doc: "Standard deviation" }
#  sem: { type: 'boolean?', inputBinding: { prefix: "--sem" }, doc: "Standard error of the mean" }
#  mad: { type: 'boolean?', inputBinding: { prefix: "--mad" }, doc: "Median absolute deviation (standardized)" }
#  mse: { type: 'boolean?', inputBinding: { prefix: "--mse" }, doc: "Mean squared error" }
#  iqr: { type: 'boolean?', inputBinding: { prefix: "--iqr" }, doc: "Inter-quartile range" }
#  bivar: { type: 'boolean?', inputBinding: { prefix: "--bivar" }, doc: "Tukey's biweight midvariance" }
#  ci: { type: 'boolean?', inputBinding: { prefix: "--ci" }, doc: "Confidence interval (by bootstrap)" }
#  pi: { type: 'boolean?', inputBinding: { prefix: "--pi" }, doc: "Prediction interval" }
#  alpha: { type: 'float?', inputBinding: { prefix: "--alpha" }, doc: "Level to estimate confidence and prediction intervals; use with --ci and --pi. [Default: 0.05]" }
#  bootstrap: { type: 'int?', inputBinding: { prefix: "--boostrap" }, doc: "Number of bootstrap iterations to estimate confidence interval; use with --ci. [Default: 100]" }

  # Resource Control
  cpu: { type: 'int?', default: 16, doc: "CPU cores to allocate to this task" }
  ram: { type: 'int?', default: 32, doc: "GB of RAM to allocate to this task" }

outputs:
  output:
    type: 'File'
    outputBinding:
      glob: '$(inputs.output_filename)'
    doc: "Genemetrics table identifying targeted genes with copy number gain or loss"
