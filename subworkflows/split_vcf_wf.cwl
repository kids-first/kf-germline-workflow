cwlVersion: v1.2
class: Workflow
id: split-vcf-wf

doc: "Workflow to chunk VCF"

requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  unpadded_intervals_file: {type: File, doc: 'hg38.even.handcurated.20k.intervals',
    "sbg:suggestedValue": {class: File, path: 5f500135e4b0370371c051b1, name: hg38.even.handcurated.20k.intervals}}
  input_vcf: {type: 'File', secondaryFiles: ['.tbi'], doc: "Input vcf to annotate"}
  output_basename: string
  tool_name: { type: string, doc: "File name string suffx to use for output files" }  
  bcftools_cores: { type: 'int?', default: 4}
  bcftools_ram: { type: 'int?', default: 8}

outputs:
  split_vcf: {type: 'File[]', outputSource: bcftools_region_subset/output}

steps:
  dynamicallycombineintervals:
    run: ../tools/script_dynamicallycombineintervals.cwl
    doc: 'Merge interval lists based on number of gVCF inputs'
    in:
      input_vcfs: 
        source: input_vcf
        valueFrom: "${ return [self] }"
      interval: unpadded_intervals_file
    out: [out_intervals]

  output_region_str:
    run: ../tools/output_region_str.cwl
    in: 
      intervals_file: dynamicallycombineintervals/out_intervals
    scatter: intervals_file
    out: [output]

  bcftools_region_subset:
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c5.4xlarge
    run: ../tools/bcftools_region_subset.cwl
    in:
      input_vcf: input_vcf
      regions: output_region_str/output
      cpu: bcftools_cores
      ram: bcftools_ram
      output_basename: output_basename
    scatter: [regions]
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

sbg:license: Apache License 2.0
sbg:publisher: KFDRC

hints:
- class: sbg:maxNumberOfParallelInstances
  value: 4
