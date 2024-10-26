library(ggplot2)
library(dplyr)
library(reshape2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
df <- read.csv("../results_pse/results_pse_4obj_percentile5.csv", header = T)

names(df)

ggplot(df, aes(x = objective.om_MSTb, y = objective.om_MSTc, colour = nbBoats, size = evolution.samples))+
  geom_point()+
  theme_bw()



library(plotly)

sel <- df$evolution.samples >= 4

# Création du graphique avec des info-bulles personnalisées
plot_ly(data = df[sel,],
        x = ~objective.om_MSTb, 
        y = ~objective.om_MSTc, 
        type = 'scatter', 
        mode = 'markers', 
        color = ~nbBoats,  # Coloration par nbBoats
        #size = ~evolution.samples,  # Taille par evolution.samples
        marker = list(sizemode = 'diameter'),
        text = ~paste("nbBoats: ", nbBoats, 
                      "<br>ReserveIntegrale: ", ReserveIntegrale, 
                      "<br>ZonesExclusionPeche: ", ZonesExclusionPeche,
                      "<br>PrixPoisson: ", PrixPoisson, 
                      "<br>BiomassInit: ", BiomassInit),
        hoverinfo = 'text') %>%
  layout(title = 'Scatter Plot with Custom Popups',
         xaxis = list(title = 'Objective MSTb'),
         yaxis = list(title = 'Objective MSTc'),
         plot_bgcolor = 'rgba(0,0,0,0)',  # Correspond à theme_bw()
         paper_bgcolor = 'rgba(0,0,0,0)')




library(plotly)

# Création du graphique 3D
a <- plot_ly(data = df[sel,], 
        x = ~objective.om_MSTb,  # Axe X
        y = ~objective.om_MSTc,  # Axe Y
        z = ~BiomassInit,   # Axe Z (3ème dimension)
        type = 'scatter3d', 
        mode = 'markers', 
        color = ~nbBoats,  # Coloration par nbBoats
        #size = ~1/BiomassInit/max(BiomassInit),  # Taille par evolution.samples
        marker = list(sizemode = 'diameter'),
        text = ~paste("nbBoats: ", nbBoats, 
                      "<br>ReserveIntegrale: ", ReserveIntegrale, 
                      "<br>ZonesExclusionPeche: ", ZonesExclusionPeche,
                      "<br>PrixPoisson: ", PrixPoisson, 
                      "<br>BiomassInit: ", BiomassInit),
        hoverinfo = 'text') %>%
  layout(scene = list(
    xaxis = list(title = 'Objective MSTb'),
    yaxis = list(title = 'Objective MSTc'),
    zaxis = list(title = 'BiomassInit')
  ))

a
# Sauvegarder en fichier HTML interactif
library(htmlwidgets)
htmlwidgets::saveWidget(as_widget(a), "/tmp/graphique_interactif.html")


