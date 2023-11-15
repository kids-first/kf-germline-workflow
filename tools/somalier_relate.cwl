cwlVersion: v1.2
class: CommandLineTool
id: somalier-relate
doc: "Tool to calculate sample relatedness and grouping"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 1000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'brentp/somalier:v0.2.19'
baseCommand: [somalier, relate]

inputs:
  somalier_output: { type: 'File[]', doc: "Somalier-formatted variant files",
    inputBinding: { position: 2} }
  groups: { type: 'File?', doc: "optional path to expected groups of samples (e.g. tumor normal pairs).
                             A group file is specified as comma-separated groups per line e.g.:
                                 normal1,tumor1a,tumor1b
                                 normal2,tumor2a",
    inputBinding: { position: 1, prefix: "--groups"} }
  ped: { type: 'File?', doc: "optional path to a PED/fam file indicating the expected relationships among samples.",
    inputBinding: { position: 1, prefix: "--ped"} }
  min_depth: { type: 'int?', doc: "only genotype sites with at least this depth.", default: 7,
    inputBinding: { position: 1, prefix: "--min-depth"} }
  min_ab: { type: 'float?', doc: "hets sites must be between min-ab and 1 - min_ab. set this to 0.2 for RNA-Seq data (default: 0.3)", default: 0.3,
    inputBinding: { position: 1, prefix: "--min-ab"} }
  unknown: { type: 'boolean?', doc: "set unknown genotypes to hom-ref. It is often preferable to use this with VCF samples that were not jointly called",
    inputBinding: { position: 1, prefix: "--unknown"} }
  infer: { type: 'boolean?', doc: "infer relationships",
    inputBinding: { position: 1, prefix: "--infer"} }
  output_prefix: { type: 'string?', doc: "output prefix for results. (default: somalier)",
    inputBinding: { position: 1, prefix: "--output-prefix" } }

outputs:
  groups_tsv:
    type: File
    outputBinding:
      glob: '*.groups.tsv'
    doc: "look at this for cancer samples - will list if detected/verified to be grouped together"
  interactive_html:
    type: File
    outputBinding:
      glob: '*.html'
  pairs_tsv:
    type: File
    outputBinding:
      glob: '*.pairs.tsv'
    doc: "Pairwise relatedness stats"
  samples_tsv:
    type: File
    outputBinding:
      glob: '*.samples.tsv'
    doc: "Pairwise samples pedigree stats"

