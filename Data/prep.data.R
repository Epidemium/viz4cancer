# Copyright February 2016 Quantmetry
# Author : Issam Ibnouhsein
# Project : Epidemium
# This scripts prepares data for the vizualisation pipeline

# Import necessary libraries

library(data.table)
library(tidyr)
library(dplyr)
options(scipen = 999)

######## environement data ##########
setwd("C:/Users/sjankowski/Downloads/")
env.data <- read.table('env_air_emis.tsv', header=TRUE, sep="\t", fileEncoding="windows-1252")

env.data <- env.data %>%
  separate(unit.ai.airsect.geo.time, into = c("unite","polluant","secteur.source","pays"), sep = "\\,")

names(env.data) <- c("unite","polluant","secteur.source","pays","2011","2010","2009","2008","2007","2006",
                     "2005","2004","2003","2002","2001","2000","1999","1998","1997","1996","1995","1994",
                     "1993","1992","1991","1990")


# definition of dictionary dataframes
env.ai.code <- data.frame(ai.code = c("NOX","PM10","NMVOC","NH3","PM2_5","SOX"),
                          ai.sig = c("oxydes d'azote", "10 um", 
                                      "composes organiques volatiles autres que methane",
                                      "ammoniac", "2.5 um", "oxydes de soufre")
)

env.airsect.code <- data.frame(airsect.code = c("SE1_RD","SE1_EUI","TOT_NAT","SE1_CIH","SE1_NRD",
                                            "SE7_OTH","SE6_WST","SE2_IP","SE3_SPU","SE1_EPD","SE4_AGR"),
                               airsect.sig = c("transport routier","utilisation d'energie dans l'industrie",
                                           "total des secteurs d'emission pour le territoire national",
                                           "commercial, institutionnel et menages","transport non-routier",
                                           "autre","dechets","processus industriels",
                                           "solvant et autres utilisations de produits", 
                                           "production et distribution d'energie","agriculture")
)

env.geo.code <- data.frame(geo.code = c("LV",	"LU",	"LT",	"HR",	"RO",	"TR",	"NO",	"HU",	"FR",	"BG",	"BE",	"DE",	
                                        "FI",	"DK",	"IE",	"CZ",	"AT",	"CY",	"SE",	"SI",	"SK",	"IS",	"UK",	
                                        "IT",	"MT",	"EU27",	"PL",	"PT",	"CH",	"ES",	"NL",	"LI",	"EE",	"EL"),
                           geo.sig = c("lettonie","luxembourg","lituanie","croatie","roumanie","turquie",
                                       "norvege","hongrie","france","bulgarie","belgique","allemagne",
                                       "finlande","danemark","irlande","republique tcheque","autriche",
                                       "chypre","suede","slovenie","slovaquie","islande","royaume-uni",
                                       "italie","malte", "ue","pologne",
                                       "portugal","suisse","espagne","pays-bas","liechtenstein","estonie",
                                       "grece")
                           )

# replacing column values with dictionaries values
env.data <- left_join(env.data, env.ai.code, by = c("polluant" = "ai.code"))
env.data <- left_join(env.data, env.airsect.code, by = c("secteur.source" = "airsect.code"))
env.data <- left_join(env.data, env.geo.code, by = c("pays" = "geo.code"))

env.data$polluant <- NULL
env.data$secteur.source <- NULL
env.data$pays <- NULL
env.data$unite <- NULL
env.data <- gather(env.data, annee, emission.T, 1:22)

names(env.data) <- c("polluant","secteur.source","pays","annee","emission.T")
env.data$polluant <- gsub(' ','.',env.data$polluant)
env.data$polluant <- gsub("'",'.',env.data$polluant)
env.data$emission.T <- gsub(" n",'',env.data$emission.T)

# restriction to france and UE data
env.france <- env.data[(env.data$pays == "france") | (env.data$pays == "ue"), ]
env.france <- spread(env.france, pays, emission.T)
names(env.france) <- c("polluant","secteur.source","annee", "emission.france", "emission.ue")
env.france <- env.france %>% 
  group_by(polluant, annee) %>%
  summarise(emission.france = sum(as.numeric(emission.france)),
            emission.ue = sum(as.numeric(emission.ue)))

