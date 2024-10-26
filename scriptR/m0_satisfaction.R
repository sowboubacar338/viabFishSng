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
data <- read.csv("results_BS/planComplet_mathias2.csv", header = T)


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

biomS <- ggplot(data = data)+
  geom_tile(aes(x = nbBoats, y = BiomassInit, fill = state_b))+
  theme_light()+
  labs(title = "From biomass perspective", subtitle = "regarding the system",
       x = "Boat Number", y = "Initial Biomass", fill = "State")
biomS
ggsave("img/m0_pse_fatisfaction_mathias_biomass.png", width = 10, height = 8)


# Comment les points Satisfactory and Durable peuvent l'être ? 
# 1. ya peut de bateau 
# 
sel <- data$state_b == "Satisfactory and Durable"
sub.df <- data[sel,]


# Classify states based on the given conditions
data <- data %>%
  mutate(
    state_c = case_when(
      om_MFETc <= 30 & om_MSTc >= delta_t ~ "Satisfactory and Durable",  # MFET <= 1 et MST >= ∆t
      om_MFETc <= 30 & om_MSTc <= delta_t ~ "Non-Satisfactory and Durable",     # MFET <= 1 et MST <= ∆t
      om_MSTc >= delta_t ~  "Satisfactory and Non-Durable",                               # MST >= ∆t
      om_MSTc < delta_t ~ "Non-Satisfactory Transitional\n(Non-Durable)"                            # MST < ∆t
    )
  )

data$state_c <- factor(data$state_c, levels = c("Satisfactory and Durable", "Satisfactory and Non-Durable", "Non-Satisfactory Transitional\n(Non-Durable)","Non-Satisfactory and Durable"))

# View the resulting classification
unique(data$state_c)

CapS <- ggplot(data = data)+
  geom_tile(aes(x = nbBoats, y = BiomassInit, fill = state_c))+
  theme_light()+
  labs(title = "From capital perspective", subtitle = "regarding the system",
       x = "Boat Number", y = "Initial Biomass", fill = "State")
CapS
compi <- grid.arrange(biomS, CapS)
ggsave("~/test.png", compi)


# Classify states based on the given conditions
data <- data %>%
  mutate(
    state_both = case_when(
      state_c == "Satisfactory and Durable" & state_b == "Satisfactory and Durable" ~ "Satisfactory and Durable",
      state_c != "Satisfactory and Durable" & state_b == "Satisfactory and Durable" ~ "Satisfactory and Non-Durable",
      state_c == "Satisfactory and Durable" & state_b != "Satisfactory and Durable" ~ "Satisfactory and Non-Durable",
      state_c == "Satisfactory and Non-Durable" & state_b == "Satisfactory and Non-Durable" ~ "Satisfactory and Non-Durable",
      state_c == "Non-Satisfactory and Durable" & state_b == "Non-Satisfactory and Durable" ~ "Non-Satisfactory and Durable",
      state_c == "Non-Satisfactory and Durable" & state_b == "Non-Satisfactory and Durable" ~ "Non-Satisfactory and Durable",
      state_c == "Non-Satisfactory Transitional\n(Non-Durable)" & state_b == "Non-Satisfactory Transitional\n(Non-Durable)" ~ "Non-Satisfactory Transitional\n(Non-Durable)",
      state_c != "Non-Satisfactory Transitional\n(Non-Durable)" & state_b == "Non-Satisfactory Transitional\n(Non-Durable)" ~ "Non-Satisfactory and Durable",
      state_c == "Non-Satisfactory Transitional\n(Non-Durable)" & state_b != "Non-Satisfactory Transitional\n(Non-Durable)" ~ "Non-Satisfactory and Durable",
      state_c == "Satisfactory and Durable" & state_b == "Non-Satisfactory and Durable" ~ "Non-Satisfactory and Durable", 
      state_c == "Satisfactory and Non-Durable" & state_b == "Non-Satisfactory and Durable" ~ "Non-Satisfactory and Durable"
    )
  )
data$state_both <- factor(data$state_both, levels = c("Satisfactory and Durable", "Satisfactory and Non-Durable", "Non-Satisfactory Transitional\n(Non-Durable)","Non-Satisfactory and Durable"))


ggplot(data = data)+
  geom_tile(aes(x = nbBoats, y = BiomassInit, fill = state_both))+
  theme_light()+
  labs(title = "From both perspective", subtitle = "regarding the system",
       x = "Boat Number", y = "Initial Biomass", fill = "State")
