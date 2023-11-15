cwlVersion: v1.2
class: CommandLineTool
id: somalier-ancestry
doc: "Tool to calculate ancestry using sites and somalier inputs"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.memory * 1000 }
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'brentp/somalier:v0.2.15'
baseCommand: [tar, -xzf]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      && somalier ancestry
      $(inputs.untar_sites_prefix)/*.somalier
  - position: 2
    shellQuote: false
    valueFrom: >-
      ++ $(inputs.input_somalier[0].dirname)/*.somalier

inputs:
  input_somalier: { type: 'File[]', doc: "Files in somalier format to calculate ancestry on"}
  labels: { type: File, doc: "TSV file with population labels for somalier sites",
  inputBinding: { position: 1, prefix: '--labels'} }
  somalier_sites: { type: File, doc: "somalier-format population reference tar ball",
  inputBinding: { position: 0 } }
  n_pcs: { type: 'int?', default: 5, doc: "number of principal components to use in the reduced dataset",
  inputBinding: { position: 1, prefix: '--n-pcs'} }
  nn_hidden_size: { type: 'int?', default: 16, doc: "shape of hidden layer in neural network",
  inputBinding: { position: 1, prefix: '--nn-hidden-size'} }
  nn_batch_size: { type: 'int?', default: 32, doc: "batch size fo training neural network",
  inputBinding: { position: 1, prefix: '--nn-batch-size'} }
  nn_test_samples: { type: 'int?', default: 101, doc: "number of labeled samples to test for NN convergence",
  inputBinding: { position: 1, prefix: '--nn-test-samples'} }
  untar_sites_prefix: { type: string, doc: "dir name that is created when somalier_sites in un-tarred" }
  output_basename: { type: string, doc: "String prefix for output results",
  inputBinding: { position: 1, prefix: "-o" } }
  cores: { type: 'int?', doc: "Num cores to make available to this tool", default: 8}
  memory: { type: 'int?', doc: "Amount of ram in GB to make available to this tool", default: 16 }

outputs:
  somalier_tsv:
    type: File
    outputBinding:
      glob: $(inputs.output_basename).somalier-ancestry.tsv
  somalier_html:
    type: File
    outputBinding:
      glob: $(inputs.output_basename).somalier-ancestry.html
