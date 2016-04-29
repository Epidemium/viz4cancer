var epidemium_config = {
    "graph_url": "http://viz4cancer.epidemium.cc:8001/plotPost2",

    "data_lists":  [
         
         ["estomac.inc", "cancer de l'estomac (indicences)"],
         ["foie.inc", "cancer du foie (indicences)"],
         ["larynx.inc", "cancer du larynx (indicences)"],
         ["melanome.de.la.peau.inc", "cancer du mélanome de la peau (indicences)"],
         ["oesophage.inc", "cancer de l'oesophage (indicences)"],
         ["pancreas.inc", "cancer du pancréas (indicences)"],
         ["poumon.inc", "cancer du poumon (indicences)"],
         ["rein.inc", "cancer du rein (indicences)"],
         ["colon.rectum.inc", "cancer du colon (indicences)"],

         ["systeme.nerveux.cent.inc", "cancer du système nerveux central (indicences)"],
         ["tous.cancers.inc", "cancer (total, indicences)"],
         ["levre.bouche.pharynx.inc", "cancer lèvre bouche pharynx (indicences)"],
         ["vessie.inc", "cancer de la vessie (indicences)"],
         ["colon.rectum.deces", "cancer du colon (décès)"],

         ["estomac.deces", "cancer de l'estomac (décès)"],
         ["larynx.deces", "cancer du larynx (décès)"],
         ["oesophage.deces", "cancer de l'oesophage (décès)"],
         ["ovaire.deces", "cancer des ovaires (décès)"],
         ["poumon.deces", "cancer du poumon (décès)"],
         ["rein.deces", "cancer du rein (décès)"],
         ["systeme.nerveux.cent.deces", "cancer du système nerveux central (décès)"],
         ["tous.cancers.deces", "cancer (total, décès)"],
         ["levre.bouche.pharynx.deces", "cancer lèvre bouche pharynx (décès)"],
         ["vessie.deces", "cancer de la vessie (décès)"],
         ["sein.deces", "cancer du sein (décès)"],
         ["thyroide.inc", "cancer de la thyroïde (incidences)"],
         ["thyroide.deces", "cancer de la thyroïde (décès)"],

         ["tabac.part.depense", "facteur: part des dépenses en tabac"],
         ["tabac.volume.par.personne.euro", "facteur: dépenses des foyers en tabac"],
         ["part.obesite", "facteur: taux d'obésité"],
         ["part.surpoids", "facteur: part de surpoids"],
         ["ammoniac.france", "facteur: rejets d'ammoniac (France)"],
         ["ammoniac.ue", "facteur: rejets d'ammoniac (U.E.)"],
         ["composes.organiques.volatiles.autres.que.methane.france", "facteur: rejets de composés organiques (France)"],
         ["composes.organiques.volatiles.autres.que.methane.ue", "facteur: rejets de composés organiques (U.EU)"],
         ["oxydes.d.azote.france", "facteur: rejets d'azote (France)"],
         ["oxydes.de.soufre.france", "facteur: rejets de soufre (France)"],
         ["oxydes.d.azote.ue", "facteur: rejets d'azote (U.E.)"],
         ["oxydes.de.soufre.ue", "facteur: rejets de soufre (U.E.)"]
    ]
/* 
// ceux la sont des meta variables
"annee",
"age",
"sexe",
"age.agg",


// CEUX QUI ONT UNE PROBLEME DE PREDICTION

"ovaire.inc",
"corps.de.l.uterus.deces",
"foie.deces",
"melanome.de.la.peau.deces",
"pancreas.deces",

// Ceux la contiennent des valeur non nulles pour les hommes -> erreur dans le dataset ??
["corps.de.l.uterus.inc", "cancer du corps de l'utérus (indicences)"],
         ["col.de.l.uterus.deces", "cancer du col de l'utérus (décès)"],
         ["col.de.l.uterus.inc", "cancer du col de l'utérus (indicences)"],



// Ceux la n'existent pas visiblement
 "10.um.france",
 "2.5.um.france",
  "10.um.ue",
 "2.5.um.ue",
 */

};
