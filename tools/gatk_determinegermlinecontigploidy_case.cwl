cwlVersion: v1.0
class: CommandLineTool
id: gatk_determinegermlinecontigploidy_case
doc: "Determines the baseline contig ploidy for germline samples given counts data. Case mode."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.1.7.0R'
baseCommand: ['/bin/bash', '-c']
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eu
      export MKL_NUM_THREADS=$(inputs.cores)
      export OMP_NUM_THREADS=$(inputs.cores)

      mkdir contig-ploidy-model
      tar xzf $(inputs.config_ploidy_model_tar.path) -C contig-ploidy-model

      /gatk --javaOptions "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" DetermineGermlineContigPloidy \\
          ${var arr=[]; for (var x = 0; x < inputs.read_count_files.length; x++) {arr.push(inputs.read_count_files[x].path)}; return (inputs.read_count_files.length > 0 ? '--input ' + arr.join(' ') : '')} \\
          --model contig-ploidy-model \\
          --output out \\
          --output-prefix case \\
          --verbosity $(inputs.verbosity) \\
          --mapping-error-rate $(inputs.mapping_error) \\ 
          --sample-psi-scale $(inputs.psi_scale_sample)

      tar c -C out/case-calls . | gzip -1 > case-contig-ploidy-calls.tar.gz

      rm -rf contig-ploidy-model
inputs:
  read_count_files: { type: 'File[]', doc: "Input paths for read-count files containing integer read counts in genomic intervals for all samples. All intervals specified via -L/-XL must be contained; if none are specified, then intervals must be identical and in the same order for all samples. If read-count files are given by Google Cloud Storage paths, have the extension .counts.tsv or .counts.tsv.gz, and have been indexed by IndexFeatureFile, only the specified intervals will be queried and streamed; this can reduce disk usage by avoiding the complete localization of all read-count files"}
  contig_ploidy_model_tar: { type: 'File', doc: "TAR of cohort model output from cohort mode Germline CNV run" }
  mapping_error: { type: 'float?', default: 0.01, doc: "Typical mapping error rate." }
  psi_scale_sample: { type: 'float?', default: 0.0001, doc: "Prior scale of the sample-specific correction to the coverage unexplained variance." }
  verbosity:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ERROR","WARNING","INFO","DEBUG"]
    doc: "Control verbosity of logging."
    default: "DEBUG"
  max_memory: { type: int?, default: 8, doc: "GB of RAM to allocate to the task. default: 8" }
  cores: { type: int?, default: 8, doc: "Minimum reserved number of CPU cores for the task. default: 4" }
outputs:
  contig_ploidy_calls_tar: { type: File, outputBinding: { glob: 'case-contig-ploidy-calls.tar.gz' } }
