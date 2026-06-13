#!/bin/bash
module load katuali
# Input files
BASECALLS=$1 #/path/to/basecalls.fastq
RUN=$2
SUMMARY=$3

BASECALLER=guppy

# ...no need to edit below here
if [ $(ls ${BASECALLS} 2>/dev/null|wc -l) -ne 0 ]
then
  BCDIR=${RUN}/${BASECALLER}/
  mkdir -p ${BCDIR}
  mkdir ${RUN}/reads
  if [ "{SUMMARY}" != "" ];
  then 
    ln -s ${SUMMARY} ${BCDIR}/sequencing_summary.txt
  else
    touch ${BCDIR}/sequencing_summary.txt
  fi

  rm -f ${BCDIR}/basecalls.fasta 

  if [  $(ls ${BASECALLS}/*.fastq 2>/dev/null|wc -l) -ne 0 ]
  then
    echo Expanding fastq.gz
    seqkit fq2fa <(cat ${BASECALLS}/*.fastq) >> ${BCDIR}/basecalls.fasta
  fi

  if [  $(ls ${BASECALLS}/*.fastq.gz 2>/dev/null|wc -l) -ne 0 ]
  then
    echo Expanding fastq.gz
    seqkit fq2fa <(zcat ${BASECALLS}/*.fastq.gz) > ${BCDIR}/basecalls.fasta
  fi
fi
