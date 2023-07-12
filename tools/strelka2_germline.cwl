cwlVersion: v1.2
class: CommandLineTool
id: strelka2_germline
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/strelka:v2.9.10'
  - class: InitialWorkDirRequirement
    listing:
      - writable: false
        entryname: "filenames.txt"
        entry: >-
          ${
              function get_file_prefix(f) {
                  if (f.metadata) {
                      if (f.metadata['sample_id']) {
                          return f.metadata['sample_id'];
                      } else {
                          return f.nameroot;
                      }
                  } else {
                      return f.nameroot;
                  }
              }
              var input_files = inputs.input_reads.filter(function (el) {return el != null})
              if (input_files.length > 1) {
                  var file_content = [];
                  for (var i = 0; i < input_files.length; i++) {
                      var prefix = get_file_prefix(input_files[i]);
                      file_content.push(prefix + ".strelka_genome.S" + (i + 1));
                  }
                  return file_content.join("\n");
              } else if (input_files.length == 1) {
                  return get_file_prefix(input_files[0]) + ".strelka_genome.S1";
              } else {
                  return "";
              }
          }

baseCommand: [/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaGermlineWorkflow.py, --runDir=./]
arguments:
  - position: 2
    shellQuote: false
    valueFrom: >-
      && ./runWorkflow.py
      -m local
      -j $(inputs.cpu)
  - position: 3
    shellQuote: false
    valueFrom: >-
      && bash ${return "-c 'for i in results/variants/*; do if [[ $i =~ .+.S[0-9]+.vcf.gz$ ]]; then filename=$(awk \"NR==$(basename=$(basename $i .vcf.gz); IFS='.S' read -ra NAMES <<< $basename; echo ${NAMES[-1]})\" filenames.txt); mv $i "+inputs.output_basename+".${filename}.g.vcf.gz; mv ${i}.tbi  "+inputs.output_basename+".${filename}.g.vcf.gz.tbi; fi done' && mv results/variants/variants.vcf.gz "+inputs.output_basename+".strelka_variants.vcf.gz && mv results/variants/variants.vcf.gz.tbi "+inputs.output_basename+".strelka_variants.vcf.gz.tbi"}

inputs:
  input_reads: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--bam=', separate: false }}], secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}], inputBinding: { position: 1 }, doc: "List of one or more BAM/CRAM/SAMs" }
  reference: { type: 'File', secondaryFiles: [{pattern: '.fai', required: true}], inputBinding: { prefix: '--referenceFasta=', separate: false }, doc: "Samtools-indexed reference fasta file" }
  call_regions: { type: 'File?', secondaryFiles: [{pattern: '.tbi', required: true}], inputBinding: { position: 1, prefix: '--callRegions=', separate: false }, doc: "bgzip-compressed/tabix-indexed BED file containing the set of regions to call. No VCF output will be provided outside of these regions." }
  compress: { type: 'File?', secondaryFiles: [{pattern: '.tbi', required: true}], inputBinding: { position: 1, prefix: '--noCompress=', separate: false }, doc: "Provide BED file of regions where gVCF block compression is not allowed. File must be bgzip-compressed/tabix-indexed." }
  forced_gt: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--forcedGT=', separate: false }}], secondaryFiles: [.tbi], inputBinding: { position: 1 }, doc: "Specify a VCF of candidate alleles. These alleles are always evaluated and reported even if they are unlikely to exist in the sample. The VCF must be tabix indexed. All indel alleles must be left-shifted/normalized, any unnormalized allele will trigger a runtime error. This option may be specified more than once, multiple input VCFs will be merged. Note that for any SNVs provided in the VCF, the SNV site will be reported (and for gVCF, excluded from block compression), but the specific SNV alleles are ignored." }
  indel_candidates: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--indelCandidates=', separate: false }}], secondaryFiles: [.tbi], inputBinding: { position: 1 }, doc: "Specify a VCF of candidate indel alleles. These alleles are always evaluated but only reported in the output when they are inferred to exist in the sample. The VCF must be tabix indexed. All indel alleles must be left-shifted/normalized, any unnormalized alleles will be ignored. This option may be specified more than once, multiple input VCFs will be merged." }
  ploidy: { type: 'File?', secondaryFiles: [.tbi], inputBinding: { position: 1, prefix: '--ploidy=', separate: false }, doc: "Provide ploidy file in VCF. The VCF should include one sample column per input sample labeled with the same sample names found in the input BAM/CRAM RG header sections. Ploidy should be provided in records using the FORMAT/CN field, which are interpreted to span the range [POS+1, INFO/END]. Any CN value besides 1 or 0 will be treated as 2. File must be tabix indexed." }
  call_continuous_vf: { type: 'string?', inputBinding: { position : 1, prefix: '--callContinuousVf=', separate: false }, doc: "Call variants on the CHROM string provided without a ploidy prior assumption, issuing calls with continuous variant frequencies" }
  rna: { type: 'boolean?', default: false, inputBinding: { position: 1, prefix: '--rna' }, doc: "Set options for RNA-Seq input." }
  exome: { type: 'boolean?', default: false, inputBinding: { position: 1, prefix: '--exome' }, doc: "Set options for exome or other targeted input: note in particular that this flag turns off high-depth filters." }
  cpu: { type: 'int?', default: 32, doc: "Number of cores to allocate to this task." }
  ram: { type: 'int?', default: 32, doc: "GB of memory to allocate to this task." }
  output_basename: {type: 'string?', default: 'output', doc: "Basename for the output files"}
outputs:
  variants_vcf_gz:
    type: 'File'
    outputBinding:
      glob: '$(inputs.output_basename).strelka_variants.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
  genome_vcf_gzs:
    type: 'File[]'
    outputBinding:
      glob: '$(inputs.output_basename).*.g.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
