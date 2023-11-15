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
    dockerPull: 'brentp/somalier:v0.2.19'
baseCommand: [somalier, extract]

inputs:
  input_file: { type: File, secondaryFiles: [ { pattern: ".bai", required: false },
    { pattern: "^.bai", required: false }, { pattern: ".crai", required: false }, { pattern: "^.crai", required: false },
    { pattern: ".tbi", required: false } ], doc: "BAM/CRAM/VCF input. BAM/CRAM recommended when available over VCF",
    inputBinding: { position: 2} }
  reference_fasta: { type: File, inputBinding: { prefix: "--fasta", position: 1 }, secondaryFiles: [ .fai ], doc: "Reference FASTA genome used" }
  sites: { type: File, inputBinding: { prefix: "--sites", position: 1 }, doc: "VCF file with common sites" }
  sample_prefix: { type: 'string?' , doc: "Prefix for the sample name stored inside the digest",
    inputBinding: {position: 1, prefix: "--sample-prefix"} }

outputs:
  somalier_output:
    type: File
    outputBinding:
      glob: '*.somalier'

