library(shiny)
library(GeoDE)
shinyServer(
	function(input, output) {

	datatable<-reactive({
		inputfile<-input$mytable
		if(is.null(inputfile)){return(NULL)}
		dtable<-read.csv(inputfile$datapath, sep=",", header=FALSE)
		names(dtable)<-c("Experiment.ID","Control","Experiment","Gene","Type","Organism","Cell.Type","Up.Genes","Down.Genes","Submitted.By","Time.Submitted","Index")
		return(dtable)
	})
	output$checkUpload<-reactive({
		if(is.null(datatable())){return(NULL)}
		else{return(TRUE)}
	})
	output$contents<-renderTable({
		if (is.null(input$mytable)){return(NULL)}
		return (datatable()[,c(1,4:7,10:12)])
	})
	output$summary<-renderPrint({
		if (is.null(input$mytable)){return(NULL)}
		summary(datatable()[,4:7])
	})
	output$experiments<-renderUI({
		return(selectInput("expt","Experiment",choices=as.character(datatable()[,1])))
	})
	output$selectedexpt<-renderTable({
		d<-datatable()
		return(d[d$Experiment.ID==input$expt,c(1,4:7,10:12)])
	})
	output$listexpts<-renderUI({
		d<-datatable()
		return(selectInput("selectexpt","Select Experiment by Index", choices=(d[d$Experiment.ID==input$expt,c(1,4:7,10:12)])$Index))

	})
	PAEA<-reactive({
		x<-datatable()
		selected<-input$selectexpt
		if(is.null(x)){return(NULL)}

		#load data
		data(example_gammas)
		data(GeneOntology_BP.gmt)

		#get upregulated genes from datatable
		select.up<-x$Up.Genes[x$Index==selected]

		#get downregulated genes from datatable
		select.down<-x$Down.Genes[x$Index==selected]

		#clean up genes and format for PAEAAnalysis
		select.up.table<-sapply(gsub(",","",select.up),function(x) strsplit(x,split="\n"))[[1]]
		select.up.table<-t(as.data.frame(sapply(select.up.table,function(x) strsplit(x,split="\t"))))
		select.down.table<-sapply(gsub(",","",select.down),function(x) strsplit(x,split="\n"))[[1]]
		select.down.table<-t(as.data.frame(sapply(select.down.table,function(x) strsplit(x,split="\t"))))
		
		if(ncol(select.up.table)==2 & ncol(select.down.table)==2){
			proc2u<-c()
			proc2d<-c()

			proc2u[[1]][[1]]<-as.matrix(as.numeric(select.up.table[,2]))
			rownames(proc2u[[1]][[1]])<-select.up.table[,1]

			proc2d[[1]][[1]]<-as.matrix(as.numeric(select.down.table[,2]))
			rownames(proc2d[[1]][[1]])<-select.down.table[,1]

			#generate plots and p value tables
			#PAEAu<-PAEAAnalysis(proc2u,gmt,example_gammas)
			#PAEAd<-PAEAAnalysis(proc2d,gmt,example_gammas)
		}else{proc2u<-NULL
			proc2d<-NULL}
		return(list("PAEAup"=proc2u,"PAEAdown"=proc2d,"G"=gmt,"gammas"=example_gammas))
	})

	output$PAEAupPlot<-renderPlot({
		validate(
			need(!is.null(PAEA()$PAEAup),"The characteristic direction data is missing")
		)
		upPlot<-PAEAAnalysis(PAEA()$PAEAup,PAEA()$G,PAEA()$gammas)
		return(upPlot)
	})
	output$PAEAupTable<-renderTable({
		validate(
			need(!is.null(PAEA()$PAEAup),"The characteristic direction data is missing")
		)
		upTable<-data.frame(t(PAEAAnalysis(PAEA()$PAEAup,PAEA()$G,PAEA()$gammas)$p_values))
		names(upTable)<-c("p value")
		return(upTable)
	})
	output$PAEAdownPlot<-renderPlot({
		validate(
			need(!is.null(PAEA()$PAEAdown),"The characteristic direction data is missing")
		)
		downPlot<-PAEAAnalysis(PAEA()$PAEAdown,PAEA()$G,PAEA()$gammas)
		return(downPlot)
	})
	output$PAEAdownTable<-renderTable({
		validate(
			need(!is.null(PAEA()$PAEAdown),"The characteristic direction data is missing")
		)
		downTable<-data.frame(t(PAEAAnalysis(PAEA()$PAEAdown,PAEA()$G,PAEA()$gammas)$p_values))
		names(downTable)<-c("p value")
		return(downTable)
	})	
	outputOptions(output,'checkUpload',suspendWhenHidden=FALSE)

})
