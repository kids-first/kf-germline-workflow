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
    dockerPull: 'kfdrc/gatk:4.1.7.0R'
baseCommand: ['/bin/bash/','-c']
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -e
      NUM_SEGMENTS=${return "$(gunzip -c " + inputs.genotyped_segments_vcf + " | grep -v '#' | wc -l)"}
      if [ $NUM_SEGMENTS -lt $(inputs.maximum_number_events) ]; then
          echo "PASS" >> $(inputs.entity_id).qcStatus.txt
      else 
          echo "EXCESSIVE_NUMBER_OF_EVENTS" >> $(inputs.entity_id).qcStatus.txt
      fi
inputs:
  genotyped_segments_vcf: { type: File } 
  maximum_number_events: { type: int }
  entity_id: { type: string }

  ram: { type: int?, default: 4, doc: "GB of RAM to allocate to the task. default: 4" }
  cores: { type: int?, default: 1, doc: "Minimum reserved number of CPU cores for the task. default: 1" }
outputs:
  qc_status_file: { type: File, outputBinding: { glob: '*qcStatus.txt' } }
  qc_status_string: { type: string, outputBinding: { glob: '*qcStatus.txt', loadContents: true, outputEval: '$(self[0].contents)' } }
