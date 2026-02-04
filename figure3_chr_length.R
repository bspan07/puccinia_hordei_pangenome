library(ggplot2)
data<-read.table("chr_lengths_plot.txt", header=T)
ggplot(data, aes(group=Chromosome,x=Chromosome, y=Length)) + geom_violin() + geom_jitter(height=0, width=0.1, size=2) + theme_bw()
