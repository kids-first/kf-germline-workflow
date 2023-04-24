cwlVersion: v1.2
class: Workflow
id: kfdrc-delly-germline-cnv-wf
label: Kids First DRC Delly Germline CNV Workflow
doc: |
  # KFDRC Delly Germline CNV Workflow

  ### Known Issues

  ### Runtime Estimates

  ### Tips To Run

  ## Other Resources
  - dockerfiles: https://github.com/d3b-center/bixtools

requirements:
- class: ScatterFeatureRequirement
- class: SubworkflowFeatureRequirement

inputs:
  input_reads: { type: 'File[]', secondaryFiles: [{pattern: ".bai", required: false}, {pattern: "^.bai", required: false}, {pattern: ".crai", required: false}, {pattern: "^.crai", required: false}], doc: "Mapped sequence reads in BAM/CRAM format", "sbg:fileTypes": "BAM,CRAM"}
  indexed_reference_fasta: {type: 'File', secondaryFiles: [{pattern: ".fai", required: true}], doc: "Reference fasta and fai index" }
  mappability_map: { type: 'File', secondaryFiles: [{pattern: ".fai", required: false}, {pattern: ".gzi", required: false}], doc: "Mappability map for sample. Chromosomes should match reference." }
  output_basename: {type: 'string', doc: "Basename to use for outputs"}
  samtools_cpu: { type: 'int?', default: 4, doc: "CPUs to allocate to samtools view" }
  samtools_ram: { type: 'int?', default: 8, doc: "GB of RAM to allocate to samtools view" }

outputs:
  genotyped_bcfs: {type: 'File[]', outputSource: delly_cnv_genotype/output }
  merged_cnvs: {type: 'File', outputSource: bcftools_merge_index/output }
  germline_cnvs: {type: 'File', outputSource: delly_classify/output }

steps:
  samtools_view:
    run: ../tools/samtools_view.cwl
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    scatter: [input_reads]
    when: $(inputs.input_reads.nameext != ".bam")
    in:
      input_reads: input_reads
      reference_fasta: indexed_reference_fasta
      output_bam:
        valueFrom: $(1 == 1)
      include_header:
        valueFrom: $(1 == 1)
      write_index:
        valueFrom: $(1 == 1)
      output_filename:
        valueFrom: $(inputs.input_reads.nameroot).bam##idx##$(inputs.input_reads.nameroot).bam.bai
      cpu: samtools_cpu
      ram: samtools_ram
    out: [output]

  stitch_bam_lists:
    run: ../tools/clt_passthrough_filelist.cwl
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    in:
      infiles:
        source: [samtools_view/output, input_reads]
        valueFrom: |
          ${
            var out = [];
            for (var i = 0; i < self[1].length; i++) {
              if (self[0][i] != null) {
                out.push(self[0][i]);
              } else {
                out.push(self[1][i]);
              }
            }
            return out;
          }
    out: [output]

  # Perhaps do the SV calling for the breakpoint refinement

  delly_cnv_call:
    run: ../tools/delly_cnv.cwl
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    scatter: [input_bam]
    in:
      input_bam: stitch_bam_lists/output
      genome: indexed_reference_fasta
      mappability: mappability_map
      output_filename:
        valueFrom: $(inputs.input_bam.basename).bcf
    out: [output]

  delly_merge:
    run: ../tools/delly_merge.cwl
    in:
      input_bcfs: delly_cnv_call/output
      output_filename:
        valueFrom: "sites.bcf"
      minsize:
        valueFrom: $(1000)
      maxsize:
        valueFrom: $(100000)
      cnvmode:
        valueFrom: $(1 == 1)
      pass:
        valueFrom: $(1 == 1)
    out: [output]

  delly_cnv_genotype:
    run: ../tools/delly_cnv.cwl
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    scatter: [input_bam]
    in:
      input_bam: stitch_bam_lists/output
      genome: indexed_reference_fasta
      mappability: mappability_map
      output_filename:
        valueFrom: $(inputs.input_bam.basename).geno.bcf
      vcffile: delly_merge/output
      segmentation:
        valueFrom: $(1 == 1)
    out: [output]

  bcftools_merge_index:
    run: ../tools/bcftools_merge_index.cwl
    in:
      input_vcfs: delly_cnv_genotype/output
      output_filename:
        source: output_basename
        valueFrom: $(self).merged.bcf
      merge:
        valueFrom: "id"
      output_type:
        valueFrom: "b"
    out: [output]

  delly_classify:
    run: ../tools/delly_classify.cwl
    in:
      input_bcf: bcftools_merge_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).filtered.bcf
      filter:
        valueFrom: "germline"
    out: [output]

  # bcftools query plot.tsv
  # delly cnv.R plot.tsv

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 4
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- CNV
- DELLY
- GERMLINE
