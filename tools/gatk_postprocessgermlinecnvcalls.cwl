cwlVersion: v1.0
class: CommandLineTool
id: gatk_postprocessgermlinecnvcalls
doc: "Stages the input files and runs GATK PostprocessGermlineCNVCalls to postprocess the output of GermlineCNVCaller and generates VCFs and denoised copy ratios"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.2.0.0'
baseCommand: ['/bin/bash','-c']
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      set -e

      sharded_interval_lists_array=(${var arr=[]; for (var x = 0; x < inputs.sharded_interval_lists.length; x++) {arr.push(inputs.sharded_interval_lists[x].path)}; return arr.join(' ')})

      gcnv_calls_tar_array=(${var arr=[]; for (var x = 0; x < inputs.gcnv_calls_tars.length; x++) {arr.push(inputs.gcnv_calls_tars[x].path)}; return arr.join(' ')})

      calling_configs_array=(${var arr=[]; for (var x = 0; x < inputs.calling_configs.length; x++) {arr.push(inputs.calling_configs[x].path)}; return arr.join(' ')})

      denoising_configs_array=(${var arr=[]; for (var x = 0; x < inputs.denoising_configs.length; x++) {arr.push(inputs.denoising_configs[x].path)}; return arr.join(' ')})

      gcnvkernel_version_array=(${var arr=[]; for (var x = 0; x < inputs.gcnvkernel_versions.length; x++) {arr.push(inputs.gcnvkernel_versions[x].path)}; return arr.join(' ')})

      sharded_interval_lists_array=(${var arr=[]; for (var x = 0; x < inputs.sharded_interval_lists.length; x++) {arr.push(inputs.sharded_interval_lists[x].path)}; return arr.join(' ')})

      calls_args=""

      for index in ${ return "${!gcnv_calls_tar_array[@]}" }; do
          gcnv_calls_tar=${ return "${gcnv_calls_tar_array[$index]}"}
          mkdir -p CALLS_$index/SAMPLE_$(inputs.sample_index)
          tar xzf $gcnv_calls_tar -C CALLS_$index/SAMPLE_$(inputs.sample_index)
          cp ${ return "${calling_configs_array[$index]}" } CALLS_$index/
          cp ${ return "${denoising_configs_array[$index]}" } CALLS_$index/
          cp ${ return "${gcnvkernel_version_array[$index]}" } CALLS_$index/
          cp ${ return "${sharded_interval_lists_array[$index]}" } CALLS_$index/
          calls_args="$calls_args --calls-shard-path CALLS_$index"
      done

      gcnv_model_tar_array=(${var arr=[]; for (var x = 0; x < inputs.gcnv_model_tars.length; x++) {arr.push(inputs.gcnv_model_tars[x].path)}; return arr.join(' ')})

      model_args=""

      for index in ${ return "${!gcnv_model_tar_array[@]}" }; do
          gcnv_model_tar=${ return "${gcnv_model_tar_array[$index]}" }
          mkdir MODEL_$index
          tar xzf $gcnv_model_tar -C MODEL_$index
          model_args="$model_args --model-shard-path MODEL_$index"
      done

      mkdir contig-ploidy-calls

      tar xzf $(inputs.contig_ploidy_calls_tar.path) -C contig-ploidy-calls

      gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" PostprocessGermlineCNVCalls
      $calls_args
      $model_args
      --autosomal-ref-copy-number $(inputs.ref_copy_number_autosomal_contigs)
      --contig-ploidy-calls contig-ploidy-calls
      --sample-index $(inputs.sample_index)
      --output-genotyped-intervals genotyped-intervals-$(inputs.entity_id).vcf.gz
      --output-genotyped-segments genotyped-segments-$(inputs.entity_id).vcf.gz
      --output-denoised-copy-ratios denoised_copy_ratios-$(inputs.entity_id).tsv
      $(inputs.allosomal_contigs_args ? '--allosomal-contig ' + inputs.allosomal_contigs_args.join(' --allosomal-contig ') : '')

      rm -rf CALLS_*

      rm -rf MODEL_*

      rm -rf contig-ploidy-calls
inputs:
  calling_configs: { type: 'File[]' }
  denoising_configs: { type: 'File[]' }
  gcnv_calls_tars: { type: 'File[]' }
  gcnv_model_tars: { type: 'File[]' }
  gcnvkernel_versions: { type: 'File[]' }
  sharded_interval_lists: { type: 'File[]' }

  contig_ploidy_calls_tar: { type: 'File' }

  ref_copy_number_autosomal_contigs: { type: 'int?', default: 2 }
  allosomal_contigs_args: { type: 'string[]?' }

  sample_index: { type: 'int' }
  entity_id: { type: 'string' }

  max_memory: { type: 'int?', default: 8, doc: "GB of RAM to allocate to the task." }
  cores: { type: 'int?', default: 4, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  genotyped_intervals_vcf: { type: 'File', outputBinding: { glob: 'genotyped-intervals-*.vcf.gz' }, secondaryFiles: [.tbi] }
  genotyped_segments_vcf: { type: 'File', outputBinding: { glob: 'genotyped-segments-*.vcf.gz' }, secondaryFiles: [.tbi] }
  denoised_copy_ratios: { type: 'File', outputBinding: { glob: 'denoised_copy_ratios-*' } }
