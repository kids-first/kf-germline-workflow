# Somalier
Somalier: "extract informative sites, evaluate relatedness, and perform quality-control on BAM/CRAM/BCF/VCF/GVCF".
See author [git repo](https://github.com/brentp/somalier)

Currently we have created three tools focusing on the major sub-functions of this tool suite (think GATK) - `somalier extract`, `somalier relate`, and `somalier ancestry`.

## extract
This tool takes known sites and an alignment file to create custom format that allows for site-to-site analysis using this quite, no matter the reference, quickly and efficiently.

### Inputs:
**REQUIRED**
 - `input_file`: BAM/CRAM/VCF input. BAM/CRAM recommended when available over VCF
 - `reference_fasta`: Reference FASTA genome used for aligned input
 - `sites`: VCF file with common sites. Author has provided; recommend "sites.hg38.rna.vcf.gz" as it provides the best results for comparing DNA and RNA data against each other and is robust enough for DNA-only comparisons

**OPTIONAL**
 - `sample_prefix`: Prefix for the sample name stored inside the digest
### Outputs:
Output is the converted `.somalier` output

## relate
calculate relatedness among samples from extracted, genotype-like information
### Inputs:
**REQUIRED**
 - `somalier_output`: Somalier-formatted variant files

**RECOMMENDED (for in-patient sample matching validation)**
 - `groups`: optional path to expected groups of samples (e.g. tumor normal pairs). A group file is specified as comma-separated groups per line e.g.:
                                 normal1,tumor1a,tumor1b
                                 normal2,tumor2a
 - `min_ab`: hets sites must be between min-ab and 1 - min_ab. set this to 0.2 for RNA-Seq data (default: 0.3), default: 0.3

 **OPTIONAL (has defaults)**
 - `ped`: optional path to a PED/fam file indicating the expected relationships among samples.
 - `min_depth`: only genotype sites with at least this depth., default: 7

 - `unknown`: set unknown genotypes to hom-ref. It is often preferable to use this with VCF samples that were not jointly called
 - `infer`: infer relationships
 - `output_prefix`: output prefix for results. (default: somalier)
### Outputs:
 - `groups_tsv`: look at this for cancer samples - will list if detected/verified to be grouped together
 - `interactive_html`: Summary html file
 - `pairs_tsv`: Pairwise relatedness stats
 - `samples_tsv`: Pairwise samples pedigree stats

## ancestry
 From [somalier wiki](https://github.com/brentp/somalier/wiki/ancestry): "somalier can predict ancestry on a set of query samples given a set of labelled samples, for example from thousand genomes along with labels for samples [sic]"

### Inputs:
**REQUIRED**
 - `input_somalier`: Files in somalier format to calculate ancestry on
 - `labels`: TSV file with population labels for somalier sites
 - `untar_sites_prefix`: dir name that is created when somalier_sites in un-tarred
 - `output_basename`: String prefix for output results
 - `somalier_sites`: somalier-format population reference tar ball

**OPTIONAL (has defaults)**
 - `n_pcs`: number of principal components to use in the reduced dataset
 - `nn_hidden_size`: shape of hidden layer in neural network
 - `nn_batch_size`: batch size for training neural network
 - `nn_test_samples`: number of labeled samples to test for NN convergence

### Outputs:
 - `somalier_tsv`: A tsv file with sample labels and predicted ancestry based on input somalier files + reference
 - `somalier_html`: A nifty plot of where input samples fall in PCA versus population