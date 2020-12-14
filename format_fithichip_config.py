import sys
ValidPairs=sys.argv[1]
PeakFile=sys.argv[2]
OutDir=sys.argv[3]
LowDistThr=sys.argv[4]
ChrSizeFile=sys.argv[5]
UseP2PBackgrnd=sys.argv[6]
content_to_addvalue = {
    "ValidPairs":ValidPairs,
    "PeakFile":PeakFile,
    "OutDir":OutDir,
    "LowDistThr":LowDistThr,
    "ChrSizeFile":ChrSizeFile,
    "UseP2PBackgrnd":UseP2PBackgrnd,
}


with open("/data2/zhanglu/66.QXL/00.BL-HiChIP-Pipeline/00.config/configfile_BiasCorrection_CoverageBias") as f:
    temp = f.read()

new_file_content = temp.format(**content_to_addvalue)

with open("/data2/zhanglu/66.QXL/00.BL-HiChIP-Pipeline/00.config/configfile_BiasCorrection_CoverageBias.txt", 'w') as fo:
    fo.write(new_file_content)


