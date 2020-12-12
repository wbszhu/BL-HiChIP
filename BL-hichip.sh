#USAGE
#nohup bash  
SAMPLE={SAMPLE}
WK_PATH={WK_PATH}
SCRIPT_PATH=$PWD
CONFIG=$PWD/../00.config
DATA=$WK_PATH/00.data/01.hichip/Rawdata
RESULTS=$WK_PATH/02.results
################################################################### hic-pro config ###########################################################################################
BOWTIE2_IDX_PATH={BOWTIE2_IDX_PATH}
REFERENCE_GENOME={REFERENCE_GENOME}
GENOME_FRAGMENT={GENOME_FRAGMENT}
LIGATION_SITE={LIGATION_SITE}
################################################################### fithichip config ##########################################################################################
GENOME_SZ={GENOME_SZ}
CHIPDATA={CHIPDATA}
VALID_PATH=$RESULTS/{SAMPLE}/01.trim.sh_output/hic_pro.results/hic_results/data/{SAMPLE}/{SAMPLE}.allValidPairs
RZL=5000
UseP2PBackgrnd=0

###########################################################################################################################################################
total_reads_states=$RESULTS/{SAMPLE}/01.trim.sh_output/trim_adaptor
after_trim_states=$RESULTS/{SAMPLE}/01.trim.sh_output/trim_linker
hic_pro_states= $RESULTS/{SAMPLE}/01.trim.sh_output/hic_pro.results/hic_results/stats/{SAMPLE}
##########################################################################################################
########################################################################trim linker#####################################################

mkdir -p $RESULTS/{SAMPLE}/01.trim.sh_output
#########################################################################trim_adaptor#################################################################################

mkdir -p $RESULTS/{SAMPLE}/01.trim.sh_output/trim_adaptor

trim_galore -q 20 --phred33 --paired --illumina --trim-n  --gzip -o $RESULTS/{SAMPLE}/01.trim.sh_output/trim_adaptor $DATA/{SAMPLE}/{SAMPLE}_R1.fq.gz  $DATA/{SAMPLE}/{SAMPLE}_R2.fq.gz


###########################################################################trim linker################################################################################
mkdir -p $RESULTS/{SAMPLE}/01.trim.sh_output/trim_linker

trimLinker -e 2  -t 12 -m 1 -k 1 -l 16 -o $RESULTS/{SAMPLE}/01.trim.sh_output/trim_linker  -n {SAMPLE} -A ACGCGATATCTTATC -B AGTCAGATAAGATAT  $RESULTS/{SAMPLE}/01.trim.sh_output/trim_adaptor/{SAMPLE}_R1_val_1.fq.gz  $RESULTS/{SAMPLE}/01.trim.sh_output/trim_adaptor/{SAMPLE}_R2_val_2.fq.gz

##################################################################prepare the fastq file for hic-pro############################
#
cd $RESULTS/{SAMPLE}/01.trim.sh_output/trim_linker;mv {SAMPLE}_1.valid.fastq {SAMPLE}_R1.fastq ;mv {SAMPLE}_2.valid.fastq  {SAMPLE}_R2.fastq
mkdir {SAMPLE};mv {SAMPLE}_R1.fastq {SAMPLE}_R2.fastq {SAMPLE}
#
##################################################################################hic-pro#####################################################

source /data2/zhanglu/miniconda2/etc/profile.d/conda.sh
conda activate HiC-Pro

python3 $SCRIPT/format_hicpro_config.py $BOWTIE2_IDX_PATH $REFERENCE_GENOME $GENOME_SZ  $GENOME_FRAGMENT $LIGATION_SITE

HiC-Pro -c $CONFIG/config-hicpro.txt -o $RESULTS/{SAMPLE}/01.trim.sh_output/hic_pro.results  -i  $RESULTS/{SAMPLE}/01.trim.sh_output/trim_linker

##############################################################################  fithichip  #########################################################################################################
source /data2/zhanglu/miniconda2/etc/profile.d/conda.sh
conda activate fithichip

mkdir -p $RESULTS/{SAMPLE}/02.fitchip_for_loop.sh_output/fithichip;cd  $RESULTS/{SAMPLE}/02.fitchip_for_loop.sh_output/fithichip

python3 $SCRIPT/format_fithichip_config.py $VALID_PATH $CHIPDATA  $RESULTS/{SAMPLE}/02.fitchip_for_loop.sh_output/fithichip/results  $RZL  $GENOME_PATH  $UseP2PBackgrnd

echo `date +"%Y-%m-%d %H:%M:%S"`
bash  ~/00.software/FitHiChIP/FitHiChIP_HiCPro.sh -C $CONFIG/configfile_BiasCorrection_CoverageBias.txt

echo `date +"%Y-%m-%d %H:%M:%S"`


##################################################################################  stastic  ##############################################################

bash for_stastcs.sh {SAMPLE} SCRIPT_PATH/{SAMPLE} $hic_pro_states
