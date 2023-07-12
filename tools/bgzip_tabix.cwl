cwlVersion: v1.2
class: CommandLineTool
id: bgzip_tabix
doc: |
  BGZIP and TABIX index an input gff, bed, sam, or vcf
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.4.0.0'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bgzip --stdout
  - position: 9
    shellQuote: false
    prefix: '>'
    valueFrom: >
      $(inputs.output_filename)
  - position: 10
    shellQuote: false
    prefix: '&&'
    valueFrom: >
      tabix
  - position: 18
    valueFrom: >
      $(inputs.output_filename)
inputs:
  input_file: { type: 'File', inputBinding: { position: 8 }, doc: "Input gff, bed, sam, or vcf file." }
  output_filename: { type: 'string?', default: "out.gz", doc: "String name to use for compressed output." }

  # BGZIP
  offset: { type: 'int?', inputBinding: { position: 2, prefix: "--offset" }, doc: "decompress at virtual file pointer (0-based uncompressed offset)" }
  index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--index" }, doc: "compress and create BGZF index" }
  index_name: { type: 'string?', inputBinding: { position: 2, prefix: "--index-name" }, doc: "name of BGZF index file [file.gz.gzi]" }
  reindex: { type: 'boolean?', inputBinding: { position: 2, prefix: "--reindex" }, doc: "(re)index compressed file" }
  rebgzip: { type: 'boolean?', inputBinding: { position: 2, prefix: "--rebgzip" }, doc: "use an index file to bgzip a file" }
  size: { type: 'int?', inputBinding: { position: 2, prefix: "--size" }, doc: "decompress INT bytes (uncompressed size)" }

  # TABIX
  zero_based: { type: 'boolean?', inputBinding: { position: 12, prefix: "--zero-based" }, doc: "coordinates are zero-based" }
  begin: { type: 'int?', inputBinding: { position: 12, prefix: "--begin" }, doc: "column number for region start [4]" }
  comment: { type: 'string?', inputBinding: { position: 12, prefix: "--comment" }, doc: "skip comment lines starting with CHAR [null]" }
  csi: { type: 'boolean?', inputBinding: { position: 12, prefix: "--csi" }, doc: "generate CSI index for VCF (default is TBI)" }
  end: { type: 'int?', inputBinding: { position: 12, prefix: "--end" }, doc: "column number for region end (if no end, set INT to -b) [5]" }
  force: { type: 'boolean?', inputBinding: { position: 12, prefix: "--force" }, doc: "overwrite existing index without asking" }
  min_shift: { type: 'int?', inputBinding: { position: 12, prefix: "--min-shift" }, doc: "set minimal interval size for CSI indices to 2^INT [14]" }
  preset:
    type:
      - 'null'
      - type: enum
        name: preset
        symbols: [ "gff", "bed", "sam", "vcf" ]
    inputBinding:
      prefix: --preset
      position: 12
    doc: "gff, bed, sam, vcf"
  sequence: { type: 'int?', inputBinding: { position: 12, prefix: "--sequence" }, doc: "column number for sequence names (suppressed by -p) [1]" }
  skip_lines: { type: 'int?', inputBinding: { position: 12, prefix: "--skip-lines" }, doc: "skip first INT lines [0]" }
  print_header: { type: 'boolean?', inputBinding: { position: 12, prefix: "--print-header" }, doc: "print also the header lines" }
  only_header: { type: 'boolean?', inputBinding: { position: 12, prefix: "--only-header" }, doc: "print only the header lines" }
  list_chroms: { type: 'boolean?', inputBinding: { position: 12, prefix: "--list-chroms" }, doc: "list chromosome names" }
  reheader: { type: 'File?', inputBinding: { position: 12, prefix: "--reheader" }, doc: "replace the header with the content of FILE" }
  regions: { type: 'File?', inputBinding: { position: 12, prefix: "--regions" }, doc: "restrict to regions listed in the file" }
  regions_strings: { type: 'string[]?', inputBinding: { position: 19 }, doc: "Regions over which to restrict indexing" }
  targets: { type: 'File?', inputBinding: { position: 12, prefix: "--targets" }, doc: "similar to -R but streams rather than index-jumps" }

  ram: { type: 'int?', default: 4, doc: "GB of RAM to allocate to the task." }
  cpu: { type: 'int?', default: 2, inputBinding: { position: 2, prefix: "--threads" }, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  output: { type: 'File', secondaryFiles: [{ pattern: '.tbi', required: false }, { pattern: '.csi', required: false }], outputBinding: { glob: $(inputs.output_filename) } }

