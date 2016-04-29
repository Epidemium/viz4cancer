##############################
# The main function starts the plumber
# server and makes all the Middle End 
# function available
##############################

library(plotly)
library(plumber)
library(dplyr)
library(readr)
library(tidyr)
library(magrittr)
library(RColorBrewer)
library(htmlwidgets)


# TODO: FIND THE DIRECTORY DYNAMICALLY!
# directory <- "C:/Users/sjankowski/Documents/R&D/Epidemium/VraiCode/20160101_Epidemium/Middle/"
directory <- "C:/Users/benjaminhabert/Documents/Quantmetry_Missions/Epidemium/20160101_Epidemium/Middle/"
source_encoding = "UTF-8"
destination_encoding = "UTF-8"

#* Import dataset
final.table <- tbl_df(read.csv(paste(directory, "final.table.csv", sep="")
                               , sep=' '
                               , row.names = NULL
                               , encoding = "UTF-8"))
final.pred.table <- tbl_df(read.csv(paste(directory, "final.pred.table.csv", sep="")
                                    , sep=' '
                                    , row.names = NULL
                                    , encoding = "UTF-8"))


dico <- list(
  "thyroide.inc" = "Nombre d'incidences du cancer de la thyroïde <br> pour 1000 habitants",
  "thyroide.deces" = "Nombre de décès du cancer de la thyroïde <br> pour 1000 habitants",
  "sein.deces" = "Nombre de décès du cancer du sein <br> pour 1000 habitants",
  "sein.inc" = "Nombre d'incidences du cancer du sein <br> pour 1000 habitants",
  "corps.de.l.uterus.inc" = "Nombre d'incidences du cancer <br>du corps de l'utérus pour 1000 habitants",
  "corps.de.l.uterus.deces" = "Nombre de décès du cancer <br>du corps de l'utérus pour 1000 habitants",
  "estomac.inc" = "Nombre d'incidences du cancer <br>de l'estomac pour 1000 habitants",
  "estomac.deces" = "Nombre de décès du cancer <br>de l'estomac pour 1000 habitants",
  "col.de.l.uterus.inc" = "Nombre d'incidences du cancer <br>du col de l'utérus pour 1000 habitants",
  "col.de.l.uterus.deces" = "Nombre de décès du cancer <br>du col de l'utérus pour 1000 habitants",
  "colon.rectum.inc" = "Nombre d'incidences du cancer <br>du colon/rectum pour 1000 habitants",
  "colon.rectum.deces" = "Nombre de décès du cancer <br>du colon/rectum pour 1000 habitants",
  "foie.inc" = "Nombre d'incidences du cancer <br>du foie pour 1000 habitants",
  "foie.deces" = "Nombre de décès du cancer <br>du foie pour 1000 habitants",
  "larynx.inc" = "Nombre d'incidences du cancer <br>du larynx pour 1000 habitants",
  "larynx.deces" = "Nombre de décès du cancer <br>du larynx pour 1000 habitants",
  "melanome.de.la.peau.inc" = "Nombre d'incidences <br>du cancer du mélanome de la peau pour 1000 habitants",
  "melanome.de.la.peau.deces" = "Nombre de décès <br>du cancer du mélanome de la peau pour 1000 habitants",
  "oesophage.inc" = "Nombre d'incidences du cancer <br>de l'oesophage pour 1000 habitants",
  "oesophage.deces" = "Nombre de décès du cancer <br>de l'oesophage pour 1000 habitants",
  "ovaire.inc" = "Nombre d'incidences du cancer <br>des ovaires pour 1000 habitants",
  "ovaire.deces" = "Nombre de décès du cancer <br>des ovaires pour 1000 habitants",
  "pancreas.inc" = "Nombre d'incidences du cancer <br>du pancréas pour 1000 habitants",
  "pancreas.deces" = "Nombre de décès du cancer <br>du pancréas pour 1000 habitants",
  "poumon.inc" = "Nombre d'incidences du cancer <br>du poumon pour 1000 habitants",
  "poumon.deces" = "Nombre de décès du cancer <br>du poumon pour 1000 habitants",
  "rein.inc" = "Nombre d'incidences du cancer <br>du rein pour 1000 habitants",
  "rein.deces" = "Nombre de décès du cancer <br>du rein pour 1000 habitants",
  "systeme.nerveux.cent.inc" = "Nombre d'incidences du cancer du système nerveux central pour 1000 habitants",
  "systeme.nerveux.cent.deces" = "Nombre de décès du cancer du système nereux central pour 1000 habitants",
  "tous.cancers.inc" = "Nombre d'incidences du cancer<br> (tous confondus) pour 1000 habitants",
  "tous.cancers.deces" = "Nombre de décès du cancer <br>(tous confondus) pour 1000 habitants",
  "levre.bouche.pharynx.inc" = "Nombre d'incidences du cancer <br>de la lèvre/bouche/pharynx pour 1000 habitants",
  "levre.bouche.pharynx.deces" = "Nombre de décès du cancer <br>de la lèvre/bouche/pharynx pour 1000 habitants",
  "vessie.inc" = "Nombre d'incidences du cancer <br>de la vessie pour 1000 habitants",
  "vessie.deces" = "Nombre de décès du cancer de la vessie pour 1000 habitants",
  
  "ammoniac.france" = "Rejets d'ammoniac en France (tonnes/an)",
  "ammoniac.ue"= "Rejets d'ammoniac en U.E. (tonnes/an)",
  "composes.organiques.volatiles.autres.que.methane.france" = "Rejets de composés oraniques volatiles<br> en France (tonnes/an, hors méthane)",
  "composes.organiques.volatiles.autres.que.methane.ue" = "Rejets de composés oraniques volatiles<br> en U.E. (tonnes/an, hors méthane)",
  "oxydes.d.azote.france" = "Rejets d'oxyde d'azote en France (tonnes/an)",
  "oxydes.de.soufre.france" = "Rejets d'oxyde de soufre en France (tonnes/an)",
  "oxydes.d.azote.ue" = "Rejets d'oxyde d'azote en U.E. (tonnes/an)",
  "oxydes.de.soufre.ue" = "Rejets d'oxyde de soufre en U.E. (tonnes/an)",
  "tabac.part.depense" = "Part du tabac dans les dépenses des français (%)",
  "tabac.volume.par.personne.euro" = "Volume des dépenses par personne pour le tabac (€)",
  "part.obesite" = "Part de l'obésité dans la population française (%)",
  "part.surpoids" = "Part du surpoids dans la population française (%)",
  "emission.france" = "Volume des émissions de pollution en France (tonnes/an)",
  "emission.ue" = "Volume des émissions de pollution en UE (tonnes/an)"
)




# for(i in names(dico)){
#   dico[[i]] <- iconv(dico[[i]], source_encoding, destination_encoding)
# }

# Plumb the Middle En code with the functions 
r <- plumb(paste(directory, 'MiddleEnd.R', sep=""))
# r <- plumb('MiddleEnd.R')
# Run on chosen port
r$run(port=8001)

