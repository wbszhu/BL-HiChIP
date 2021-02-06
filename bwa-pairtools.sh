#/public/home/xlliu/01.lzhang/02.scripts
#!/bin/sh
#BSUB -J ${SAMPLE}
#BSUB -n 10
#BSUB -R span[hosts=1]
#BSUB -o %J.out
#BSUB -e %J.err
#BSUB -q normal


SAMPLE=${SAMPLE}
WK_PATH=/public/home/xlliu/01.lzhang/01.data
SCRIPT_PATH=/public/home/xlliu/01.lzhang/BL-HiChIP
CONFIG=$SCRIPT_PATH/00.config
DATA=$WK_PATH/01.DRP
RESULTS=/public/home/xlliu/01.lzhang/01.data/01.DRP/
TRIMLNKER=/public/home/xlliu/01.lzhang/00.software/ChIA-PET2/bin/trimLinker
#BWA INDEX
BWA_IDX_PATH=/public/home/xlliu/01.lzhang/22.genome/GRCh38/bwa_index/GRCh38.primary_assembly.genome_no_scaff.fa
#fithichip config
GENOME_SZ=/public/home/xlliu/01.lzhang/22.genome/GRCh38/GRCh38.primary_assembly.genome_no_scaff.fa.sizes
CHIPDATA=/public/home/xlliu/01.lzhang/01.data/22.chip-seq-cut-tag/k562/peak_bw_html/02.peak/H3K27ac_K562_pup5_qup2_peak.bed
VALID_PATH=/$RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.allValidPairs
RZL=5000
UseP2PBackgrnd=0


source /public/home/qyyang/soft/miniconda3/etc/profile.d/conda.sh
conda activate lzhang_misc

mkdir -p $RESULTS/${SAMPLE}/01.trim.sh_output

#trim_adaptor

mkdir -p $RESULTS/${SAMPLE}/01.trim.sh_output/trim_adaptor

trim_galore -q 20 --phred33 --paired --illumina --trim-n  --gzip -o $RESULTS/${SAMPLE}/01.trim.sh_output/trim_adaptor $DATA/${SAMPLE}/${SAMPLE}_R1.fq.gz  $DATA/${SAMPLE}/${SAMPLE}_R2.fq.gz

#trim linker
mkdir -p $RESULTS/${SAMPLE}/01.trim.sh_output/trim_linker

$TRIMLNKER -e 2  -t 12 -m 1 -k 1 -l 16 -o $RESULTS/${SAMPLE}/01.trim.sh_output/trim_linker  -n ${SAMPLE} -A ACGCGATATCTTATC -B AGTCAGATAAGATAT  $RESULTS/${SAMPLE}/01.trim.sh_output/trim_adaptor/${SAMPLE}_R1_val_1.fq.gz  $RESULTS/${SAMPLE}/01.trim.sh_output/trim_adaptor/${SAMPLE}_R2_val_2.fq.gz

#bwa
mkdir -p $RESULTS/${SAMPLE}/01.trim.sh_output/align
bwa mem -SP5M -t 20  -o   $RESULTS/${SAMPLE}/01.trim.sh_output/align/${SAMPLE}.sam $BWA_IDX_PATH   $RESULTS/${SAMPLE}/01.trim.sh_output/trim_linker/${SAMPLE}_1.valid.fastq $RESULTS/${SAMPLE}/01.trim.sh_output/trim_linker/${SAMPLE}_2.valid.fastq

#pairtools

mkdir -p $RESULTS/${SAMPLE}/01.trim.sh_output/pairs
pairtools parse -c $GENOME_SZ -o  $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.pairs.gz --drop-sam  $RESULTS/${SAMPLE}/01.trim.sh_output/align/${SAMPLE}.sam
pairtools sort -o $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.sorted.pairs.gz $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.pairs.gz
pairtools dedup -o  $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.sorted.dedup.pairs.gz $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.sorted.pairs.gz
pairtools select '(pair_type=="UU")' -o  $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.sorted.dedup.UU.pairs.gz  $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.sorted.dedup.pairs.gz
pairtools stats -o $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.STATS.UU  $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.sorted.dedup.UU.pairs.gz
zcat $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.sorted.dedup.UU.pairs.gz |awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$6,$4,$5,$7}'|grep -v "" > $RESULTS/${SAMPLE}/01.trim.sh_output/pairs/${SAMPLE}.allValidPairs

#fithichip
conda activate lzhang_FitHiChIP

mkdir -p $RESULTS/${SAMPLE}/02.fitchip_for_loop.sh_output/fithichip;cd  $RESULTS/${SAMPLE}/02.fitchip_for_loop.sh_output/fithichip

python3 $SCRIPT_PATH/format_fithichip_config.py  $VALID_PATH  $CHIPDATA  $RESULTS/${SAMPLE}/02.fitchip_for_loop.sh_output/fithichip/results  $RZL  $GENOME_SZ  $UseP2PBackgrnd

echo `date +"%Y-%m-%d %H:%M:%S"`

bash  ~/01.lzhang/00.software/FitHiChIP/FitHiChIP_HiCPro.sh -C $CONFIG/configfile_BiasCorrection_CoverageBias.txt

echo `date +"%Y-%m-%d %H:%M:%S"`
