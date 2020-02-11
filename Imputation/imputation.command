#! /bin/bash

### This script is for the SNP's imputation performed by the Michigan imputation server (Linux machine)


# download reference panel for the imputation
wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz

unzip HRC-1000G-check-bim-v4.2.7.zip # unzip the file to use it


perl HRC-1000G-check-bim.pl -b /home/duna/Desktop/TFM/plink_files/filtered_cases_plink.bim -f /home/duna/Desktop/TFM/MIS/cases.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

sh Run-plink.sh



# go to home directory and then to the folder where plink is downloaded
cd 
cd BioCompu/TFM/apps/plink_mac_20200121 

echo ''
echo ''
echo '>>>> We are in plink directory now'
echo ''
echo ''

# execute plink over control files to obtain freq file
./plink --bfile /Volumes/GRU/TFM/plink_files/hwe_control_plink --make-bed --out '/Volumes/GRU/TFM/MIS/control' 

echo ''
echo ''
echo '>>>> Plink over the control files performed'
echo ''
echo ''

# execute plink over control files to obtain freq file
./plink --freq --bfile /Volumes/GRU/TFM/plink_files/filtered_cases_plink --allow-no-sex --out /Volumes/GRU/TFM/MIS/cases


echo ''
echo ''
echo '>>>> Plink over the case files performed'
echo ''
echo ''