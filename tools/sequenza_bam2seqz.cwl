cwlVersion: v1.2
class: CommandLineTool
id: sequenza_bam2seqz 
doc: "Process BAM and Wiggle files to produce a seqz file."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/sequenza:3.0.0'
baseCommand: [sequenza-utils, bam2seqz]
arguments:
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  # Input/Ouput Arguments
  indexed_reference:
    type: 'File?'
    doc: "Reference fasta. Required when input are BAM. Must have a .fai index file."
    secondaryFiles: [{ pattern: ".fai", required: true }]
    inputBinding:
      position: 2
      prefix: "--fasta"
  output_filename:
    type: 'string'
    doc: "Name of output file. To use gzip compression name the file ending in .gz. Default STDOUT" 
    inputBinding:
      position: 2
      prefix: "--output"
  input_wiggle:
    type: 'File'
    doc: "The GC-content wiggle file. Can be gzipped."
    inputBinding:
      position: 2
      prefix: "-gc"
  input_normal:
    type: 'File'
    doc: "BAM/pileup file from the reference/normal sample"
    secondaryFiles: [{ pattern: ".bai", required: false }, { pattern: "^.bai", required: false }]
    inputBinding:
      position: 2
      prefix: "--normal"
  input_normal2:
    type: 'File?'
    doc: "Optional BAM/pileup file used to compute the depth.normal and depth-ratio, instead of using the normal BAM."
    secondaryFiles: [{ pattern: ".bai", required: false }, { pattern: "^.bai", required: false }]
    inputBinding:
      position: 2
      prefix: "--normal2"
  input_tumor:
    type: 'File'
    doc: "BAM/pileup file from the tumor sample"
    secondaryFiles: [{ pattern: ".bai", required: false }, { pattern: "^.bai", required: false }]
    inputBinding:
      position: 2
      prefix: "--tumor"
  pileup_inputs:
    type: 'boolean?'
    doc: "Treat input files as pileups rather than BAMs."
    inputBinding:
      position: 2
      prefix: "--pileup"

  # Genotype Arguments
  hom_threshold:
    type: 'float?'
    doc: "Threshold to select homozygous positions."
    inputBinding:
      position: 2
      prefix: "--hom"
  het_threshold:
    type: 'float?'
    doc: "Threshold to select heterozygous positions."
    inputBinding:
      position: 2
      prefix: "--het"
  het_frequency:
    type: 'float?'
    doc: "Threshold of frequency in the forward strand to trust heterozygous calls."
    inputBinding:
      position: 2
      prefix: "--het_f"

  # Subset indexed files Arguments
  chromosome:
    type: 'string?'
    doc: |
      Argument to restrict the input/output to a chromosome or a chromosome region.
      Coordinate format is Name:pos .start-pos.end, eg: chr17:7565097-7590856, for a
      particular region; eg: chr17, for the entire chromosome. Chromosome names can
      checked in the BAM/pileup files and are depending on the FASTA reference used
      for alignment. Default behavior is to not selecting any chromosome.
    inputBinding:
      position: 2
      prefix: "--chromosome"

  # Quality and Format Arguments
  qlimit:
    type: 'int?'
    doc: "Minimum nucleotide quality score for inclusion in the counts."
    inputBinding:
      position: 2
      prefix: "--qlimit"
  qformat:
    type:
      - 'null'
      - type: enum
        name: qformat
        symbols: ["sanger","illumina"]
    doc: |
      Quality format, options are "sanger" or "illumina".  This will add an offset of
      33 or 64 respectively to the qlimit value. Default "sanger".

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4 
    doc: "GB size of RAM to allocate to this task."
outputs:
  seqz:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
