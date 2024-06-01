library(tidyverse)

rm(list = ls())
setwd("~/github/viabFishSng/")
data <- read.csv("results_BS/modelv0_experiment_mathias_31052024.csv", skip = 6, header = T)

# identifier les simu qui commence au dessu de la satisfaction pour biomass
# et capital. On les spécifie comme satisfaisant

## Classer satisfait et non-satisfait
## satisfait MFET = 0 ET MST = 3650 --> Jamais sorti
sel <- data$MFETb == 0 & data$MSTb == 0
data <- data %>%
  mutate(satisfaction = factor(ifelse(sel, "satisfaisant", "non-satisfaisant"),
                             levels = c("satisfaisant", "non-satisfaisant")))

## classer sur la durabilite
## il faut définir un seuil d
d <- 0.90
## si MST > d alors la simu est durable
## Sinon elle est non durable

sel <- data$MSTb > d
data <- data %>%
  mutate(durabilite = factor(ifelse(sel, "durable", "non-durable"),
                               levels = c("durable", "non-durable")))
 

library(dplyr)
library(ggplot2)

# Ajouter une nouvelle colonne qui combine les niveaux
data <- data %>%
  mutate(combined = interaction(satisfaction, durabilite))


# Définir un vecteur de couleurs
colors <- c(#"satisfaisant.durable" = "#7fc97f",
            "non-satisfaisant.durable" = "#beaed4",
            "satisfaisant.non-durable" = "#fdc086",
            "non-satisfaisant.non-durable" = "#ffff99")  # Couleur ajoutée pour la dernière combinaison


# Créer le graphique
ggplot(data, aes(x = nbBoats, y = BiomassInit, color = combined)) +
  geom_point(size = 3) +
  scale_color_manual(values = colors) +
  theme_bw() +
  facet_grid(ReserveIntegrale~capital_totalI,labeller = label_both)+
  labs(color = "Combinaison", 
       #title = "Graphique de Combinaison des Facteurs", 
       x = "nb bateau", y = "biomassInit")


ggsave("img/m0_fatisfaction_mathias.png", height = 10, width = 14)
