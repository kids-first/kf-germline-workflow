cwlVersion: v1.2
class: CommandLineTool
id: svaba
doc: |
  SvABA is a method for detecting structural variants in sequencing data using
  genome-wide local assembly. Under the hood, SvABA uses a custom implementation
  of SGA (String Graph Assembler) by Jared Simpson, and BWA-MEM by Heng Li.
  Contigs are assembled for every 25kb window (with some small overlap) for every
  region in the genome. The default is to use only clipped, discordant, unmapped
  and indel reads, although this can be customized to any set of reads at the
  command line using VariantBam rules. These contigs are then immediately aligned
  to the reference with BWA-MEM and parsed to identify variants. Sequencing reads
  are then realigned to the contigs with BWA-MEM, and variants are scored by
  their read support.

  SvABA is currently configured to provide indel and rearrangement calls (and
  anything "in between"). It can jointly call any number of BAM/CRAM/SAM files,
  and has built-in support for case-control experiments (e.g. tumor/normal, or
  trios or quads). In case/control mode, any number of cases and controls (but
  min of 1 case) can be input, and will jointly assemble all sequences together.
  If both a case and control are present, variants are output separately in
  "somatic" and "germline" VCFs. If only a single SAM is present (input with the
  -t flag), a single SV and a single indel VCF will be emitted.

  A BWA-MEM index reference genome must also be supplied with -G.
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/svaba:1.1.0'
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cores)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      seq_cache_populate.pl -r $PWD/ref_cache $(inputs.reference_genome.path)
      && export REF_CACHE=$PWD/ref_cache/%2s/%2s/%s
      && svaba run
  - position: 11
    valueFrom: "--g-zip"
inputs:
  tumor_bams:
    type:
      type: array
      items: File
      inputBinding:
        prefix: '--tumor-bam'
    secondaryFiles: [{pattern: '^.bai', required: false}, {pattern: '.bai', required: false}, {pattern: '^.crai', required: false}, {pattern: '.crai', required: false}]
    inputBinding:
      position: 11
    doc: "Case BAM/CRAM/SAM file (eg tumor). Can input multiple."
  normal_bams:
    type:
      - 'null'
      - type: array
        items: File
        inputBinding:
          prefix: '--normal-bam'
    secondaryFiles: [{pattern: '^.bai', required: false}, {pattern: '.bai', required: false}, {pattern: '^.crai', required: false}, {pattern: '.crai', required: false}]
    inputBinding:
      position: 11
    doc: "Control BAM/CRAM/SAM file (eg normal). Can input multiple. Optional."
  reference_genome: { type: 'File', secondaryFiles: [{pattern: '.fai', required: true}, {pattern: '.64.amb', required: true}, {pattern: '.64.ann', required: true}, {pattern: '.64.bwt', required: true}, {pattern: '.64.pac', required: true}, {pattern: '.64.sa', required: true}], inputBinding: { prefix: '--reference-genome', position: 11 }, doc: "Path to indexed reference genome to be used by BWA-MEM." }

  dbsnp_vcf: { type: 'File?', inputBinding: { prefix: '--dbsnp-vcf', position: 11 }, doc: "DBsnp database (VCF) to compare indels against" }
  region_file: { type: 'File?', inputBinding: { prefix: '--region-file', position: 11 }, doc: "Run on targeted intervals. Accepts BED file" }
  blacklist: { type: 'File?', inputBinding: { prefix: '--blacklist', position: 11 }, doc: "BED-file with blacklisted regions to not extract any reads from." }
  germline_sv_database: { type: 'File?', inputBinding: { prefix: '--germline-sv-database', position: 11 }, doc: "BED file containing sites of known germline SVs. Used as additional filter for somatic SV detection." }

  germline: { type: 'boolean?', inputBinding: { prefix: '--germline', position: 11}, doc: "Sets recommended settings for case-only analysis (eg germline). (-I, -L5, assembles NM >= 3 reads)" }
  rules: { type: 'boolean?', inputBinding: { valueFrom: "$(self ? '--rules all' : '')", position: 11 }, doc: "Default behavior is just assemble clipped/discordant/unmapped/gapped reads. Override?" }
  highly_parallel: { type: 'boolean?', inputBinding: { prefix: '--hp', position: 11 }, doc: "Highly parallel. Don't write output until completely done. More memory, but avoids all thread-locks." }
  no_interchrom_lookup: { type: 'boolean?', inputBinding: { prefix: '--no-interchrom-lookup', position: 11 }, doc: "Set true to not do mate-region lookup if mates are mapped to different chromosome." }

  mate_lookup_min: { type: 'int?', inputBinding: { prefix: '--mate-lookup-min', position: 11 }, doc: "Minimum number of somatic reads required to attempt mate-region lookup" }

  output_basename: { type: 'string', inputBinding: { prefix: '--id-string', position: 11 }, doc: "String specifying the analysis ID to be used as part of ID common." }
  cores: { type: 'int?', default: 16, inputBinding: { prefix: '--threads', position: 11 }, doc: "Use NUM threads to run svaba." }
  ram: { type: 'int?', default: 16, doc: "Minimum ram to allocate to the task." }
outputs:
  alignments: { type: 'File', outputBinding: { glob: "*.alignments.txt.gz" }, doc: "An ASCII plot of variant-supporting contigs and the BWA-MEM alignment of reads to the contigs" }
  bps: { type: 'File', outputBinding: { glob: "*.bps.txt.gz" }, doc: "Raw, unfiltered variants" }
  contigs: { type: 'File', outputBinding: { glob: "*.contigs.bam" }, doc: "All assembly contigs as aligned to the reference with BWA-MEM" }
  log: { type: 'File', outputBinding: { glob: "*.log" }, doc: "Log file giving run-time information, including CPU and Wall time (and how it was partitioned among the tasks), number of reads retrieved and contigs assembled for each region" }
  germline_indel_vcf_gz: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.$(inputs.normal_bams ? 'germline.' : '')indel.vcf.gz" }, secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF containing germline indels that PASS filtration" }
  germline_indel_unfiltered_vcf_gz: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.unfiltered.$(inputs.normal_bams ? 'germline.' : '')indel.vcf.gz" }, secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF containing all germline indels, including non-PASS variants." }
  germline_sv_vcf_gz: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.$(inputs.normal_bams ? 'germline.' : '')sv.vcf.gz" }, secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF containing germline structural variants that PASS filtration" }
  germline_sv_unfiltered_vcf_gz: { type: 'File?', outputBinding: { glob: "$(inputs.output_basename).svaba.unfiltered.$(inputs.normal_bams ? 'germline.' : '')sv.vcf.gz" }, secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF containing all germline structural variants, including non-PASS variants." }
  somatic_indel_vcf_gz: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.somatic.indel.vcf.gz }, secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF containing somatic indels that PASS filtration." }
  somatic_indel_unfiltered_vcf_gz: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.somatic.indel.vcf.gz }, secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF containing all somatic indels, including non-PASS variants." }
  somatic_sv_vcf_gz: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.somatic.sv.vcf.gz }, secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF containing somatic structural variants that PASS filtration." }
  somatic_sv_unfiltered_vcf_gz: { type: 'File?', outputBinding: { glob: $(inputs.output_basename).svaba.unfiltered.somatic.sv.vcf.gz },  secondaryFiles: [{pattern: '.tbi', required: true}], doc: "VCF containing somatic structural variants, including non-PASS variants." }
