#'
#' #Read in biom file and return relative abundance
read.biom<-function(biom="biom",new=T,metagenome=F){
  if(new & !metagenome){biom <- read.table(biom,header=T,sep="\t",comment.char="",skip=1)}
  if(new && metagenome){biom <- read.table(biom,header=T,sep="\t",comment.char="",skip=1,quote="")}
  #taxonomy and OTU information
  if(!metagenome){
    taxon=biom$ConsensusLineage
    taxon=do.call("rbind",strsplit(as.character(taxon),';'))
    taxon=data.frame(apply(taxon,2,as.character))
    names(taxon)=c("Kingdom","Phylum","Class","Order","Family","Genus","Species")
    otus=biom[,1]
    taxon=cbind(otus,taxon)
  }

  #remove taxonomy column
  rownames(biom) <- biom[,1]
  biom=biom[,-(c(1,ncol(biom)))]

  #remove singletons and OTU's with no counts
  biom[biom==1]<-0
  if(!metagenome){taxon=taxon[-(which(rowSums(biom)==0)),]}
  biom.trim=biom[-(which(rowSums(biom)==0)),]

  #create general tab-delimited file with taxonomy attached
  if(!metagenome){biom_tab=cbind.data.frame(biom.trim,taxon[,-1])}


  #Convert to relative abundance
  col.sums=apply(biom.trim,2,sum)
  per.trial=sweep(biom.trim,2,col.sums,"/")
  per.trial=as.data.frame(t(per.trial)*100)
  
  if(!metagenome){return(list("RA.Otus"=per.trial,"taxon"=taxon,"biom_tab"=biom_tab))}
  if(metagenome){return(list("RA.genes"=per.trial))}
}
