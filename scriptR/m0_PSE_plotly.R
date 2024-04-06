library(ggplot2)
library(dplyr)
library(reshape2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
df <- read.csv("../results_pse/population1720_percentile5.csv", header = T)

names(df)

ggplot(df, aes(x = objective.om_capitalTotal, y = objective.om_sumBiomass, colour = nbBoats, size = evolution.samples))+
  geom_point()+
  theme_bw()


ggplot(df, aes(x = objective.om_capitalTotal, y = objective.om_sumBiomass, colour = ReserveIntegrale, size = evolution.samples))+
  geom_point()+
  theme_bw()
df <- df[df$evolution.samples>1,]

library(plotly)
plot_ly(x = df$objective.om_capitalTotal, y = df$objective.om_sumBiomass, z=df$nbBoats, 
        type="scatter3d", 
        mode="markers", 
        color=df$ReserveIntegrale,
        size = 5)%>%
layout( scene = list(xaxis = list(title = 'Capital'),
                       yaxis = list(title = 'Biomass'),
                       zaxis = list(title = 'nb boat')),
        legend = list(title = list(text = 'Espèce')))


