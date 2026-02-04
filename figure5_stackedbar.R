library(ggplot2)
data<-read.table("repeat_puccinia.txt", header=T)
data$repeat_type <- factor(data$repeat_type, levels=c("DNAtransposons", "Gypsy/DIRS1", "Ty1/Copia", "LINEs", "othernon-LTR-retroelement", "Lowcomplexity", "Rolling-circles", "Simplerepeats", "Unclassified", "non_repetitive"))
p<-ggplot(data, aes(fill=repeat_type, y=coverage, x=genome)) + geom_bar(position="stack", stat="identity") + scale_fill_manual(values=c("#FC4646", "#FFFF66", "#98C127", "#C8E19B", "#5F94FD", "#00B2D6", "#8FD7D7", "#FFA3B5", "#B1B1B3", "#000000")) + theme_bw()
