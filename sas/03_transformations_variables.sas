/* ================================================================================= */
/* PARTIE 1 : Variable quantitaives - Dicrétisation (echantillon apprentissage)                                                */
/* ================================================================================= */		


/************************************NBJDEPDP******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_NBJDEPDP ;
	var NBJDEPDP ;
	ranks d_NBJDEPDP ; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_NBJDEPDP min max ;
	class d_NBJDEPDP;
	var NBJDEPDP ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_NBJDEPDP ;
proc freq data = deciles_NBJDEPDP  ;
	tables d_NBJDEPDP * DDefaut_NDB / missing chisq ;
	run ;
ods output close ; 

/* création de la variable découpée */
data pcs.train_varx_conforme ;
	set pcs.train_cleanf ;
	if NBJDEPDP = 0 then NBJDEPDP_C = 0 ;
	else NBJDEPDP_C = 1  ;
run ; 

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_NBJDEPDP_C ;
proc freq data = pcs.train_varx_conforme   ;
	tables NBJDEPDP_C* DDefaut_NDB / missing chisq ;
	run ;
ods output close ;

/************************************NJRS_DEP_DA******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_NJRS_DEP_DA ;
	var NJRS_DEP_DA ;
	ranks d_NJRS_DEP_DA ; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_NJRS_DEP_DA min max ;
	class d_NJRS_DEP_DA;
	var NJRS_DEP_DA ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_NJRS_DEP_DA ;
proc freq data = deciles_NJRS_DEP_DA  ;
	tables d_NJRS_DEP_DA * DDefaut_NDB / missing chisq ;
run ;
ods output close ; 

/* création de la variable découpée */
data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme  ;
	if NJRS_DEP_DA = 0 then NJRS_DEP_DA_C = 0 ;
	else if 1 <= NJRS_DEP_DA <= 3 then NJRS_DEP_DA_C = 1 ;
	else if NJRS_DEP_DA >= 4 then NJRS_DEP_DA_C = 2 ; 
run ;


/************************************NB_JR_DEB******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_NB_JR_DEB ;
	var NB_JR_DEB ;
	ranks d_NB_JR_DEB ; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_NB_JR_DEB min max ;
	class d_NB_JR_DEB;
	var NB_JR_DEB ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_NJRS_DEP_DA ;
proc freq data = deciles_NB_JR_DEB  ;
	tables d_NB_JR_DEB * DDefaut_NDB / missing chisq ;
	run ;  
ods output close ;

/* création de la variable découpée */
data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ;
	if NB_JR_DEB = 0 then NB_JR_DEB_C = 0 ;
	else if 1 <= NB_JR_DEB <= 4 then NB_JR_DEB_C = 1 ;
	else if NB_JR_DEB >= 5 then NB_JR_DEB_C = 2 ; 
run ;


/************************************SOLD_DIB******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_SOLD_DIB ;
	var SOLD_DIB ;
	ranks d_SOLD_DIB ; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_SOLD_DIB min max ;
	class d_SOLD_DIB;
	var SOLD_DIB ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_SOLD_DIB ;
proc freq data = deciles_SOLD_DIB  ;
	tables d_SOLD_DIB * DDefaut_NDB / missing chisq ;
run ;
ods output close ;

/* création de la variable découpée */
data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ;
	if SOLD_DIB = 0 then SOLD_DIB_C = 0 ;
	else if SOLD_DIB >= -5573 then SOLD_DIB_C = 1 ;
	else if SOLD_DIB >= -73780 then SOLD_DIB_C = 2 ; 
	else SOLD_DIB_C = 3 ;
run ;


/************************************SFMois_AG******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_SFMois_AG ;
	var SFMois_AG ;
	ranks d_SFMois_AG ; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_SFMois_AG min max ;
	class d_SFMois_AG;
	var SFMois_AG ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_SFMois_AG ;
proc freq data = deciles_SFMois_AG  ;
	tables d_SFMois_AG * DDefaut_NDB / missing chisq ;
run ;
ods output close ;

/* création de la variable découpée */

data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ;
	if SFMois_AG <= 2100 then SFMois_AG_C = 4 ;
	else if SFMois_AG <= 82600 then SFMois_AG_C = 3 ;
	else if SFMois_AG <= 163300 then SFMois_AG_C = 2 ;
	else if SFMois_AG > 937500 and SFMois_AG <= 4389600 then SFMois_AG_C = 0 ;
	else SFMois_AG_C = 1 ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_SFMois_AG_C ;
proc freq data = pcs.train_varx_conforme   ;
	tables SFMois_AG_C* DDefaut_NDB / missing chisq ;
	run ;
ods output close ;


