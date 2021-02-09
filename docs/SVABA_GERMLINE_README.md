# KFDRC SvABA Workflow
The KFDRC SvABA Workflow is a tool to perform indel and rearrangement (structural variant/SV) calling.
The tool takes one or more BAM/CRAM files as input and outputs multiple files including filtered and
unfiltered indel and SV VCFs. For more information on the different ouptuts please refer to the [SvABA docs](https://github.com/walaj/svaba/tree/1.1.0#output-file-description).

The tool itself is capable of performing both somatic and germline calling. For germline calling,
only input `tumor_bam` files and set the `germline` option to `true`.
