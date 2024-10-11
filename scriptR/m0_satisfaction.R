# Load necessary libraries
library(dplyr)
library(ggplot2)
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
data <- read.csv("results_pse/results_pse_obj_biomassCapital.csv", header = T)


# Appliquer la fonction sur la colonne 'values'
data$om_MFETb <- sapply(data$om_MFETb, clean_and_average)
data$om_MSTb <- sapply(data$om_MSTb, clean_and_average)



# Define the ∆t value (you can set this as needed)
delta_t <- 0.8

# Classify states based on the given conditions
data <- data %>%
  mutate(
    state_b = case_when(
      om_MFETb <= 30 & om_MSTb >= delta_t ~ "Non-Satisfactory and Durable",  # MFET <= 1 et MST >= ∆t
      om_MFETb <= 30 & om_MSTb <= delta_t ~ "Satisfactory and Durable", #"Non-Satisfactory and Non-Durable",      # MFET <= 1 et MST <= ∆t
      om_MFETb >= 30 & om_MSTb >= delta_t ~ "Non-Satisfactory Transitional\n(Non-Durable)",#"Satisfactory and Durable",                          # MST >= ∆t
      om_MSTb < delta_t ~ "Satisfactory and Non-Durable"#"Satisfactory and Non-Durable"                        # MST < ∆t
    )
  )
data$state_b <- factor(data$state_b, levels = c("Satisfactory and Durable", "Satisfactory and Non-Durable", "Non-Satisfactory Transitional\n(Non-Durable)","Non-Satisfactory and Durable"))
# View the resulting classification
unique(data$state_b)

ggplot(data = data)+
  geom_point(aes(x = nbBoats, y = BiomassInit, colour = state_b),size = 5)+
  theme_light()+
  labs(title = "From biomass perspective", subtitle = "regarding the system",
       x = "Boat Number", y = "Initial Biomass", colour = "State")

ggsave("img/m0_pse_fatisfaction_mathias_biomass.png", width = 10, height = 8)


## Regarder PSE de manière plus habituelle

ggplot(data = data)+
  geom_point(aes(x = objective.om_MFETb, y = objective.om_MSTb, colour = nbBoats) )+
  theme_light()+
  labs(title = "From biomass perspective", subtitle = "regarding the system")


# Comment les points Satisfactory and Durable peuvent l'être ? 
# 1. ya peut de bateau 
# 
sel <- data$state_b == "Satisfactory and Durable"
sub.df <- data[sel,]


# Classify states based on the given conditions
data <- data %>%
  mutate(
    state_c = case_when(
      om_MFETc <= 1 & om_MSTc >= delta_t ~ "Non-Satisfactory and Non-Durable",  # MFET <= 1 et MST >= ∆t
      om_MFETc <= 1 & om_MSTc <= delta_t ~ "Non-Satisfactory and Durable",     # MFET <= 1 et MST <= ∆t
      om_MSTc >= delta_t ~ "Satisfactory and Durable",                               # MST >= ∆t
      om_MSTc < delta_t ~ "Satisfactory and Non-Durable"                            # MST < ∆t
    )
  )

# View the resulting classification
unique(data$state)

ggplot(data = data)+
  geom_point(aes(x = nbBoats, y = BiomassInit, colour = state_c))+
  theme_light()+
  labs(title = "From capital perspective", subtitle = "regarding the system")
