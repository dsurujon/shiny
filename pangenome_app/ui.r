library(shiny)
source("chooser.r")

presence_table<-read.csv("data/374_clusters.csv",header=T,stringsAsFactors = FALSE)
presence_table[presence_table==" "]<-NA
xv<-ncol(presence_table)
allstrains<-names(presence_table)[2:xv]

# Define UI 
shinyUI(fluidPage(

	titlePanel("Streptococcus pneumoniae pan-genome project"),
	
	fluidRow(
	sidebarPanel(
		tags$small(paste0("Select the strains you want to examine from the left. ",
		"The selected strains will appear on the right-hand box. ")),
		chooserInput("mychooser", "Available organisms", "Selected organisms",
			allstrains, c(), size = 10, multiple = TRUE),
		verbatimTextOutput("coreandpan")
	),
	
	mainPanel(plotOutput("distance_phylogeny") )
	),
	fluidRow(
		tags$h2("Gene table for the selected strains"),
		downloadButton('subtable_dl',"Download gene table"),
		dataTableOutput("selection"))
	

  
))