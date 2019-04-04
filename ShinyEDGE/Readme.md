ShinyEDGE: Exploration of Differential Gene Expression
-----------------------------------------

This app allows exploratory data analysis on RNAseq data. It comes pre-loaded with data from Zhu et al 2019 *(in preparation)* where two strains of *Streptococcus pneumoniae* (19F and T4) are treated with 4 different antibiotics (LVX, KAN, VNC, RIF). To access the app with this dataset, visit http://bioinformatics.bc.edu/shiny/ShinyEDGE/

There are 4 panels that allow for different types of data exploration: 
* **Single Experiment:** plot differential expression (DE) against any other metadata associated with genes (e.g. to answer whether essential genes are more downregulated, you can select Essetiality as the x-axis metadata variable)
* **Compare 2 Experiments:** plot DE from one experiment against the DE in another experiment (e.g. to answer whether two strains respond similarly to the same antibiotic, plot T4_LVX against 19F_LVX)
* **Compare All Experiments:** Use a heatmap and PCA to see if there are groups of highly similar experiments 
* **Network:** Overlay significant expression changes on a network, compare network characteristics (e.g. degree) to gene data (e.g. DE or other metadata)

### Single Experiment
In this panel, you can select one RNAseq experiment (which could include multiple timepoints) using the dropdown menu "Select experiment". The DE data for that experiment and corresponding metadata for the strain will be loaded, and the scatter plot will update accordingly. In this plot, the y axis is always DE, and the x axis is the metadata variable you may select from the dropdown menu "Variable". Transcriptionally Important Genes (TIGs) are defined as genes with significant DE. More formally, |log2FoldChange(experiment/control)|>1 and Bonferroni-adjusted p-value < 0.05. TIGs are colored in green, whereas non-TIGs are black.     
There are several visualization options. For categorical x-axis variables, checking "Jitter x axis" adds some noise to the x-coordinate of each data point, and might make the visualization easier to interpret. It is also possible to overlay a violin plot with mean +- 95% confidence intervals (in red).   
![Jitter Example](https://contattafiles.s3.us-west-1.amazonaws.com/tnt8877/qK2wZmkn9549tMt/Pasted%20Image%3A%20Apr%204%2C%202019%20-%2011%3A58%3A36am)    
Some metadata variables may follow log-normal distribution. In order to accomodate for this, there is also a checkbox to log-transform the x-axis ("log-scale x axis"). Finally, the slider "Transparency" controls the transparency of the points. For experiments where a large number of points will be plotted simultaneously, use a value ~0.5.     
    
The scatter plot itself is brushable, meaning it is possble to select a subset of points by dragging a selection window directly on the plot. The selected genes will then be displayed on the table at the bottom of the screen

## Running the app locally




## Using custom data

