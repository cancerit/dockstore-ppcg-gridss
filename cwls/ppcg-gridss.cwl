#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "ppcg-gridss"

label: "Dockerised iRAP for RNAseq data analysis"

cwlVersion: v1.0

doc: |
    ![build_status](https://quay.io/repository/wtsicgp/dockstore-ppcg-gridss/status)
    A Docker container to run GRIDSS for PPCG. See the [dockstore-ppcg-gridss](https://github.com/cancerit/dockstore-ppcg-gridss) website for more information.

requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/wtsicgp/dockstore-ppcg-gridss:v0.1.0"

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
    default: "out.vcf"
    inputBinding:
      prefix: -s
      separate: true
      shellQuote: true

  output_bam_name:
    type: string
    doc: "output BAM file name"
    default: "out.bam"
    inputBinding:
      prefix: -b
      separate: true
      shellQuote: true

  output_log_name:
    type: string
    doc: "output log file name"
    default: "out.log"
    inputBinding:
      prefix: -l
      separate: true
      shellQuote: true

outputs:

  output_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf_name)
    secondaryFiles: .idx

  output_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_bam_name)
    secondaryFiles:
      - .throttled.bed
      - ^.bai

  output_log:
    type: File
    outputBinding:
      glob: $(inputs.output_log_name)

baseCommand: ["run_gridss.sh"]


$schemas:
  - http://schema.org/docs/schema_org_rdfa.html

$namespaces:
  s: http://schema.org/

s:codeRepository: https://github.com/cancerit/dockstore-ppcg-gridss
s:license: https://spdx.org/licenses/AGPL-3.0-only

s:author:
  - class: s:Person
    s:email: mailto:yx2@sanger.ac.uk
    s:name: Yaobo Xu
