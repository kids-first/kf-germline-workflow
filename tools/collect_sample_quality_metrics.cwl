cwlVersion: v1.0
class: CommandLineTool
id: collect_sample_quality_metrics
doc: "Determines if sample VCF has less than the maximum number of events"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.2.0.0R'
baseCommand: ['/bin/bash','-c']
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      set -eo pipefail

      NUM_SEGMENTS=${return "$(gunzip -c " + inputs.genotyped_segments_vcf.path + " | grep -v '#' | wc -l)"}

      if [ $NUM_SEGMENTS -lt $(inputs.maximum_number_events) ]; then
          echo "PASS" >> $(inputs.entity_id).qcStatus.txt
      else
          echo "EXCESSIVE_NUMBER_OF_EVENTS" >> $(inputs.entity_id).qcStatus.txt
      fi
inputs:
  genotyped_segments_vcf: { type: 'File', secondaryFiles: [.tbi] }
  maximum_number_events: { type: 'int' }
  entity_id: { type: 'string' }
  ram: { type: 'int?', default: 1, doc: "GB of RAM to allocate to the task. default: 1" }
  cores: { type: 'int?', default: 1, doc: "Minimum reserved number of CPU cores for the task. default: 1" }
outputs:
  qc_status_file: { type: 'File', outputBinding: { glob: '*qcStatus.txt' } }
  qc_status_string: { type: 'string', outputBinding: { glob: '*qcStatus.txt', loadContents: true, outputEval: '$(self[0].contents)' } }
