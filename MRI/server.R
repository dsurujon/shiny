library(shiny)

#some global variables
values<-reactiveValues(data_submitted=FALSE,labels_submitted=FALSE,pvals=NULL,mriraw1=NULL,mrilables=NULL)

shinyServer(function(input, output) {	

	##make sure the file uploads are reactive.
	observe({
		input$MRI_data_file
		if(is.null(input$MRI_data_file)){return()}
		
		isolate({
			print("Data file submitted")
			values$data_submitted=TRUE
			values$mriraw1 <- read.delim(input$MRI_data_file$datapath, header=T, sep=input$sep, na.string="NA") 
		})
	})
	observe({
		input$MRI_labels
		if(is.null(input$MRI_labels)){return()}
		
		isolate({
			print("Labels file submitted")
			values$labels_submitted=TRUE
			values$mrilabels<-read.delim(input$MRI_labels$datapath,header=T, sep="\t")
		})
	})

	##Generate the significance summary of the data
	output$MRIdata <- renderTable({
		#Don't compute anything unless both files have been submitted
		if ((values$data_submitted==FALSE)||(values$labels_submitted==FALSE)){return(NULL)}
		
		#clean the data --by QWY
		mripar <- c("Label", "Fat", "Lean", "Weight")
		mriraw2 <- values$mriraw1[mripar]
		averaged <- aggregate(mriraw2[c("Fat", "Lean", "Weight")], list(id=mriraw2$Label), mean)
		mri <- within(averaged, {Fbw <- Fat/Weight*100})
		mat2 <- merge(mri, values$mrilabels, by="id")
		mat2 <- mat2[c("id", "gp", "Fat", "Lean", "Weight", "Fbw")]
		groups<-list(gp=mat2$gp)
		mri.values <- aggregate(mat2[c("Fat", "Lean", "Weight", "Fbw")],groups,mean, simplify=TRUE)
		rownames(mri.values)<-mri.values[,1]
		mri.values <- mri.values[,2:ncol(mri.values)]
		mri.values <- as.matrix(mri.values)
		values$mri.value<-mri.values
		
		#compute SEM
		stderr <- function(x) sqrt(var(x)/length(x))
		mri.errbar <- aggregate(mat2[c("Fat", "Lean", "Weight", "Fbw")],list(gp=mat2$gp),stderr, simplify=TRUE)
		rownames(mri.errbar) <- mri.errbar[,1]
		mri.errbar[,1] <- NULL
		mri.errbar <- as.matrix(mri.errbar)
		values$mri.errbar<-mri.errbar
		
		#compute t-test p values through anova (in case there are >2 cohorts) and then Tukey's post-hoc test
		pvalues<-function(x){
			tuk<-TukeyHSD(aov(mat2[x][,1]~mat2["gp"][,1]))
			return (tuk[[1]][,4])
		} 
		
		#clean and display the p-values
		pvals<-sapply(c("Fat","Lean","Weight","Fbw"),pvalues)
		pval_results<-as.data.frame(pvals)
		pval_results
		
	})

	##Generate a bar plot with standard error. Groups are stacked.
	output$MRIbar<-renderPlot({
		if (is.null(input$MRI_data_file)||is.null(input$MRI_labels)){return(NULL)}
		par(cex=1, lwd=2.8)
		#add an error bar function --QWY
		error.bar <- function(x, y, upper, lower=upper, length=0.1,...){
			if(length(x) != length(y) | length(y) !=length(lower) | length(lower) != length(upper))
			stop("vectors must be same length")
			arrows(x,y+upper, x, y-lower, angle=90, code=3, length=length, ...)
		}
		barxylim <- 45
		#plot the data --QWY
		barx <- barplot(height=values$mri.value, main=input$fig1_label, ylab="Mass (gram) or Percentage", beside=TRUE, ylim=c(0,barxylim), border=NA, axes=F, legend.text=T) 
		error.bar(barx,values$mri.value,values$mri.errbar)
		axis(2, lwd = 2, lwd.ticks = 2)
	
	})
	
	
})
