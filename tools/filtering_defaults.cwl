cwlVersion: v1.2
class: ExpressionTool
doc: |
  This is a glorified config file that stores the logic and defaults for VQSR and Hard Filtering.

  The logic is the following:
  - First define the data as low or high data (all WGS are high, all targeted are low, and WXS with cohorts smaller than 30 are low data)
  - For high data inputs, return the VQSR defaults
  - For low data inputs, return the Hard Filtering defaults
  - Properly formated objects are returned using Object.assign

  The hope is moving forward we only need to update this file to:
  - Change the defaults for existing experiment_types
  - Add new experiment types and their defaults
requirements:
- class: InlineJavascriptRequirement
inputs:
  num_vcfs: int
  experiment_type: string
outputs:
  low_data: boolean
  snp_tranches: string[]?
  indel_tranches: string[]?
  snp_annotations: string[]?
  indel_annotations: string[]?
  snp_ts_filter_level: float?
  indel_ts_filter_level: float?
  snp_hardfilter: string?
  indel_hardfilter: string?
expression: |
  ${
    var OUTPUTS = {
        "low_data": null,
        "snp_tranches": null,
        "indel_tranches": null,
        "snp_annotations": null,
        "indel_annotations": null,
        "snp_ts_filter_level": null,
        "indel_ts_filter_level": null,
        "snp_hardfilter": null,
        "indel_hardfilter": null,
    };
    var IS_LOW_DATA = {
      "WGS": false,
      "WXS": inputs.num_vcfs < 30,
      "Targeted Sequencing": true,
    };
    var HIGH_DATA_FILTERS = {
      "WGS": {
        "low_data": false,
        "snp_tranches": ["100.0", "99.95", "99.9", "99.8", "99.6", "99.5", "99.4", "99.3", "99.0", "98.0", "97.0", "90.0" ],
        "indel_tranches": ["100.0", "99.95", "99.9", "99.5", "99.0", "97.0", "96.0", "95.0", "94.0", "93.5", "93.0", "92.0", "91.0", "90.0"],
        "snp_annotations": ["QD", "MQRankSum", "ReadPosRankSum", "FS", "MQ", "SOR", "DP"],
        "indel_annotations": ["FS", "ReadPosRankSum", "MQRankSum", "QD", "SOR", "DP"],
        "snp_ts_filter_level": 99.7,
        "indel_ts_filter_level": 99.0,
      },
      "WXS": {
        "low_data": false,
        "snp_tranches": ["100.0", "99.95", "99.9", "99.8", "99.7", "99.6", "99.5", "99.4", "99.3", "99.0", "98.0", "97.0", "90.0" ],
        "indel_tranches": ["100.0", "99.95", "99.9", "99.5", "99.0", "97.0", "96.0", "95.0", "94.0", "93.5", "93.0", "92.0", "91.0", "90.0"],
        "snp_annotations": ["AS_QD", "AS_MQRankSum", "AS_ReadPosRankSum", "AS_FS", "AS_MQ", "AS_SOR"],
        "indel_annotations": ["AS_FS", "AS_ReadPosRankSum", "AS_MQRankSum", "AS_QD", "AS_SOR"],
        "snp_ts_filter_level": 99.7,
        "indel_ts_filter_level": 95.0,
      }
    };
    var LOW_DATA_FILTERS = {
      "low_data": true,
      "snp_hardfilter": '-filter "QD < 2.0" --filter-name "QD2" ' +
                        '-filter "QUAL < 30.0" --filter-name "QUAL30" ' +
                        '-filter "SOR > 3.0" --filter-name "SOR3_SNP" ' +
                        '-filter "FS > 60.0" --filter-name "FS60_SNP" ' +
                        '-filter "MQ < 40.0" --filter-name "MQ40_SNP" ' +
                        '-filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5_SNP" ' +
                        '-filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8_SNP"',
      "indel_hardfilter": '-filter "QD < 2.0" --filter-name "QD2" ' +
                          '-filter "QUAL < 30.0" --filter-name "QUAL30" ' +
                          '-filter "FS > 200.0" --filter-name "FS200_INDEL" ' +
                          '-filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20_INDEL"',
    };
    var PICKED = IS_LOW_DATA[inputs.experiment_type] ? LOW_DATA_FILTERS : HIGH_DATA_FILTERS[inputs.experiment_type];
    return Object.assign({}, OUTPUTS, PICKED);
  }