/************************************SOLD_CRE******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_SOLD_CRE ;
	var SOLD_CRE ;
	ranks d_SOLD_CRE ; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_SOLD_CRE min max ;
	class d_SOLD_CRE;
	var SOLD_CRE ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_SOLD_CRE ;
proc freq data = deciles_SOLD_CRE  ;
	tables d_SOLD_CRE * DDefaut_NDB / missing chisq ;
run ;
ods output close ;

/* création de la variable découpée */

data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ;
	if SOLD_CRE <= 582141 then SOLD_CRE_C = 4 ;
	else if SOLD_CRE <= 2043078 then SOLD_CRE_C = 3 ;
	else if SOLD_CRE <= 3917955 then SOLD_CRE_C = 2 ;
	else if SOLD_CRE > 11458936 and SOLD_CRE <= 143026254 then SOLD_CRE_C = 0 ;
	else SOLD_CRE_C = 1 ;
run ;


/************************************MVT_AFF_12M******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_MVT_AFF_12M ;
	var MVT_AFF_12M;
	ranks d_MVT_AFF_12M ; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_MVT_AFF_12M min max ;
	class d_MVT_AFF_12M;
	var MVT_AFF_12M ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_MVT_AFF_12M ;
proc freq data = deciles_MVT_AFF_12M  ;
	tables d_MVT_AFF_12M * DDefaut_NDB / missing chisq ;
run ;
ods output close ;

/* création de la variable découpée */

data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ;
	if MVT_AFF_12M <= 42691 then MVT_AFF_12M_C = 2 ;
	else if MVT_AFF_12M > 188333 and MVT_AFF_12M <= 1082150 then MVT_AFF_12M_C = 0 ;
	else MVT_AFF_12M_C = 1 ;
run ;


/************************************ANC_RELA_LCL******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_ANC_RELA_LCL ;
	var ANC_RELA_LCL;
	ranks d_ANC_RELA_LCL ; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_ANC_RELA_LCL min max ;
	class d_ANC_RELA_LCL;
	var ANC_RELA_LCL ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_ANC_RELA_LCL ;
proc freq data = deciles_ANC_RELA_LCL  ;
	tables d_ANC_RELA_LCL * DDefaut_NDB / missing chisq ;
run ;
ods output close ;

/* création de la variable découpée */

data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ;
	if ANC_RELA_LCL <= 19 then ANC_RELA_LCL_C = 2 ;
	else if ANC_RELA_LCL <= 25 then ANC_RELA_LCL_C = 1 ;
	else ANC_RELA_LCL_C = 0 ;
run ;


/************************************NBJRDB_AT******************************************/
/* Decoupage en X classe */

proc rank data = pcs.train_cleanf groups = 10 out = deciles_NBJRDB_AT ;
	var NBJRDB_AT;
	ranks d_NBJRDB_AT; 
run ;

/* Pour avoir les bornes selon la valeur de la variable, par classe */
proc means data = deciles_NBJRDB_AT min max ;
	class d_NBJRDB_AT;
	var NBJRDB_AT ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_d_NBJRDB_AT ;
proc freq data = deciles_NBJRDB_AT  ;
	tables d_NBJRDB_AT * DDefaut_NDB / missing chisq ;
run ;
ods output close ;

/* création de la variable découpée */

data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ;
	if NBJRDB_AT = 0 then NBJRDB_AT_C = 0 ;
	else NBJRDB_AT_C = 1 ;
run ;

/* Observation du taux de défaut, afin de déterminer les regroupements */
ods output CrossTabFreqs = Freq_NBJRDB_AT_C ;
proc freq data = pcs.train_varx_conforme   ;
	tables NBJRDB_AT_C* DDefaut_NDB / missing chisq ;
	run ;
ods output close ;

/************************************V de Cramer ******************************************/

/* Suite à la discrétisation de nos variables, nous allons mobiliser la statistique du V de Cramer afin d'arbitrer 
entre les variables que nous devous conserver pour celles ou nous avons identier des 
coefficients de corrélation élevé.*/

/* Calcul du V de Cramer pour les variables du premier groupe avec la variable cible */

/* Groupe 1 : SFMois_AG_C, MVT_AFF_12M_C, SOLD_CRE_C */

ODS OUTPUT Chisq = chi2g1 ;
proc freq data = pcs.train_varx_conforme ;
	tables DDefaut_NDB *
		(SFMois_AG_C
		 MVT_AFF_12M_C
		 SOLD_CRE_C)/ MISSING chisq;
run ;

ODS OUTPUT CLOSE ;

