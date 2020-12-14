import sys
out_file = sys.argv[1]
content_to_addvalue = {
    "SAMPLE":"AH-1",
    "WK_PATH":"/data2/zhanglu/66.QXL/00.BL-HiChIP-Pipeline/test",
    "BOWTIE2_IDX_PATH":"/data2/zhanglu/22.genome/susScr11_xy/bowtie2_index",
    "REFERENCE_GENOME":"susScr11_index",
    "GENOME_FRAGMENT":"/data2/zhanglu/22.genome/susScr11_xy/susScr11.AluI.bed",
    "LIGATION_SITE":"AGCT",
    "GENOME_SZ":"/data2/zhanglu/22.genome/susScr11_xy/pig11.1_from_star_chrom.sizes",
    "CHIPDATA":"/data2/zhanglu/13.PAM/00.data/00.chip-seq/0h/0h_H3K27ac_qvalueup2_pvalueup5.narrowPeak.sorted.bed",
}

with open("00.BL-hichip.sh") as f:
    temp = f.read()

new_file_content = temp.format(**content_to_addvalue)

with open(out_file, 'w') as fo:
    fo.write(new_file_content)


