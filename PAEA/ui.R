shinyUI(fluidPage(
	headerPanel("PAEA analysis of Geo2Enrichr Output"),
	sidebarPanel(
		fileInput("mytable","Select CSV File"),
		conditionalPanel(condition="output.checkUpload!=null",
			uiOutput("experiments")			
		),#conditionalPanel
		tags$p("Upload a csv file containing Geo2Enrichr output data. Then select an experiment by ID. The 'PAEA Main' panel will display the selected experiment and allow for further selection if there are multiple entries with the same experiment ID. The 'PAEA UP' and 'PAEA DOWN' panels show the plotted and tabulated results for up- and down-regulated gene sets. The 'Contents' panel shows a truncated version of the the data table uploaded. The 'Summary' tab shows a summary of the data table ")
	
	), #sidebarPanel	
	mainPanel(
		tabsetPanel(
			tabPanel("Contents",tableOutput('contents')),
			tabPanel("Summary",verbatimTextOutput('summary')),
			tabPanel("PAEA Selection",
				conditionalPanel(condition="output.checkUpload!=null",
				tags$p("Selected Experiment:"),
				tableOutput('selectedexpt')),#conditionalPanel
				conditionalPanel(condition="output.checkUpload!=null",
				uiOutput("listexpts"))#conditionalPanel
			),#tabPanel-PAEA Plots
			tabPanel("PAEA UP",
				conditionalPanel(condition="output.checkUpload!=null",
				tags$p("Upregulated gene sets"),
				plotOutput('PAEAupPlot')),#conditionalPanel
				conditionalPanel(condition="output.checkUpload!=null",
				tableOutput('PAEAupTable')
				)#conditionalPanel
			),#tabPanel-PAEA p values UP
			tabPanel("PAEA DOWN",
				conditionalPanel(condition="output.checkUpload!=null",
				tags$p("Downregulated gene sets"),
				plotOutput('PAEAdownPlot')),#conditionalPanel
				conditionalPanel(condition="output.checkUpload!=null",
				tableOutput('PAEAdownTable')
				)#conditionalPanel
			)#tabPanel - PAEAp values DOWN
	))#tabsetPanel, MainPanel
))
