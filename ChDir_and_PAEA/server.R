##NOTE: Memory issues with 32-bit R


library(shiny)
library(GeoDE)
library(GEOquery)
library(data.table)

microtask_data<-read.csv("data/sgpfbge-2-1-2015.csv", sep=",", header=FALSE)
names(microtask_data)<-c("Experiment.ID","Control","Experiment","Gene","Type","Organism","Cell.Type","Up.Genes","Down.Genes","Submitted.By","Time.Submitted","Index")
microtask_data$Label<-paste(microtask_data$Gene,microtask_data$Type,microtask_data$Experiment.ID,sep=".")

values<-reactiveValues(expression=NA,expt_submit=FALSE,chdir_submit=FALSE,PAEA_submit=FALSE)


shinyServer(
	function(input, output) {

	#get input expression data from file
	input_data_file<-reactive({
		inputfile<-input$expression_data_file
		if(is.null(inputfile)){return(NULL)}
		datatable<-read.csv(inputfile$datapath, sep=",", header=FALSE)
	})
		
	#submit GDS ID 
	#get input data from GDS database
	observe({
		if(input$submit_id==0){return()}

		input$submit_id
		isolate({values$expression<-input$expression_data
			values$gds<-getGEO(values$expression,destdir="data")
			values$md<-Meta(values$gds)
			values$expt_submit<-TRUE
			values$chdir_submit<-FALSE
			values$PAEA_submit<-FALSE
		})
	})
	
	#monitor whether there's a valid GDS ID
	output$checkGDS<-reactive({!is.null(values$gds)})
	outputOptions(output, "checkGDS", suspendWhenHidden=FALSE)
	#monitor the visibility of other panels
	output$checkChdir<-reactive({values$chdir_submit})
	outputOptions(output, "checkChdir", suspendWhenHidden=FALSE)
	output$checkPAEA<-reactive({values$PAEA_submit})
	outputOptions(output, "checkPAEA", suspendWhenHidden=FALSE)

	#generate summary
	output$input_descr<-renderText({
		if(!is.null(values$gds)){
			as.character(values$md$description)
		}else(return(NULL))
	})
	output$input_id<-renderText({
		if(!is.null(values$gds)){
			as.character(unique(values$md$dataset_id))
		}else(return(NULL))
	})
	output$input_org<-renderText({
		if(!is.null(values$gds)){
			as.character(values$md$sample_organism)
		}else(return(NULL))
	})
	output$input_cite<-renderText({
		if(!is.null(values$gds)){
			as.character(values$md$ref)
		}else(return(NULL))
	})
	#select sample classes
	output$sample_control_select<-renderUI({
		if(!is.null(values$gds) && input$submit_id>0){
			radioButtons("control_samples","Choose Controls",unique(values$md$sample_id))
		}else if (is.null(values$gds)){helpText("Please enter a valid experiment identifier")
		}		
	})
	output$sample_experiment_select<-renderUI({
		if(!is.null(values$gds) && input$submit_id>0){
			radioButtons("experiment_samples","Choose Experiments",unique(values$md$sample_id))
		}else if (is.null(values$gds)){helpText("Please enter a valid experiment identifier")
		}		
	})


	#perform ChDir
	observe({
		input$submit_sample_id
		if(is.null(input$submit_sample_id)||input$submit_sample_id==0){return()}

		isolate({
			cat("started chdir \n")
			values$chdir_submit<-TRUE
			expr_data<-NULL
			expr_data_trim<-NULL
			class_factors<-NULL
			x<-list("ctrl"=input$control_samples,"expt"=input$experiment_samples)
			values$c<-strsplit(x$ctrl,",")[[1]]
			values$e<-strsplit(x$expt,",")[[1]]
			#doesn't update control_samples or experiment_samples
			expr_data<-Table(values$gds)
			
			#keep only entries with real gene names
			expr_data<-expr_data[as.character(expr_data$ID_REF)!=as.character(expr_data$IDENTIFIER),]
			
			class_factors<-factor(sapply(names(expr_data), function(x) if(x %in% values$c){return(1)} else if(x %in% values$e){return(2)} else{return(NA)}))
			values$factors<-class_factors
			
			expr_data_trim<-as.data.frame(lapply(expr_data[,!is.na(class_factors)],as.numeric))
			expr_data_trim<-cbind(expr_data$IDENTIFIER,expr_data_trim)
			
			#use a data table to aggregate the entries with the same gene name
			expr_table<-data.table(expr_data_trim)
			setnames(expr_table,1,"ID")
			#remove all entries with ":" in them (chromosomal locations)
			values$expr_table<-data.frame(expr_table[sapply(expr_data$IDENTIFIER,function(x) !grepl(":",x)),lapply(.SD,mean),by=ID])
			
			#in case the data is too large - test with a manageable portion
			#cat(nrow(values$expr_table),"\n")
			#if(nrow(values$expr_table)>100){values$expr_data<-values$expr_data[1:100,]}
			
			values$class_factors<-class_factors[!is.na(class_factors)]
		
		})
	})

	#print out ctrls and expts
	output$list_controls<-renderText({values$c})
	output$list_experiments<-renderText({values$e})
	
	output$chdirplot<-renderPlot({
		chdir_out<-chdirAnalysis(values$expr_table,values$class_factors)
		values$chdir_plot<-chdir_out
		values$chdir_props<-chdir_out$chdirprops
		values$chdir_results<-chdir_out$results
	})
	output$chdirsig<-renderText({
		return(values$chdir_props$number_sig_genes[[1]])})
	output$chdirlist<-renderTable({
		x<-data.frame(values$chdir_results)
		setnames(x,1,"Characteristic Direction")
		return(head(x))
	})
	output$download_ChDir<-downloadHandler(
		filename=function(){paste(unique(values$md$dataset_id),"ChDir.csv",sep="_")
		},content=function(file){write.table(values$chdir_results,file,sep=",")}
	)

	#Perform PAEA
	observe({
		input$submit_PAEA
		if(is.null(input$submit_PAEA)||input$submit_PAEA==0){return()}
		
		isolate({
			cat("started PAEA\n")
			values$PAEA_submit<-TRUE
			#First generate reference gmt lists for up and down genes 
			#where each list element is an experiment and each element is a vector with the experiment ID as the first entry
			values$up_gmt<-apply(microtask_data,1,function(z) c(z[13],unlist(sapply(unlist(strsplit(gsub(",","",z[8]),"\n")),function(x)sub("(.*?)\t.*","\\1",x)))))
			values$down_gmt<-apply(microtask_data,1,function(z) c(z[13],unlist(sapply(unlist(strsplit(gsub(",","",z[9]),"\n")),function(x)sub("(.*?)\t.*","\\1",x)))))

			cd<-data.frame("gene"=rownames(values$chdir_props[[1]][[1]]),"cd"=values$chdir_props[[1]][[1]])
			cd_up<-cd[cd$X1>0,]
			cd_down<-cd[cd$X1<0,]

			proc2u<-c()
			proc2u[[1]][[1]]<-as.matrix(cd_up$X1)
			rownames(proc2u[[1]][[1]])<-cd_up$gene
			proc2d<-c()
			proc2d[[1]][[1]]<-as.matrix(cd_down$X1)
			rownames(proc2d[[1]][[1]])<-cd_down$gene
		
			values$upgenes<-proc2u
			values$downgenes<-proc2d
		})
	})
	
	output$PAEAup_plot<-renderPlot({
		PAEAup<-PAEAAnalysis(values$upgenes,values$up_gmt)
		values$PAEAup_p<-PAEAup$p_values
		values$PAEAup_PAs<-PAEAup$principal_angles
	})
	output$PAEAdown_plot<-renderPlot({
		PAEAdown<-PAEAAnalysis(values$downgenes,values$down_gmt)
		values$PAEAdown_p<-PAEAdown$p_values
		values$PAEAdown_PAs<-PAEAdown$principal_angles
	})
	output$PAEAcompare<-renderTable({
		values$p<-input$pval
		u<-data.frame("Experiment"=colnames(values$PAEAup_p),"P.UP"=as.numeric(values$PAEAup_p))
		d<-data.frame("Experiment"=colnames(values$PAEAdown_p),"P.DOWN"=as.numeric(values$PAEAdown_p))
		#values$common_expts<-merge(u,d,by="Experiment")
		#merge duplicates some values. order then cbind.
		values$common_expts<-cbind(u[order(u$Experiment),],d[order(d$Experiment),2])
		setnames(values$common_expts,3,"P.DOWN")

		headers<-strsplit(as.character(values$common_expts$Experiment),".",fixed=TRUE)
		maxlen<-max(sapply(headers,length))
		# fill in blanks
		headers <- t(sapply(headers, function(x) c(x, rep(NA, maxlen - length(x)))
  			))
		
		values$common_expts_m<-cbind(headers,values$common_expts)
		setnames(values$common_expts_m,1:4,c("Gene","Perturbation","Experiment.ID","X"))
		values$common_expts_p<-values$common_expts_m[values$common_expts_m$P.UP<values$p&values$common_expts_m$P.DOWN<values$p,]
	})
	output$download_PAEA<-downloadHandler(
		filename=function(){paste(unique(values$md$dataset_id),"PAEA_p",as.character(values$p),".csv",sep="_")
		},content=function(file){write.table(values$common_expts_p,file,sep=",")}
	)

})
