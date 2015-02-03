shinyUI(fluidPage(
	headerPanel("PAEA analysis of Geo2Enrichr Output"),
	sidebarPanel(

		uiOutput("experiments"),			

		tags$p("Select an experiment by gene name from the Geo2Enrichr data. The 'PAEA Main' panel will display all experiments involving perturbations in that gene and allow for further selection if there are multiple entries. The 'PAEA UP' and 'PAEA DOWN' panels show the plotted and tabulated results for up- and down-regulated gene sets. The 'Contents' panel shows a truncated version of the the data table uploaded. The 'Summary' tab shows a summary of the data table ")
	
	), #sidebarPanel	
	mainPanel(
		tabsetPanel(
			tabPanel("Contents",tableOutput('contents')),
			tabPanel("Summary",verbatimTextOutput('summary')),
			tabPanel("PAEA Selection",
				tags$p("Experiments with selected gene:"),
				dataTableOutput('selectedexpt')
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