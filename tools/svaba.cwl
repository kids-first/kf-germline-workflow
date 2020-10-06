cwlVersion: v1.0
class: CommandLineTool
id: svaba
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/svaba:1.1.0'
  - class: ResourceRequirement
    ramMin: $(inputs.ram)
    coresMin: $(inputs.cores)
baseCommand: ['svaba','run']
inputs:
  case_bams: { type: {type: 'array', items: 'File', inputBinding: { prefix: '--case-bam' } }, secondaryFiles: [.bai], inputBinding: { position: 0 }, doc: "Case BAM/CRAM/SAM file (eg tumor). Can input multiple." }
  control_bams: { type: ['null', {type: 'array', items: 'File', inputBinding: { prefix: '--control-bam' } }], secondaryFiles: [.bai], inputBinding: { position: 0 }, doc: "(optional) Control BAM/CRAM/SAM file (eg normal). Can input multiple." }
  reference_genome: { type: 'File', secondaryFiles: [.amb,.ann,.bwt,.fai,.pac,.sa], inputBinding: { prefix: '--reference-genome', position: 0 }, doc: "Path to indexed reference genome to be used by BWA-MEM." }
  dbsnp_vcf: { type: 'File', inputBinding: { prefix: '--dbsnp-vcf', position: 0 }, doc: "DBsnp database (VCF) to compare indels against" }
  region: { type: 'File?', inputBinding: { prefix: '--region', position: 0 }, doc: "Run on targeted intervals. Accepts BED file" }
  blacklist: { type: 'File?', inputBinding: { prefix: '--blacklist', position: 0 }, doc: "BED-file with blacklisted regions to not extract any reads from." }
  germline_sv_database: { type: 'File?', inputBinding: { prefix: '--germline-sv-database', position: 0 }, doc: "BED file containing sites of known germline SVs. Used as additional filter for somatic SV detection." }

  gzip: { type: 'boolean?', default: true, inputBinding: { valueFrom: "$(self ? '--g-zip' : '')", position: 0 }, doc: "Gzip and tabix the output VCF files." }
  germline: { type: 'boolean?', default: false, inputBinding: { valueFrom: "$(self ? '--germline' : '')", position: 0}, doc: "Sets recommended settings for case-only analysis (eg germline). (-I, -L5, assembles NM >= 3 reads)" }
  rules: { type: 'boolean?', default: false, inputBinding: { valueFrom: "$(self ? '--rules all' : '')", position: 0 }, doc: "Default behavior is just assemble clipped/discordant/unmapped/gapped reads. Override?" }
  highly_parallel: { type: 'boolean?', default: false, inputBinding: { valueFrom: "$(self ? '--hp' : '')", position: 0 }, doc: "Highly parallel. Don't write output until completely done. More memory, but avoids all thread-locks." }

  output_basename: { type: 'string', inputBinding: { prefix: '--id-string', position: 0 }, doc: "String specifying the analysis ID to be used as part of ID common." }
  cores: { type: 'int?', default: 4, inputBinding: { prefix: '--threads', position: 0 }, doc: "Use NUM threads to run svaba." }
  ram: { type: 'int?', default: 8, doc: "Minimum ram to allocate to the task." }
outputs:
  alignments: { type: 'File', outputBinding: { glob: $(inputs.output_basename).alignments.txt.gz } }
  bps: { type: 'File', outputBinding: { glob: $(inputs.output_basename).bps.txt.gz } }
  configs: { type: 'File', outputBinding: { glob: $(inputs.output_basename).contigs.bam } }
  log: { type: 'File', outputBinding: { glob: $(inputs.output_basename).log } }
  germline_indel_vcf: { type: 'File', outputBinding: { glob: $(inputs.output_basename).svaba.germline.indel.vcf.gz }, secondaryFiles: [.tbi] }
  germline_sv_vcf: { type: 'File', outputBinding: { glob: $(inputs.output_basename).svaba.sv.indel.vcf.gz }, secondaryFiles: [.tbi] }
  somatic_indel_vcf: { type: 'File', outputBinding: { glob: $(inputs.output_basename).svaba.somatic.indel.vcf.gz }, secondaryFiles: [.tbi] }
  somatic_sv_vcf: { type: 'File', outputBinding: { glob: $(inputs.output_basename).svaba.somatic.sv.vcf.gz }, secondaryFiles: [.tbi] }
  germline_indel_unfiltered_vcf: { type: 'File', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.germline.indel.vcf.gz }, secondaryFiles: [.tbi] }
  germline_sv_unfiltered_vcf: { type: 'File', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.germline.sv.vcf.gz }, secondaryFiles: [.tbi] }
  somatic_indel_unfiltered_vcf: { type: 'File', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.somatic.indel.vcf.gz }, secondaryFiles: [.tbi] }
  somatic_sv_unfiltered_vcf: { type: 'File', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.somatic.sv.vcf.gz },  secondaryFiles: [.tbi] }
