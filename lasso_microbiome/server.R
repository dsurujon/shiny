
library(glmnet)


#load data set
mice<-read.csv("data/OTU_and_phenotype.csv")


values<-reactiveValues()

shinyServer(function(input,output,session){
	

	prepare_inputs<-reactive({
		mice_traits<-names(mice)[60:70]
		clin_data<-mice[,c(60:70)]
		expr_form_mx<-as.matrix(mice[,c(5:59)])
		return(list("mice_traits"=mice_traits,"clin_data"=clin_data,"expr"=expr_form_mx))
	
	})

	output$select_trait<-renderUI({
		selectInput("clinvar","Clinical variable", prepare_inputs()$mice_traits)
	})
	output$select_type<-renderUI({
		selectInput("microbiome_type","Type of Microbiome Data", unique(as.character(mice$Type)))
	})

	set_lambda<-reactive({
		return(input$lbd)	
	})
	
	glmfit<-reactive({
		values$expr_sub<-prepare_inputs()$expr[mice$Type==input$microbiome_type,]

		cat(nrow(values$expr_sub),"\t",ncol(values$expr_sub),"\n")
		values$clin_sub<-prepare_inputs()$clin_data[mice$Type==input$microbiome_type,]

		values$cvar<-input$clinvar
		values$col<-grep(values$cvar,prepare_inputs()$mice_traits)

		myfit<-glmnet(values$expr_sub[!is.na(values$clin_sub[,values$col]),],values$clin_sub[!is.na(values$clin_sub[,values$col]),values$col])

		return(list("plot"=myfit,"coef"=coef(myfit,s=set_lambda())))
	
	})
	glmcvfit<-reactive({
		values$cvar<-input$clinvar
		values$col<-grep(values$cvar,prepare_inputs()$mice_traits)

		cvfit<-cv.glmnet(values$expr_sub[!is.na(values$clin_sub[,values$col]),],values$clin_sub[!is.na(values$clin_sub[,values$col]),values$col],nfolds=25)

		return(list("plot"=cvfit,"lmin"=cvfit$lambda.min,"coef"=coef(cvfit,s="lambda.min")))
	})
	
	#make plot of the coefficients, accross lambda
	output$fitplot<-renderPlot({
		plot(glmfit()$plot,xvar="lambda")

	})
	#make cross validation plot
	output$cvfitplot<-renderPlot({
		plot(glmcvfit()$plot)
	})
	
	#fit coefficient at specified lambda from input field
	output$fitcoef<-renderTable({
		fit_coef<-glmfit()$coef
		fit_df<-data.frame(fit_coef[fit_coef[,1]!=0,])
		return(fit_df)
	})
	output$fit_dl<-downloadHandler(
		filename=function(){
			paste0(Sys.Date(),input$clinvar,".",input$microbiome_type,"lambda",as.character(set_lambda()),".csv")
		},
		content=function(file){
			fit_coef<-glmfit()$coef
			fit_df<-data.frame(fit_coef[fit_coef[,1]!=0,])
			write.csv(fit_df,file)	
		}
		
	)

	#summary of the fit for all lambda
	output$fitsummary<-renderTable({
		fit_sum<-data.frame(print(glmfit()$plot))
		return(fit_sum)
	})
	output$fit_dl<-downloadHandler(
		filename=function(){
			paste0(Sys.Date(),input$clinvar,".",input$microbiome_type,"_fit_summary.csv")
		},
		content=function(file){
			fit_sum<-data.frame(print(glmfit()$plot))
			write.csv(fit_sum,file)	
		}
		
	)

	#lambda minimizing MSE from cross-validation
	output$lambdamin<-renderText({
		return(glmcvfit()$lmin)
	})
	
	#same as table 2, but with lambda.min
	output$cvfitcoef<-renderTable({
		cvfit_coef<-glmcvfit()$coef
		cvfit_df<-data.frame(cvfit_coef[cvfit_coef[,1]!=0,])
		return(cvfit_df)
	})
	output$cvfit_dl<-downloadHandler(
		filename=function(){
			paste0(Sys.Date(),input$clinvar,".",input$microbiome_type,".lambdamin.csv")
		},
		content=function(file){
			cvfit_coef<-glmcvfit()$coef
			cvfit_df<-data.frame(cvfit_coef[cvfit_coef[,1]!=0,])
			write.csv(cvfit_df,file)	
		}
		
	)
})
