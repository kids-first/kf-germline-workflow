cwlVersion: v1.2
class: CommandLineTool
id: somalier-ancestry
doc: "Tool to calculate ancestry using sites and somalier inputs"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 32000
    coresMin: 16
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
  labels: { type: File, doc: "tsv file with population labels for somalier sites",
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

outputs:
  somalier_tsv:
    type: File
    outputBinding:
      glob: $(inputs.output_basename).somalier-ancestry.tsv
  somalier_html:
    type: File
    outputBinding:
      glob: $(inputs.output_basename).somalier-ancestry.html
