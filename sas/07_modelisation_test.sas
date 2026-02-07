/* ================================================================================= */
/* PARTIE 1 : Modélisation -  (echantillon Test)                                                */
/* ================================================================================= */

/***************************************Discrétisation***************************************/
/* SFMois_AG_C, SOLD_DIB_C, MVT_AFF_12M_C, ANC_RELA_LCL_C */

/* SOLD_DIB_C */

data pcs.test_modele ;
	set pcs.test_cleanf ;
	if SOLD_DIB = 0 then SOLD_DIB_C = 0 ;
	else if SOLD_DIB >= -5573 then SOLD_DIB_C = 1 ;
	else if SOLD_DIB >= -73780 then SOLD_DIB_C = 2 ; 
	else SOLD_DIB_C = 3 ;
run ;

/* SFMois_AG_C */

data pcs.test_modele ;
	set pcs.test_modele ;
	if SFMois_AG <= 2100 then SFMois_AG_C = 4 ;
	else if SFMois_AG <= 82600 then SFMois_AG_C = 3 ;
	else if SFMois_AG <= 163300 then SFMois_AG_C = 2 ;
	else if SFMois_AG > 937500 and SFMois_AG <= 4389600 then SFMois_AG_C = 0 ;
	else SFMois_AG_C = 1 ;
run ;

/* MVT_AFF_12M_C  */

data pcs.test_modele ;
	set pcs.test_modele ;
	if MVT_AFF_12M <= 42691 then MVT_AFF_12M_C = 2 ;
	else if MVT_AFF_12M > 188333 and MVT_AFF_12M <= 1082150 then MVT_AFF_12M_C = 0 ;
	else MVT_AFF_12M_C = 1 ;
run ;

/***************************************Croisement***************************************/
/* Arrieres_adate_C, incident_passe_C */

/* Arrieres_adate_C */ 

data pcs.test_modele ;
    set pcs.test_modele ; 

    /* --- Construction de Arrieres_adate_C --- */
    
    /* 1. Priorité Absolue (Risque Max) : Y a-t-il un "2" quelque part ? */
    /* Si Impaye=2 OU Depassement=2, alors le client est classé 2 */
    if whichn(2, Impaye, Depassement) > 0 then Arrieres_adate_C = 2 ;

    /* 2. Priorité Secondaire (Risque Moyen) : Y a-t-il un "1" ? */
    /* On arrive ici seulement si aucun "2" n'a été trouvé au-dessus. */
    /* Si Impaye=1 OU Depassement=1, alors le client est classé 1 */
    else if whichn(1, Impaye, Depassement) > 0 then Arrieres_adate_C = 1 ;

    /* 3. Sinon : Tout est clean (que des 0) */
    else Arrieres_adate_C = 0 ;

run ;

/* incident_passe_C */

/*1) Calcul de  NDB_C */

data pcs.test_modele ;
    set pcs.test_modele ;

    /* STRATÉGIE DE PRIORITÉ : On cherche le pire cas d'abord */

    /* 1. Priorité Absolue : Y a-t-il au moins un "1" (Défaut) n'importe où ? */
    /* La fonction WHICHN renvoie la position de la valeur cherchée. Si > 0, c'est trouvé. */
    if whichn(1, of NDB_1-NDB_6) > 0 then NDB_C = 2 ; 

    /* 2. Priorité Secondaire : Pas de défaut trouvé, mais y a-t-il un "2" (Non renseigné) ? */
    /* On arrive ici seulement si la condition du dessus est fausse */
    else if whichn(2, of NDB_1-NDB_6) > 0 then NDB_C = 1 ;

    /* 3. Sinon : Tout est propre (que des 0) */
    else NDB_C = 0 ;

run ;

/*2) Calcul de Arrieres_passe_C */

data pcs.test_modele ;
    set pcs.test_modele ; 

    /* 1. Priorité ABSOLUE : Risque Max (2) */
    /* Si on trouve un '2' n'importe où dans l'historique M1, M2 ou M3 */
    if whichn(2, of Impaye_M1-Impaye_M3, of Depassement_M1-Depassement_M3) > 0 
        then arrieres_passe_C = 3 ;

    /* 2. Priorité SECONDAIRE : Risque Standard (1) */
    /* On arrive ici seulement s'il n'y a PAS de 2. */
    /* Le '1' l'emporte sur le '3' conformément à votre règle */
    else if whichn(1, of Impaye_M1-Impaye_M3, of Depassement_M1-Depassement_M3) > 0 
        then arrieres_passe_C = 2 ;

    /* 3. Priorité TERTIAIRE : Incertitude (3) */
    /* S'il n'y a ni 2 ni 1, mais qu'il y a un trou d'info (3) */
    else if whichn(3, of Impaye_M1-Impaye_M3, of Depassement_M1-Depassement_M3) > 0 
        then arrieres_passe_C = 1 ;

    /* 4. Sinon : Client Parfait (0) */
    else arrieres_passe_C = 0 ;

