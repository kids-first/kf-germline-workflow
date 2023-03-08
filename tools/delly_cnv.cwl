cwlVersion: v1.2
class: CommandLineTool
id: delly_cnv 
doc: "Delly CNV tool"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dellytools/delly:latest'

baseCommand: [delly, cnv]
inputs:
  # Required Arguments
  input_bam: { type: 'File', inputBinding: { position: 9 }, doc: "Input bam file" }
  genome: { type: 'File', inputBinding: { position: 2, prefix: "--genome"}, doc: "genome file" }
  mappability: { type: 'File', inputBinding: { position: 2, prefix: "--mappability"}, doc: "input mappability map" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--outfile"}, doc: "BCF output file" }

  # Generic Arguments
  quality: { type: 'int?', inputBinding: { position: 2, prefix: "--quality"}, doc: "min. mapping quality" }
  ploidy: { type: 'int?', inputBinding: { position: 2, prefix: "--ploidy"}, doc: "baseline ploidy" }
  covfile: { type: 'File?', inputBinding: { position: 2, prefix: "--covfile"}, doc: "gzipped coverage file" }

  # CNV calling Arguments
  sdrd: { type: 'float?', inputBinding: { position: 2, prefix: "--sdrd"}, doc: "min. SD read-depth shift" }
  cn_offset: { type: 'float?', inputBinding: { position: 2, prefix: "--cn-offset"}, doc: "min. CN offset" }
  cnv_size: { type: 'int?', inputBinding: { position: 2, prefix: "--cnv-size"}, doc: "min. CNV size" }
  svfile: { type: 'File?', inputBinding: { position: 2, prefix: "--svfile"}, doc: "delly SV file for breakpoint refinement" }
  vcffile: { type: 'File?', inputBinding: { position: 2, prefix: "--vcffile"}, doc: "input VCF/BCF file for re-genotyping" }
  segmentation: { type: 'boolean?', inputBinding: { position: 2, prefix: "--segmentation"}, doc: "copy-number segmentation" }
  
  # Read_depth windows Arguments
  window_size: { type: 'int?', inputBinding: { position: 2, prefix: "--window-size"}, doc: "window size" }
  window_offset: { type: 'float?', inputBinding: { position: 2, prefix: "--window-offset"}, doc: "window offset" }
  bed_intervals: { type: 'File?', inputBinding: { position: 2, prefix: "--bed-intervals"}, doc: "input BED file" }
  fraction_window: { type: 'float?', inputBinding: { position: 2, prefix: "--fraction-window"}, doc: "min. callable window fraction [0,1]" }
  adaptive_windowing: { type: 'boolean?', inputBinding: { position: 2, prefix: "--adaptive-windowing"}, doc: "use mappable bases for window size" }
  
  # GC fragment normalization arguemnts
  scan_window: { type: 'int?', inputBinding: { position: 2, prefix: "--scan-window"}, doc: "scanning window size" }
  fraction_unique: { type: 'float?', inputBinding: { position: 2, prefix: "--fraction-unique"}, doc: "uniqueness filter for scan windows [0,1]" }
  scan_regions: { type: 'File?', inputBinding: { position: 2, prefix: "--scan-regions"}, doc: "scanning regions in BED format" }
  mad_cutoff: { type: 'int?', inputBinding: { position: 2, prefix: "--mad-cutoff"}, doc: "median + 3 * mad count cutoff" }
  percentile: { type: 'float?', inputBinding: { position: 2, prefix: "--percentile"}, doc: "excl. extreme GC fraction" }
  no_window_selection: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-window-selection"}, doc: "no scan window selection" }

  # Resource Control
  cpu: {type: 'int?', default: 16, doc: "CPUs to allocate to this tool"}
  ram: {type: 'int?', default: 32, doc: "GB of RAM to allocate to this tool"}
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_filename) 
