cwlVersion: v1.2
class: CommandLineTool
id: delly_classify
doc: "Delly Classify tool"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dellytools/delly:latest'

baseCommand: [delly, classify]
inputs:
  # Required Arguments
  input_bcf: { type: 'File', inputBinding: { position: 9 }, doc: "Input bcf file" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--outfile"}, doc: "Filtered CNV BCF output file" }

  # Generic Arguments
  filter:
    type:
      - 'null'
      - type: enum
        name: filter
        symbols: ["somatic","germline"]
    inputBinding:
      position: 2
      prefix: "--filter"
    doc: "Filter mode (somatic, germline)"
  minsize: { type: 'int?', inputBinding: { position: 2, prefix: "--minsize"}, doc: "min. CNV size" }
  maxsize: { type: 'int?', inputBinding: { position: 2, prefix: "--maxsize"}, doc: "max. CNV size" }
  pass: { type: 'boolean?', inputBinding: { position: 2, prefix: "--pass"}, doc: "Filter sites for PASS" }

  # Somatic Arguments
  samples: { type: 'File?', inputBinding: { position: 2, prefix: "--samples"}, doc: "Two-column sample file listing sample name and tumor or control" }
  pgerm: { type: 'float?', inputBinding: { position: 2, prefix: "--pgerm"}, doc: "probability germline" }
  cn-offset: { type: 'float?', inputBinding: { position: 2, prefix: "--cn-offset"}, doc: "min. CN offset" }

  # Germline Arguments
  ploidy: { type: 'int?', inputBinding: { position: 2, prefix: "--ploidy"}, doc: "baseline ploidy" }
  qual: { type: 'int?', inputBinding: { position: 2, prefix: "--qual"}, doc: "min. site quality" }
  maxsd: { type: 'float?', inputBinding: { position: 2, prefix: "--maxsd"}, doc: "max. population SD" }

  # Resource Control
  cpu: {type: 'int?', default: 16, doc: "CPUs to allocate to this tool"}
  ram: {type: 'int?', default: 32, doc: "GB of RAM to allocate to this tool"}
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
