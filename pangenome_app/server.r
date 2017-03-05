library(shiny)
library(png)
library(rasterImage)
source("customdistance.r")

presence_table<-read.csv("data/374_clusters.csv",header=T,stringsAsFactors = FALSE)
presence_table[presence_table==" "]<-NA

values<-reactiveValues()
xv<-ncol(presence_table)
allstrains<-names(presence_table)[2:xv]

refstrains<-c("ATCC","AP200","BHN97",'R6','SPNA45','ST556',
              'TCH84331.19A','TIGR4','X19A','X19F','X670.6B',
              'X70585','CGSP14','D39','G54','gamPNI0373',
              'INV104','INV200','JJA','OXC141','P1031')

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  output$strains<-renderPrint(allstrains)
  
  
  #get the gene x-reference table for the selected strains
  prepare_subtable<-reactive({
    st<-cbind(presence_table[,c("Product",input$mychooser$right)])
    xc<-ncol(st)
    st<-st[rowSums(is.na(st))<xc-1,]
    pan<-nrow(st)
    core<-length(which(complete.cases(st)))	
    coret<-st[which(complete.cases(st)),]
    accessoryt=st[!complete.cases(st),]
    distance_matrix<-matrix(0,xc-1,xc-1)
    for (i in c(2:xc)){
      for (j in c(2:xc)){
        distance_matrix[i-1,j-1]<-get_distance(st,i,j)
      }
    }
    colnames(distance_matrix)<-names(st)[2:xc]
    return(list("subtable"=st,"coretable"=coret,"accessorytable"=accessoryt,"pansize"=pan,"coresize"=core,"distances"=distance_matrix))
    
  })
  
  #get uploaded strain selection
  observe({
    infile<- input$strainslist
    if (is.null(infile)){
      values$leftselection<-allstrains
      values$rightselection<-c()
      return(NULL)}
    else{
      strainslist<-input$strainslist
      strains<-readLines(strainslist$datapath)
      values$leftselection<-setdiff(allstrains,strains)
      values$rightselection<-strains
    }
  })
  
  output$make_selector<-renderUI(
    chooserInput("mychooser", "Available organisms", "Selected organisms",
                 values$leftselection, values$rightselection, size = 10, multiple = TRUE)
  )
  
  #get the table of unique genes for each strain for the selected strains
  prepare_uniques<-reactive({
    acctable<-prepare_subtable()$accessorytable
    numberNAs<-ncol(acctable)-2 #removing product, and one gene
    acctable<-acctable[rowSums(is.na(acctable)) == numberNAs, ]
    selectionnames=names(acctable)
    selectionnames<-selectionnames[selectionnames!="Product"]
    return(list("selectionnames"=selectionnames,"fulluniquetable"=acctable))
  })
  
  #get the unique genes for a single selected strain
  prepare_singleunique<-reactive({
    acctable<-prepare_uniques()$fulluniquetable
    unique_genes<-acctable[,c("Product",input$uniquestrain)]
    unique_genes<-unique_genes[complete.cases(unique_genes),]
    return(list("singleuniquetable"=unique_genes))
    
  })
  
  #selection of strains
  output$selectionnames<-renderText(input$mychooser$right)
  
  #output the full xref table
  output$selection <- renderDataTable(
    tryCatch(
      prepare_subtable()$subtable
      , error=function(e) message("No strains are selected."))
  )
  
  #output the core xref table
  output$selectionCore <- renderDataTable(
    tryCatch(
      prepare_subtable()$coretable
      , error=function(e) message("No strains are selected."))
  )
  
  #output the accessory xref table
  output$selectionAcc <- renderDataTable(
    tryCatch(
      prepare_subtable()$accessorytable
      , error=function(e) message("No strains are selected."))
  )
  
  #output the size of the core and pan genomes for the selection of strains
  output$coreandpan<-renderText(
    tryCatch(
      paste("Pangenome size:",as.character(prepare_subtable()$pansize),
            "\nCore Genome size:",as.character(prepare_subtable()$coresize))
      , error=function(e) return("No strains selected"))
  )
  
  #plot the dendrogram of selected strains based on gene distance
  make_dendrogram<-function(){
    tryCatch(
      plot(hclust(as.dist(prepare_subtable()$distances)),xlab="",sub="")
      , error=function(e) {
        message("At least three strains are needed for constructing a dendrogram")
        myimg<-readPNG("img/strep_dendro.png")
        transparent<-myimg[,,4]==0
        img<-as.raster(myimg[,,1:3])
        img[transparent]<-NA
        plot(1:2,type='n',xaxt='n', ann=FALSE, yaxt='n',bty='n')
        rasterImage(img, 1.1, 1.1, 1.7, 1.8, interpolate=FALSE)})
  }
  
  #display dendro as plot 
  output$distance_phylogeny<-renderPlot(
    make_dendrogram()
  )
  
  #download the full xref table
  output$subtable_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".genetable.csv")
    },
    content=function(file){
      write.csv(prepare_subtable()$subtable,file,row.names=FALSE)	
    })
  
  #download the core xref table
  output$subtableCore_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".core.genetable.csv")
    },
    content=function(file){
      write.csv(prepare_subtable()$coretable,file,row.names=FALSE)	
    })
  
  #download the accessory xref table
  output$subtableAcc_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".accessory.genetable.csv")
    },
    content=function(file){
      write.csv(prepare_subtable()$accessorytable,file,row.names=FALSE)	
    })
  
  #strain selector (dropdown UI) for the unique genes
  output$unique_selector<-renderUI(
    selectInput("uniquestrain","Make a selection to get genes unique to that strain",
                choices=prepare_uniques()$selectionnames)
  )
  
  #output the unique genes table
  output$unique_for_strain<-renderDataTable(
      prepare_singleunique()$singleuniquetable
  )
  
  #download the unique genes table
  output$subtableUniqu_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".unique.genetable.csv")
    },
    content=function(file){
      write.csv(prepare_singleunique()$singleuniquetable,file,row.names=FALSE)	
    })
  
  #download the dendro as png image
  output$dendrogram_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".dendrogram.png")
    },
    content=function(file){
      png(file)
      make_dendrogram()
      dev.off()
    }
  )
  
  #download list of selected strains
  output$current_selection<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".strains.txt")
    },
    content=function(file){
      write(prepare_uniques()$selectionnames,file)
    }
  )
  
  #upload txt file with strain selection
  
})