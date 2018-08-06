#! /bin/bash

function usage {
  echo -e "\nUsage: run_gridss.sh -j file -k file -c file -i file -t int [-s file] [-b file] [-l file] -n file -p file [-t file] [-t file] \n";
  echo " -j file: GRIDSS jar file";
  echo " -k file: Black list bed file for GRIDSS";
  echo " -c file: Sanger core reference tar file";
  echo " -i file: Sanger BWA index tar file";
  echo " -t int: number of threads to use.";
  echo " -s file: output SV file in VCF format, default: out.vcf.";
  echo " -b file: output BAM, default: out.bam.";
  echo " -l file: output log file, default: out.log.";
  echo " -n file : input normal BAM file.";
  echo " -p file : input primary tumour BAM file.";
  echo " -r file : other tumour BAM of the same individual, use -r for each additional tumour BAM when there are more";
}

# processing the inputs
while getopts ":hj:t:s:b:l:n:p:r:k:c:i:" opt; do
  case $opt in
    h ) usage
        exit 0 ;;
    j ) GRIDSSS_JAR="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    k ) BLACK_LIST="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    c ) SANGER_REF="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    i ) SANGER_BWA_IDX="$OPTARG"
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
if [ "-$INTPUT_NORMAL" == "-" ]; then echo "Error: missing mandatory parameter -n." >&2; exit 1; fi
if [ "-$INTPUT_PRI_TUMOUR" == "-" ]; then echo "Error: missing mandatory parameter -p." >&2; exit 1; fi
if [ "-$BLACK_LIST" == "-" ]; then echo "Error: missing mandatory parameter -k." >&2; exit 1; fi
if [ "-$GRIDSSS_JAR" == "-" ]; then echo "Error: missing mandatory parameter -j." >&2; exit 1; fi
if [ "-$SANGER_REF" == "-" ]; then echo "Error: missing mandatory parameter -c." >&2; exit 1; fi
if [ "-$SANGER_BWA_IDX" == "-" ]; then echo "Error: missing mandatory parameter -i." >&2; exit 1; fi

# asign default
JAVA_TMP_DIR=/tmp/java_tmp_dir
mkdir -p $JAVA_TMP_DIR
WORKING_DIR=$HOME
REF_DIR=$HOME/ref
GENOME_REF_FILE=$REF_DIR/genome.fa
if [ "-$OUTPUT_SV" == "-" ]; then OUTPUT_SV="out.vcf"; fi
if [ "-$OUTPUT_BAM" == "-" ]; then OUTPUT_BAM="out.bam"; fi
if [ "-$OUTPUT_LOG" == "-" ]; then OUTPUT_LOG="out.log"; fi

OTHER_TUMOUR_FILES_STRING=""
if [ ${#INTPUT_OTHER_TUMOURS[@]} != 0 ];
then
  for a_file in "${INTPUT_OTHER_TUMOURS[@]}"
  do
    OTHER_TUMOUR_FILES_STRING="$OTHER_TUMOUR_FILES_STRING INPUT=$a_file"
  done
fi

set -xe

# Prepare references
mkdir -p $REF_DIR
tar xzf $SANGER_REF -C $REF_DIR --strip-components 1
tar xzf $SANGER_BWA_IDX -C $REF_DIR --strip-components 1

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
