get_distance<-function(pangenome,x,y){
	pgsub<-pangenome[,c(x,y)]
	shared<-length(which(complete.cases(pgsub)))
	neither<-nrow(pgsub[rowSums(is.na(pgsub))==2,])
	distance<-nrow(pangenome)-shared-neither
	return(distance)
}