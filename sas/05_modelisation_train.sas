/* ================================================================================= */
/* PARTIE 1 : Modélisation - Méthodologie step by step (echantillon apprentissage)                                                */
/* ================================================================================= */

/*Première variable Arrieres_adate_C*/

ods output parameterestimates=param_modele1 (keep=variable classval0 estimate where = (variable ne "Intercept"));


proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0') / param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C/  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;

/*
D de Sommer/ Indice de Gini : 0.478 
Aire sous la courbe ROC, AUC : 0.739
AIC : 5486.835 */

/*Deuxième variable - incident_passe_C */

ods output parameterestimates=param_modele2 (keep=variable classval0 estimate where = (variable ne "Intercept"));

proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0')
	incident_passe_C (ref='0') / param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C
									incident_passe_C /  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;

/*
D de Sommer/ Indice de Gini : 0.591
Aire sous la courbe ROC, AUC : 0,7955
AIC : 5291.946 
classe 1 de incident_passe_C non significatif pvalue = 0.2197
*/


/*Troisième variable variable - SFMois_AG_C */

ods output parameterestimates=param_modele3 (keep=variable classval0 estimate where = (variable ne "Intercept"));


proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0')
	incident_passe_C (ref='0')
	SFMois_AG_C (ref='0') / param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C
									incident_passe_C
									SFMois_AG_C/  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;

/*
D de Sommer/ Indice de Gini : 0.700
Aire sous la courbe ROC, AUC : 0.850
AIC : 5191.753 
classe 1 de incident_passe_C non significatif pvalue = 0.8340
*/

/*Quatrième variable variable - SOLD_DIB_C */

ods output parameterestimates=param_modele4 (keep=variable classval0 estimate where = (variable ne "Intercept"));


proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0')
	incident_passe_C (ref='0')
	SFMois_AG_C (ref='0')
	SOLD_DIB_C(ref='0') / param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C
									incident_passe_C
									SFMois_AG_C
									SOLD_DIB_C/  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;

/*
D de Sommer/ Indice de Gini : 0.721
Aire sous la courbe ROC, AUC : 0.861
AIC : 5131.936 
classe 1 de incident_passe_C non significatif pvalue = 0.7657
classe 2 de incident_passe_C non significatif pvalue = 0.0714 
classe 1 de SOLD_DIB_C non significatif pvalue = 0.4005
*/


/*Cinquième variable variable - MVT_AFF_12M_C */

ods output parameterestimates=param_modele5 (keep=variable classval0 estimate where = (variable ne "Intercept"));


proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0')
	incident_passe_C (ref='0')
	SFMois_AG_C (ref='0')
	SOLD_DIB_C(ref='0') 
	MVT_AFF_12M_C (ref='0') / param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C
									incident_passe_C
									SFMois_AG_C
									SOLD_DIB_C
									MVT_AFF_12M_C/  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;

/*
D de Sommer/ Indice de Gini : 0.736
Aire sous la courbe ROC, AUC : 0.868
AIC : 5108.532 
classe 1 de incident_passe_C non significatif pvalue = 0.9361
classe 2 de incident_passe_C non significatif pvalue = 0.0487
classe 1 de SOLD_DIB_C non significatif pvalue = 0.4939
*/


/*Sixième variable variable - ANC_RELA_LCL_C */

ods output parameterestimates=param_modele6 (keep=variable classval0 estimate where = (variable ne "Intercept"));


proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0')
	incident_passe_C (ref='0')
	SFMois_AG_C (ref='0')
	SOLD_DIB_C(ref='0') 
	MVT_AFF_12M_C (ref='0') 
	ANC_RELA_LCL_C (ref='0') / param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C
									incident_passe_C
									SFMois_AG_C
									SOLD_DIB_C
									MVT_AFF_12M_C
									ANC_RELA_LCL_C/  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;

/*
D de Sommer/ Indice de Gini : 0.736
Aire sous la courbe ROC, AUC : 0.868
AIC : 5107.272
classe 1 de incident_passe_C non significatif pvalue = 0.7973
classe 2 de incident_passe_C non significatif pvalue = 0.0520
classe 1 de SOLD_DIB_C non significatif pvalue = 0.4357
classe 1 de ANC_RELA_LCL_C non significatif pvalue = 0.0778
*/

/* Retraitement des classes non significatives pour les variables concernés :*/

