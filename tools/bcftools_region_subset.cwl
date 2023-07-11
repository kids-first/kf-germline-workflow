cwlVersion: v1.2
class: CommandLineTool
id: bcftools-region-subset
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest'

baseCommand: [bcftools, view]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --output-type z
  - position: 2
    shellQuote: false
    valueFrom: >-
      --output-file $(inputs.output_basename).${
        if (inputs.regions_file != null){
          return inputs.regions_file.nameroot;
        }
        else{
          return inputs.regions.replace(':', '-')
        }
        }.vcf.gz
  - position: 3
    shellQuote: false
    valueFrom: >-
      && tabix $(inputs.output_basename).${
        if (inputs.regions_file != null){
          return inputs.regions_file.nameroot;
        }
        else{
          return inputs.regions.replace(':', '-')
        }
        }.vcf.gz

inputs:
    regions_file: { type: 'File?', doc: "Bed interval list to subset vf on",
      inputBinding: { position: 0, prefix: "--regions-file"} }
    regions: { type: 'string?', doc: "If not regions file, use string",
      inputBinding: { position: 0, prefix: "--regions"} } 
    cpu: { type: 'int?', default: 8, doc: "Number of CPUs to allocate to this task",
      inputBinding: {  position: 0, prefix: "--threads"} }
    input_vcf: { type: 'File', secondaryFiles: ['.tbi'], doc: "VCF to subset",
      inputBinding: { position: 1 } }
    output_basename: { type: 'string', doc: "String value to use as the base of the output filename" }
    ram: { type: 'int?', default: 16, doc: "GB of memory to allocate to this task" }

outputs:
  output:
    type: 'File'
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: ['.tbi']