# spreading pollution data to columns
env.france$polluant.bis <- paste0(env.france$polluant, ".ue")
env.france$polluant <- paste0(env.france$polluant, ".france")
env.france <- env.france %>% spread(polluant, emission.france)
env.france <- env.france %>% spread(polluant.bis, emission.ue)
env.france <- env.france %>% 
  group_by(annee) %>%
  summarise(`10.um.france` = max(`10.um.france`, na.rm = TRUE),
            `2.5.um.france` = max(`2.5.um.france`, na.rm = TRUE),
            ammoniac.france = max(ammoniac.france, na.rm = TRUE),
            composes.organiques.volatiles.autres.que.methane.france = max(composes.organiques.volatiles.autres.que.methane.france, na.rm = TRUE),
            oxydes.d.azote.france = max(oxydes.d.azote.france, na.rm = TRUE),
            oxydes.de.soufre.france = max(oxydes.de.soufre.france, na.rm = TRUE),
            `10.um.ue` = max(`10.um.ue`, na.rm = TRUE),
            `2.5.um.ue` = max(`2.5.um.ue`, na.rm = TRUE),
            ammoniac.ue = max(ammoniac.ue, na.rm = TRUE),
            composes.organiques.volatiles.autres.que.methane.ue = max(composes.organiques.volatiles.autres.que.methane.ue, na.rm = TRUE),
            oxydes.d.azote.ue = max(oxydes.d.azote.ue, na.rm = TRUE),
            oxydes.de.soufre.ue = max(oxydes.de.soufre.ue, na.rm = TRUE)
            )
env.france$annee <- as.numeric(as.character(env.france$annee))


######### weight data ###########
poids <- read.table("poids.csv", header = FALSE, sep = ";", dec = ',')
names(poids) <- c("annee", "population", "part.population")
poids <- spread(poids, population, part.population)
names(poids) <- c("annee", "part.obesite", "part.surpoids")
poids$part.obesite <- poids$part.obesite 
poids$part.surpoids <- poids$part.surpoids

######## tobacco data ############
tabac <- read.table("tabac.csv", header = FALSE, sep = ";", dec = ',')
names(tabac) <- c("annee", "unite", "valeur")
tabac <- spread(tabac, unite, valeur)
names(tabac) <- c("annee", "tabac.part.depense", "tabac.volume.par.personne.euro")
tabac$tabac.part.depense <- tabac$tabac.part.depense 
tabac$tabac.volume.par.personne.euro <- tabac$tabac.volume.par.personne.euro 


######### cancer data #############
cancer <- read.csv("cancer.france.csv", header = FALSE, fill = TRUE, sep = ';', colClasses = "character")
names(cancer) <- c("type.cancer","annee","age","incidents.homme","deces.homme","incidents.femme","deces.femme", "pop.homme", "pop.femme")
cancer$part.inc.homme <- as.numeric(cancer$incidents.homme)/as.numeric(cancer$pop.homme)*1000
cancer$part.deces.homme <- as.numeric(cancer$deces.homme)/as.numeric(cancer$pop.homme)*1000
cancer$part.inc.femme <- as.numeric(cancer$incidents.femme)/as.numeric(cancer$pop.femme)*1000
cancer$part.deces.femme <- as.numeric(cancer$deces.femme)/as.numeric(cancer$pop.femme)*1000

cancer$incidents.homme <- NULL
cancer$incidents.femme <- NULL
cancer$deces.homme <- NULL
cancer$deces.femme <- NULL
# cancer$pop.homme <- NULL
# cancer$pop.femme <- NULL


cancer <- cancer %>% gather(sexe,part.inc,6,8)
cancer$sexe <- ifelse(cancer$sexe == "part.inc.homme","homme","femme")
cancer$part.deces <- ifelse(cancer$sexe == "homme", cancer$part.deces.homme, cancer$part.deces.femme)
cancer$pop <- ifelse(cancer$sexe == "homme", cancer$pop.homme, cancer$pop.femme)
cancer$part.deces.homme <- NULL
cancer$part.deces.femme <- NULL
cancer$pop.femme <- NULL
cancer$pop.homme <- NULL

# creation of aggregated age column
cancer$age.agg <- ifelse(cancer$age %in% c("[00-04]","[05-09]","[10-14]","[15-19]"),
                     "[0-19]",
                     ifelse(cancer$age %in% c("[20-24]","[25-29]","[30-34]","[35-39]"),
                            "[20-39]",
                            ifelse(cancer$age %in% c("[40-44]","[45-49]","[50-54]","[55-59]"),
                                   "[40-59]",
                                   ifelse(cancer$age %in% c("[60-64]","[65-69]","[70-74]","[75-79]"),
                                          "[60-79]",
                                          "[80-++]"))))


