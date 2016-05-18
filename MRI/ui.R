shinyUI(fluidPage(
	headerPanel("MRI Data Analysis"),
	sidebarPanel(
		radioButtons('sep', 'Delimitor in data file',
                   c(Comma=',',Semicolon=';',Tab='\t'),
                   ','),
		fileInput("MRI_data_file","Upload a data file"),
		fileInput("MRI_labels","Upload a labels file"),
		tags$p("Make sure the labels file is tab separated and has two columns: one for animal ID('id') and one for group('gp')"),
		textInput("fig1_label", label = p("Figure 1 Label"), value = "Body Composition")
		
	), #sidebarPanel
	mainPanel(
			tags$p('Significance Summary (Student T-test p-values):'),
			tableOutput('MRIdata'),
			tags$p('Graphical summary of data:'),
			plotOutput('MRIbar')
		
		
	)#mainPanel

))
