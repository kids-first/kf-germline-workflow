cwlVersion: v1.2
class: Workflow
id: kfdrc-germline-sv-wf
label: Kids First DRC Germline SV Workflow
doc: |
  # Kids First Data Resource Center Germline Structural Variant Workflow

  <p align="center">
    <img src="https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png">
  </p>

  The Kids First Data Resource Center (KFDRC) Germline Structural Variant (SV)
  Caller Workflow is a common workflow language (CWL) implmentation to generate
  SV calls from an aligned reads BAM or CRAM file. The workflow makes use of
  Manta and SvABA to call varaiants then annotates these variants using AnnotSV.

  ## Relevant Softwares and Versions

  - [Manta](https://github.com/Illumina/manta): `1.6.0`
  - [SvABA](https://github.com/walaj/svaba): `1.1.0`
  - [AnnotSV](https://github.com/lgmgeo/AnnotSV/): `3.1.1`

  ### Manta

  Manta calls structural variants (SVs) and indels from mapped paired-end
  sequencing reads. It is optimized for analysis of germline variation in small
  sets of individuals and somatic variation in tumor/normal sample pairs. Manta
  discovers, assembles and scores large-scale SVs, medium-sized indels and large
  insertions within a single efficient workflow. The method is designed for rapid
  analysis on standard compute hardware: NA12878 at 50x genomic coverage is
  analyzed in less than 20 minutes on a 20 core server, and most WGS tumor/normal
  analyses can be completed within 2 hours. Manta combines paired and split-read
  evidence during SV discovery and scoring to improve accuracy, but does not
  require split-reads or successful breakpoint assemblies to report a variant in
  cases where there is strong evidence otherwise. It provides scoring models for
  germline variants in small sets of diploid samples and somatic variants in
  matched tumor/normal sample pairs.

  ### SvABA

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
  "somatic" and "germline" VCFs. If only a single BAM/CRAM is present (input with
  the -t flag), a single SV and a single indel VCF will be emitted.

  A BWA-MEM index reference genome must also be supplied with -G.

  ### AnnotSV

  AnnotSV is a program designed for annotating and ranking Structural Variations
  (SV). This tool compiles functionally, regulatory and clinically relevant
  information and aims at providing annotations useful to i) interpret SV
  potential pathogenicity and ii) filter out SV potential false positives.

  ## Input Files

  - Universal
      - `germline_reads`: The germline BAM/CRAM input that has been aligned to a reference genome.
      - `indexed_reference_fasta`: The reference genome fasta (and associated indicies) to which the germline BAM/CRAM was aligned.
  - AnnotSV
      - `annotsv_annotations_dir`: These annotations are simply those from the install-human-annotation installation process run during AnnotSV installation (see: https://github.com/lgmgeo/AnnotSV/#quick-installation). Specifically these are the annotations installed with v3.1.1 of the software. Newer or older annotations can be slotted in here as needed.

  ## Output Files

  - Manta
      - `manta_svs`: Structural Variants called by Manta
      - `manta_indels`: Small INDELs called by Manta
  - SvABA
      - `svaba_svs`: Structural Variants called by SvABA
      - `svaba_indels`: Small INDELs called by SvABA
  - AnnotSV
      - `manta_annotated_svs`: This file contains all records from the `manta_svs` that AnnotSV could annotate.
      - `svaba_annotated_svs`: This file contains all records from the `svaba_svs` that AnnotSV could annotate.

  ## Basic Info
  - [D3b dockerfiles](https://github.com/d3b-center/bixtools)
  - Testing Tools:
      - [Seven Bridges Cavatica Platform](https://cavatica.sbgenomics.com/)
      - [Common Workflow Language reference implementation (cwltool)](https://github.com/common-workflow-language/cwltool/)

  ## References
  - KFDRC AWS s3 bucket: s3://kids-first-seq-data/broad-references/
  - Cavatica: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/
  - Broad Institute Goolge Cloud: https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0/
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
inputs:
  indexed_reference_fasta:
    type: 'File'
    secondaryFiles:
    - {pattern: '^.dict', required: true}
    - {pattern: '.fai', required: true}
    - {pattern: '.64.alt', required: false}
    - {pattern: '.64.amb', required: true}
    - {pattern: '.64.ann', required: true}
    - {pattern: '.64.bwt', required: true}
    - {pattern: '.64.pac', required: true}
    - {pattern: '.64.sa', required: true}
    doc: |
      The reference genome fasta (and associated indicies) to which the germline BAM was aligned.
    "sbg:fileTypes": "FASTA, FA"
    "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [{class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict},
        {class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai},
        {class: File, path: 60639019357c3a53540ca7eb, name: Homo_sapiens_assembly38.fasta.64.alt},
        {class: File, path: 6063901f357c3a53540ca84d, name: Homo_sapiens_assembly38.fasta.64.amb},
        {class: File, path: 6063901f357c3a53540ca849, name: Homo_sapiens_assembly38.fasta.64.ann},
        {class: File, path: 6063901d357c3a53540ca81e, name: Homo_sapiens_assembly38.fasta.64.bwt},
        {class: File, path: 6063901c357c3a53540ca801, name: Homo_sapiens_assembly38.fasta.64.pac},
        {class: File, path: 60639015357c3a53540ca7a9, name: Homo_sapiens_assembly38.fasta.64.sa}]}
  germline_reads: {type: 'File', secondaryFiles: [{pattern: '^.bai', required: false},
      {pattern: '.bai', required: false}, {pattern: '^.crai', required: false}, {
        pattern: '.crai', required: false}], doc: "Input BAM file", "sbg:fileTypes": "BAM,\
      \ CRAM"}
  annotsv_annotations_dir: {type: 'File', doc: "TAR.GZ'd Directory containing AnnotSV\
      \ annotations", "sbg:fileTypes": "TAR, TAR.GZ, TGZ", "sbg:suggestedValue": {
      class: File, path: 6245fde8274f85577d646da0, name: annotsv_311_annotations_dir.tgz}}
  annotsv_genome_build:
    type:
    - 'null'
    - type: enum
      name: annotsv_genome_build
      symbols: ["GRCh37", "GRCh38", "mm9", "mm10"]
    doc: |
      The genome build of the reference fasta. AnnotSV is capable of annotating the following genomes: "GRCh37","GRCh38","mm9","mm10".
  output_basename: {type: 'string?', doc: "String value to use as basename for outputs"}
  run_svaba: {type: 'boolean?', default: true, doc: "Run the SVaba module?"}
  run_manta: {type: 'boolean?', default: true, doc: "Run the Manta module?"}
  svaba_cpu: {type: 'int?', doc: "CPUs to allocate to SVaba"}
  svaba_ram: {type: 'int?', doc: "GB of RAM to allocate to SVava"}
  manta_cpu: {type: 'int?', doc: "CPUs to allocate to Manta"}
  manta_ram: {type: 'int?', doc: "GB of RAM to allocate to Manta"}
outputs:
  svaba_indels: {type: 'File?', outputSource: svaba/germline_indel_vcf_gz, doc: "VCF\
      \ containing INDEL variants called by SvABA"}
  svaba_svs: {type: 'File?', outputSource: svaba/germline_sv_vcf_gz, doc: "VCF containing\
      \ SV called by SvABA"}
  svaba_annotated_svs: {type: 'File?', outputSource: annotsv_svaba/annotated_calls,
    doc: "TSV containing annotated variants from the svaba_svs output"}
  manta_indels: {type: 'File?', outputSource: manta/small_indels, doc: "VCF containing\
      \ INDEL variants called by Manta"}
  manta_svs: {type: 'File?', outputSource: manta/output_sv, doc: "VCF containing SV\
      \ called by Manta"}
  manta_annotated_svs: {type: 'File?', outputSource: annotsv_manta/annotated_calls,
    doc: "TSV containing annotated variants from the manta_svs output"}
steps:
  svaba:
    run: ../tools/svaba.cwl
    when: $(inputs.run_svaba)
    in:
      run_svaba: run_svaba
      tumor_bams:
        source: germline_reads
        valueFrom: $([self])
      reference_genome: indexed_reference_fasta
      germline:
        valueFrom: $(1 == 1)
      output_basename:
        source: output_basename
        valueFrom: |
          $(self != null ? self : inputs.tumor_bams[0].basename.split('.')[0])
      cores: svaba_cpu
      ram: svaba_ram
    out: [alignments, bps, contigs, log, germline_indel_vcf_gz, germline_indel_unfiltered_vcf_gz,
      germline_sv_vcf_gz, germline_sv_unfiltered_vcf_gz]
  manta:
    run: ../tools/manta.cwl
    when: $(inputs.run_manta)
    in:
      run_manta: run_manta
      reference: indexed_reference_fasta
      input_normal_reads:
        source: germline_reads
        valueFrom: $([self])
      output_basename:
        source: output_basename
        valueFrom: |
          $(self != null ? self : inputs.input_normal_reads[0].basename.split('.')[0])
      cores: manta_cpu
      ram: manta_ram
    out: [output_sv, small_indels]
  annotsv_svaba:
    run: ../tools/annotsv.cwl
    when: $(inputs.run_svaba)
    in:
      run_svaba: run_svaba
      annotations_dir_tgz: annotsv_annotations_dir
      sv_input_file: svaba/germline_sv_vcf_gz
      genome_build: annotsv_genome_build
    out: [annotated_calls, unannotated_calls]
  annotsv_manta:
    run: ../tools/annotsv.cwl
    when: $(inputs.run_manta)
    in:
      run_manta: run_manta
      annotations_dir_tgz: annotsv_annotations_dir
      sv_input_file: manta/output_sv
      genome_build: annotsv_genome_build
    out: [annotated_calls, unannotated_calls]
hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
$namespaces:
  sbg: https://sevenbridges.com
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- ANNOTATION
- ANNOTSV
- GERMLINE
- MANTA
- STRUCTURAL
- SV
- SVABA
- VCF
"sbg:links":
- id: 'https://github.com/kids-first/kf-germline-workflow/releases/tag/v1.0.0'
  label: github-release