cancer$type.cancer <- tolower(cancer$type.cancer)
cancer$type.cancer <- gsub(" ",".",cancer$type.cancer)
cancer$type.cancer <- gsub("'",".",cancer$type.cancer)
cancer$type.cancer <- gsub("-",".",cancer$type.cancer)

# spreading cancer types data to columns
cancer$type.cancer.bis <- paste0(cancer$type.cancer, ".deces")
cancer$type.cancer <- paste0(cancer$type.cancer, ".inc")
cancer <- cancer %>% spread(type.cancer, part.inc)
cancer <- cancer %>% spread(type.cancer.bis, part.deces)
cancer <- cancer %>% 
  group_by(annee, age, sexe, age.agg) %>%
  summarise(pop = min(pop, na.rm=TRUE),
            colon.rectum.inc = min(colon.rectum.inc, na.rm = TRUE),
            col.de.l.uterus.inc = min(col.de.l.uterus.inc, na.rm = TRUE),
            corps.de.l.uterus.inc = min(corps.de.l.uterus.inc, na.rm = TRUE),
            estomac.inc = min(estomac.inc, na.rm = TRUE),
            foie.inc = min(foie.inc, na.rm = TRUE),
            larynx.inc = min(larynx.inc, na.rm = TRUE),
            melanome.de.la.peau.inc = min(melanome.de.la.peau.inc, na.rm = TRUE),
            oesophage.inc = min(oesophage.inc, na.rm = TRUE),
            ovaire.inc = min(ovaire.inc, na.rm = TRUE),
            pancreas.inc = min(pancreas.inc, na.rm = TRUE),
            poumon.inc = min(poumon.inc, na.rm = TRUE),
            rein.inc = min(rein.inc, na.rm = TRUE),
            sein.inc = min(sein.inc, na.rm = TRUE),
            systeme.nerveux.cent.inc = min(systeme.nerveux.cent.inc, na.rm = TRUE),
            thyroide.inc = min(thyroide.inc, na.rm = TRUE),
            tous.cancers.inc = min(tous.cancers.inc, na.rm = TRUE),
            levre.bouche.pharynx.inc = min(levre.bouche.pharynx.inc, na.rm = TRUE),
            vessie.inc = min(vessie.inc, na.rm = TRUE),

            colon.rectum.deces = min(colon.rectum.deces, na.rm = TRUE),
            col.de.l.uterus.deces = min(col.de.l.uterus.deces, na.rm = TRUE),
            corps.de.l.uterus.deces = min(corps.de.l.uterus.deces, na.rm = TRUE),
            estomac.deces = min(estomac.deces, na.rm = TRUE),
            foie.deces = min(foie.deces, na.rm = TRUE),
            larynx.deces = min(larynx.deces, na.rm = TRUE),
            melanome.de.la.peau.deces = min(melanome.de.la.peau.deces, na.rm = TRUE),
            oesophage.deces = min(oesophage.deces, na.rm = TRUE),
            ovaire.deces = min(ovaire.deces, na.rm = TRUE),
            pancreas.deces = min(pancreas.deces, na.rm = TRUE),
            poumon.deces = min(poumon.deces, na.rm = TRUE),
            rein.deces = min(rein.deces, na.rm = TRUE),
            sein.deces = min(sein.deces, na.rm = TRUE),
            systeme.nerveux.cent.deces = min(systeme.nerveux.cent.deces, na.rm = TRUE),
            thyroide.deces = min(thyroide.deces, na.rm = TRUE),
            tous.cancers.deces = min(tous.cancers.deces, na.rm = TRUE),
            levre.bouche.pharynx.deces = min(levre.bouche.pharynx.deces, na.rm = TRUE),
            vessie.deces = min(vessie.deces, na.rm = TRUE)
            )

cancer$annee <- as.numeric(as.character(cancer$annee))
            
####### final table #########

final.table <- merge(cancer,tabac)
final.table <- merge(final.table,poids)
final.table <- merge(final.table,env.france)

write.table(final.table, file = "final.table.csv")

###### predictions ##########

library(ggplot2)

ggplot(tabac, aes(x = annee, y = tabac.part.depense)) + geom_line()
ggplot(tabac, aes(x = annee, y = tabac.volume.par.personne.euro)) + geom_line()
ggplot(poids, aes(x = annee, y = part.obesite)) + geom_line()
ggplot(poids, aes(x = annee, y = part.surpoids)) + geom_line()
ggplot(env.france, aes(x = annee, y = ammoniac.france)) + geom_line()

