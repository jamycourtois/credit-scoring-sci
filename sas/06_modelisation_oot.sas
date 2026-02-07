/* ================================================================================= */
/* PARTIE 1 : Modélisation -  (echantillon OOT)                                                */
/* ================================================================================= */

/* Application des traitements réalisé pour Base Train et Test */

proc contents data = sasuser.base_oot_sci  ;
	title Résumé base de données ;
run ;

data base_oot ;
set sasuser.base_oot_sci ;
run ;

/* ================================================================================= */

/* Variables Quantis */
proc format;
    value CheckMiss
        . = 'Manquant'       
        other = 'Renseigné'; 
run;

proc freq data = base_oot;
	format _numeric_ CheckMiss.; 
	tables ANC_ENTR /* Valeurs Manquantes : 64 soit 0.06%  */
	       ANC_RELA_LCL /* Valeurs Manquantes : 64 soit 0.06%  */
	       Engagement_prorat
	       MVT_AFF_12M /* Valeurs Manquantes : 64 soit 0.06%  */
	       NBJDEPDP /* Valeurs Manquantes : 64 soit 0.06%  */
	       NBJRDB_AT /* Valeurs Manquantes : 64 soit 0.06%  */
	       NB_JR_DEB /* Valeurs Manquantes : 64 soit 0.06%  */
	       NJRS_DEP_DA /* Valeurs Manquantes : 64 soit 0.06%  */
	       SFMois_AG /* Valeurs Manquantes : 64 soit 0.06%  */
	       SOLD_CRE /* Valeurs Manquantes : 64 soit 0.06%  */
	       SOLD_DIB/ missing nocum; 
run;


/* suppresion */
data base_oot ;
	set base_oot;
	if nmiss(ANC_RELA_LCL) > 0 then delete;
run;


/* Controles pour les valeurs manquantes */
proc means data = base_oot nmiss mean q1 median q3 std cv skew kurt min max maxdec=2 ;
	var	ANC_ENTR 
		ANC_RELA_LCL  
		Engagement_prorat
		MVT_AFF_12M  
		NBJDEPDP  
		NBJRDB_AT  
		NB_JR_DEB  
		NJRS_DEP_DA  
		SFMois_AG  
		SOLD_CRE 								
		SOLD_DIB  ;
run ;

/* ================================================================================= */

/*Variables Qualis */

proc freq data = base_oot ;
	tables
		CODETAJUR
		CODNAF2
		SEC_DER
		Depassement
		Depassement_M1 
		Depassement_M2 
		Depassement_M3 
		Impaye
		Impaye_M1 
		Impaye_M2 
		Impaye_M3 
		Top_immo
		Top_Interfimo
		Top_engagement
		Top_hbilan_uniq
		Top_MLT
		Top_pp  
		
		Top_pret_perso 
		
		Top_pro_lib 
		Top_sci 
		segment
		NDB_1 
		NDB_2 
		NDB_3 
		NDB_4 
		NDB_5 
		NDB_6 / missing nocum; ;
run ;

/* Suppression des variables inutiles (Top_pp,Top_pret_perso,Top_sci)*/

data base_oot ;
	set base_oot ;
	drop Top_pp Top_pret_perso Top_sci ;
run ;

/* Imputations de nouvelles valeurs aux variables manquantes */

data base_oot;
	set base_oot; 
	array vect_ndb (*) NDB_1 NDB_2 NDB_3 NDB_4 NDB_5 NDB_6;
	do i = 1 to dim(vect_ndb);
	  if vect_ndb(i) = . then vect_ndb(i) = 2;
	    end;
		drop i;
run;

data base_oot;
	set base_oot; 
	array vect_IxD (*) Depassement_M1 Depassement_M2 Depassement_M3 Impaye_M1 Impaye_M2 Impaye_M3 ;
	do i = 1 to dim(vect_IxD);
	  if vect_IxD(i) = . then vect_IxD(i) = 3;
	    end;
		drop i;
run;

/* Vérification de la présence de doublons */

Proc sql ;
	create table doublons
	as select id_client, datdelhis, count (*) as nb_dossier
	from  base_oot
	group by id_client, datdelhis
	having nb_dossier > 1;
quit ;

/* Pas de doublons */

/********** Fin du Nettoyage de la base de données **********/

libname pcs "/home/u64383858/Crédit scoring" ;
data pcs.oot_modele ;
	set base_oot ;
run ;

/* ================================================================================= */
/* Discrétisation des variables quantitatives utilisées dans le modèle */
/* SFMois_AG_C, SOLD_DIB_C, MVT_AFF_12M_C, ANC_RELA_LCL_C */

