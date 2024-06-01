library(tidyverse)

rm(list = ls())
setwd("~/github/viabFishSng/")
data <- read.csv("results_BS/modelv0_experiment_mathias_31052024.csv", skip = 6, header = T)


result <- data %>%
  group_by(nbBoats, capital_totalI, ReserveIntegrale, BiomassInit) %>%
  summarise(
    MFETc = mean(MFETc, na.rm = TRUE),  # Calcul de la moyenne de MFET, en excluant les NA
    MFETb = mean(MFETb, na.rm = TRUE),
    MSTc  = mean(MSTc, na.rm = TRUE),
    MSTb  = mean(MSTb, na.rm = TRUE),
    .groups = "drop"
  )


# identifier les simu qui commence au dessu de la satisfaction pour biomass
# et capital. On les spécifie comme satisfaisant

## Classer satisfait et non-satisfait
## satisfait MFET = 0 ET MST = 0 --> Jamais sorti
sel <- result$MFETb == 0 & result$MSTb == 0
result <- result %>%
  mutate(satisfaction = factor(ifelse(sel, "satisfaisant", "non-satisfaisant"),
                             levels = c("satisfaisant", "non-satisfaisant")))

## classer sur la durabilite
## il faut définir un seuil d
d <- 0.90
## si MST > d alors la simu est durable
## Sinon elle est non durable

sel <- result$MSTb > d
result <- result %>%
  mutate(durabilite = factor(ifelse(sel, "durable", "non-durable"),
                               levels = c("durable", "non-durable")))
 
# Ajouter une nouvelle colonne qui combine les niveaux
data <- data %>%
  mutate(combined = interaction(satisfaction, durabilite))


# Définir un vecteur de couleurs
colors <- c(#"satisfaisant.durable" = "#7fc97f",
            "non-satisfaisant.durable" = "#beaed4",
            "satisfaisant.non-durable" = "#fdc086",
            "non-satisfaisant.non-durable" = "#ffff99")  # Couleur ajoutée pour la dernière combinaison


# Créer le graphique
ggplot(data, aes(x = nbBoats, y = BiomassInit, fill = combined)) +
  geom_tile() +
  scale_fill_manual(values = colors) +
  theme_bw() +
  facet_grid(ReserveIntegrale~capital_totalI,labeller = label_both)+
  labs(color = "Combinaison", 
       title = "Satisfaction sur le biomass", 
       x = "nb bateau", y = "biomassInit")


ggsave("img/m0_fatisfaction_mathias.png", height = 10, width = 14)
