library(shiny)
library(png)
library(rasterImage)
source("customdistance.r")

presence_table<-read.csv("data/374_clusters.csv",header=T,stringsAsFactors = FALSE)
presence_table[presence_table==" "]<-NA
#product<-presence_table$Product
#presence_table$Product<-NULL
#presence_table<-presence_table[ , order(namrunes(presence_table))]
#presence_table<-cbind(product,presence_table)
values<-reactiveValues()
xv<-ncol(presence_table)
allstrains<-names(presence_table)[2:xv]

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  output$strains<-renderPrint(allstrains)
  
  
  
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
  
  prepare_uniques<-reactive({
    acctable<-prepare_subtable()$accessorytable
    numberNAs<-ncol(acctable)-2 #removing product, and one gene
    acctable<-acctable[rowSums(is.na(acctable)) == numberNAs, ]
    selectionnames=names(acctable)
    selectionnames<-selectionnames[selectionnames!="Product"]
    return(list("selectionnames"=selectionnames,"fulluniquetable"=acctable))
  })
  
  prepare_singleunique<-reactive({
    acctable<-prepare_uniques()$fulluniquetable
    unique_genes<-acctable[,c("Product",input$uniquestrain)]
    unique_genes<-unique_genes[complete.cases(unique_genes),]
    return(list("singleuniquetable"=unique_genes))
    
  })
  output$selectionnames<-renderText(input$mychooser$right)
  
  output$selection <- renderDataTable(
    tryCatch(
      prepare_subtable()$subtable
      , error=function(e) message("No strains are selected."))
  )
  
  output$selectionCore <- renderDataTable(
    tryCatch(
      prepare_subtable()$coretable
      , error=function(e) message("No strains are selected."))
  )
  output$selectionAcc <- renderDataTable(
    tryCatch(
      prepare_subtable()$accessorytable
      , error=function(e) message("No strains are selected."))
  )
  
  output$coreandpan<-renderText(
    tryCatch(
      paste("Pangenome size:",as.character(prepare_subtable()$pansize),
            "\nCore Genome size:",as.character(prepare_subtable()$coresize))
      , error=function(e) return("No strains selected"))
  )
  
  output$distance_phylogeny<-renderPlot(
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
  )
  
  output$subtable_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".genetable.csv")
    },
    content=function(file){
      write.csv(prepare_subtable()$subtable,file,row.names=FALSE)	
    })
  
  output$subtableCore_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".core.genetable.csv")
    },
    content=function(file){
      write.csv(prepare_subtable()$coretable,file,row.names=FALSE)	
    })
  
  output$subtableAcc_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".accessory.genetable.csv")
    },
    content=function(file){
      write.csv(prepare_subtable()$accessorytable,file,row.names=FALSE)	
    })
  
  output$unique_selector<-renderUI(
    selectInput("uniquestrain","Make a selection to get genes unique to that strain",
                choices=prepare_uniques()$selectionnames)
  )
  output$unique_for_strain<-renderDataTable(
      prepare_singleunique()$singleuniquetable
  )
  
  output$subtableUniqu_dl<-downloadHandler(
    filename=function(){
      paste0(Sys.Date(),".unique.genetable.csv")
    },
    content=function(file){
      write.csv(prepare_singleunique()$singleuniquetable,file,row.names=FALSE)	
    })
  
})