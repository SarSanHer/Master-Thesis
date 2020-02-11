#! /bin/bash

### This script executes the plink program twice: (1) over the control SNPs files to filter out all SNPs that are not in Hardy–Weinberg equilibrium; and (2) over the case SNPs files to filter out all SNPs that do not meet the quality criteria.




#args=("$@") # line so that I can read the arguments used to call the script
## ${args[0]} -> control files name 
## ${args[1]} -> case files name 


# go to home directory and then to the folder where plink is downloaded
cd 
cd BioCompu/TFM/apps/plink_mac_20200121 

echo ''
echo ''
echo '>>>> We are in plink directory now'
echo ''
echo ''

# execute plink over control files: this puts the files in the right format (otherwise it gives an error about 'split chromosome in the .bed file')
./plink --bfile /Volumes/GRU/TFM/SET_DATOS_CONTROLES_36_HG18/CTRL_iChip_Spain01020405_1KG_TopBot_F3_SEX --make-bed --out '/Volumes/GRU/TFM/plink_files/control_plink' 


# now we can filter with plink
./plink --bfile '/Volumes/GRU/TFM/plink_files/control_plink' --make-bed --hwe 0.0001 --out '/Volumes/GRU/TFM/plink_files/hwe_control_plink'


echo ''
echo ''
echo '>>>> Plink over the control files performed successfully'
echo ''
echo ''

#extract second column since that one contains the SNPs
cat '/Volumes/GRU/TFM/plink_files/hwe_control_plink.bim' | cut -f2 > /Volumes/GRU/TFM/plink_files/my_SNPs.txt  

echo ''
echo ''
echo '>>>> SNPs file created'
echo ''
echo ''



# execute plink over control files: this puts the files in the right format (otherwise it gives an error about 'split chromosome in the .bed file')
./plink --bfile /Volumes/GRU/TFM/cases/RA_MARHC_Paz_Princesa_Santander_completo --make-bed --out '/Volumes/GRU/TFM/plink_files/cases_plink'


# execute plink over case files + all filters
./plink --bfile '/Volumes/GRU/TFM/plink_files/cases_plink' --make-bed --allow-no-sex --het --mind 0.02 --maf 0.05 --geno 0.02 --extract /Volumes/GRU/TFM/plink_files/my_SNPs.txt --out '/Volumes/GRU/TFM/plink_files/filtered_cases_plink'

echo ''
echo ''
echo '>>>> Plink over case files performed successfully' 
echo ''
echo ''

cd ..
cd ..
cd Volumes/GRU/TFM/plink_files


cat filtered_cases_plink.het | awk '$6<=0.05' > FINAL_filtered_cases_plink.het
echo ''
echo ''
echo '>>>> File with the heterozygosity filter applied has been created and it has #variants:' 
cat FINAL_filtered_cases_plink.het | wc -l
echo ''
echo ''
