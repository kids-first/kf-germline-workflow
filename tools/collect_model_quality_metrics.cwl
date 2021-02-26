cwlVersion: v1.0
class: CommandLineTool
id: collect_model_quality_metrics
doc: "Determines if all values for ARD components are negative"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.ram * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R'
baseCommand: ['/bin/bash','-c']
arguments:
  - position: 0
    shellQuote: true
    valueFrom: |-
        sed -e
        qc_status="PASS"

        gcnv_model_tar_array=(${var arr=[]; for (var x = 0; x < inputs.gcnv_model_tars.length; x++) {arr.push(inputs.gcnv_model_tars[x].path)}; return arr.join(' ')})
        for index in ${ return "${!gcnv_model_tar_array[@]}" }; do
            gcnv_model_tar=${ return "${gcnv_model_tar_array[$index]}" }
            mkdir MODEL_$index
            tar xzf $gcnv_model_tar -C MODEL_$index
            ard_file=MODEL_$index/mu_ard_u_log__.tsv

            NUM_POSITIVE_VALUES=${ return "$(awk '{ if (index($0, \"@\") == 0) {if ($1 > 0.0) {print $1} }}' MODEL_$index/mu_ard_u_log__.tsv | wc -l)" }
            if [ $NUM_POSITIVE_VALUES -eq 0 ]; then
                qc_status="ALL_PRINCIPAL_COMPONENTS_USED"
                break
            fi
        done
        echo $qc_status >> qcStatus.txt
inputs:
  gcnv_model_tars: { type: 'File[]', doc: "One or more tar files output from GATK GermlineCNVCaller run in Cohort Mode" }
  ram: { type: int?, default: 4, doc: "GB of RAM to allocate to the task. default: 4" }
  cores: { type: int?, default: 1, doc: "Minimum reserved number of CPU cores for the task. default: 1" }
outputs:
  qc_status_file: { type: File, outputBinding: { glob: 'qcStatus.txt' } }
  qc_status_string: { type: string, outputBinding: { glob: 'qcStatus.txt', loadContents: true, outputEval: '$(self[0].contents)' } }
