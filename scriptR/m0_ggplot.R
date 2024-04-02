# Chargement des bibliothèques nécessaires pour le traitement des données et la visualisation
library(data.table)  # Pour la manipulation efficace des données
library(reshape2)    # Pour remodeler les données, si nécessaire (non utilisé dans cet exemple)
library(ggplot2)     # Pour la création de graphiques
library(dplyr)       # Pour la manipulation des données avec des fonctions comme arrange(), mutate(), etc.

# Définition du répertoire de travail où se trouve le fichier de données
setwd("Téléchargements/")

# Chargement des données à partir d'un fichier CSV, en ignorant les 6 premières lignes
data.df <- fread("m0_01022024.cvs", sep = ",", skip = 6)

# Création de nouvelles colonnes 'run' et 'step' pour simplifier l'accès aux colonnes correspondantes
data.df$run <- data.df$`[run number]`
data.df$step <- data.df$`[step]`

# Filtrage des données pour ne conserver que les dernières valeurs de chaque simulation
# Cela est réalisé en sélectionnant les lignes où 'step' est égal à sa valeur maximale dans le jeu de données
end.simu <- data.df[data.df$step == max(data.df$step),]

# Visualisation des noms des colonnes de 'end.simu' pour vérification
names(end.simu)

# Sélection de certaines colonnes d'intérêt et stockage dans 'sub.end.simu'
sub.end.simu <- subset(data.df, select = c(run, step, LongueurFilet, LongueurFiletEtrangers,
                                           SortieSemaine, ZonesExclusionPeche,
                                           PrixPoisson, ReserveIntegrale, sumBiomass,
                                           capital_moyen_1, capital_moyen_2))

# Calcul de la colonne 'capitalTotal' comme somme de 'capital_moyen_1' et 'capital_moyen_2'
sub.end.simu$capitalTotal <- sub.end.simu$capital_moyen_1 + sub.end.simu$capital_moyen_2


# Définition d'un sous-ensemble de données selon certains critères pour l'analyse de l'effet de la zone d'exclusion de pêche
sel <- sub.end.simu$LongueurFilet == 3000 & 
  sub.end.simu$LongueurFiletEtrangers == 3000 &
  sub.end.simu$SortieSemaine == 6 & 
  sub.end.simu$ZonesExclusionPeche == FALSE &
  sub.end.simu$PrixPoisson == 1500  
# sub.end.simu$ReserveIntegrale == 0  # Cette ligne est commentée et donc non exécutée

# Tri des données par 'step', groupement par 'ReserveIntegrale', et calcul de la somme cumulée de 'capitalTotal' dans chaque groupe
sub.end.simu <- sub.end.simu[sel,] %>%
  arrange(step) %>%
  group_by(ReserveIntegrale) %>%
  mutate(cumSumCapital = cumsum(capitalTotal))

# Création d'un graphique de la biomasse en fonction du temps pour les données filtrées
ggplot(sub.end.simu) +
  geom_path(aes(x=step, y = sumBiomass, color = as.factor(ReserveIntegrale))) +
  scale_colour_brewer(palette="Dark2") +
  labs(colour ="Reserve\n(mois)", x = "temps", y = "biomasse") +
  theme_bw()
# Sauvegarde du graphique dans un fichier image
ggsave("m0_biomass_reserve_int.png")

# Création d'un second graphique montrant la somme cumulée du capital en fonction du temps
ggplot(sub.end.simu) +
  geom_path(aes(x=step, y = cumSumCapital, color = as.factor(ReserveIntegrale))) +
  scale_colour_brewer(palette="Dark2") +
  labs(colour ="Reserve\n(mois)", x = "temps", y = "somme cumulée du captial") +
  theme_bw()
# Sauvegarde du second graphique dans un fichier image
ggsave("m0_capCum_reserve_int.png")

# Sauvegarde du sous-ensemble de données dans un fichier RDS pour une utilisation ultérieure
saveRDS(sub.end.simu, file = "my_data.rds")


### Analyse petite réserve #################################################################

# Sélection de certaines colonnes d'intérêt et stockage dans 'sub.end.simu'
sub.end.simu <- subset(data.df, select = c(run, step, LongueurFilet, LongueurFiletEtrangers,
                                           SortieSemaine, ZonesExclusionPeche,
                                           PrixPoisson, ReserveIntegrale, sumBiomass,
                                           capital_moyen_1, capital_moyen_2))

# Calcul de la colonne 'capitalTotal' comme somme de 'capital_moyen_1' et 'capital_moyen_2'
sub.end.simu$capitalTotal <- sub.end.simu$capital_moyen_1 + sub.end.simu$capital_moyen_2

# Définition d'un sous-ensemble de données selon certains critères pour l'analyse de l'effet de la zone d'exclusion de pêche
sel <- sub.end.simu$LongueurFilet == 3000 & 
  sub.end.simu$LongueurFiletEtrangers == 3000 &
  sub.end.simu$SortieSemaine == 6 & 
  # sub.end.simu$ZonesExclusionPeche == TRUE &
  sub.end.simu$PrixPoisson == 1500 &
  sub.end.simu$ReserveIntegrale == 0
  
# Tri des données par 'step', groupement par 'ReserveIntegrale', et calcul de la somme cumulée de 'capitalTotal' dans chaque groupe
sub.end.simu <- sub.end.simu[sel,] %>%
    arrange(step) %>%
    group_by(ZonesExclusionPeche) %>%
    mutate(cumSumCapitalSmRes = cumsum(capitalTotal))

ggplot(sub.end.simu) +
  geom_path(aes(x=step, y = sumBiomass, color = as.factor(ZonesExclusionPeche))) +
  scale_colour_brewer(palette="Dark2") +
  labs(colour ="Réserves\ncommunautaire", x = "temps", y = "biomasse") +
  theme_bw()
