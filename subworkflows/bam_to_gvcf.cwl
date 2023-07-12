cwlVersion: v1.2
class: Workflow
id: bam_to_gvcf
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: StepInputExpressionRequirement

inputs:
  input_bam: File
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: '^.dict', required: true }, { pattern: '.fai', required: true }] }
  scattered_calling_interval_lists: { type: 'File[]' }
  biospecimen_name: string
  contamination: float?
  contamination_sites_bed: File
  contamination_sites_mu: File
  contamination_sites_ud: File
  dbsnp_vcf: { type: 'File', secondaryFiles: [{ pattern: '.idx', required: true }]}
  wgs_evaluation_interval_list: File
  output_basename: string

outputs:
  verifybamid_output: {type: File, outputSource: verifybamid_checkcontam_conditional/output}
  gvcf: {type: File, outputSource: picard_mergevcfs_python_renamesample/output}
  gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output}

steps:
  verifybamid_checkcontam_conditional:
    run: ../tools/verifybamid_contamination_conditional.cwl
    in:
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      precalculated_contamination: contamination
      input_bam: input_bam
      ref_fasta: indexed_reference_fasta
      output_basename: output_basename
    out: [output,contamination]

  gatk_haplotypecaller:
    run: ../tools/gatk_haplotypecaller.cwl
    hints:
      - class: sbg:AWSInstanceType
        value: c5.9xlarge
    scatter: [interval_list]
    in:
      contamination: verifybamid_checkcontam_conditional/contamination
      input_bam: input_bam
      interval_list: scattered_calling_interval_lists
      reference: indexed_reference_fasta
    out: [output]

  picard_mergevcfs_python_renamesample:
    run: ../tools/picard_mergevcfs_python_renamesample.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: output_basename
      biospecimen_name: biospecimen_name
    out: [output]

  picard_collectgvcfcallingmetrics:
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      final_gvcf_base_name:
        source: picard_mergevcfs_python_renamesample/output
        valueFrom: $(self.basename)
      input_vcf: picard_mergevcfs_python_renamesample/output
      reference_dict:
        source: indexed_reference_fasta
        valueFrom: |
          $(self.secondaryFiles.filter(function(e) { return e.nameext == '.dict' })[0])
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 2