run ;

/* 3) Calcul de incident_passe_C */

data pcs.test_modele ;
    set pcs.test_modele ;
    /* On combine l'historique  (Arrieres) et (NDB) */

    /* 1. RISQUE MAX (Note 3) */
    /* Si Arriérés = 3 (Gros impayé interne) OU NDB = 2 (Défaut Externe) */
    if arrieres_passe_C = 3 or NDB_C = 2 then incident_passe_C = 3 ;

    /* 2. RISQUE ÉLEVÉ (Note 2) */
    /* Si Arriérés = 2 (Défaut interne standard) */
    /* Note : On n'a pas besoin de vérifier NDB ici car si NDB était à 2, 
       il aurait été capté par la condition précédente. */
    else if arrieres_passe_C = 2 then incident_passe_C = 2 ;

    /* 3. RISQUE MODÉRÉ / INCERTITUDE (Note 1) */
    /* Si l'un des deux signale une incertitude ou un petit pépin (1) */
    else if arrieres_passe_C = 1 or NDB_C = 1 then incident_passe_C = 1 ;

    /* 4. CLIENT SAIN (Note 0) */
    /* Si rien de tout ça n'est vrai, c'est que tout est à 0 */
    else incident_passe_C = 0 ;

run ;
/***************************************Regroupement***************************************/
/*segment */

data pcs.test_modele ;
	set pcs.test_modele ; 
	if segment in (2, 7, 8) then segment_c = 0 ;
	else if segment in (1, 5, 6) then segment_c = 1 ;
	else if segment = 4 then segment_c = 2 ;
	else if segment = 3 then segment_c = 3 ;

run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if segment_c = 3 then segment_c = 2 ;
run ;

/***************************************Retraitement***************************************/
/* Retraitement des variables retraités en apprentissage */

/*incident_passe_c*/
data pcs.test_modele ;
	set pcs.test_modele ;
	if incident_passe_c = 1 then incident_passe_c = 0 ;
run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if incident_passe_c = 2 then incident_passe_c = 1 ;
run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if incident_passe_c = 3 then incident_passe_c = 2 ;
run ;

/* Vérification  */
proc freq data= pcs.test_modele ;
tables incident_passe_c*DDefaut_NDB;
run ;


/* incident_passe_C 2 */
data pcs.test_modele ;
	set pcs.test_modele ;
	if incident_passe_C = 1 then incident_passe_C = 0 ;
run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if incident_passe_C = 2 then incident_passe_C = 1 ;
run ;

/*SOLD_DIB_C */
data pcs.test_modele ;
	set pcs.test_modele ;
	if SOLD_DIB_C = 1 then SOLD_DIB_C = 0 ;
run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if SOLD_DIB_C = 2 then SOLD_DIB_C = 1 ;
run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if SOLD_DIB_C = 3 then SOLD_DIB_C = 2 ;
run ;

/* Vérification sur la table la plus récente */
proc freq data= pcs.test_modele ;
tables SOLD_DIB_C*DDefaut_NDB;
run ;


/* Modèle sur echantillon de test */
proc logistic data = pcs.test_modele ;
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

/*
D de Sommer/ Indice de Gini : 0.761
Aire sous la courbe ROC, AUC : 0.881
AIC : 2069.473

/***************************************Retraitement***************************************/
/* MVT_AFF_12M_C*/

data pcs.test_modele ;
	set pcs.test_modele ;
	if MVT_AFF_12M_C = 1 then MVT_AFF_12M_C = 0 ;
run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if MVT_AFF_12M_C = 2 then MVT_AFF_12M_C = 1 ;
run ;

proc freq data= pcs.test_modele ;
tables MVT_AFF_12M_C*DDefaut_NDB;
run ;


/* SFMois_AG_C */
data pcs.test_modele ;
	set pcs.test_modele ;
	if SFMois_AG_C = 1 then SFMois_AG_C = 0 ;
run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if SFMois_AG_C = 2 then SFMois_AG_C = 1 ;
run ;


data pcs.test_modele ;
	set pcs.test_modele ;
	if SFMois_AG_C = 3 then SFMois_AG_C = 2 ;
run ;

data pcs.test_modele ;
	set pcs.test_modele ;
	if SFMois_AG_C = 4 then SFMois_AG_C = 3 ;
run ;

proc freq data= pcs.test_modele ;
tables SFMois_AG_C*DDefaut_NDB;
run ;

proc logistic data = pcs.test_modele ;
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
/*
D de Sommer/ Indice de Gini : 0.756
Aire sous la courbe ROC, AUC : 0.878
AIC : 2070.382 */


/********** Fin du code **********/