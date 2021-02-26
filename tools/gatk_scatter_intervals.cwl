cwlVersion: v1.0
class: CommandLineTool
id: gatk_scatter_intervals
doc: "Scatter using IntervalListTools"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R'
baseCommand: [/bin/bash, -c]
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      set -eo pipefail

      mkdir out

      NUM_INTERVALS=${ return "$(grep -v '@' " + inputs.intervals_list.path + " | wc -l)" }

      NUM_SCATTERS=${ return "$(echo $((NUM_INTERVALS / " + inputs.num_intervals_per_scatter + ")))"}

      if [ $NUM_SCATTERS -le 1 ]; then
          >&2 echo "Not running IntervalListTools because only a single shard is required. Copying original interval list..."
          cp $(inputs.intervals_list.path) out/$(inputs.intervals_list.nameroot).scattered.0001.interval_list
      else
          /gatk --java-options "-Xmx${return Math.floor(inputs.max_memory*1000/1.074-1)}m" IntervalListTools \
          --INPUT $(inputs.intervals_list.path) \
          --SUBDIVISION_MODE INTERVAL_COUNT \
          --SCATTER_CONTENT $(inputs.num_intervals_per_scatter) \
          --OUTPUT out

          ls -v out/*/scattered.interval_list | \
          cat -n | \
          while read n filename; do mv $filename out/$(inputs.intervals_list.nameroot).scattered.${ return "$(printf \"%04d\" $n)"}.interval_list; done

          rm -rf out/temp_*_of_*
      fi
inputs:
  intervals_list: { type: 'File', doc: "A set of genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs." }
  num_intervals_per_scatter: { type: int, doc: "Total number of intervals to include in each scattered interval list" }
  max_memory: { type: int?, default: 8, doc: "GB of RAM to allocate to the task. default: 8" }
  cores: { type: int?, default: 8, doc: "Minimum reserved number of CPU cores for the task. default: 4" }
outputs:
  scattered_intervals_lists: { type: 'File[]', outputBinding: { glob: 'out/*.interval_list' } }
