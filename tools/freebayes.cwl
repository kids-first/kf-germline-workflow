cwlVersion: v1.0
class: CommandLineTool
id: freebayes
doc: |-
  From [freebayes github](https://github.com/ekg/freebayes/blob/master/README.md):
  freebayes is a Bayesian genetic variant detector designed to find small polymorphisms, specifically
  SNPs (single-nucleotide polymorphisms), indels (insertions and deletions), MNPs (multi-nucleotide
  polymorphisms), and complex events (composite insertion and substitution events) smaller than the
  length of a short-read sequencing alignment.
  
  freebayes is haplotype-based, in the sense that it calls variants based on the literal sequences
  of reads aligned to a particular target, not their precise alignment. This model is a
  straightforward generalization of previous ones (e.g. PolyBayes, samtools, GATK) which detect or
  report variants based on alignments. This method avoids one of the core problems with
  alignment-based variant detection--- that identical sequences may have multiple possible alignments.
  
  freebayes uses short-read alignments (BAM files with Phred+33 encoded quality scores, now standard)
  for any number of individuals from a population and a reference genome (in FASTA format) to
  determine the most-likely combination of genotypes for the population at each position in the
  reference. It reports positions which it finds putatively polymorphic in variant call file (VCF)
  format. It can also use an input set of variants (VCF) as a source of prior information, and a copy
  number variant map (BED) to define non-uniform ploidy variation across the samples under analysis.

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.cpu)
    ramMin: ${return inputs.ram * 1000}
  - class: InitialWorkDirRequirement
    listing:
      - entryname: bams.txt
        entry: |-
          ${
              var text = ""
              for (var i = 0; i < inputs.input_bams.length; i++) {
                  text += inputs.input_bams[i].path + "\n"
              }
              return text
          }
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/freebayes:v1.3.2'

baseCommand: [freebayes, --bam-list, bams.txt]

