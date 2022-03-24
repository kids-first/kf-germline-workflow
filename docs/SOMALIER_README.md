# Somalier
Somalier: "extract informative sites, evaluate relatedness, and perform quality-control on BAM/CRAM/BCF/VCF/GVCF".
See author [git repo](https://github.com/brentp/somalier)

Currently we have created two tools focusing on two sub-functions of this tool suite (think GATK) - `somalier extract` and `somalier ancestry`.

## extract
This tool takes known sites and an alignment file to create custom format that allows for site-to-site analysis using this quite, no matter the reference, quickly and efficiently.

### Inputs:
```yaml
inputs:
  input_file: { type: File, secondaryFiles: [ { pattern: ".bai", required: false },
    { pattern: "^.bai", required: false }, { pattern: ".crai", required: false }, { pattern: "^.crai", required: false },
    { pattern: ".tbi", required: false } ], doc: "BAM/CRAM/VCF input. BAM/CRAM recommended when available over vcf"}
  reference_fasta: { type: File, inputBinding: { prefix: "--fasta" }, secondaryFiles: [ .fai ], doc: "Reference genome used" }
  sites: { type: File, inputBinding: { prefix: "--sites" }, doc: "vcf file with common sites" }
```
### Outputs:
Output is the converted `.somalier` output

## ancestry
 From [somalier wiki](https://github.com/brentp/somalier/wiki/ancestry): "somalier can predict ancestry on a set of query samples given a set of labelled samples, for example from thousand genomes along with labels for samples [sic]"

### Inputs:
```yaml
inputs:
  input_somalier: { type: 'File[]', doc: "Files in somalier format to calculate ancestry on"}
  labels: { type: File, doc: "tsv file with population labels for somalier sites",
  inputBinding: { position: 1, prefix: '--labels'} }
  somalier_sites: { type: File, doc: "vcf file with common sites",
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
```

### Outputs:
 - `somalier_tsv`: A tsv file with sample labels and predicted ancestry based on input somalier files + reference
 - `somalier_html`: A nifty plot of where input samples fall in PCA versus population