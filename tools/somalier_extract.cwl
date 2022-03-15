cwlVersion: v1.2
class: CommandLineTool
id: somalier-extract
doc: "Tool to convert reads/variants file into a common sites file usable by the somalier suite"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 1000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'brentp/somalier:v0.2.15'
baseCommand: [somalier, extract]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      $(inputs.input_file.path)

inputs:
  input_file: { type: File, secondaryFiles: [ { pattern: ".bai", required: false },
    { pattern: "^.bai", required: false }, { pattern: ".crai", required: false }, { pattern: "^.crai", required: false },
    { pattern: ".tbi", required: false } ], doc: "BAM/CRAM/VCF input. BAM/CRAM recommended when available over vcf"}
  reference_fasta: { type: File, inputBinding: { prefix: "--fasta" }, secondaryFiles: [ .fai ], doc: "Reference genome used" }
  sites: { type: File, inputBinding: { prefix: "--sites" }, doc: "vcf file with common sites" }

outputs:
  somalier_output:
    type: File
    outputBinding:
      glob: '*.somalier'

