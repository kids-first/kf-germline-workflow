cwlVersion: v1.0
class: CommandLineTool
id: gatk_variantfiltration
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
      VariantFiltration
      -V $(inputs.input_vcf.path)
      ${
        if (inputs.selection == "SNP") {
          return '-filter "QD < 2.0" --filter-name "QD2" ' +
                 '-filter "QUAL < 30.0" --filter-name "QUAL30" ' +
                 '-filter "SOR > 3.0" --filter-name "SOR3_SNP" ' +
                 '-filter "FS > 60.0" --filter-name "FS60_SNP" ' +
                 '-filter "MQ < 40.0" --filter-name "MQ40_SNP" ' +
                 '-filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5_SNP" ' +
                 '-filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8_SNP" ' +
                 '-O ' + inputs.output_basename + '.snps.filtered.vcf.gz'
        } else if (inputs.selection == "INDEL") {
          return '-filter "QD < 2.0" --filter-name "QD2" ' +
                 '-filter "QUAL < 30.0" --filter-name "QUAL30" ' +
                 '-filter "FS > 200.0" --filter-name "FS200_INDEL" ' +
                 '-filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20_INDEL" ' +
                 '-O ' + inputs.output_basename + '.indels.filtered.vcf.gz'
        }
      }

inputs:
  input_vcf: { type: 'File', secondaryFiles: [.tbi] }
  selection: { type: { type: 'enum', name: selection, symbols: ["SNP", "INDEL"] }, doc: "Type of variants in the input file" }
  output_basename: { type: 'string', doc: "String value to use as the base for the output filename" }
  max_memory: { type: 'int?', default: 8, doc: "GB of memory to allocate to this task. default: 8" }
  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task. default: 4" }
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
