cwlVersion: v1.2
class: CommandLineTool
id: tar
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: LoadListingRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.cpu)
    ramMin: $(inputs.ram * 1000)
  - class: InitialWorkDirRequirement
    listing: $(inputs.input_files)
baseCommand: [tar, czf]
inputs:
  output_filename: { type: 'string', inputBinding: { position: 1 } }
  input_files:
    type:
      type: array
      items: File
      inputBinding:
        valueFrom: $(self.basename)
    inputBinding: { position: 9 }
  cpu: { type: 'int?', default: 1, doc: "Number of threads to use." }
  ram: { type: 'int?', default: 4, doc: "GB of RAM to allocate to this task." }
outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