/************************************incident_passe_c******************************************/
data pcs.train_modele ;
	set pcs.train_modele ;
	if incident_passe_c = 1 then incident_passe_c = 0 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if incident_passe_c = 2 then incident_passe_c = 1 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if incident_passe_c = 3 then incident_passe_c = 2 ;
run ;

/* Vérification  */
proc freq data= pcs.train_modele ;
tables incident_passe_c*DDefaut_NDB;
run ;

/************************************incident_passe_c2******************************************/
data pcs.train_modele ;
	set pcs.train_modele ;
	if incident_passe_C = 1 then incident_passe_C = 0 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if incident_passe_C = 2 then incident_passe_C = 1 ;
run ;

/************************************SOLD_DIB_C******************************************/


data pcs.train_modele ;
	set pcs.train_modele ;
	if SOLD_DIB_C = 1 then SOLD_DIB_C = 0 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if SOLD_DIB_C = 2 then SOLD_DIB_C = 1 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if SOLD_DIB_C = 3 then SOLD_DIB_C = 2 ;
run ;


proc freq data= pcs.train_modele ;
tables SOLD_DIB_C*DDefaut_NDB;
run ;

/* Modèle opti */
ods output parameterestimates=param_modele6opti (keep=variable classval0 estimate where = (variable ne "Intercept"));

proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0')
	incident_passe_C (ref='0')
	SFMois_AG_C (ref='0')
	SOLD_DIB_C(ref='0') 
	MVT_AFF_12M_C (ref='0')  / param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C
									incident_passe_C
									SFMois_AG_C
									SOLD_DIB_C
									MVT_AFF_12M_C
									/  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;
/*
D de Sommer/ Indice de Gini : 0.733
Aire sous la courbe ROC, AUC : 0.867
AIC : 5106.713
*/



/* Tentative d'incorporation de segment_c qui avait un V de cramer de 0.49 avec 
 Arrieres_adate_C */
ods output parameterestimates=pcs.param_modele7 (keep=variable classval0 estimate where = (variable ne "Intercept"));

proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0')
	incident_passe_C (ref='0')
	SFMois_AG_C (ref='0')
	SOLD_DIB_C(ref='0') 
	MVT_AFF_12M_C (ref='0') 
	segment_c (ref='0')/ param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C
									incident_passe_C
									SFMois_AG_C
									SOLD_DIB_C
									MVT_AFF_12M_C
									segment_c/  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;
/*
D de Sommer/ Indice de Gini : 0.765
Aire sous la courbe ROC, AUC : 0.882
AIC : 4994.074 *



/* Retraitement des classes instable en terme de significativité sur les différents 
échantillons : */

/************************************MVT_AFF_12M_C******************************************/
data pcs.train_modele ;
	set pcs.train_modele ;
	if MVT_AFF_12M_C = 1 then MVT_AFF_12M_C = 0 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if MVT_AFF_12M_C = 2 then MVT_AFF_12M_C = 1 ;
run ;

proc freq data= pcs.train_modele ;
tables MVT_AFF_12M_C*DDefaut_NDB;
run ;


/************************************SFMois_AG_C******************************************/
data pcs.train_modele ;
	set pcs.train_modele ;
	if SFMois_AG_C = 1 then SFMois_AG_C = 0 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if SFMois_AG_C = 2 then SFMois_AG_C = 1 ;
run ;


data pcs.train_modele ;
	set pcs.train_modele ;
	if SFMois_AG_C = 3 then SFMois_AG_C = 2 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if SFMois_AG_C = 4 then SFMois_AG_C = 3 ;
run ;

proc freq data= pcs.train_modele ;
tables SFMois_AG_C*DDefaut_NDB;
run ;

ods output parameterestimates=pcs.param_modele_finale (keep=variable classval0 estimate where = (variable ne "Intercept"));

proc logistic data = pcs.train_modele ;
	class 
	Arrieres_adate_C (ref='0')
	incident_passe_C (ref='0')
	SFMois_AG_C (ref='0')
	SOLD_DIB_C(ref='0') 
	MVT_AFF_12M_C (ref='0') 
	segment_c (ref='0')/ param=glm ;
	model DDefaut_NDB (ref=first) = Arrieres_adate_C
									incident_passe_C
									SFMois_AG_C
									SOLD_DIB_C
									MVT_AFF_12M_C
									segment_c/  ridging=none link=logit RSQUARE OUTROC=roc1 lackfit ;
run;
ods output close ;

/*
D de Sommer/ Indice de Gini : 0.761
Aire sous la courbe ROC, AUC : 0.881
AIC : 5015.149 

/********** Fin du code **********/
