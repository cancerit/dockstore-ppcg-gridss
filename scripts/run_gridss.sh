#! /bin/bash

function usage {
  echo -e "\nUsage: run_gridss.sh [-j file] -t int -s file -b file -l file -n file -p file [-t file] [-t file] \n";
  echo " -j file: GRIDSS jar file, default: https://github.com/PapenfussLab/gridss/releases/download/v1.7.1/gridss-1.7.1-gridss-jar-with-dependencies.jar.";
  echo " -t int: number of threads to use.";
  echo " -s file: output SV file in VCF format.";
  echo " -b file: output BAM.";
  echo " -l file: output log file.";
  echo " -n file : input normal BAM file.";
  echo " -p file : input primary tumour BAM file.";
  echo " -r file : other tumour BAM of the same individual, use -t for each file when there are more than one file";
}

# processing the inputs
while getopts ":hj:t:s:b:l:n:p:r:" opt; do
  case $opt in
    h ) usage
        exit 0 ;;
    j ) GRIDSSS_JAR="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    t ) WORKER_THREADS="$OPTARG"
        if [[ ! $OPTARG =~ ^-?[0-9]+$ ]]; then echo -e "\nError: $OPTARG should be an integer" >&2; exit 1; fi ;;
    s ) OUTPUT_SV="$OPTARG" ;;
    b ) OUTPUT_BAM="$OPTARG" ;;
    l ) OUTPUT_LOG="$OPTARG" ;;
    n ) INTPUT_NORMAL="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    p ) INTPUT_PRI_TUMOUR="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    r ) if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi
        INTPUT_OTHER_TUMOURS+=("$OPTARG") ;;
    \? ) echo ""
        echo "Error: Unimplemented option: -$OPTARG" >&2
        usage >&2
        exit 1 ;;
    : ) echo ""
        echo "Error: Option -$OPTARG needs an argument." >&2
        usage >&2
        exit 1 ;;
    * ) usage >&2
        exit 1 ;;
  esac
done

# require at leaest 1 argument
if [ $# -eq 0 ];
then
  echo ""
  echo "Error: No arguments" >&2
  usage >&2
  exit 1
fi

# check mandatory options:
if [ "-$WORKER_THREADS" == "-" ]; then echo "Error: missing mandatory parameter -t." >&2; exit 1; fi
if [ "-$OUTPUT_SV" == "-" ]; then echo "Error: missing mandatory parameter -s." >&2; exit 1; fi
if [ "-$OUTPUT_BAM" == "-" ]; then echo "Error: missing mandatory parameter -b." >&2; exit 1; fi
if [ "-$OUTPUT_LOG" == "-" ]; then echo "Error: missing mandatory parameter -l." >&2; exit 1; fi
if [ "-$INTPUT_NORMAL" == "-" ]; then echo "Error: missing mandatory parameter -n." >&2; exit 1; fi
if [ "-$INTPUT_PRI_TUMOUR" == "-" ]; then echo "Error: missing mandatory parameter -p." >&2; exit 1; fi

# asign default
JAVA_TMP_DIR=/tmp/java_tmp_dir
mkdir -p $JAVA_TMP_DIR
WORKING_DIR=$HOME
GENOME_REF_FILE=$HOME/core_ref_GRCh37d5/genome.fa
BLACK_LIST=/home/ubuntu/ENCFF001TDO_GRCh37.bed
if [ ! -f "$BLACK_LIST" ]; then echo -e "\nError: $BLACK_LIST does not exist" >&2; exit 1; fi

OTHER_TUMOUR_FILES_STRING=""
if [ ${#INTPUT_OTHER_TUMOURS[@]} != 0 ];
then
  for a_file in "${INTPUT_OTHER_TUMOURS[@]}"
  do
    OTHER_TUMOUR_FILES_STRING="$OTHER_TUMOUR_FILES_STRING INPUT=$a_file"
  done
fi

set -xe

if [ "-$GRIDSSS_JAR" == "-" ];
then
  GRIDSSS_JAR=$HOME/gridss-jar-with-dependencies.jar
  curl -SsL https://github.com/PapenfussLab/gridss/releases/download/v1.7.1/gridss-1.7.1-gridss-jar-with-dependencies.jar > $GRIDSSS_JAR
fi

# Prepare references
curl -SsL ftp://ftp.sanger.ac.uk/pub/cancer/dockstore/human/core_ref_GRCh37d5.tar.gz > $HOME/core_ref_GRCh37d5.tar.gz
tar xzf $HOME/core_ref_GRCh37d5.tar.gz
curl -SsL ftp://ftp.sanger.ac.uk/pub/cancer/dockstore/human/bwa_idx_GRCh37d5.tar.gz > $HOME/bwa_idx_GRCh37d5.tar.gz
tar xzf $HOME/bwa_idx_GRCh37d5.tar.gz
mv -f $HOME/bwa_idx_GRCh37d5/* $HOME/core_ref_GRCh37d5

java -ea -Xmx40g \
-Dsamjdk.create_index=true \
-Dsamjdk.use_async_io_read_samtools=true \
-Dsamjdk.use_async_io_write_samtools=true \
-Dsamjdk.use_async_io_write_tribble=true \
-Dsamjdk.compression_level=1 \
-cp $GRIDSSS_JAR gridss.CallVariants \
TMP_DIR=$JAVA_TMP_DIR \
WORKER_THREADS=$WORKER_THREADS \
WORKING_DIR=$WORKING_DIR \
REFERENCE_SEQUENCE=$GENOME_REF_FILE \
INPUT=$INTPUT_NORMAL \
INPUT=$INTPUT_PRI_TUMOUR \
$OTHER_TUMOUR_FILES_STRING \
OUTPUT=$OUTPUT_SV \
ASSEMBLY=$OUTPUT_BAM \
BLACKLIST=$BLACK_LIST 2>&1 | tee -a $OUTPUT_LOG