Data Chi2_V_Cramerg1 ;
set chi2g1 (Where = (Statistic = "V de Cramer") Keep = Table statistic Value) ;
V_Cramer = abs(Value) ;
Drop Statistic Value;
run;

Proc sort data = Chi2_V_Cramerg1  out = select_varg1 ; by descending V_Cramer ;
run ;

/* Calcul du V de Cramer pour les variables du premier groupe avec la variable cible */

/* Groupe 2 :NBJDEPDP_C , NB_JR_DEB_C, NJRS_DEP_DA_C */

ODS OUTPUT Chisq = chi2g2 ;
proc freq data = pcs.train_varx_conforme ;
	tables DDefaut_NDB *
		(NB_JR_DEB_C
		 NBJDEPDP_C
		 NJRS_DEP_DA_C)/ MISSING chisq;
run ;

ODS OUTPUT CLOSE ;

Data Chi2_V_Cramerg2 ;
set chi2g2 (Where = (Statistic = "V de Cramer") Keep = Table statistic Value) ;
V_Cramer = abs(Value) ;
Drop Statistic Value;
run;

Proc sort data = Chi2_V_Cramerg2  out = select_varg2 ; by descending V_Cramer ;
run ;

/*A ce stade, les variables encore candidates sont :

NBJDEPDP_C
SFMois_AG_C
MVT_AFF_12M_C
ANC_RELA_LCL_C
SOLD_DIB_C */


/* ================================================================================= */
/* PARTIE 2 : Variable qualitavtives - Regroupement (echantillon apprentissage)                                                */
/* ================================================================================= */



/************************************segment******************************************/
/* Observation du taux de défaut, afin de déterminer les regroupements */
PROC freq data = pcs.train_varx_conforme  ;
	tables segment* DDefaut_NDB / missing chisq ;
run ;

/* On observe ici que deux des modalités de la variable segment ne respecte pas la contrainte
de la proportion minal d'un groupe conditionnellement à l'echantillon de référence qui se doit
d'etre à 1 %. Ces modalités seront alors regroupé avec les modalités ayant un risque de tomber
en défaut balois similaire. */

/* regroupement */

data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ; 
	if segment in (2, 7, 8) then segment_c = 0 ;
	else if segment in (1, 5, 6) then segment_c = 1 ;
	else if segment = 4 then segment_c = 2 ;
	else if segment = 3 then segment_c = 3 ;

run ;

data pcs.train_varx_conforme ;
	set pcs.train_varx_conforme ;
	if segment_c = 3 then segment_c = 2 ;
run ;

proc freq data = pcs.train_varx_conforme ;
	tables segment_c *DDefaut_NDB / MISSING chisq; ;
run ;

/************************************Autres Var Quali******************************************/
proc freq data = test_clean ;
	tables (Depassement
		Depassement_M1
		Depassement_M2
		Depassement_M3
		Impaye
		Impaye_M1
		Impaye_M2
		Impaye_M3
		NDB_1
		NDB_2
		NDB_3
		NDB_4
		NDB_5
		NDB_6)*DDefaut_NDB;
run ;



/* Nous pensons jouer sur la nature des variables et sur la temporalité de celles-ci
afin de créer de nouveau croisement */


/************************************NDB_C******************************************/
data pcs.train_varx_conforme ;
    set pcs.train_varx_conforme ;

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

proc freq data = pcs.train_varx_conforme  ;
	tables NDB_C* DDefaut_NDB / missing chisq ;
run ;

/* non conforme en proportion minimal */

/************************************Arrieres_adate_C******************************************/

data pcs.train_varx_conforme ;
    set pcs.train_varx_conforme ; 

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

proc freq data = pcs.train_varx_conforme  ;
	tables Arrieres_adate_C* DDefaut_NDB / missing chisq ;
run ;

/* Confrome en proportion minimal */

/************************************Arrieres_passe_C******************************************/


data pcs.train_varx_conforme ;
    set pcs.train_varx_conforme ; 

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

proc freq data = pcs.train_varx_conforme  ;
	tables arrieres_passe_C* DDefaut_NDB / missing chisq ;
run ;

/* Confrome en proportion minimal */

/************************************incident_passe_C******************************************/

data pcs.train_varx_conforme ;
    set pcs.train_varx_conforme ;
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

proc freq data = pcs.train_varx_conforme  ;
	tables incident_passe_C* DDefaut_NDB / missing chisq ;
run ;

/* conforme en proportion minimal */

/* Les variables encore candidates ici sont : 

NBJDEPDP_C
SFMois_AG_C
MVT_AFF_12M_C
ANC_RELA_LCL_C
SOLD_DIB_C
segment_c
Arrieres_adate_C
incident_passe_C */

/********** Fin du code **********/

