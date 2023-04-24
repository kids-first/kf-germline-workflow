cwlVersion: v1.2
class: CommandLineTool
id: bcftools_concat_index
doc: |
  BCFTOOLS concat and optionally index
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.10.2'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bcftools concat
  - position: 90
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? "&& bcftools index --threads " + inputs.cpu : "")
  - position: 99
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? inputs.output_filename : "")

inputs:
  # Required Inputs
  input_vcfs: { type: 'File[]', inputBinding: { position: 9 }, doc: "VCF files to concat, sort, and optionally index" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output"}, doc: "output file name [stdout]" }

  # Concat Options
  allow_overlaps: { type: 'boolean?', inputBinding: { position: 2, prefix: "--allow-overlaps"}, doc: "First coordinate of the next file can precede last record of the current file." }
  compact_PS: { type: 'boolean?', inputBinding: { position: 2, prefix: "--compact-PS"}, doc: "Do not output PS tag at each site, only at the start of a new phase set block." }
  rm_dups:
    type:
      - 'null'
      - type: enum
        name: rm_dups
        symbols: ["snps", "indels", "both", "all", "none"]
    inputBinding:
      prefix: "--rm-dups"
      position: 2
  remove_duplicates: { type: 'boolean?', inputBinding: { position: 2, prefix: "--remove-duplicates"}, doc: "Alias for --rm-dups none" }
  ligate: { type: 'boolean?', inputBinding: { position: 2, prefix: "--ligate"}, doc: "Ligate phased VCFs by matching phase at overlapping haplotypes" }
  no_version: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-version"}, doc: "Do not append version and command line to the header" }
  naive: { type: 'boolean?', inputBinding: { position: 2, prefix: "--naive"}, doc: "Concatenate files without recompression, a header check compatibility is performed" }
  naive_force: { type: 'boolean?', inputBinding: { position: 2, prefix: "--naive-force"}, doc: "Same as --naive, but header compatibility is not checked. Dangerous, use with caution." }
  min_PQ: { type: 'int?', inputBinding: { position: 2, prefix: "--min-PQ"}, doc: "Break phase set if phasing quality is lower than <int> [30]" }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "Restrict to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "Restrict to regions listed in a file" }
  verbose:
    type:
      - 'null'
      - type: enum
        name: verbose
        symbols: ["0", "1"]
    inputBinding:
      prefix: "--verbose"
      position: 2
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

  # Index Arguments
  force: { type: 'boolean?', inputBinding: { position: 92, prefix: "--force"}, doc: "overwrite index if it already exists" }
  min_shift: { type: 'int?', inputBinding: { position: 92, prefix: "--min-shift"}, doc: "set minimal interval size for CSI indices to 2^INT [14]" }
  output_index_filename: { type: 'string?', inputBinding: { position: 92, prefix: "--output-file"}, doc: "optional output index file name" }
  csi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--csi"}, doc: "generate CSI-format index for VCF/BCF files [default]" }
  tbi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--tbi"}, doc: "generate TBI-format index for VCF files" }
  nrecords: { type: 'boolean?', inputBinding: { position: 92, prefix: "--nrecords"}, doc: "print number of records based on existing index file" }
  stats: { type: 'boolean?', inputBinding: { position: 92, prefix: "--stats"}, doc: "print per contig stats based on existing index file" }

  # Metadata options
  tool_name: { type: 'string?', default: "bcftools", doc: "Tool name to put in toolname metadata field" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  vcf:
    type: 'File'
    secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}]
    outputBinding:
      glob: $(inputs.output_filename)
      outputEval: |
        ${
          var outfile = self[0];
          if (!("metadata" in outfile)) { outfile.metadata = {} };
          outfile.metadata["toolname"] = inputs.tool_name;
          return outfile;
        }
