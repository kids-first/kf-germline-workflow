cwlVersion: v1.2
class: CommandLineTool
id: bcftools_merge
doc: |
  BCFTOOLS merge
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.16'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bcftools merge

inputs:
  # Required Inputs
  input_vcfs: { type: 'File[]', inputBinding: { position: 9 }, doc: "One or more VCF files to query." }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output-file"}, doc: "output file name" }

  # Merge Arguments
  force_samples: { type: 'boolean?', inputBinding: { position: 2, prefix: "--force-samples"}, doc: "resolve duplicate sample names" }
  print_header: { type: 'boolean?', inputBinding: { position: 2, prefix: "--print-header"}, doc: "print only the merged header and exit" }
  use_header: { type: 'File?', inputBinding: { position: 2, prefix: "--use-header"}, doc: "use the provided header" }
  missing_to_ref: { type: 'boolean?', inputBinding: { position: 2, prefix: "--missing-to-ref"}, doc: "assume genotypes at missing sites are 0/0" }
  apply_filters: { type: 'string?', inputBinding: { position: 2, prefix: "--apply-filters"}, doc: "require at least one of the listed FILTER strings (e.g. 'PASS,.')" }
  filter_logic:
    type:
      - 'null'
      - type: enum
        name: filter_logic
        symbols: ["x", "+"]
    inputBinding:
      prefix: "--filter-logic"
      position: 2
    doc: |
      remove filters if some input is PASS ('x'), or apply all filters ('+')
  gvcf: { type: 'File?', inputBinding: { position: 2, prefix: "--gvcf"}, doc: "merge gVCF blocks, INFO/END tag is expected. Implies -i QS:sum,MinDP:min,I16:sum,IDV:max,IMF:max. Provide a reference fasta." }
  info_rules: { type: 'string?', inputBinding: { position: 2, prefix: "--info-rules"}, doc: "rules for merging INFO fields (method is one of sum,avg,min,max,join) or '-' to turn off the default [DP:sum,DP4:sum]" }
  file_list: { type: 'File?', inputBinding: { position: 2, prefix: "--file-list"}, doc: "read file names from the file" }
  no_index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-index"}, doc: "Merge unindexed files, the same chromosomal order is required and -r/-R are not allowed" }
  no_version: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  regions_overlap:
    type:
      - 'null'
      - type: enum
        name: regions_overlap
        symbols: ["0","1","2"]
    inputBinding:
      prefix: "--regions-overlap"
      position: 2
    doc: |
      Include if POS in the region (0), record overlaps (1), variant overlaps (2)
  merge:
    type:
      - 'null'
      - type: enum
        name: merge
        symbols: ["snps","indels","both","snp-ins-del","all","none","id"]
    inputBinding:
      prefix: "--merge"
      position: 2
    doc: |
      allow multiallelic records for <snps|indels|both|all|none|id>, see man page for details
  output_type:
    type:
      - 'null'
      - type: enum
        name: output_type
        symbols: ["b", "u", "v", "z"]
    inputBinding:
      prefix: "--output-type"
      position: 2
    doc: |
      b: compressed BCF, u: uncompressed BCF, z: compressed VCF, v: uncompressed VCF [v]

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      prefix: "--threads"
      position: 2
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