/* SOLD_DIB_C */
data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SOLD_DIB = 0 then SOLD_DIB_C = 0 ;
	else if SOLD_DIB >= -5573 then SOLD_DIB_C = 1 ;
	else if SOLD_DIB >= -73780 then SOLD_DIB_C = 2 ; 
	else SOLD_DIB_C = 3 ;
run ;

/* SFMois_AG_C */
data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SFMois_AG <= 2100 then SFMois_AG_C = 4 ;
	else if SFMois_AG <= 82600 then SFMois_AG_C = 3 ;
	else if SFMois_AG <= 163300 then SFMois_AG_C = 2 ;
	else if SFMois_AG > 937500 and SFMois_AG <= 4389600 then SFMois_AG_C = 0 ;
	else SFMois_AG_C = 1 ;
run ;

/* MVT_AFF_12M_C  */
data pcs.oot_modele ;
	set pcs.oot_modele ;
	if MVT_AFF_12M <= 42691 then MVT_AFF_12M_C = 2 ;
	else if MVT_AFF_12M > 188333 and MVT_AFF_12M <= 1082150 then MVT_AFF_12M_C = 0 ;
	else MVT_AFF_12M_C = 1 ;
run ;

/* ================================================================================= */
/* Croisement des variables qualitatives utilisées dans le modèle */
/* Arrieres_adate_C, incident_passe_C */

/* Arrieres_adate_C */ 
data pcs.oot_modele ;
    set pcs.oot_modele ; 

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
data pcs.oot_modele ;
    set pcs.oot_modele ;

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
data pcs.oot_modele ;
    set pcs.oot_modele ; 

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
data pcs.oot_modele ;
    set pcs.oot_modele ;
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

/* ================================================================================= */

/* regroupement segment */
data pcs.oot_modele ;
	set pcs.oot_modele ; 
	if segment in (2, 7, 8) then segment_c = 0 ;
	else if segment in (1, 5, 6) then segment_c = 1 ;
	else if segment = 4 then segment_c = 2 ;
	else if segment = 3 then segment_c = 3 ;

run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if segment_c = 3 then segment_c = 2 ;
run ;
/* ================================================================================= */
/* Retraitement des variables retraités en apprentissage */

/*Incident_passe_c*/

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if incident_passe_c = 1 then incident_passe_c = 0 ;
run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if incident_passe_c = 2 then incident_passe_c = 1 ;
run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if incident_passe_c = 3 then incident_passe_c = 2 ;
run ;

/*incident_passe_C 2 */
data pcs.oot_modele ;
	set pcs.oot_modele ;
	if incident_passe_C = 1 then incident_passe_C = 0 ;
run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if incident_passe_C = 2 then incident_passe_C = 1 ;
run ;

/* Vérification  */
proc freq data= pcs.oot_modele ;
tables incident_passe_c*DDefaut_NDB;
run ;

/*SOLD_DIB_C */

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SOLD_DIB_C = 1 then SOLD_DIB_C = 0 ;
run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SOLD_DIB_C = 2 then SOLD_DIB_C = 1 ;
run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SOLD_DIB_C = 3 then SOLD_DIB_C = 2 ;
run ;

/* Vérification sur la table la plus récente */
proc freq data= pcs.oot_modele ;
tables SOLD_DIB_C*DDefaut_NDB;
run ;

/* ================================================================================= */

/* Modèle sur echantillon OOT */

proc logistic data = pcs.oot_modele ;
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

/* ================================================================================= */
/* Retraitement des classes instable en terme de significativité sur les différents 
échantillons : */

/* MVT_AFF_12M_C*/
data pcs.oot_modele ;
	set pcs.oot_modele ;
	if MVT_AFF_12M_C = 1 then MVT_AFF_12M_C = 0 ;
run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if MVT_AFF_12M_C = 2 then MVT_AFF_12M_C = 1 ;
run ;

proc freq data= pcs.oot_modele ;
tables MVT_AFF_12M_C*DDefaut_NDB;
run ;

/* SFMois_AG_C */
data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SFMois_AG_C = 1 then SFMois_AG_C = 0 ;
run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SFMois_AG_C = 2 then SFMois_AG_C = 1 ;
run ;


data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SFMois_AG_C = 3 then SFMois_AG_C = 2 ;
run ;

data pcs.oot_modele ;
	set pcs.oot_modele ;
	if SFMois_AG_C = 4 then SFMois_AG_C = 3 ;
run ;

proc freq data= pcs.oot_modele ;
tables SFMois_AG_C*DDefaut_NDB;
run ;

proc logistic data = pcs.oot_modele ;
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

/*D de Sommer/ Indice de Gini : 0.805
Aire sous la courbe ROC, AUC : 0.903
AIC : 6753.959 */


/********** Fin du code **********/