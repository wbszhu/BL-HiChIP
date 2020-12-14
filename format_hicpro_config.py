import sys
BOWTIE2_IDX_PATH=sys.argv[1]
REFERENCE_GENOME=sys.argv[2]
GENOME_SIZE=sys.argv[3]
GENOME_FRAGMENT=sys.argv[4]
LIGATION_SITE=sys.argv[5]

content_to_addvalue = {
    "BOWTIE2_IDX_PATH":BOWTIE2_IDX_PATH,
    "REFERENCE_GENOME":REFERENCE_GENOME,
    "GENOME_SIZE":GENOME_SIZE,
    "GENOME_FRAGMENT":GENOME_FRAGMENT,
    "LIGATION_SITE":LIGATION_SITE,
}


with open("/data2/zhanglu/66.QXL/00.BL-HiChIP-Pipeline/00.config/config-hicpro") as f:
    temp = f.read()

new_file_content = temp.format(**content_to_addvalue)

with open("/data2/zhanglu/66.QXL/00.BL-HiChIP-Pipeline/00.config/config-hicpro.txt", 'w') as fo:
    fo.write(new_file_content)


