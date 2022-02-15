cwlVersion: v1.2
class: CommandLineTool
id: somalier-ancestry
doc: "Tool to calculate ancestry using sites and somalier inputs"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 32000
    coresMin: 16
  - class: DockerRequirement
    dockerPull: 'brentp/somalier:v0.2.15'
baseCommand: [tar, -xzf]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      $(inputs.somalier_sites.path)
      && somalier ancestry
      --labels $(inputs.labels.path)
      $(inputs.untar_sites_prefix)/*.somalier
      -o $(inputs.output_basename)
      ++ $(inputs.input_somalier[0].dirname)/*.somalier

inputs:
  input_somalier: { type: 'File[]', doc: "Files in somalier format to calculate ancestry on"}
  labels: { type: File, doc: "tsv file with population labels for somalier sites" }
  somalier_sites: { type: File, doc: "vcf file with common sites" }
  untar_sites_prefix: { type: string, doc: "dir name that is created when somalier_sites in un-tarred" }
  output_basename: { type: string, doc: "String prefix for output results" }

outputs:
  somalier_tsv:
    type: File
    outputBinding:
      glob: $(inputs.output_basename).somalier-ancestry.tsv
  somalier_html:
    type: File
    outputBinding:
      glob: $(inputs.output_basename).somalier-ancestry.html
