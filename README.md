# shiny
R-Shiny apps

oligo tm
--------------------------
[This shiny app](https://dsurujon.shinyapps.io/primer-tm/) calculates the melting temperatures(Tm) of a pair of DNA sequences or oligonucleotides. The Tm is defined as the temperature at which 50% of the oligonucleotides will be dissociated from their complementary strand. This information can be applied when designing polymerase chain reaction (PCR) protocols. Enter two dna sequences (strings only containing the characters a,c,t,g,A,C,T,G) in the Oligo input fields on the left and hit calculate to generate their corresponding Tm's. 
The calculation is based on the description in [this webpage by promega ](https://www.promega.com/techserv/tools/biomath/calc11.htm#disc). 


PAEA
--------------------------
[This app](https://dsurujon.shinyapps.io/PAEA_App/) utilizes the Principle Angle Enrichment Analysis (PAEA) tool (available in the package [GeoDE](http://cran.r-project.org/web/packages/GeoDE/GeoDE.pdf)) developped by the Maayan Lab at Mount Sinai School of Medicine. There is a pre-loaded data set containing [Geo2Enrichr](http://maayanlab.net/g2e/) (also developped by the Maayan Lab) output data. This file contains information on single-gene alteration experiments in human and mouse cells and tissues with the up-regulated and down-regulated genes identified. The user can review the experiments in the "Summary" tab, and select a single experiment to perform PAEA analysis on the differentially regulated genes of the experiment. The visualized and tabulated results for upregulated and downregulated genes are shown on separate tabs. This app uses the KEGG pathways data as the reference set. 

ChDir_and_PAEA
---------------------------
This app utilizes the Principle Angle Enrichment Analysis (PAEA) tool (available in the package [GeoDE](http://cran.r-project.org/web/packages/GeoDE/GeoDE.pdf)) developped by the Maayan Lab at Mount Sinai School of Medicine. The data from the Maayan Lab could be used to query any Geo Dataset for microarray data and see which single-gene alteration experiments it resembles the most in terms of gene expression profile. 

lasso_microbiome
---------------------------
[This app](https://dsurujon.shinyapps.io/lasso_microbiome) will fit a generalized linear model based on intestinal microbiota to the clinical data selected from the drop down list above. Plot 1 shows the regression coefficients along varying constrainsts on the l1 norm of the entirety of the coefficient vector. Plot 2 is the cross-validation fit showing the mean squared errors over the penalty factor lambda. Table 1 shows the number of variables (Df) and % variability (Dev) explained at each lambda value calculated. The slider allows for the selection of any lambda and the resulting coefficients are presented in Table 2. Table 3 (not displayed) is the coefficients with the lambda that minimizes MSE. For more information visit [here](http://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html)
