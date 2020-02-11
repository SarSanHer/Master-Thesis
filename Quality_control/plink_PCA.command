#! /bin/bash

### This script executes the plink program to perform a PCA analysis over the control sample files in order to detect stratification in the population.


# go to home directory and then to the folder where plink is downloaded
cd 
cd BioCompu/TFM/apps/plink_mac_20200121 

echo ''
echo ''
echo '>>>> We are in plink directory now'
echo ''
echo ''

# execute plink over control files
./plink --bfile '/Volumes/GRU/TFM/plink_files/filtered_cases_plink' --pca 10 --out '/Volumes/GRU/TFM/plink_files/PCA/PCA_cases_plink'

echo ''
echo ''
echo '>>>> Plink over the control files performed'
echo ''
echo ''

cd
cd ..
cd ..
cd Volumes/GRU/TFM/plink_files/PCA
