shinyUI(fluidPage(
	headerPanel("PAEA analysis of Geo2Enrichr Output"),
	sidebarPanel(
		textInput("expression_data",label="GDS ID",value="GDS4988"),
		actionButton("submit_id", label="Submit")
		#fileInput("expression_data_file","Upload a CSV file")

	), #sidebarPanel	
	mainPanel(
		tabsetPanel(
			tabPanel("Metadata",
				tags$h4("Description"),
				verbatimTextOutput('input_descr'),
				tags$h4("Dataset ID"),
				verbatimTextOutput('input_id'),
				tags$h4("Organism"),
				verbatimTextOutput('input_org'),
				tags$h4("Reference"),
				verbatimTextOutput('input_cite')
			),#tabPanel - Data Preview

			tabPanel("Select Experiment Groups",
				uiOutput('sample_control_select'),
				uiOutput('sample_experiment_select'),
				actionButton("submit_sample_id", label="Submit for ChDir")
			),#tabPanel - Select Experiment

			
			tabPanel("ChDir",
			conditionalPanel(condition="output.checkChdir==true",
				tags$h4("Selected Controls"),
				verbatimTextOutput('list_controls'),
				tags$h4("Selected Experiments"),
				verbatimTextOutput('list_experiments'),
				actionButton("submit_PAEA",label="Submit for PAEA"),
				tags$h4("Top genes"),
				plotOutput('chdirplot'),
				tableOutput('chdirlist'),
				downloadButton('download_ChDir',"Download Full ChDir Table")
				
			)#conditionalPanel
			),#tabPanel - ChDir
			
			tabPanel("PAEA",
				conditionalPanel(condition="output.checkPAEA==true",
					tags$h4("PAEA of upregulated genes"),
					plotOutput('PAEAup_plot'),
					tags$h4("PAEA of downregulated genes"),
					plotOutput('PAEAdown_plot')
				)#conditionalPanel
			),#tabPanel - PAEA
			tabPanel("PAEA Common",
				conditionalPanel(condition="output.checkPAEA==true",
					sliderInput("pval","Set maximum P-value",min=0,max=1,value=0.1,step=0.01),
					tags$h4("Common experiments in up and downregulated pathways"),
					downloadButton('download_PAEA',"Download Current PAEA Table"),
					tableOutput('PAEAcompare')
				)#conditionalPanel
			)#tabPanel - PAEA common
		)#tabsetPanel
	)#MainPanel
))
