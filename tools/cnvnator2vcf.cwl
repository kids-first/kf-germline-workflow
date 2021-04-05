cwlVersion: v1.0
class: CommandLineTool
id: cnvnator_call
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/cnvnator:0.4.1'
baseCommand: [cnvnator2vcf.pl]
inputs:
  prefix: { type: 'string?', inputBinding: { prefix: '-prefix' }, doc: "Prefix string you want to append to the ID field in your output VCF. For e.g., if you set your -prefix as 'study1', then your resulting ID column will be study1_CNVnator_del_1, study1_CNVnator_del_2 etc." }
  reference_name: { type: 'string?', inputBinding: { prefix: '-reference' }, doc: "The name of reference genome you used, for e.g., GRCh37, hg19 etc." }
  input_calls: { type: 'File', inputBinding: { position: 99 }, doc: "Input calls file" }
  genome_dir: { type: 'Directory?', inputBinding: { position: 100 }, doc: "directory containing your individual reference fasta files such as 1.fa, 2.fa etc. (or chr1.fa, chr2.fa etc.)" }
  max_memory: { type: 'int?', default: 8, doc: "GB of memory to allocate to this task." }
  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task." }
outputs:
  output:
    type: stdout 
stdout: $(inputs.input_calls.basename).vcf
