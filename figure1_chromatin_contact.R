library(ggplot2)
library(dplyr)
data<-read.table("chromatin_contact.txt", header=TRUE)

summary_df <- data %>%
  group_by(chromosome, nucleus) %>%
  summarise(
    mean_contact = mean(contact),
    sd_contact   = sd(contact),
    se_contact   = sd(contact) / sqrt(n())
  )
ggplot(summary_df,
       aes(x = chromosome,
           y = mean_contact,
           fill = nucleus)) +
  geom_bar(position = position_dodge(width = 0.9),
           stat = "identity") +
  geom_errorbar(aes(
    ymin = mean_contact - se_contact,
    ymax = mean_contact + se_contact
  ),
  position = position_dodge(width = 0.9),
  width = 0.2
  ) +
  labs(x = "Chromosome",
       y = "Contact (%)",
       fill = "Nucleus") +
  theme_classic()
