library(ggplot2)
library(dplyr)
library(forcats)
data<-read.table("phenotype.txt", header=TRUE)
postscript("phenotype.eps", width=6, height=6, horizontal = FALSE,
           onefile = FALSE, paper = "special")
p <- data %>% mutate(Isolate = fct_relevel(Isolate, "ISR90-3", "China", "Neth202", "Ger5", "VA82", "WA92-74", "VA93-27", "17MN32B", "TX94-4", "15CA06C")) %>% mutate(Differential = fct_relevel(Differential, "Rph1.a", "Rph2.b", "Rph3.c", "Rph4.d", "Rph5.e", "Rph5.f", "Rph7.g", "Rph8.h", "Rph9.i", "Rph9.z", "Rph10.o", "Rph11.p", "Rph13.x", "Rph14.ab", "Rph15.ad")) %>% ggplot( aes(x=Differential, y=Isolate, fill=data$Phenotype)) + geom_tile() + scale_fill_gradient(low="white", high="red")
p
dev.off()
