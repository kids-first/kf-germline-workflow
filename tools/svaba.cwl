cwlVersion: v1.0
class: CommandLineTool
id: svaba
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/svaba:1.1.0'
  - class: ResourceRequirement
    ramMin: $(inputs.ram)
    coresMin: $(inputs.cores)
baseCommand: ['svaba','run']
inputs:
  tumor_bams: { type: {type: 'array', items: 'File', inputBinding: { prefix: '--tumor-bam' } }, secondaryFiles: [^.bai], inputBinding: { position: 0 }, doc: "Case BAM/CRAM/SAM file (eg tumor). Can input multiple." }
  normal_bams: { type: ['null', {type: 'array', items: 'File', inputBinding: { prefix: '--normal-bam' } }], secondaryFiles: [^.bai], inputBinding: { position: 0 }, doc: "(optional) Control BAM/CRAM/SAM file (eg normal). Can input multiple." }
  reference_genome: { type: 'File', secondaryFiles: [.fai,.64.amb,.64.ann,.64.bwt,.64.pac,.64.sa], inputBinding: { prefix: '--reference-genome', position: 0 }, doc: "Path to indexed reference genome to be used by BWA-MEM." }

  dbsnp_vcf: { type: 'File?', inputBinding: { prefix: '--dbsnp-vcf', position: 0 }, doc: "DBsnp database (VCF) to compare indels against" }
  region_file: { type: 'File?', inputBinding: { prefix: '--region-file', position: 0 }, doc: "Run on targeted intervals. Accepts BED file" }
  blacklist: { type: 'File?', inputBinding: { prefix: '--blacklist', position: 0 }, doc: "BED-file with blacklisted regions to not extract any reads from." }
  germline_sv_database: { type: 'File?', inputBinding: { prefix: '--germline-sv-database', position: 0 }, doc: "BED file containing sites of known germline SVs. Used as additional filter for somatic SV detection." }

  gzip: { type: 'boolean?', default: true, inputBinding: { prefix: '--g-zip', position: 0 }, doc: "Gzip and tabix the output VCF files." }
  germline: { type: 'boolean?', default: false, inputBinding: { prefix: '--germline', position: 0}, doc: "Sets recommended settings for case-only analysis (eg germline). (-I, -L5, assembles NM >= 3 reads)" }
  rules: { type: 'boolean?', default: false, inputBinding: { valueFrom: "$(self ? '--rules all' : '')", position: 0 }, doc: "Default behavior is just assemble clipped/discordant/unmapped/gapped reads. Override?" }
  highly_parallel: { type: 'boolean?', default: false, inputBinding: { prefix: '--hp', position: 0 }, doc: "Highly parallel. Don't write output until completely done. More memory, but avoids all thread-locks." }
  no_interchrom_lookup: { type: 'boolean?', default: false, inputBinding: { prefix: '--no-interchrom-lookup', position: 0 }, doc: "Set true to not do mate-region lookup if mates are mapped to different chromosome." }

  mate_lookup_min: { type: 'int?', inputBinding: { prefix: '--mate-lookup-min', position: 0 }, doc: "Minimum number of somatic reads required to attempt mate-region lookup" }

  output_basename: { type: 'string', inputBinding: { prefix: '--id-string', position: 0 }, doc: "String specifying the analysis ID to be used as part of ID common." }
  cores: { type: 'int?', default: 8, inputBinding: { prefix: '--threads', position: 0 }, doc: "Use NUM threads to run svaba." }
  ram: { type: 'int?', default: 8, doc: "Minimum ram to allocate to the task." }
outputs:
  alignments: { type: 'File', outputBinding: { glob: $(inputs.output_basename).alignments.txt.gz }, doc: "An ASCII plot of variant-supporting contigs and the BWA-MEM alignment of reads to the contigs" }
  bps: { type: 'File', outputBinding: { glob: $(inputs.output_basename).bps.txt.gz }, doc: "Raw, unfiltered variants" }
  contigs: { type: 'File', outputBinding: { glob: $(inputs.output_basename).contigs.bam }, doc: "All assembly contigs as aligned to the reference with BWA-MEM" }
  log: { type: 'File', outputBinding: { glob: $(inputs.output_basename).log }, doc: "Log file giving run-time information, including CPU and Wall time (and how it was partitioned among the tasks), number of reads retrieved and contigs assembled for each region" }
  germline_indel_vcf_gz: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.$(inputs.normal_bams ? 'germline.' : '')indel.vcf.gz" }, secondaryFiles: [.tbi] }
  germline_indel_unfiltered_vcf_gz: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.unfiltered.$(inputs.normal_bams ? 'germline.' : '')indel.vcf.gz" }, secondaryFiles: [.tbi] }
  germline_sv_vcf_gz: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.$(inputs.normal_bams ? 'germline.' : '')sv.vcf.gz" }, secondaryFiles: [.tbi] }
  germline_sv_unfiltered_vcf_gz: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.unfiltered.$(inputs.normal_bams ? 'germline.' : '')sv.vcf.gz" }, secondaryFiles: [.tbi] }
  somatic_indel_vcf_gz: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.somatic.indel.vcf.gz }, secondaryFiles: [.tbi] }
  somatic_indel_unfiltered_vcf_gz: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.somatic.indel.vcf.gz }, secondaryFiles: [.tbi] }
  somatic_sv_vcf_gz: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.somatic.sv.vcf.gz }, secondaryFiles: [.tbi] }
  somatic_sv_unfiltered_vcf_gz: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.somatic.sv.vcf.gz },  secondaryFiles: [.tbi] }
  germline_indel_vcf: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.$(inputs.normal_bams ? 'germline.' : '')indel.vcf" } }
  germline_indel_unfiltered_vcf: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.unfiltered.$(inputs.normal_bams ? 'germline.' : '')indel.vcf" } }
  germline_sv_vcf: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.$(inputs.normal_bams ? 'germline.' : '')sv.vcf" } }
  germline_sv_unfiltered_vcf: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.unfiltered.$(inputs.normal_bams ? 'germline.' : '')sv.vcf" } }
  somatic_indel_vcf: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.somatic.indel.vcf } }
  somatic_indel_unfiltered_vcf: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.somatic.indel.vcf } }
  somatic_sv_vcf: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.somatic.sv.vcf } }
  somatic_sv_unfiltered_vcf: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.somatic.sv.vcf } }
