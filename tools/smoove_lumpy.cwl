cwlVersion: v1.2
class: CommandLineTool
id: kfdrc-smoove-lumpy-sv
doc: |
  smoove simplifies and speeds calling and genotyping SVs for short reads. It
  also improves specificity by removing many spurious alignment signals that are
  indicative of low-level noise and often contribute to spurious calls.
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/smoove:0.2.5'
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      set -euo pipefail

      mkdir TMP

      export TMPDIR=/$PWD/TMP

      ${
        if (inputs.input_tumor_align == null && inputs.input_normal_align == null){
          throw new Error('Need to provide one or both of a tumor bam/cram and normal bam/cram');
        }
        else{
          return "echo Simple alignment file input check passed";
        }
      }

      /samtools-1.9/misc/seq_cache_populate.pl
      -root $PWD/ref_cache
      $(inputs.reference.path)
      && export REF_CACHE=$PWD/ref_cache/%2s/%2s/%s
      && export REF_PATH=$(inputs.reference.path)
      && smoove
      call --name $(inputs.output_basename)
      --fasta $(inputs.reference.path)
      --processes $(inputs.cores)
      --outdir ./
      --genotype
      ${
          var args="";
          if (inputs.exclude_bed != null){
              args += " --exclude " + inputs.exclude_bed.path;
          }
          if (inputs.disable_smoove != null && inputs.disable_smoove == "Y"){
              args += " --noextrafilters";
          }
          if (inputs.duphold_flag != null && inputs.duphold_flag == "Y"){
              args += " --duphold";
          }
          if (inputs.support != null){
              args += " --support " + inputs.support;
          }
          if (inputs.input_tumor_align != null){
            args += " " + inputs.input_tumor_align.path;
          }
          if (inputs.input_normal_align != null){
            args += " " + inputs.input_normal_align.path;
          }
          return args;
      }

      tabix $(inputs.output_basename)-smoove.genotyped.vcf.gz

inputs:
  reference: { type: 'File',  secondaryFiles: [{pattern: '.fai', required: true}], doc: "Fasta genome assembly with samtools index" }
  input_tumor_align: { type: 'File?', secondaryFiles: [{pattern: '.crai', required: false}, {pattern: '.bai', required: false}], doc: "BAM/CRAM file containing aligned reads from the tumor sample." }
  input_normal_align: { type: 'File?', secondaryFiles: [{pattern: '.crai', required: false}, {pattern: '.bai', required: false}], doc: "BAM/CRAM file containing aligned reads from the normal sample." }
  exclude_bed: {type: 'File?', doc: "Bed file with regions to exlude from analysis, i.e. non-canonical chromosomes. Highly recommneded."}
  duphold_flag: {type: ['null', {type: enum, name: duphold_flag, symbols: ["Y", "N"] }], doc: "Run Brent P duphold and annotate DUP and DEL with depth change", default: "Y"}
  disable_smoove: {type: ['null', {type: enum, name: disable_smoove, symbols: ["Y", "N"] }], doc: "Disable smoove filtering, just do standard lumpy_filter", default: "N"}
  support: {type: 'int?', doc: "Min support for a variant. App default is 4."}
  output_basename: { type: 'string', doc: "String to use as the basename for ouptuts" }
  cores: {type: 'int?', default: 16, doc: "Cores to allocate to this task" }
  ram: {type: 'int?', default: 32, doc: "GB of RAM to allocate to this task" }

outputs:
  output:
    type: File
    outputBinding:
      glob: '*-smoove.genotyped.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
    doc: "GZIPPED VCF containing structural variant calls"
