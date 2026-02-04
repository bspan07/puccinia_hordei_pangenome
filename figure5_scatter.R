library(ggplot2)
data<-read.table("total_repeat_puccinia.txt", header=T)
ggplot(data, aes(x=total, y=repeats, color=data$species)) + geom_jitter(size=6)
