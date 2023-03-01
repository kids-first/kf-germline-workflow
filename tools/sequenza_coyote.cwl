cwlVersion: v1.2
class: CommandLineTool
id: sequenza_coyote
doc: "Runs the custom TGEN Coyote Sequenza R script on the seqz.gz"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/sequenza:3.0.0'
  - class: InitialWorkDirRequirement
    listing:
    - entryname: sequenza.R
      writable: false
      entry:
        $include: ../scripts/sequenza.R
baseCommand: [Rscript, sequenza.R]
arguments:
  - position: 2
    prefix: '--out_dir'
    shellQuote: false
    valueFrom: |
      $(inputs.sample_name)
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  input_seqz: { type: 'File', secondaryFiles: [{pattern: '.tbi', required: true}], inputBinding: { position: 2, prefix: "--sample_input" }, doc: "Input seqz.gz file." }
  sample_name: { type: 'string', inputBinding: { position: 2, prefix: "--sample_name" }, doc: "Name of the sample." }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 64
    doc: "GB size of RAM to allocate to this task."
outputs:
  cn_bars:
    type: 'File'
    outputBinding:
      glob: "*/*CN_bars.pdf"
  cp_contours:
    type: 'File'
    outputBinding:
      glob: "*/*CP_contours.pdf"
  alt_fit:
    type: 'File'
    outputBinding:
      glob: "*/*alternative_fit.pdf"
  alt_solutions:
    type: 'File'
    outputBinding:
      glob: "*/*alternative_solutions.txt"
  chr_depths:
    type: 'File'
    outputBinding:
      glob: "*/*chromosome_depths.pdf"
  chr_view:
    type: 'File'
    outputBinding:
      glob: "*/*chromosome_view.pdf"
  confints_cp:
    type: 'File'
    outputBinding:
      glob: "*/*confints_CP.txt"
  gc_plots:
    type: 'File'
    outputBinding:
      glob: "*/*gc_plots.pdf"
  genome_view:
    type: 'File'
    outputBinding:
      glob: "*/*genome_view.pdf"
  model_fit:
    type: 'File'
    outputBinding:
      glob: "*/*model_fit.pdf"
  mutations:
    type: 'File'
    outputBinding:
      glob: "*/*mutations.txt"
  segments:
    type: 'File'
    outputBinding:
      glob: "*/*segments.txt"
  sequenza_cp_table:
    type: 'File'
    outputBinding:
      glob: "*/*sequenza_cp_table.RData"
  sequenza_extract:
    type: 'File'
    outputBinding:
      glob: "*/*sequenza_extract.RData"
  sequenza_log:
    type: 'File'
    outputBinding:
      glob: "*/*sequenza_log.txt"
  max_likelihood:
    type: 'File'
    outputBinding:
      glob: "*/*Maximum_Likelihood_plot.png"
