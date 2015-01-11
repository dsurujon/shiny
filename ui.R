shinyUI(pageWithSidebar(
	headerPanel("Tm calculator for primer sequences"),

	sidebarPanel(
	textInput(inputId="primer1",label="Oligo sequence 1"),
	textInput(inputId="primer2",label="Oligo sequence 2"),
	p("\n"),
	actionButton("goButton","Calculate")
	),
	
	mainPanel(
	p("This shiny app calculates the melting temperatures(Tm) of a pair of DNA  sequences or oligonucleotides. The Tm is defined as the temperature at  which 50% of the oligonucleotides will be dissociated from their  complementary strand. This information can be applied when designing  polymerase chain reaction (PCR) protocols. Enter two dna sequences (strings  only containing the characters a,c,t,g,A,C,T,G) in the Oligo input fields  on the left and hit calculate to generate their corresponding Tm's. 
The calculation is based on the description in the promega website here:  https://www.promega.com/techserv/tools/biomath/calc11.htm#disc"),
	h4("Sequence 1:"),
	textOutput("seq1"),
	h5("Tm for oligo 1:"),
	textOutput("tm1"),
	h4("Sequence 2:"),
	textOutput("seq2"),
	h5("Tm for oligo 2:"),
	textOutput("tm2")	
	)
	
))
