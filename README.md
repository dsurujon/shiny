# shiny
R-Shiny apps

oligo tm
--------------------------

[This shiny app](https://dsurujon.shinyapps.io/primer-tm/) calculates the melting temperatures(Tm) of a pair of DNA sequences or oligonucleotides. The Tm is defined as the temperature at which 50% of the oligonucleotides will be dissociated from their complementary strand. This information can be applied when designing polymerase chain reaction (PCR) protocols. Enter two dna sequences (strings only containing the characters a,c,t,g,A,C,T,G) in the Oligo input fields on the left and hit calculate to generate their corresponding Tm's. 
The calculation is based on the description in [this webpage by promega ](https://www.promega.com/techserv/tools/biomath/calc11.htm#disc). 


PAEA
--------------------------
[This app](https://dsurujon.shinyapps.io/PAEA_App/) utilizes the Principle Angle Enrichment Analysis (PAEA) tool (available in the package [GeoDE](http://cran.r-project.org/web/packages/GeoDE/GeoDE.pdf)) developped by the Maayan Lab at Mount Sinai School of Medicine. The user can upload a csv file containing [Geo2Enrichr](http://maayanlab.net/g2e/) (also developped by the Maayan Lab) output data. This file will contain information on single-gene alteration experiments in human and mouse cells and tissues with the up-regulated and down-regulated genes identified. Once this file is uploaded the user can review the experiments in the "Summary" tab, and select a single experiment to perform PAEA analysis on the differentially regulated genes of the experiment. The visualized and tabulated results for upregulated and downregulated genes are shown on separate tabs. This app uses the KEGG pathways data as the reference set. 
