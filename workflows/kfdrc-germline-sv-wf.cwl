cwlVersion: v1.2
class: Workflow
id: kfdrc-germline-sv-wf 
doc: |
  # KFDRC Germline SV Workflow 
  SVaba
  Manta
  AnnotSV x2

  ### Runtime Estimates
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
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
    "sbg:fileTypes": "FASTA, FA"
    "sbg:suggestedValue": {
      class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [
        {class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict},
        {class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai},
        {class: File, path: 60639019357c3a53540ca7eb, name: Homo_sapiens_assembly38.fasta.64.alt},
        {class: File, path: 6063901f357c3a53540ca84d, name: Homo_sapiens_assembly38.fasta.64.amb},
        {class: File, path: 6063901f357c3a53540ca849, name: Homo_sapiens_assembly38.fasta.64.ann},
        {class: File, path: 6063901d357c3a53540ca81e, name: Homo_sapiens_assembly38.fasta.64.bwt},
        {class: File, path: 6063901c357c3a53540ca801, name: Homo_sapiens_assembly38.fasta.64.pac},
        {class: File, path: 60639015357c3a53540ca7a9, name: Homo_sapiens_assembly38.fasta.64.sa}
      ]
    }
  input_bams: {type: 'File[]', secondaryFiles: [{pattern: '^.bai', required: false}, {pattern: '.bai', required: false}], doc: "Input BAM file", "sbg:fileTypes": "BAM"} 

  annotsv_annotations_dir: { type: 'File', doc: "TAR.GZ'd Directory containing annotations", "sbg:fileTypes": "TAR, TAR.GZ, TGZ", "sbg:suggestedValue": {class: File, path: 6245fde8274f85577d646da0, name: annotsv_311_annotations_dir.tgz} } 
  annotsv_genome_build:
    type:
      - 'null'
      - type: enum
        name: annotsv_genome_build
        symbols: ["GRCh37","GRCh38","mm9","mm10"]

  output_basename: {type: 'string', doc: "String value to use as basename for outputs"}

  # Resource Requirements
  svaba_cpu: {type: 'int?', doc: "CPUs to allocate to SVaba"}
  svaba_ram: {type: 'int?', doc: "GB of RAM to allocate to SVava"}
  manta_cpu: {type: 'int?', doc: "CPUs to allocate to Manta"}
  manta_ram: {type: 'int?', doc: "GB of RAM to allocate to Manta"}

outputs:
  svaba_indels: {type: 'File', outputSource: svaba/germline_indel_vcf_gz}
  svaba_svs: {type: 'File', outputSource: svaba/germline_sv_vcf_gz}
  svaba_annotated_svs: {type: 'File?', outputSource: annotsv_svaba/annotated_calls}
  svaba_unannotated_svs: {type: 'File?', outputSource: annotsv_svaba/unannotated_calls}
  manta_indels: {type: 'File', outputSource: manta/small_indels}
  manta_svs: {type: 'File', outputSource: manta/output_sv}
  manta_annotated_svs: {type: 'File?', outputSource: annotsv_manta/annotated_calls}
  manta_unannotated_svs: {type: 'File?', outputSource: annotsv_manta/unannotated_calls}

steps:
  svaba:
    run: ../tools/svaba.cwl
    in:
      tumor_bams: input_bams
      reference_genome: indexed_reference_fasta 
      germline:
        valueFrom: $(1 == 1)
      output_basename: output_basename 
      cores: svaba_cpu
      ram: svaba_ram
    out: [alignments, bps, contigs, log, germline_indel_vcf_gz, germline_indel_unfiltered_vcf_gz, germline_sv_vcf_gz, germline_sv_unfiltered_vcf_gz]

  manta:
    run: ../tools/manta.cwl
    in:
      reference: indexed_reference_fasta 
      input_normal_reads: input_bams 
      output_basename: output_basename
      cores: manta_cpu
      ram: manta_ram 
    out: [output_sv, small_indels]

  annotsv_svaba:
    run: ../tools/annotsv.cwl
    in:
      annotations_dir_tgz: annotsv_annotations_dir
      sv_input_file: svaba/germline_sv_vcf_gz
      genome_build: annotsv_genome_build
    out: [annotated_calls, unannotated_calls]

  annotsv_manta:
    run: ../tools/annotsv.cwl
    in:
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
