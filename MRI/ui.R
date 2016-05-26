shinyUI(fluidPage(
	headerPanel("MRI Data Analysis"),
	sidebarPanel(
		radioButtons('sep', 'Delimitor in data file',
                   c(Comma=',',Semicolon=';',Tab='\t'),
                   ','),
		fileInput("MRI_data_file","Upload a data file"),
		fileInput("MRI_labels","Upload a labels file"),
		tags$p("Make sure the labels file is tab separated and has two columns: one for animal ID('id') and one for group('gp')"),
		textInput("fig1_label", label = p("Figure 1 Label"), value = "Body Composition"),
		checkboxInput("outliers", "Include outliers", TRUE),
		tags$p("Outlier(s) removed:"),
		verbatimTextOutput("outliers"),
		radioButtons('bars',"Error bars show:",c("Standard Error"=1,"Standard Deviation"=2))
		
		
	), #sidebarPanel
	mainPanel(
			uiOutput('select_category1'),
			uiOutput('select_category2'),
			tags$p('Significance Summary:'),
			tableOutput('MRIdata'),
			tags$p('Graphical summary of data:'),
			plotOutput('MRIbar')
		
		
	)#mainPanel

))
