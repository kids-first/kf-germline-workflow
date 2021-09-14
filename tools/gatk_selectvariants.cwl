cwlVersion: v1.0
class: CommandLineTool
id: gatk_selectvariants
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R'
baseCommand: [/gatk]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --java-options "-Xmx${ return Math.floor(inputs.max_memory*1000/1.074-1) }m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10"
      SelectVariants
      $(inputs.selection == "INDEL" ? "-select-type MIXED" : "")
      -select-type $(inputs.selection)
      -O $(inputs.output_basename).$(inputs.selection.toLowerCase()).vcf.gz
      -V $(inputs.input_vcf.path)

inputs:
  input_vcf: {type: 'File', secondaryFiles: [.tbi], doc: "A VCF file containing variants"}
  selection: {type: {type: enum, name: selection, symbols: ["SNP", "INDEL"]}, doc: "Select only a certain type of variants from the input file"}
  output_basename: {type: 'string', doc: "String value to serve as the base for the output filename."}
  max_memory: {type: 'int?', default: 8, doc: "GB of memory to allocate to this task. default: 8"}
  cpu: {type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task. default: 4" }
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
