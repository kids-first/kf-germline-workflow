cwlVersion: v1.2
class: Workflow
id: split-vcf-wf

doc: "Workflow to chunk VCF"

requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  input_vcf: {type: 'File', secondaryFiles: ['.tbi'], doc: "vcf to split"}
  input_regions: { type: 'File', doc: "File containing a set of genomic regions." }
  reference_dict: { type: 'File?', doc: "Reference sequence dictionary, or BAM/VCF/IntervalList from which a dictionary can be extracted. Required if input_regions are in a BED file." }
  break_bands_at_multiples_of: { type: 'int?', default: 1000000, doc: "If set to a positive value will create a new interval list with the original intervals broken up at integer multiples of this value. Set to 0 to NOT break up intervals." }
  scatter_count: { type: 'int?', default: 50, doc: "Total number of scatter intervals and beds to make" }
  subdivision_mode:
    type:
      - 'null'
      - type: enum
        name: subdivision_mode
        symbols: [ "INTERVAL_SUBDIVISION", "BALANCING_WITHOUT_INTERVAL_SUBDIVISION", "BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW", "INTERVAL_COUNT", "INTERVAL_COUNT_WITH_DISTRIBUTED_REMAINDER" ]
    default: "BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW"
    doc: |
      The mode used to scatter the interval list:
      - INTERVAL_SUBDIVISION (Scatter the interval list into similarly sized interval
        lists (by base count), breaking up intervals as needed.)
      - BALANCING_WITHOUT_INTERVAL_SUBDIVISION (Scatter the interval list into
        similarly sized interval lists (by base count), but without breaking up
        intervals.)
      - BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW (Scatter the interval
        list into similarly sized interval lists (by base count), but without
        breaking up intervals. Will overflow current interval list so that the
        remaining lists will not have too many bases to deal with.)
      - INTERVAL_COUNT (Scatter the interval list into similarly sized interval lists
        (by interval count, not by base count). Resulting interval lists will contain
        the same number of intervals except for the last, which contains the
        remainder.)
      - INTERVAL_COUNT_WITH_DISTRIBUTED_REMAINDER (Scatter the interval list into
        similarly sized interval lists (by interval count, not by base count).
        Resulting interval lists will contain similar number of intervals.)
  bcftools_cores: { type: 'int?', default: 4}
  bcftools_ram: { type: 'int?', default: 8}
  output_basename: { type: string, doc: "Output basename of vcf, sans extension (vcf.gz)" }

outputs:
  split_vcf: {type: 'File[]', outputSource: bcftools_region_subset/output}

steps:
  scatter_regions:
    run: ../subworkflows/scatter_regions.cwl
    in:
        input_regions: input_regions
        reference_dict: reference_dict
        break_bands_at_multiples_of: break_bands_at_multiples_of
        scatter_count: scatter_count
        subdivision_mode: subdivision_mode
    out: [scattered_intervallists, scattered_beds]

  bcftools_region_subset:
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c5.4xlarge
    run: ../tools/bcftools_region_subset.cwl
    in:
      input_vcf: input_vcf
      regions_file: scatter_regions/scattered_beds
      cpu: bcftools_cores
      ram: bcftools_ram
      output_basename: output_basename
    scatter: [regions_file]
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

sbg:license: Apache License 2.0
sbg:publisher: KFDRC

hints:
- class: sbg:maxNumberOfParallelInstances
  value: 4
