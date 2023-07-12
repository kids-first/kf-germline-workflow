class: CommandLineTool
cwlVersion: v1.2
id: samtools_index
doc: |-
  generate index for a BAM/CRAM file

  This index is needed when region arguments are used to limit samtools view
  and similar commands to particular regions of interest.

  When only one alignment file is being indexed, the output index filename can
  be specified via -o or as shown in the second synopsis.

  When no output filename is specified, for a CRAM file aln.cram, index file
  aln.cram.crai will be created; for a BAM file aln.bam, either aln.bam.bai or
  aln.bam.csi will be created; and for a compressed SAM file aln.sam.gz, either
  aln.sam.gz.bai or aln.sam.gz.csi will be created, depending on the index format
  selected.

  The BAI index format can handle individual chromosomes up to 512 Mbp (2^29
  bases) in length. If your input file might contain reads mapped to positions
  greater than that, you will need to use a CSI index.
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'staphb/samtools:1.17'
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.input_reads)
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      samtools index
inputs:
  # View Positional Arguments
  input_reads: { type: 'File[]', inputBinding: { position: 9 }, doc: "Input BAM/CRAM/SAM file" }
  output_filename: { type: 'string?', inputBinding: { position: 2, prefix: "-o"}, doc: "Write the output index to this file name." }

  bai: { type: 'boolean?', inputBinding: { position: 2, prefix: "-b"}, doc: "Generate BAI-format index for BAM files [default]" }
  csi: { type: 'boolean?', inputBinding: { position: 2, prefix: "-c"}, doc: "Generate CSI-format index for BAM files" }
  min_interval: { type: 'int?', inputBinding: { position: 2, prefix: "-m"}, doc: "Set minimum interval size for CSI indices to 2^INT [14]" }
  multiple_inputs: { type: 'boolean?', inputBinding: { position: 2, prefix: "-M"}, doc: "Interpret all filename arguments as files to be indexed" }

  cpu:
    type: 'int?'
    default: 8
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      prefix: "-@"
      position: 2
  ram:
    type: 'int?'
    default: 16
    doc: "GB size of RAM to allocate to this task."

outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*.*am.*'

$namespaces:
  sbg: https://sevenbridges.com