# Sauvegarde du graphique dans un fichier image
ggsave("m0_biomass_reserve_commu.png")

# Création d'un second graphique montrant la somme cumulée du capital en fonction du temps
ggplot(sub.end.simu) +
  geom_path(aes(x=step, y = cumSumCapitalSmRes, color = as.factor(ZonesExclusionPeche))) +
  scale_colour_brewer(palette="Dark2") +
  labs(colour ="Réserves\ncommunautaire", x = "temps", y = "somme cumulée du captial") +
  theme_bw()

# Sauvegarde du second graphique dans un fichier image
ggsave("m0_capCum_reserve_commu.png")

### Analyse longueur filet #################################################################

# Sélection de certaines colonnes d'intérêt et stockage dans 'sub.end.simu'
sub.end.simu <- subset(data.df, select = c(run, step, LongueurFilet, LongueurFiletEtrangers,
                                           SortieSemaine, ZonesExclusionPeche,
                                           PrixPoisson, ReserveIntegrale, sumBiomass,
                                           capital_moyen_1, capital_moyen_2))

# Calcul de la colonne 'capitalTotal' comme somme de 'capital_moyen_1' et 'capital_moyen_2'
sub.end.simu$capitalTotal <- sub.end.simu$capital_moyen_1 + sub.end.simu$capital_moyen_2

# Définition d'un sous-ensemble de données selon certains critères pour l'analyse de l'effet de la zone d'exclusion de pêche
sel <- #sub.end.simu$LongueurFilet == 3000 & 
  #sub.end.simu$LongueurFiletEtrangers == 3000 &
  sub.end.simu$SortieSemaine == 6 & 
  sub.end.simu$ZonesExclusionPeche == TRUE &
  sub.end.simu$PrixPoisson == 1500 &
  sub.end.simu$ReserveIntegrale == 0

# Tri des données par 'step', groupement par 'ReserveIntegrale', et calcul de la somme cumulée de 'capitalTotal' dans chaque groupe
sub.end.simu <- sub.end.simu[sel,] %>%
  arrange(step) %>%
  group_by(LongueurFilet,LongueurFiletEtrangers) %>%
  mutate(cumSumCapitalSmRes = cumsum(capitalTotal))

ggplot(sub.end.simu) +
  geom_path(aes(x=step, y = sumBiomass, color = as.factor(LongueurFilet))) +
  scale_colour_brewer(palette="Dark2") +
  labs(colour ="Longueur\nde filet", x = "temps", y = "biomasse") +
  theme_bw()
# Sauvegarde du graphique dans un fichier image
ggsave("m0_biomass_longFilet.png")

# Création d'un second graphique montrant la somme cumulée du capital en fonction du temps
ggplot(sub.end.simu) +
  geom_path(aes(x=step, y = cumSumCapitalSmRes, color = as.factor(LongueurFilet))) +
  scale_colour_brewer(palette="Dark2") +
  labs(colour ="Longueur\nde filet", x = "temps", y = "somme cumulée du captial") +
  theme_bw()

# Sauvegarde du second graphique dans un fichier image
ggsave("m0_capCum_longFilet.png")


### Nombre de sorties par semaines ##################################################################


# Sélection de certaines colonnes d'intérêt et stockage dans 'sub.end.simu'
sub.end.simu <- subset(data.df, select = c(run, step, LongueurFilet, LongueurFiletEtrangers,
                                           SortieSemaine, ZonesExclusionPeche,
                                           PrixPoisson, ReserveIntegrale, sumBiomass,
                                           capital_moyen_1, capital_moyen_2))

# Calcul de la colonne 'capitalTotal' comme somme de 'capital_moyen_1' et 'capital_moyen_2'
sub.end.simu$capitalTotal <- sub.end.simu$capital_moyen_1 + sub.end.simu$capital_moyen_2

# Définition d'un sous-ensemble de données selon certains critères pour l'analyse de l'effet de la zone d'exclusion de pêche
sel <- sub.end.simu$LongueurFilet == 3000 & 
  sub.end.simu$LongueurFiletEtrangers == 3000 &
  #sub.end.simu$SortieSemaine == 6 & 
  sub.end.simu$ZonesExclusionPeche == FALSE &
  sub.end.simu$PrixPoisson == 1500 &
  sub.end.simu$ReserveIntegrale == 0

# Tri des données par 'step', groupement par 'ReserveIntegrale', et calcul de la somme cumulée de 'capitalTotal' dans chaque groupe
sub.end.simu <- sub.end.simu[sel,] %>%
  arrange(step) %>%
  group_by(SortieSemaine) %>%
  mutate(cumSumCapitalSmRes = cumsum(capitalTotal))

ggplot(sub.end.simu) +
  geom_path(aes(x=step, y = sumBiomass, color = as.factor(SortieSemaine))) +
  scale_colour_brewer(palette="Dark2") +
  labs(colour ="Nombres de\nsorties par semaine", x = "temps", y = "biomasse") +
  theme_bw()
# Sauvegarde du graphique dans un fichier image
ggsave("m0_biomass_nbSorties.png")

# Création d'un second graphique montrant la somme cumulée du capital en fonction du temps
ggplot(sub.end.simu) +
  geom_path(aes(x=step, y = cumSumCapitalSmRes, color = as.factor(SortieSemaine))) +
  scale_colour_brewer(palette="Dark2") +
  labs(colour ="Nombres de\nsorties par semaine", x = "temps", y = "somme cumulée du captial") +
  theme_bw()

# Sauvegarde du second graphique dans un fichier image
ggsave("m0_capCum_nbSorties.png")
