# KFDRC VCF-to-Parquet Tool
This is a tool designed to convert vcf files to parquet output.
Conversion allows for more efficient usage of spark cluster capabilities

![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

## Inputs
Needed:
 - `input_vcf`: VCF file to convert
 - `output_basename`: Output file prefix to use
Optional:
 - `normalize_flag`: Set to true if you'd like to normalize file before converting. Recommended
 - `reference_genome`: Must provide fai indexed fasta file if normalizing

### Comprehensive
```yaml
inputs:
  input_vcf: { type: 'File', inputBinding: { prefix: "--input_vcf" }, doc: "VCF to convert" }
  output_basename: { type: 'string', inputBinding: { prefix: "--output_basename" }, doc: "Output prefix of dirname for parquet files" }
  normalize_flag: { type: 'boolean?', inputBinding: { prefix: "--normalize_flag" }, doc: "Use if you want to normalize before output" }
  reference_genome: { type: 'File?', inputBinding: { prefix: "--reference_genome" }, secondaryFiles: [.fai], doc: "Provide if normalizing vcf. Fasta index must also be included"}

  # Resource Control
  cpu: { type: 'int?', default: 36, doc: "CPU cores to allocate to this task" }
  ram: { type: 'int?', default: 60, doc: "GB of RAM to allocate to this task" }


```

## Outputs:
```yaml
outputs:
  parquet_dir:
    type: 'Directory'
    outputBinding:
      glob: $(inputs.output_basename).parquet
    doc: "Resultant parquet file directory bundle"
```