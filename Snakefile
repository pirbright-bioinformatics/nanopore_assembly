import pandas as pd
configfile: "config.yml"

OUTDIR=config["output_directory"] 
SEQDATAPATH=config["data_path"]
samples = pd.read_csv("reference.csv").set_index("Sample", drop=False)


# Filter the DataFrame to keep only rows where the directory is empty
def is_empty_dir(directory):
    directory=SEQDATAPATH + "/fastq_pass/" + directory
    return os.path.isdir(directory) and len(os.listdir(directory)) != 0
samples = samples[samples.iloc[:, 0].apply(is_empty_dir)]

Canu_genomeSize = "8k"
Canu_maxInputCoverage = "100"

rule all:
   input:expand(OUTDIR + "/{Sample}/depth/depth.png",Sample=samples.Sample),
         expand(OUTDIR + "/{Sample}/guppy/medaka/consensus.fasta",Sample=samples.Sample),
         expand(OUTDIR + "/{Sample}/minimap2/aligned.medaka.bam",Sample=samples.Sample)
   shell: "echo {input};echo ---"

rule bamqc:
   input:OUTDIR + "/{Sample}/minimap2/aligned.bam"
   output:
         outdir=directory(OUTDIR + "/{Sample}/minimap.bamqc"),
         outfile=OUTDIR + "/{Sample}/minimap.bamqc/report.pdf"
   shell:
       """
       mkdir -p {output.outdir}
       export DISPLAY=
       qualimap bamqc -outfile report.pdf -outdir {output.outdir} -bam {input} -outformat PDF:HTML 
       """

rule plot:
   input:
       depthfile=OUTDIR + "/{Sample}/depth/depth.txt",
       #directory=OUTDIR + "/{Sample}/depth"
   output:
       normalPNG=OUTDIR + "/{Sample}/depth/depth.png",
       logPNG=OUTDIR + "/{Sample}/depth/depth.log.png",
   shell:
       """
       Rscript {workflow.basedir}/depthplot.R {OUTDIR}/{wildcards.Sample}/depth 
       Rscript {workflow.basedir}/depthplot.log.R  {OUTDIR}/{wildcards.Sample}/depth 
       """

rule depth:
    input:
        OUTDIR + "/{Sample}/minimap2/aligned.bam"
    output:
        OUTDIR + "/{Sample}/depth/depth.txt"
    log:
        OUTDIR + "/{Sample}/logs/depth.log"
    shell:
        """
        set -euo pipefail
        samtools depth -d 1000000 {input} > {output} 2> {log}
        [ -s {output} ] || (echo "Error: {wildcards.Sample} does not contain aligned reads" >> {log}; exit 1)
        """

rule minimap2:
   input:
        fastq=OUTDIR + "/{Sample}/guppy/basecalls.fasta",
        reference = lambda wc: samples[samples.Sample == wc.Sample].Reference[0]
   output:OUTDIR + "/{Sample}/minimap2/aligned.bam"
   threads: 8
   params:
        ref=lambda wc: samples[samples.Sample == wc.Sample].Reference[0]
   shell:"minimap2 -a -t {threads} {input.reference} {input.fastq}|samtools sort -@ {threads} -o {output} "


rule fakeguppy:
   input:
        indir=SEQDATAPATH + "/fastq_pass/{Sample}",
   params: 
        seqpath = SEQDATAPATH,
        outdir = directory(OUTDIR + "/{Sample}")
   output:
        outfile = OUTDIR + "/{Sample}/guppy/basecalls.fasta"
   threads: 1
   shell:
       """
       Summary_File=$( ls {params.seqpath}/sequencing_summary_* ||true)
       {workflow.basedir}/guppy2katuali.sh {input.indir} {params.outdir} $Summary_File 
       """

rule runcanu:
   input:
        fastq=OUTDIR + "/{Sample}/guppy/basecalls.fasta",
        reference = lambda wc: samples[samples.Sample == wc.Sample].Reference[0]
   params: 
        outdir = OUTDIR + "/{Sample}/canu"
   output:
        consensus = OUTDIR + "/{Sample}/canu/consensus.fa"
   threads: 20 
   shell:
       """
       canu -p {wildcards.Sample} -d {params.outdir} genomeSize={Canu_genomeSize} maxInputCoverage={Canu_maxInputCoverage} -nanopore-raw {input.fastq} maxThreads={threads}
       if [ -e "{params.outdir}/{wildcards.Sample}.contigs.fasta" ]
       then
           mv {params.outdir}/{wildcards.Sample}.contigs.fasta {output.consensus}
           rm -rf {params.outdir}/{wildcards.Sample}.* {params.outdir}/correction {params.outdir}/haplotyping {params.outdir}/trimming {params.outdir}/unitigging 
       else
           touch {output.consensus} 
       fi
       # remove canu intermediates we don't use
       """

rule medaka:
   input:
        fastq=OUTDIR + "/{Sample}/guppy/basecalls.fasta",
        reference = lambda wc: samples[samples.Sample == wc.Sample].Reference[0]
   output:
        outdir=directory(OUTDIR + "/{Sample}/guppy/medaka"),
        outconsensus=OUTDIR + "/{Sample}/guppy/medaka/consensus.fasta"
   threads: 20 
   shell:
       """
       medaka_consensus -i {input.fastq} -d {input.reference} -o {output.outdir} -t {threads} -g
       """

rule map_medaka:
   input:
        fastq=OUTDIR + "/{Sample}/guppy/basecalls.fasta",
        reference=OUTDIR + "/{Sample}/guppy/medaka/consensus.fasta"
   output:OUTDIR + "/{Sample}/minimap2/aligned.medaka.bam"
   threads: 8
   shell:"minimap2 -a -t {threads} {input.reference} {input.fastq}|samtools sort -@ {threads} -o {output} "
