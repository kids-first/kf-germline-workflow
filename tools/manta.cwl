cwlVersion: v1.2
class: CommandLineTool
id: kfdrc-manta-sv
label: Manta SV Caller
doc: 'Calls structural variants.  Tool designed to pick correct run mode based on if tumor, normal, or both crams are given'
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/manta:1.6.0'

baseCommand: [/manta-1.6.0.centos6_x86_64/bin/configManta.py]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      ${
        var std = " --ref " + inputs.reference.path + (inputs.hg38_strelka_bed ? " --callRegions " + inputs.hg38_strelka_bed.path : "") + " --runDir=./ && ./runWorkflow.py -m local -j " + inputs.cores + " ";
        var mv = " && mv results/variants/";
        if (typeof inputs.input_tumor_reads === 'undefined' || inputs.input_tumor_reads === null){
          var mv_cmd = mv + "diploidSV.vcf.gz " +  inputs.output_basename + ".manta.diploidSV.vcf.gz" + mv + "diploidSV.vcf.gz.tbi " + inputs.output_basename + ".manta.diploidSV.vcf.gz.tbi" + mv + "candidateSmallIndels.vcf.gz " + inputs.output_basename + ".manta.candidateSmallIndels.vcf.gz" + mv + "candidateSmallIndels.vcf.gz.tbi " + inputs.output_basename + ".manta.candidateSmallIndels.vcf.gz.tbi";
          var normal_crams = "";
          for (var i=0; i < inputs.input_normal_reads.length; i++) {
            normal_crams += " --bam " + inputs.input_normal_reads[i].path
          }
          return normal_crams + std + mv_cmd;
        }
        else if (typeof inputs.input_normal_reads === 'undefined' || inputs.input_normal_reads === null){
          var mv_cmd = mv + "tumorSV.vcf.gz " + inputs.output_basename + ".manta.tumorSV.vcf.gz" + mv + "tumorSV.vcf.gz.tbi " + inputs.output_basename + ".manta.tumorSV.vcf.gz.tbi" + mv + "candidateSmallIndels.vcf.gz " + inputs.output_basename + ".manta.candidateSmallIndels.vcf.gz" + mv + "candidateSmallIndels.vcf.gz.tbi " + inputs.output_basename + ".manta.candidateSmallIndels.vcf.gz.tbi";
          return "--tumorBam " + inputs.input_tumor_reads.path + std + mv_cmd;
        }
        else{
          var mv_cmd = mv + "somaticSV.vcf.gz " + inputs.output_basename + ".manta.somaticSV.vcf.gz" + mv + "somaticSV.vcf.gz.tbi " + inputs.output_basename + ".manta.somaticSV.vcf.gz.tbi" + mv + "candidateSmallIndels.vcf.gz " + inputs.output_basename + ".manta.candidateSmallIndels.vcf.gz" + mv + "candidateSmallIndels.vcf.gz.tbi " + inputs.output_basename + ".manta.candidateSmallIndels.vcf.gz.tbi";
          var normal_crams = "";
          for (var i=0; i < inputs.input_normal_reads.length; i++) {
            normal_crams += " --normalBam " + inputs.input_normal_reads[i].path
          }
          return "--tumorBam " + inputs.input_tumor_reads.path + normal_crams + std + mv_cmd;
        }
      }

inputs:
    reference: {type: 'File', secondaryFiles: [{pattern: '^.dict', required: true}, {pattern: '.fai', required: true}]}
    hg38_strelka_bed: {type: 'File?', secondaryFiles: [{pattern: '.tbi', required: true}]}
    input_tumor_reads: {type: 'File?', secondaryFiles: [{pattern: '.crai', required: false}, {pattern: '.bai', required: false}]}
    input_normal_reads: {type: 'File[]?', secondaryFiles: [{pattern: '.crai', required: false}, {pattern: '.bai', required: false}]}
    cores: {type: 'int?', default: 16}
    ram: {type: 'int?', default: 32, doc: "GB of RAM an instance must have to run the task"}
    output_basename: string
outputs:
  output_sv:
    type: File
    outputBinding:
      glob: '*SV.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
  small_indels:
    type: File
    outputBinding:
      glob: '*SmallIndels.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
