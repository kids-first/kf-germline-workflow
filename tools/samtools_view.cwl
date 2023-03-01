class: CommandLineTool
cwlVersion: v1.2
id: samtools_view
doc: |-
  views and converts SAM/BAM/CRAM files
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/samtools:1.15.1'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      samtools view
inputs:
  # View Positional Arguments
  input_reads: { type: File, inputBinding: { position: 7 }, doc: "Input BAM/CRAM/SAM file" }
  customized_index_file: { type: 'File?', inputBinding: { position: 8 }, doc: "The customized index for the input reads" }
  regions: { type: 'string?', inputBinding: { position: 9, shellQuote: false }, doc: "Region from which to select reads" }

  # View Arguments
  output_bam: { type: 'boolean?', inputBinding: { position: 2, prefix: "--bam" }, doc: "Output BAM file" }
  output_cram: { type: 'boolean?', inputBinding: { position: 2, prefix: "--cram" }, doc: "Output CRAM (requires reference fasta input)" }
  fast_compression: { type: 'boolean?', inputBinding: { position: 2, prefix: "--fast" }, doc: "Enable fast compression. This also changes the default output format to BAM, but this can be overridden by the explicit format options or using a filename with a known suffix." }
  uncompressed_bam: { type: 'boolean?', inputBinding: { position: 2, prefix: "--uncompressed" }, doc: "Output uncompressed data. This also changes the default output format to BAM, but this can be overridden by the explicit format options or using a filename with a known suffix. Useful for piped commands." }
  include_header: { type: 'boolean?', inputBinding: { position: 2, prefix: "--with-header" }, doc: "Include the header in the output." }
  exclude_header: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-header" }, doc: "When producing SAM format, output alignment records but not headers." }
  only_header: { type: 'boolean?', inputBinding: { position: 2, prefix: "--header-only" }, doc: "Output the header only." }
  count: { type: 'boolean?', inputBinding: { position: 2, prefix: "--count" }, doc: "Instead of printing the alignments, only count them and print the total number. All filter options are taken into account. The unmap option is ignored in this mode." }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output", shellQuote: false }, doc: "Write output to FILE" }
  output_unselected_filename:  { type: 'string?', inputBinding: { position: 2, prefix: "--unoutput" }, doc: "Output reads not selected by filters to FILE" }
  flag_unmap: { type: 'boolean?', inputBinding: { position: 2, prefix: "--unmap" }, doc: "Set the UNMAP flag on alignments that are not selected by the filter options. These alignments are then written to the normal output." }
  fetch_pairs: { type: 'boolean?', inputBinding: { position: 2, prefix: "--fetch-pairs" }, doc: "Retrieve complete pairs even when outside of region" }
  reference_fai: { type: 'File?', inputBinding: { position: 2, prefix: "--fai-reference" }, doc: "FILE listing reference names and lengths" }
  use_index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--use-index" }, doc: "Use index and multi-region iterator for regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file" }, doc: "Use index to include only reads overlapping FILE" }
  customized_index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--customized-index" }, doc: "Expect extra index file argument after <in.bam>" }
  targets_file: { type: 'File?', inputBinding: { position: 2, prefix: "--targets-file" }, doc: "Only output alignments overlapping this input BED FILE" }
  read_group: { type: 'string?', inputBinding: { position: 2, prefix: "--read-group" }, doc: "Output alignments in read group STR. Records with no RG tag will also be output when using this option." }
  read_group_file: { type: 'string?', inputBinding: { position: 2, prefix: "--read-group-file" }, doc: "Output alignments in read groups listed in this input file. Records with no RG tag will also be output when using this option." }
  qname_file: { type: 'File?', inputBinding: { position: 2, prefix: "--qname-file" }, doc: "Output only alignments with read names listed in this input file" }
  tag: { type: 'string?', inputBinding: { position: 2, prefix: "--tag" }, doc: "STR1[:STR2] Only output alignments with tag STR1 and associated value STR2, which can be a string or an integer [null]. The value can be omitted, in which case only the tag is considered." }
  tag_file: { type: 'File?', inputBinding: { position: 2, prefix: "--tag-file" }, doc: "Only output alignments with tag STR and associated values listed in this input file" }
  min_mapq: { type: 'int?', inputBinding: { position: 2, prefix: "--min-MQ" }, doc: "Skip alignments with MAPQ smaller than this value." }
  library: { type: 'string?', inputBinding: { position: 2, prefix: "--library" }, doc: "Only output alignments from this library name." }
  min_qlen: { type: 'int?', inputBinding: { position: 2, prefix: "--min-qlen" }, doc: "Only output alignments with number of CIGAR bases consuming query sequence greater than or equal to this value." }
  filter_expression: { type: 'string?', inputBinding: { position: 2, prefix: "--expr" }, doc: "Only output alignments that pass this expression." }
  require_flags: { type: 'string?', inputBinding: { position: 2, prefix: "--require-flags" }, doc: "Only output alignments with all bits set in FLAG present in the FLAG field." }
  exclude_flags: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude-flags" }, doc: "Do not output alignments with any bits set in FLAG present in the FLAG field." }
  include_flags: { type: 'string?', inputBinding: { position: 2, prefix: "--include-flags" }, doc: "Only output alignments with any bit set in FLAG present in the FLAG field." }
  exclude_all: { type: 'string?', inputBinding: { position: 2, prefix: "-G" }, doc: "Do not output alignments with all bits set in INT present in the FLAG field." }
  subsample: { type: 'float?', inputBinding: { position: 2, prefix: "--subsample" }, doc: "Output only a proportion of the input alignments, as specified by 0.0 ≤ FLOAT ≤ 1.0, which gives the fraction of templates/pairs to be kept" }
  subsample_seed: { type: 'int?', inputBinding: { position: 2, prefix: "--subsample-seed" }, doc: "Subsampling seed used to influence which subset of reads is kept." }
  add_flags: { type: 'string?', inputBinding: { position: 2, prefix: "--add-flags" }, doc: "Adds flag(s) to read." }
  remove_flags: { type: 'string?', inputBinding: { position: 2, prefix: "--remove-flags" }, doc: "Remove flag(s) from read." }
  remove_tag: { type: 'string?', inputBinding: { position: 2, prefix: "--remove-tag" }, doc: "Comma-separated read tags to strip" }
  keep_tag: { type: 'string?', inputBinding: { position: 2, prefix: "--keep-tag" }, doc: "Comma-separated read tags to preserve" }
  remove_b: { type: 'boolean?', inputBinding: { position: 2, prefix: "--remove-B" }, doc: "Collapse the backward CIGAR operation" }
  no_pg: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-PG" }, doc: "Do not add a @PG line to the header of the output file." }
  reference_fasta: { type: 'File?', secondaryFiles: [{ pattern: '.fai', required: false}], inputBinding: { position: 2, prefix: "--reference" }, doc: "Reference sequence FASTA FILE" }
  write_index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--write-index" }, doc: "Automatically index the output files" }
  input_format: { type: 'string?', inputBinding: { position: 2, prefix: "--input-fmt" }, doc: "Specify input format (SAM, BAM, CRAM) and any other options/values FORMAT[,OPT[=VAL]]..." }
  output_format: { type: 'string?', inputBinding: { position: 2, prefix: "--output-fmt" }, doc: "Specify output format (SAM, BAM, CRAM) and any other options/values FORMAT[,OPT[=VAL]]..." }
  cpu:
    type: 'int?'
    default: 1
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
    type: File
    secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}]
    outputBinding:
      glob: '*.*am'

$namespaces:
  sbg: https://sevenbridges.com
