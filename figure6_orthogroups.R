library(ggplot2)
data<-read.table("haplotypes.txt", header=T)
ggplot(data, aes(x=genomes, y=orthogroups, fill=type)) + geom_bar(position="stack", stat="identity")