inputs:

  # Input Variables

  input_bams: { type: 'File[]', secondaryFiles: [^.bai], doc: "BAM files to be analyzed" }
  reference_fasta: { type: 'File', inputBinding: { prefix: "--fasta-reference" }, secondaryFiles: [.fai], doc: "Reference fasta and fai index" }
  targets_file: { type: 'File?', inputBinding: { prefix: "--targets" }, doc: "BED file containing targets for analysis" }
  region_strings: { type: 'string[]?', inputBinding: { prefix: "--region", itemSeparator: ".." }, doc: "List containing BED-formatted strings (<chrom>:<start_position>-<end_position>;0-base coordinates, end_position not included) detailing target locations for analysis. Either '-' or '..' maybe used as a separator" }
  samples_file: { type: 'File?', inputBinding: { prefix: "--samples" }, doc: "Limit analysis to samples listed (one per line) in the FILE. By default FreeBayes will analyze all samples in its input BAM files." }
  populations_file: { type: 'File?', inputBinding: { prefix: "--populations" }, doc: "Each line of FILE should list a sample and a population which it is part of.  The population-based bayesian inference model will then be partitioned on the basis of the populations." }
  cnv_map_file: { type: 'File?', inputBinding: { prefix: "--cnv-map" }, doc: "Read a copy number map from the BED file FILE, which has either a sample-level ploidy: (sample_name copy_number) or a region-specific format: (seq_name start end sample_name copy_number). For each region in each sample which does not have the default copy number as set by --ploidy. These fields can be delimited by space or tab." }

  # Output Variables

  output_basename: { type: 'string', inputBinding: { prefix: "--vcf", valueFrom: '${ return self+".freebayes.vcf" }' }, doc: "Output VCF-format results to path provided." }
  output_gvcf: { type: 'boolean?', default: false, inputBinding: { prefix: "--gvcf" }, doc: "Write gVCF output, which indicates coverage in uncalled regions." }
  gvcf_chunk: { type: 'long?', inputBinding: { prefix: "--gvcf-chunk" }, doc: "When writing gVCF output emit a record for every NUM bases." }
  gvcf_dont_use_chunk: { type: 'boolean?', inputBinding: { prefix: "--gvcf-dont-use-chunk" }, doc: "When writing the gVCF output emit a record for all bases if set to true , will also route an int to --gvcf-chunk similar to --output-mode EMIT_ALL_SITES from GATK" }
  variant_input_file: { type: 'File?', inputBinding: { prefix: "--variant_input" }, doc: "Use variants reported in VCF file as input to the algorithm. Variants in this file will included in the output even if there is not enough support in the data to pass input filters." }
  only_use_input_alleles: { type: 'boolean?', default: false, inputBinding: { prefix: "--only-use-input-alleles" }, doc: "Only provide variant calls and genotype likelihoods for sites and alleles which are provided in the VCF input, and provide output in the VCF for all input alleles, not just those which have support in the data." }
  haplotype_basis_alleles_file: { type: 'File?', inputBinding: { prefix: "--haplotype-basis-alleles" }, doc: "When specified, only variant alleles provided in this input VCF will be used for the construction of complex or haplotype alleles." }
  report_all_haplotype_alleles: { type: 'boolean?', default: false, inputBinding: { prefix: "--report-all-haplotype-alleles" }, doc: "At sites where genotypes are made over haplotype alleles, provide information about all alleles in output, not only those which are called." }
  report_monomorphic: { type: 'boolean?', default: false, inputBinding: { prefix: "--report-monomorphic" }, doc: "Report even loci which appear to be monomorphic, and report all considered alleles, even those which are not in called genotypes. Loci which do not have any potential alternates have '.' for ALT." }
  pvar: { type: 'double?', inputBinding: { prefix: "--pvar" }, doc: "Report sites if the probability that there is a polymorphism at the site is greater than N.  default: 0.0.  Note that post-filtering is generally recommended over the use of this parameter." }
  strict_vcf: { type: 'boolean?', default: false, inputBinding: { prefix: "--strict-vcf" }, doc: "Generate strict VCF format (FORMAT/GQ will be an int)" }

  # Population Model Variables

  theta: { type: 'double?', inputBinding: { prefix: "--theta" }, doc: "The expected mutation rate or pairwise nucleotide diversity among the population under analysis.  This serves as the single parameter to the Ewens Sampling Formula prior model default: 0.001" }
  ploidy: { type: 'int?', inputBinding: { prefix: "--ploidy" }, doc: "Sets the default ploidy for the analysis to N.  default: 2" }
  pooled_discrete: { type: 'boolean?', default: false, inputBinding: { prefix: "--pooled-discrete" }, doc: "Assume that samples result from pooled sequencing. Model pooled samples using discrete genotypes across pools. When using this flag, set --ploidy to the number of alleles in each sample or use the --cnv-map to define per-sample ploidy." }
  pooled_continuous: { type: 'boolean?', default: false, inputBinding: { prefix: "--pooled-continuous" }, doc: "Output all alleles which pass input filters, regardles of genotyping outcome or model." }

  # Reference Allele Variables

  use_reference_allele: { type: 'boolean?', default: false, inputBinding: { prefix: "--use-reference-allele" }, doc: "This flag includes the reference allele in the analysis as if it is another sample from the same population." }
  reference_quality: { type: 'string?', inputBinding: { prefix: "--reference-quality" }, doc: "Assign mapping quality of MQ to the reference allele at each site and base quality of BQ. format: MQ,BQ; default: 100,60" }

  # Allele Scope Variables

  use_best_n_alleles: { type: 'int?', inputBinding: { prefix: "--use-best-n-allelles" }, doc: "Evaluate only the best N SNP alleles, ranked by sum of supporting quality scores.  (Set to 0 to use all; default: all)" }
  max_haplotype_gap: { type: 'int?', inputBinding: { prefix: "--max-complex-gap" }, doc: "Allow haplotype calls with contiguous embedded matches of up to this length. Set N=-1 to disable clumping. (default: 3)" }
  haplotype_length: { type: 'int?', inputBinding: { prefix: "--haplotype-length" }, doc: "Allow haplotype calls with contiguous embedded matches of up to this length. Set N=-1 to disable clumping. (default: 3)" }
  min_repeat_size: { type: 'int?', inputBinding: { prefix: "--min-repeat-size" }, doc: "When assembling observations across repeats, require the total repeat length at least this many bp.  (default: 5)" }
  min_repeat_entropy: { type: 'int?', inputBinding: { prefix: "--min-repeat-entropy" }, doc: "To detect interrupted repeats, build across sequence until it has entropy > N bits per bp. Set to 0 to turn off. (default: 1)" }
  no_partial_observations: { type: 'boolean?', default: false, inputBinding: { prefix: "--no-partial-observations" }, doc: "Exclude observations which do not fully span the dynamically-determined detection window.  (default, use all observations, dividing partial support across matching haplotypes when generating haplotypes.)" }

  # Indel Realignment Variables

  dont_left_align_indels: { type: 'boolean?', default: false, inputBinding: { prefix: "--dont-left-align-indels" }, doc: "Turn off left-alignment of indels, which is enabled by default." }

  # Input Filter Variables

  use_duplicate_reads: { type: 'boolean?', default: false, inputBinding: { prefix: "--use-duplicate-reads" }, doc: "Include duplicate-marked alignments in the analysis. default: exclude duplicates marked as such in alignments" }
  min_mapping_quality: { type: 'int?', inputBinding: { prefix: "--min-mapping-quality" }, doc: "Exclude alignments from analysis if they have a mapping quality less than Q.  default: 1" }
  min_base_quality: { type: 'int?', inputBinding: { prefix: "--min-base-quality" }, doc: "Exclude alleles from analysis if their supporting base quality is less than Q.  default: 0" }
  min_supporting_allele_qsum: { type: 'int?', inputBinding: { prefix: "--min-supporting-allele-qsum" }, doc: "Consider any allele in which the sum of qualities of supporting observations is at least Q.  default: 0" }
  min_supporting_mapping_qsum: { type: 'int?', inputBinding: { prefix: "--min-supporting-mapping-qsum" }, doc: "Consider any allele in which and the sum of mapping qualities of supporting reads is at least Q.  default: 0" }
  mismatch_base_quality_threshold: { type: 'int?', inputBinding: { prefix: "--mismatch-base-quality-threshold" }, doc: "Count mismatches toward --read-mismatch-limit if the base quality of the mismatch is >= Q.  default: 10" }
  read_mismatch_limit: { type: 'int?', inputBinding: { prefix: "--read-mismatch-limit" }, doc: "Exclude reads with more than N mismatches where each mismatch has base quality >= mismatch-base-quality-threshold. default: ~unbounded" }
  read_max_mismatch_fraction: { type: 'double?', inputBinding: { prefix: "--read-max-mismatch-fraction" }, doc: "Exclude reads with more than N [0,1] fraction of mismatches where each mismatch has base quality >= mismatch-base-quality-threshold default: 1.0" }
  read_snp_limit: { type: 'int?', inputBinding: { prefix: "--read-snp-limit" }, doc: "Exclude reads with more than N base mismatches, ignoring gaps with quality >= mismatch-base-quality-threshold. default: ~unbounded" }
  read_indel_limit: { type: 'int?', inputBinding: { prefix: "--read-indel-limit" }, doc: "Exclude reads with more than N separate gaps. default: ~unbounded" }
  standard_filters: { type: 'boolean?', default: false, inputBinding: { prefix: "--standard-filters" }, doc: "Use stringent input base and mapping quality filters. Equivalent to --min-mapping-quality 30 --min-base-quality 20 --min-supporting-allele-qsum 0 --genotype-variant-threshold 0" }
  min_alternate_fraction: { type: 'double?', inputBinding: { prefix: "--min-alternate-fraction" }, doc: "Require at least this fraction of observations supporting an alternate allele within a single individual in the in order to evaluate the position.  default: 0.05" }
  min_alternate_count: { type: 'int?', inputBinding: { prefix: "--min-alternate-count" }, doc: "Require at least this count of observations supporting an alternate allele within a single individual in order to evaluate the position.  default: 2" }
  min_alternate_qsum: { type: 'int?', inputBinding: { prefix: "--min-alternate-qsum" }, doc: "Require at least this sum of quality of observations supporting an alternate allele within a single individual in order to evaluate the position.  default: 0" }
  min_alternate_total: { type: 'int?', inputBinding: { prefix: "--min-alternate-total" }, doc: "Require at least this count of observations supporting an alternate allele within the total population in order to use the allele in analysis.  default: 1" }
  min_coverage: { type: 'int?', inputBinding: { prefix: "--min-coverage" }, doc: "Require at least this coverage to process a site. default: 0" }
  limit_coverage: { type: 'int?', inputBinding: { prefix: "--limit-coverage" }, doc: "Downsample per-sample coverage to this level if greater than this coverage. default: no limit" }
  skip_coverage: { type: 'int?', inputBinding: { prefix: "--skip-coverage" }, doc: "Skip processing of alignments overlapping positions with coverage >N. This filters sites above this coverage, but will also reduce data nearby. default: no limit" }

  # Population Priors Variables

  no_population_priors: { type: 'boolean?', default: false, inputBinding: { prefix: "--no-population-priors" }, doc: "Equivalent to --pooled-discrete --hwe-priors-off and removal of Ewens Sampling Formula component of priors." }

  # Mappability Priors

  hwe_priors_off: { type: 'boolean?', default: false, inputBinding: { prefix: "--hwe-priors-off" }, doc: "Disable estimation of the probability of the combination arising under HWE given the allele frequency as estimated by observation frequency." }
  binomial_obs_priors_off: { type: 'boolean?', default: false, inputBinding: { prefix: "--binomial-obs-priors-off" }, doc: "Disable incorporation of prior expectations about observations. Uses read placement probability, strand balance probability, and read position (5'-3') probability." }
  allele_balance_priors_off: { type: 'boolean?', default: false, inputBinding: { prefix: "--allele-balance-priors-off" }, doc: "Disable use of aggregate probability of observation balance between alleles as a component of the priors." }

  # Genotype Likelihoods Variables

  observation_bias_file: { type: 'File?', inputBinding: { prefix: "--observation-bias" }, doc: "Read length-dependent allele observation biases from FILE. The format is [length] [alignment efficiency relative to reference] where the efficiency is 1 if there is no relative observation bias." }
  base_quality_cap: { type: 'int?', inputBinding: { prefix: "--base-quality-cap" }, doc: "Limit estimated observation quality by capping base quality at Q." }
  prob_contamination: { type: 'double?', inputBinding: { prefix: "--prob-contamination" }, doc: "An estimate of contamination to use for all samples.  default: 10e-9" }
  legacy_gls: { type: 'boolean?', default: false, inputBinding: { prefix: "--legacy-gls" }, doc: "Use legacy (polybayes equivalent) genotype likelihood calculations" }
  contamination_estiamtes_file: { type: 'File?', inputBinding: { prefix: "--contamination-estimates" }, doc: "A file containing per-sample estimates of contamination, such as those generated by VerifyBamID.  The format should be: sample p(read=R|genotype=AR) p(read=A|genotype=AA). Sample '*' can be used to set default contamination estimates." }

  # Algorithmic Features Variables

  report_genotype_likelihood_max: { type: 'boolean?', default: false, inputBinding: { prefix: "--report-genotype-likelihood-max" }, doc: "Report genotypes using the maximum-likelihood estimate provided from genotype likelihoods." }
  genotyping_max_iterations: { type: 'int?', inputBinding: { prefix: "--genotyping-max-iterations" }, doc: "Iterate no more than N times during genotyping step. default: 1000." }
  genotyping_max_banddepth: { type: 'int?', inputBinding: { prefix: "--genotyping-max-banddepth" }, doc: "Integrate no deeper than the Nth best genotype by likelihood when genotyping. default: 6." }
  posterior_integration_limits: { type: 'string?', inputBinding: { prefix: "--posterior-integration-limits" }, doc: "Integrate all genotype combinations in our posterior space which include no more than N samples with their Mth best data likelihood. format: N,M; default: 1,3." }
  exclude_unobserved_genotypes: { type: 'boolean?', default: false, inputBinding: { prefix: "--exclude-unobserved-genotypes" }, doc: "Skip sample genotypings for which the sample has no supporting reads." }
  genotype_variant_threshold: { type: 'int?', inputBinding: { prefix: "--genotype-variant-threshold" }, doc: "Limit posterior integration to samples where the second-best genotype likelihood is no more than log(N) from the highest genotype likelihood for the sample.  default: ~unbounded" }
  use_mapping_quality: { type: 'boolean?', default: false, inputBinding: { prefix: "--use-mapping-quality" }, doc: "Use mapping quality of alleles when calculating data likelihoods." }
  harmonic_indel_quality: { type: 'boolean?', default: false, inputBinding: { prefix: "--harmonic-indel-quality" }, doc: "Use a weighted sum of base qualities around an indel, scaled by the distance from the indel.  By default use a minimum BQ in flanking sequence." }
  read_dependence_factor: { type: 'double?', inputBinding: { prefix: "--read-dependence-factor" }, doc: "Incorporate non-independence of reads by scaling successive observations by this factor during data likelihood calculations.  default: 0.9" }
  genotype_qualities: { type: 'boolean?', default: false, inputBinding: { prefix: "--genotype-qualities" }, doc: "Calculate the marginal probability of genotypes and report as GQ in each sample field in the VCF output." }

  # Debugging Variables

  debug: { type: 'boolean?', default: false, inputBinding: { prefix: "--debug" }, doc: "Print debugging output." }

  # Resource Control
  ram: { type: 'int?', default: 2, doc: "Minimum reserved RAM for the task. default: 16" }
  cpu: { type: 'int?', default: 1, doc: "Minimum reserved number of CPU cores for the task. default: 4" }

outputs:
  output: { type: 'File', outputBinding: { glob: "*.freebayes.vcf" } }
