cwlVersion: v1.0
class: CommandLineTool
id: scatter_ploidy_calls_by_sample
doc: "Archive call files by sample, renaming so they will be glob'd in order"
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
      set -eu

      mkdir calls

      tar xzf $(inputs.contig_ploidy_calls_tar.path) -C calls/

      sample_ids=($(inputs.samples.join(' ')))

      num_samples=${ return inputs.samples.length }

      num_digits=${ return "${#num_samples}" }

      for (( i=0; i<${ return "${num_samples}" }; i++ ))
      do
        sleep 5
        sample_id=${ return "${sample_ids[$i]}" }
        padded_sample_index=${ return "$(printf \"%0${num_digits}d\" $i)" }
        tar -czf sample_${ return "${padded_sample_index}" }.${ return "${sample_id}" }.contig_ploidy_calls.tar.gz -C calls/SAMPLE_${ return "${i}" } .
      done
inputs:
  contig_ploidy_calls_tar: { type: 'File', doc: "TAR file output from GATK DetermineGermlineConfigPloidy" }
  samples: { type: 'string[]', doc: "One or more sample names" }
  ram: { type: int?, default: 1, doc: "GB of RAM to allocate to the task." }
  cores: { type: int?, default: 1, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  sample_contig_ploidy_calls_tars: { type: 'File[]', outputBinding: { glob: '*.contig_ploidy_calls.tar.gz' } }
