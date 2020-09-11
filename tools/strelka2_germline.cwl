cwlVersion: v1.0
class: CommandLineTool
id: strelka2_germline
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'kfdrc/strelka:v2.9.10'

baseCommand: [/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaGermlineWorkflow.py, --runDir=./]
arguments:
  - position: 2
    shellQuote: false
    valueFrom: >-
      && ./runWorkflow.py
      -m local
      -j $(inputs.cores)

inputs:
  input_bams: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--bam=', separate: false }}], secondaryFiles: [.bai], inputBinding: { position: 1 }, doc: "List of one or more BAMs" }
  input_crams: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--bam=', separate: false }}], secondaryFiles: [.crai], inputBinding: { position: 1 }, doc: "List of one or more CRAMs" }
  reference: { type: 'File', secondaryFiles: [.fai], inputBinding: { prefix: '--referenceFasta=', separate: false }, doc: "Samtools-indexed reference fasta file" }
  call_regions: { type: 'File?', secondaryFiles: [.tbi], inputBinding: { position: 1, prefix: '--callRegions=', separate: false }, doc: "bgzip-compressed/tabix-indexed BED file containing the set of regions to call. No VCF output will be provided outside of these regions." }
  compress: { type: 'File?', secondaryFiles: [.tbi], inputBinding: { position: 1, prefix: '--noCompress=', separate: false }, doc: "Provide BED file of regions where gVCF block compression is not allowed. File must be bgzip-compressed/tabix-indexed." }
  forced_gt: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--forcedGT=', separate: false }}], secondaryFiles: [.tbi], inputBinding: { position: 1 }, doc: "Specify a VCF of candidate alleles. These alleles are always evaluated and reported even if they are unlikely to exist in the sample. The VCF must be tabix indexed. All indel alleles must be left-shifted/normalized, any unnormalized allele will trigger a runtime error. This option may be specified more than once, multiple input VCFs will be merged. Note that for any SNVs provided in the VCF, the SNV site will be reported (and for gVCF, excluded from block compression), but the specific SNV alleles are ignored." }
  indel_candidates: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--indelCandidates=', separate: false }}], secondaryFiles: [.tbi], inputBinding: { position: 1 }, doc: "Specify a VCF of candidate indel alleles. These alleles are always evaluated but only reported in the output when they are inferred to exist in the sample. The VCF must be tabix indexed. All indel alleles must be left-shifted/normalized, any unnormalized alleles will be ignored. This option may be specified more than once, multiple input VCFs will be merged." }
  ploidy: { type: 'File?', secondaryFiles: [.tbi], inputBinding: { position: 1, prefix: '--ploidy=', separate: false }, doc: "Provide ploidy file in VCF. The VCF should include one sample column per input sample labeled with the same sample names found in the input BAM/CRAM RG header sections. Ploidy should be provided in records using the FORMAT/CN field, which are interpreted to span the range [POS+1, INFO/END]. Any CN value besides 1 or 0 will be treated as 2. File must be tabix indexed." }
  call_continuous_vf: { type: 'string?', inputBinding: { position : 1, prefix: '--callContinuousVf=', separate: false }, doc: "Call variants on the CHROM string provided without a ploidy prior assumption, issuing calls with continuous variant frequencies" }
  rna: { type: 'boolean?', default: false, inputBinding: { position: 1, prefix: '--rna' }, doc: "Set options for RNA-Seq input." }
  exome: { type: 'boolean?', default: false, inputBinding: { position: 1, prefix: '--exome' }, doc: "Set options for exome or other targeted input: note in particular that this flag turns off high-depth filters." }
  cores: { type: 'int?', default: 4, doc: "Number of cores to allocate to this task." }
  ram: { type: 'int?', default: 8, doc: "GB of memory to allocate to this task." }
outputs:
  output_snv:
    type: 'File'
    outputBinding:
      glob: 'results/variants/*.snvs.vcf.gz'
    secondaryFiles: [.tbi]
  output_indel:
    type: 'File'
    outputBinding:
      glob: 'results/variants/*.indels.vcf.gz'
    secondaryFiles: [.tbi]

