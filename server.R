library(shiny)
bases<-c("a","c","g","t")
shinyServer(
	function(input, output) {
	observe({
	
	#convert to lowercase
	p1<-tolower(input$primer1)
	#unique characters in the oligo sequence
	uniques1<-unique(strsplit(p1,"")[[1]])

	output$seq1<-renderText({
		if (input$goButton==0) ""
		#check if the entered sequence is a valid DNA sequence
		else if (all(lapply(uniques1,function (i) i %in% bases))) p1
		else "please enter a valid dna sequence"})
	#number of each nucleotide
	primer1A<-nchar(gsub("[^a]","",p1))
	primer1T<-nchar(gsub("[^t]","",p1))
	primer1G<-nchar(gsub("[^g]","",p1))
	primer1C<-nchar(gsub("[^c]","",p1))
	
	T1<-0
	#use the simpler equation for primers shorter than 14 nucleotides
	if (nchar(p1)<14) {T1<-4*(primer1G+primer1C)+2*(primer1A+primer1T)}
	else {T1<-64.9+41*(primer1G+primer1C-16.4)/(nchar(p1))}	
	output$tm1<-renderText({
		if (input$goButton==0) ""
		else T1})
	
	#convert to lowercase
	p2<-tolower(input$primer2)
	#unique characters in the oligo sequence
	uniques2<-unique(strsplit(p2,"")[[1]])
	output$seq2<-renderText({
		if (input$goButton==0) ""
		#check if the entered sequence is a valid DNA sequence
		else if (all(lapply(uniques2,function (i) i %in% bases))) p2
		else "please enter a valid dna sequence"})
	#number of each nucleotide
	primer2A<-nchar(gsub("[^a]","",p2))
	primer2T<-nchar(gsub("[^t]","",p2))
	primer2G<-nchar(gsub("[^g]","",p2))
	primer2C<-nchar(gsub("[^c]","",p2))	
	
	T2<-0
	#use the simpler equation for primers shorter than 14 nucleotides
	if (nchar(p2)<14) {T2<-4*(primer2G+primer2C)+2*(primer2A+primer2T)}
	else {T2<-64.9+41*(primer2G+primer2C-16.4)/(nchar(p2))}	
	output$tm2<-renderText({
		if (input$goButton==0) ""
		else T2})
	})
})
