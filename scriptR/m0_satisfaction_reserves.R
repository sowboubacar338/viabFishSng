# Load necessary libraries
library(dplyr)
library(ggplot2)
library(gridExtra)
rm(list = ls())
setwd("~/github/viabFishSng/")

# Fonction pour nettoyer les valeurs et calculer la moyenne
clean_and_average <- function(value) {
  # Retirer les crochets et les espaces supplémentaires
  clean_value <- gsub("\\[|\\]", "", value)
  
  # Séparer les valeurs par virgule et les convertir en numérique
  numeric_values <- as.numeric(unlist(strsplit(clean_value, ",")))
  
  # Calculer la moyenne des valeurs
  return(mean(numeric_values))
}



# Load the dataset (replace with your file path)
# execustion time 1320h - duration 9h15
data <- read.csv("results_BS/planComplet_mathias3.csv", header = T)


# Appliquer la fonction sur la colonne 'values'
data$om_MFETb <- sapply(data$om_MFETb, clean_and_average)
data$om_MSTb <- sapply(data$om_MSTb, clean_and_average)



# Define the ∆t value (you can set this as needed)
delta_t <- 0.8 # seuil de durabilité
satisfactionb <- 150000
delta_r <- 0.6 # seuil de résiliance


#####################
# Classify states based on the given conditions
data <- data %>%
  mutate(
    state_b = case_when(
      BiomassInit >= satisfactionb & om_MSTb < delta_t & om_MSTb > delta_r ~ "Resilient Satisfactory and Non-Durable",
      BiomassInit >= satisfactionb & om_MSTb <= delta_t ~ "Satisfactory and Durable",
      BiomassInit >= satisfactionb & om_MSTb > delta_t ~ "Satisfactory and Non-Durable",
      
      BiomassInit < satisfactionb & om_MSTb <= delta_t & om_MSTb > delta_r ~ "Resilient Satisfactory and Durable",
      
      BiomassInit < satisfactionb & om_MSTb <= delta_t ~ "Non-Satisfactory and Non-Durable",
      BiomassInit < satisfactionb & om_MSTb > delta_t ~ "Non-Satisfactory and Durable",
      
    )
  )


##########


data$state_b <- factor(data$state_b, levels = c("Satisfactory and Durable", "Satisfactory and Non-Durable",
                                                "Non-Satisfactory and Non-Durable","Non-Satisfactory and Durable",
                                                "Resilient Satisfactory and Non-Durable", "Resilient Satisfactory and Durable"))
# View the resulting classification
# unique(data$state_b)


biomS <- ggplot(data = data)+
  geom_tile(aes(x = nbBoats, y = BiomassInit, fill = state_b))+
  scale_fill_manual(values = c('#4575b4','#91bfdb','#fee090','#d73027','#e0f3f8','#fc8d59'))+
  theme_light()+
  facet_grid(~ReserveIntegrale)+
  labs(title = "From biomass perspective", subtitle = "regarding the system",
       x = "Boat Number", y = "Initial Biomass", fill = "State")
biomS
ggsave("img/m0_pse_fatisfaction_mathias_biomass.png", width = 10, height = 8)

