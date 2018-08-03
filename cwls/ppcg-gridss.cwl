#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "ppcg-gridss"

label: "Dockerised iRAP for RNAseq data analysis"

cwlVersion: v1.0

doc: |
    ![build_status](https://quay.io/repository/wtsicgp/dockstore-ppcg-gridss/status)
    A Docker container to run GRIDSS for PPCG. See the [dockstore-ppcg-gridss](https://github.com/cancerit/dockstore-ppcg-gridss) website for more information.

dct:creator:
  "@id": "yaobo.xu@sanger.ac.uk"
  foaf:name: Yaobo Xu
  foaf:mbox: "yx2@sanger.ac.uk"

requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/wtsicgp/dockstore-ppcg-gridss:0.1.0"

inputs:

  gridss_jar:
    type: File
    doc: "a GRIDSS jar file"
    inputBinding:
      prefix: -j
      separate: true
      shellQuote: true

  gridss_black_list:
    type: File
    doc: "a black list bed file for GRIDSS to use"
    inputBinding:
      prefix: -k
      separate: true
      shellQuote: true

  sanger_core_ref_tar:
    type: File
    doc: "Sanger core reference tar file"
    inputBinding:
      prefix: -c
      separate: true
      shellQuote: true

  sanger_bwa_index_tar:
    type: File
    doc: "Sanger BWA index tar file"
    inputBinding:
      prefix: -i
      separate: true
      shellQuote: true

  threads:
    type: int
    doc: "number of threads to use"
    inputBinding:
      prefix: -t
      separate: true
      shellQuote: true

  normal:
    type: File
    doc: "normal sample BAM"
    inputBinding:
      prefix: -n
      separate: true
      shellQuote: true

  primary_tumour:
    type: File
    doc: "primary tumour sample BAM"
    inputBinding:
      prefix: -p
      separate: true
      shellQuote: true

  other_tumours:
    type:
    - "null"
    - type: array
      items: File
      inputBinding:
        prefix: -r
        separate: true
        shellQuote: true
    doc: "other tumour BAM files of the same individual"

  output_vcf_name:
    type: string
    doc: "output VCF file name"
    inputBinding:
      prefix: -s
      separate: true
      shellQuote: true

  output_bam_name:
    type: string
    doc: "output BAM file name"
    inputBinding:
      prefix: -b
      separate: true
      shellQuote: true

  output_log_name:
    type: string
    doc: "output log file name"
    inputBinding:
      prefix: -l
      separate: true
      shellQuote: true

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf_name)

  output_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_bam_name)

  output_log:
    type: File
    outputBinding:
      glob: $(inputs.output_log_name)

need to capture these files:
patient1.gridss.assembly.bam
patient1.gridss.assembly.bai
patient1.gridss.assembly.bam.throttled.bed

patient1.sv.vcf
patient1.sv.vcf.idx

baseCommand: [""]
