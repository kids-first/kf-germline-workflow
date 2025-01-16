cwlVersion: v1.2
class: CommandLineTool
id: gatk_plot_annotations
doc: |
  Plot annotations relevant to GATK hardfiltering. Take a TSV table generated
  by VariantsToTable and create density charts for relevant annotations.

  TAR the results and return.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/tidyverse:4.4.2-gatk-plotter'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: gatk_plot_annotations.R
        entry:
          $include: ../scripts/gatk_plot_annotations.R
baseCommand: [Rscript, gatk_plot_annotations.R]
inputs:
  input_table: { type: 'File', inputBinding: { position: 8 }, doc: "TSV table with variants and annotations." }
  input_type: { type: 'string', inputBinding: { position: 7 }, doc: "Type of input. SNP or INDEL." }
  output_basename: { type: 'string', inputBinding: { position: 6 }, doc: "String to use as basename for outputs." }
  annotation_fields: { type: 'string[]?', inputBinding: { position: 9 }, doc: "Annotation fields being examined." }
  ram: { type: 'int?', default: 4, doc: "GB of RAM to allocate to the task." }
  cpu: { type: 'int?', default: 2, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  plots: { type: 'File[]', outputBinding: { glob: '*.pdf' } }