# arima
library(forecast)
value <- env.france$ammoniac.france
sensor <- ts(value) # consider adding a start so you get nicer labelling on your chart. 
fit <- auto.arima(sensor)
fcast <- forecast(fit)
plot(fcast)
grid()

# ESN : KO

# polynomial regression

predict_poly <- function(df, x, y, pred.win, deg.poly){
  clf <- lm(as.formula(paste0(y,"~","poly(",x,",",deg.poly,",raw = TRUE)")), df, na.action=na.omit)
  start.pred <- max(get(x, df)) + 1 
  newdata <- data.frame(c(get(x,df), c(start.pred: (start.pred + pred.win))))
  names(newdata) <- paste0(x)
  res <- predict(clf, newdata = newdata)
  plot(c(get(x, df), c(start.pred: (start.pred + pred.win))), 
       res, 
       type="l", col="blue")
  points(get(x, df), get(y, df))
  grid()
  return(res)
}


predict_poly(cancer %>% filter(sexe == "femme" & age == "[60-64]"), "annee", "poumon.deces", 5, 3)


# random forest

library(randomForest)

predict_poly <- function(df, x, y, pred.win, deg.poly){
  clf <- randomForest(as.formula(paste0(y,"~",x)), 
                       df,
                       ntree = 20,
                       metry = 1)
  start.pred <- max(get(x, df)) + 1
  newdata <- data.frame(c(get(x,df), c(start.pred: (start.pred + pred.win))))
  names(newdata) <- paste0(x)
  res <- predict(clf, newdata = newdata)
  plot(c(get(x, df), c(start.pred: (start.pred + pred.win))), 
       res, 
       type="l", col="blue")
  points(get(x, df), get(y, df))
  grid()
  return(res)
}


predict_poly(cancer %>% filter(sexe == "homme", age == "[60-64]"), "annee", "poumon.inc", 10, 10)


# Gradient Boosting

library(gbm)

predict_poly <- function(df, x, y, pred.win, deg.poly){
  clf <- gbm(as.formula(paste0(y,"~",x)), 
                       data = df,
                       n.trees = 50,
                       interaction.depth = 2,
                       bag.fraction = 1)
  start.pred <- max(get(x, df)) + 1
  newdata <- data.frame(c(get(x,df), c(start.pred: (start.pred + pred.win))))
  names(newdata) <- paste0(x)
  res <- predict(clf, newdata = newdata, n.trees = 50)
  plot(c(get(x, df), c(start.pred: (start.pred + pred.win))), 
       res, 
       type="l", col="blue")
  points(get(x, df), get(y, df))
  grid()
  return(res)
}

predict_poly(final.table %>% filter(sexe == "homme", age == "[60-64]"), "annee", "ammoniac.ue", 8, 4)

# creation of final table

final.pred.table <- expand.grid(c(unique(final.table$annee),c(2012:2020)), unique(final.table$sexe), unique(final.table$age))
names(final.pred.table) <- c("annee", "sexe", "age")

for (col in names(final.table[,c(5:ncol(final.table))])){
  print(col)
  col.pred.table <- final.pred.table[0,]
  for (s in unique(final.table$sexe)){
    for (a in unique(final.table$age)){
      tmp <- final.table %>% filter(sexe == s, age == a)
      try(res <- predict_poly(tmp, "annee", col, 8, 4))
      new.data <- data.frame(annee = c(1992:2020), sexe = s, age = a, x = tail(res,29)) 
      names(new.data) <- c("annee", "sexe", "age", paste0(col))
      col.pred.table <- rbind(col.pred.table, new.data)                          
    }
  }
  final.pred.table <- merge(final.pred.table, col.pred.table)
}

final.pred.table$age.agg <- ifelse(final.pred.table$age %in% c("[00-04]","[05-09]","[10-14]","[15-19]"),
                                   "[0-19]",
                                   ifelse(final.pred.table$age %in% c("[20-24]","[25-29]","[30-34]","[35-39]"),
                                          "[20-39]",
                                          ifelse(final.pred.table$age %in% c("[40-44]","[45-49]","[50-54]","[55-59]"),
                                                 "[40-59]",
                                                 ifelse(final.pred.table$age %in% c("[60-64]","[65-69]","[70-74]","[75-79]"),
                                                        "[60-79]",
                                                        "[80-++]"))))

write.table(final.pred.table, file = "final.pred.table.csv")



