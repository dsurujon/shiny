shinyUI(fluidPage(
	headerPanel("PAEA analysis of Geo2Enrichr Output"),
	sidebarPanel(

		uiOutput("experiments"),			

		tags$p("Upload a csv file containing Geo2Enrichr output data. Then select an experiment by gene name. The 'PAEA Main' panel will display the selected experiment and allow for further selection if there are multiple entries with the same gene perturbation. The 'PAEA UP' and 'PAEA DOWN' panels show the plotted and tabulated results for up- and down-regulated gene sets. The 'Contents' panel shows a truncated version of the the data table uploaded. The 'Summary' tab shows a summary of the data table ")
	
	), #sidebarPanel	
	mainPanel(
		tabsetPanel(
			tabPanel("Contents",tableOutput('contents')),
			tabPanel("Summary",verbatimTextOutput('summary')),
			tabPanel("PAEA Selection",
				tags$p("Selected Experiment:"),
				tableOutput('selectedexpt'),
				uiOutput("listexpts")
			),#tabPanel-PAEA Selection

			tabPanel("PAEA UP",
				tags$p("Upregulated gene sets"),
				plotOutput('PAEAupPlot'),
				tableOutput('PAEAupTable')
			),#tabPanel-PAEA p values UP
			tabPanel("PAEA DOWN",
				tags$p("Downregulated gene sets"),
				plotOutput('PAEAdownPlot'),
				tableOutput('PAEAdownTable')
			)#tabPanel - PAEAp values DOWN
	))#tabsetPanel, MainPanel
))