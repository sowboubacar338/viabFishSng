library(tidyverse)

rm(list = ls())
setwd("~/github/viabFishSng/")
data <- read.csv("results_BS/modelv0_experiment_mathias_27082024.csv", skip = 6, header = T)

small.df <- subset(data, X.step. == 3650)

result <- small.df %>%
  group_by(nbBoats, capital_totalI, ReserveIntegrale, BiomassInit) %>%
  summarise(
    MFETc = mean(MFETc, na.rm = TRUE),  # Mean First Exit Time capital de la zone init
    MFETb = mean(MFETb, na.rm = TRUE),  # Mean First Exit Time biomass
    MSTc  = mean(MSTc, na.rm = TRUE),   # Mean Satisfaction Time capital (le temps moyen de la simu passer dans la zone de satisfaction)
    MSTb  = mean(MSTb, na.rm = TRUE),   # Mean Satisfaction Time biomass (le temps moyen de la simu passer dans la zone de satisfaction)
    .groups = "drop"
  )

## Biomass ####

# identifier les simu qui commence au dessu de la satisfaction pour biomass
# et capital. On les spécifie comme satisfaisant

## Classer satisfait et non-satisfait
## satisfait MFET = 0 ET MST = 0 --> Jamais sorti
sel <-result$MSTb == 0
result <- result %>%
  mutate(satisfaction = factor(ifelse(sel, "satisfaisant", "non-satisfaisant"),
                             levels = c("satisfaisant", "non-satisfaisant")))

## classer sur la durabilite
## il faut définir un seuil d
d <- 0.50
## si MST > d alors la simu est durable
## Sinon elle est non durable

sel <- result$MSTb > d
result <- result %>%
  mutate(durabilite = factor(ifelse(sel, "durable", "non-durable"),
                               levels = c("durable", "non-durable")))
 
# Ajouter une nouvelle colonne qui combine les niveaux
result <- result %>%
  mutate(combined = paste(satisfaction, "-",durabilite))


# Définir un vecteur de couleurs
colors <- c("satisfaisant - durable" = "#008000",
            "non-satisfaisant - durable" = "#FF0000",
            "satisfaisant - non-durable" = "#90EE90",
            "non-satisfaisant - non-durable" = "#FFC0CB")  # Couleur ajoutée pour la dernière combinaison


# Créer le graphique
ggplot(result, aes(x = nbBoats, y = BiomassInit, fill = combined)) +
  geom_tile() +
  scale_fill_manual(values = colors) +
  theme(
    plot.title = element_text(size = 20, face = "bold"),    # Taille du titre
    axis.title.x = element_text(size = 16),                 # Taille du titre de l'axe X
    axis.title.y = element_text(size = 16),                 # Taille du titre de l'axe Y
    axis.text.x = element_text(size = 14),                  # Taille des textes de l'axe X
    axis.text.y = element_text(size = 14),                  # Taille des textes de l'axe Y
    legend.title = element_text(size = 14),                 # Taille du titre de la légende
    legend.text = element_text(size = 12)                   # Taille des textes de la légende
  )+
  #facet_grid(ReserveIntegrale~capital_totalI,labeller = label_both)+
  labs(color = "Combinaison", 
       title = "Satisfaction sur la biomass", 
       x = "Nb Bateau", y = "Biomasse Initial", fill = "") 


ggsave("img/m0_fatisfaction_mathias_biomass.png", height = 10, width = 14)





### Sur le capital ####

## Classer satisfait et non-satisfait
## satisfait MFET = 0 ET MST = 0 --> Jamais sorti
sel <- result$MFETc == 0 & result$MSTc == 0
result <- result %>%
  mutate(satisfaction = factor(ifelse(sel, "satisfaisant", "non-satisfaisant"),
                               levels = c("satisfaisant", "non-satisfaisant")))

## classer sur la durabilite
## il faut définir un seuil d
d <- 0.80
## si MST > d alors la simu est durable
## Sinon elle est non durable

sel <- result$MSTc > d
result <- result %>%
  mutate(durabilite = factor(ifelse(sel, "durable", "non-durable"),
                             levels = c("durable", "non-durable")))

# Ajouter une nouvelle colonne qui combine les niveaux
result <- result %>%
  mutate(combined = paste(satisfaction, "-",durabilite))



# Créer le graphique
ggplot(result, aes(x = nbBoats, y = BiomassInit, fill = combined)) +
  geom_tile() +
  scale_fill_manual(values = colors) +
  theme(
    plot.title = element_text(size = 20, face = "bold"),    # Taille du titre
    axis.title.x = element_text(size = 16),                 # Taille du titre de l'axe X
    axis.title.y = element_text(size = 16),                 # Taille du titre de l'axe Y
    axis.text.x = element_text(size = 14),                  # Taille des textes de l'axe X
    axis.text.y = element_text(size = 14),                  # Taille des textes de l'axe Y
    legend.title = element_text(size = 14),                 # Taille du titre de la légende
    legend.text = element_text(size = 12)                   # Taille des textes de la légende
  )+
  # facet_grid(ReserveIntegrale~capital_totalI,labeller = label_both)+
  labs(color = "Combinaison", 
       title = "Satisfaction sur le capital", 
       x = "Nb Bateau", y = "Biomasse Initial", fill = "")


ggsave("img/m0_fatisfaction_mathias_capital.png", height = 10, width = 14)
