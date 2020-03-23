# SNPeff

This file contains the commands used for running the program *SNPeff* in order to identify the function of the regions of our SNPs. We will create a library of SNPs related functionality to refear to once the SNPs have been prioriticed and we want to look further into the impact of some SNPs.

## Get program  
The program can be installed from its website ([link](http://snpeff.sourceforge.net/)) or using code. The following has been extracted from the [SnpEff Documentation](http://snpeff.sourceforge.net/SnpEff_manual.html#run).

    # Download using wget
    wget http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip

    # If you prefer to use 'curl' instead of 'wget', you can type:
    curl -L http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip > snpEff_latest_core.zip

    # Install
    unzip snpEff_latest_core.zip 

## Running program

    java -Xmx4g -jar snpEff.jar -v -stats <train.html> GRCh37.75 <trainCases.vcf> > <trainCases.ann.vcf>
    
