cwlVersion: v1.0
class: CommandLineTool
id: pyspark-vcf2parquet
doc: 'Tool to optionally normalize and convert input vcf to parquet file'
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: pyspark_vcf2parquet.py
        entry:
          $include: ../scripts/pyspark_vcf2parquet.py

  - class: DockerRequirement
    dockerPull: 'migbro/pyspark:3.1.2'
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)

baseCommand: [spark-submit]

arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --packages io.projectglow:glow-spark3_2.12:1.1.2
      --conf spark.hadoop.io.compression.codecs=io.projectglow.sql.util.BGZFCodec
      --driver-memory $(inputs.ram)G 
      pyspark_vcf2parquet.py

inputs:
  input_vcf: { type: 'File', inputBinding: { prefix: "--input_vcf" }, doc: "VCF to convert" }
  output_basename: { type: 'string', inputBinding: { prefix: "--output_basename" }, doc: "Output prefix of dirname for parquet files" }
  normalize_flag: { type: 'boolean?', inputBinding: { prefix: "--normalize_flag" }, doc: "Use if you want to normalize before output" }
  reference_genome: { type: 'File?', inputBinding: { prefix: "--reference_genome" }, secondaryFiles: [.fai], doc: "Provide if normalizing vcf. Fasta index must also be included"}

  # Resource Control
  cpu: { type: 'int?', default: 36, doc: "CPU cores to allocate to this task" }
  ram: { type: 'int?', default: 60, doc: "GB of RAM to allocate to this task" }

outputs:
  parquet_dir:
    type: 'Directory'
    outputBinding:
      glob: $(inputs.output_basename).parquet
    doc: "Resultant parquet file"
