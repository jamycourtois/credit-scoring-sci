/* ================================================================================= */
/* PARTIE 1 : Construction de la base d'analyse                                                    */
/* ================================================================================= */

/*Description de la base de données */

proc contents data = sasuser.base_sci ;
	title Résumé base de données ;
run ;

/* Echantillongae */

Proc sort data = sasuser.base_sci out = base_pre_split; by datdelhis DDefaut_NDB;
run ;

Proc surveyselect data = base_pre_split
	method = SRS
	out = base_split outall
	samprate = 70.00
	seed = 123;
	strata DATDELHIS DDefaut_NDB;
run;

proc freq data = base_split; tables DDefaut_NDB / Missing ; run;
proc freq data = base_split (Where = (Selected = 0)) ; tables DDefaut_NDB / Missing; run;
proc freq data = base_split (Where = (Selected = 1)) ; tables DDefaut_NDB / Missing; run;

DATA b_train b_test ;
		SET base_split ;

		IF Selected=1 THEN OUTPUT b_train ;
		else if Selected=0 THEN OUTPUT b_test ;

	RUN ;
	
/* ================================================================================= */
/* PARTIE 1 : Construction de la base d'analyse FIN                                                   */
/* ================================================================================= */


/* ================================================================================= */
/* PARTIE 2 : Nettoyage Base apprentissage                                               */
/* ================================================================================= */

/* Valeurs manquantes */

/************************************Variables Quantis******************************************/

proc format;
    value CheckMiss
        . = 'Manquant'       
        other = 'Renseigné'; 
run;

proc freq data=b_train;
	format _numeric_ CheckMiss.; 
	tables ANC_ENTR /* Valeurs Manquantes : 18 soit 0.03%  */
	       ANC_RELA_LCL /* Valeurs Manquantes : 18 soit 0.03%  */
	       Engagement_prorat
	       MVT_AFF_12M /* Valeurs Manquantes : 18 soit 0.03%  */
	       NBJDEPDP /* Valeurs Manquantes : 18 soit 0.03%  */
	       NBJRDB_AT /* Valeurs Manquantes : 18 soit 0.03%  */
	       NB_JR_DEB /* Valeurs Manquantes : 18 soit 0.03%  */
	       NJRS_DEP_DA /* Valeurs Manquantes : 18 soit 0.03%  */
	       SFMois_AG /* Valeurs Manquantes : 18 soit 0.03%  */
	       SOLD_CRE /* Valeurs Manquantes : 18 soit 0.03%  */
	       SOLD_DIB/ missing nocum; 
run;

/* On soupsonne que les variables pour lesquelles ont observent ces valeurs manquantes
concerne à chaque fois les même individus */

data train_clean ;
	set b_train;
	if nmiss(ANC_RELA_LCL) > 0 then delete;
run;

/* Controles pour les valeurs manquantes + etudes distributions des variables */

proc means data = train_clean nmiss mean q1 median q3 std cv skew kurt min max maxdec=2 ;
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

/* Hypothèse vérifiée */


/* Nombre de valeurs négatives pour NJRS_DEP_DA */
/* 1. On crée un format pour regrouper tout ce qui est positif */
proc format;
    value CheckSigne
        0 - high = "Valeurs Correctes (>=0)"; 
        /* On ne définit PAS les négatifs ici ) par défaut */
run;

/* 2. On lance la fréquence sur TOUTE la base  */
proc freq data=train_clean;
    title "Comparaison : Valeur Abérrante vs Reste de la population";
    
    /* On applique le format pour regrouper les 70 000 bonnes lignes en une seule ligne */
    tables NJRS_DEP_DA / missing;
    
    format NJRS_DEP_DA CheckSigne.;
run;
title; 

/* On trouve une valeur négative, cela concerne donc 1 observation sur un échantillon de 
70 000 observation, on peut supprimer cette observation. */

/* Suppprésion de l'observation prenant la valeur abbérante */

data train_clean;
	set train_clean;
	if NJRS_DEP_DA < 0 then delete;
run;

proc means data = train_clean min ;
	var NJRS_DEP_DA ;
run ;

/************************************Variables Qualis******************************************/


proc freq data = train_clean ;
	format _numeric_ CheckMiss.;
	tables
		CODETAJUR
		CODNAF2
		SEC_DER
		Depassement
		Depassement_M1 /* Valeurs Manquantes : 621 (619) soit 0.89% (0.88%) */
		Depassement_M2 /* Valeurs Manquantes : 1156(1154) soit 1.65%  (1.65%) */
		Depassement_M3 /* Valeurs Manquantes : 1708 (1706) soit 2.44% (2.44%) */
		Impaye
		Impaye_M1 /* Valeurs Manquantes : 621 (619) soit 0.89% (0.88%)  */
		Impaye_M2 /* Valeurs Manquantes : 1156 (1154)soit 1.65% (1.65%) */
		Impaye_M3 /* Valeurs Manquantes : 1708 (1706) soit 2.44% (2.44%) */
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
		NDB_1 /* Valeurs Manquantes : 645 (643) soit 0.92% (0.92%)  */
		NDB_2 /* Valeurs Manquantes : 1180 (1177) soit 1.69% (1.68%) */
		NDB_3 /* Valeurs Manquantes : 1728 (1725) soit 2.47% (2.46%) */
		NDB_4 /* Valeurs Manquantes : 2239 (2235)  soit 3.2% (3.19%) */
		NDB_5 /* Valeurs Manquantes : 2807 (3802) soit 4.01% (4.00%) */
		NDB_6 /* Valeurs Manquantes : 3420 (3413) soit 4.88% (4.88%) *// missing nocum; ;
run ;


/* (HYPOTHESE!) Ces individus on une ancienneté inférieur à 1an chez LCL.*/

/* Test hypothèse */

/* ÉTAPE 1 : Création des Groupes et des Indicateurs de Manquants */
data varcat_manquantes;
	set train_clean;
    
    /* 1. Création de la variable de GROUPE (Discrétisation) */
    length Groupe_Anciennete $15.;
    
    if ANC_RELA_LCL = 0 then Groupe_Anciennete = 'Ancienneté < 1an';
    else if ANC_RELA_LCL = 1 then Groupe_Anciennete = 'Ancienneté = 1an ';
    else Groupe_Anciennete = 'Ancienneté > 1 an';

    /* 2. Création des drapeaux (Flags) : 1 si manquant, 0 sinon */
    /* Utilisez la fonction missing() qui marche pour le numérique et le texte */
    
    /* Dépassement */
    M_Dep_M1 = missing(Depassement_M1);
    M_Dep_M2 = missing(Depassement_M2);
    M_Dep_M3 = missing(Depassement_M3);
    
    /* Impayés */
    M_Imp_M1 = missing(Impaye_M1);
    M_Imp_M2 = missing(Impaye_M2);
    M_Imp_M3 = missing(Impaye_M3);
    
    /* NDB (Nombre de Jours Débiteurs / incidents) */
    M_NDB_1 = missing(NDB_1);
    M_NDB_2 = missing(NDB_2);
    M_NDB_3 = missing(NDB_3);
    M_NDB_4 = missing(NDB_4);
    M_NDB_5 = missing(NDB_5);
    M_NDB_6 = missing(NDB_6);
run;

/* ÉTAPE 2 : Le TableauX Croisé */

title "Répartition de l'origine des valeurs manquantes en fonction de l'ancienneté en %";
proc tabulate data=varcat_manquantes;
    
    /* On définit la variable qui fait les colonnes */
    class Groupe_Anciennete; 
    
    /* Les variables à analyser (Vos indicateurs de manquants) */
    /* VAR indique à SAS qu'on va faire des sommes dessus */
    var M_Dep_M1-M_Dep_M3 
        M_Imp_M1-M_Imp_M3 
        M_NDB_1-M_NDB_6;
        
    /* Construction du Tableau */
    /* LIGNES : La liste de toutes vos variables */
    table (M_Dep_M1 M_Dep_M2 M_Dep_M3 
           M_Imp_M1 M_Imp_M2 M_Imp_M3 
           M_NDB_1 M_NDB_2 M_NDB_3 M_NDB_4 M_NDB_5 M_NDB_6),
           
    /* COLONNES : Les Groupes d'Ancienneté */
    /* ROWPCTSUM : Calcule le % de la ligne basé sur la somme des 1 */
    /* f=percent8.1 : Pour un affichage propre en % */
           (Groupe_Anciennete) * ROWPCTSUM * f=8.1;
run;
title;
/* L'hypothèse évoqué plutot est validé */


/* Imputations de nouvelles valeurs aux variables manquantes */

data train_clean;
	set train_clean; 
	array vect_ndb (*) NDB_1 NDB_2 NDB_3 NDB_4 NDB_5 NDB_6;
	do i = 1 to dim(vect_ndb);
	  if vect_ndb(i) = . then vect_ndb(i) = 2;
	    end;
		drop i;
run;

data train_clean;
	set train_clean; 
	array vect_IxD (*) Depassement_M1 Depassement_M2 Depassement_M3 Impaye_M1 Impaye_M2 Impaye_M3 ;
	do i = 1 to dim(vect_IxD);
	  if vect_IxD(i) = . then vect_IxD(i) = 3;
	    end;
		drop i;
run;

/* Verification */

proc freq data = train_clean ;
	tables Depassement_M1
		Depassement_M2
		Depassement_M3
		Impaye_M1
		Impaye_M2
		Impaye_M3
		NDB_1
		NDB_2
		NDB_3
		NDB_4
		NDB_5
		NDB_6 ;
run ;

/* Statistiques descriptives variables qualitatives  */


proc freq data = train_clean NLEVELS; 
    tables 
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
        NDB_6 / noprint; 
run ;

/* Calcul du MODE pour les variables numériques */
proc means data = train_clean N NMISS MODE maxdec=0; 
    var
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
        Top_pp  /* Variable categorielle avec une seul modalité => à supprimer
				car ne peut pas discriminer */
        Top_pret_perso /* Variable categorielle avec une seul modalité => à supprimer
				car ne peut pas discriminer */
        Top_pro_lib 
        Top_sci /* Variable categorielle avec une seul modalité => à supprimer
				car ne peut pas discriminer */
        segment 
        NDB_1 
        NDB_2 
        NDB_3 
        NDB_4 
        NDB_5 
        NDB_6 ;
run ;
/* Suppression des variables inutiles (Top_pp,Top_pret_perso,Top_sci)*/

data train_clean ;
	set train_clean ;
	drop Top_pp Top_pret_perso Top_sci ;
run ;

/* Vérification de la présence de doublons */


Proc sql ;
	create table doublons
	as select id_client, datdelhis, count (*) as nb_dossier
	from train_clean 
	group by id_client, datdelhis
	having nb_dossier > 1;
quit ;

/* Résultats : Aucun doublons */


/* ================================================================================= */
/* PARTIE 2 : Nettoyage Base apprentissage Fin                                                */
/* ================================================================================= */

data train_cleanf ;
	set train_clean ;
run ;

/* Sauvegarde de la base nettoyer dans librairie perso */

libname pcs "/home/u64383858/Crédit scoring" ;
data pcs.train_cleanf ;
	set train_cleanf ;
run ;


/* ================================================================================= */
/* PARTIE 3 : Duplication du nettoyage Base Test                                              */
/* ================================================================================= */


/************************************Variables Quantis******************************************/

proc format;
    value CheckMiss
        . = 'Manquant'       
        other = 'Renseigné'; 
run;

proc freq data=b_test;
	format _numeric_ CheckMiss.; 
	tables ANC_ENTR /* Valeurs Manquantes : 6 soit 0.02%  */
	       ANC_RELA_LCL /* Valeurs Manquantes : 6 soit 0.02%  */
	       Engagement_prorat
	       MVT_AFF_12M /* Valeurs Manquantes : 6 soit 0.02%  */
	       NBJDEPDP /* Valeurs Manquantes : 6 soit 0.02%  */
	       NBJRDB_AT /* Valeurs Manquantes : 6 soit 0.02%  */
	       NB_JR_DEB /* Valeurs Manquantes : 6 soit 0.02%  */
	       NJRS_DEP_DA /* Valeurs Manquantes : 6 soit 0.02%  */
	       SFMois_AG /* Valeurs Manquantes : 6 soit 0.02%  */
	       SOLD_CRE /* Valeurs Manquantes : 6 soit 0.02%  */
	       SOLD_DIB/ missing nocum; 
run;

/* On s'assure que le pourcentage de valeurs maquantes n'a pas explosé et que 
le split à été correctement réaliser avant d'appliquer le meme traitement pour les variables 
quantitatives */

data test_clean ;
	set b_test;
	if nmiss(ANC_RELA_LCL) > 0 then delete;
run;

/************************************Variables Qualis******************************************/

/* Suppression des variables inutiles (Top_pp,Top_pret_perso,Top_sci)*/

data test_clean ;
	set test_clean ;
	drop Top_pp Top_pret_perso Top_sci ;
run ;

/* Imputations de nouvelles valeurs aux variables manquantes */

data test_clean;
	set test_clean; 
	array vect_ndb (*) NDB_1 NDB_2 NDB_3 NDB_4 NDB_5 NDB_6;
	do i = 1 to dim(vect_ndb);
	  if vect_ndb(i) = . then vect_ndb(i) = 2;
	    end;
		drop i;
run;

data test_clean;
	set test_clean; 
	array vect_IxD (*) Depassement_M1 Depassement_M2 Depassement_M3 Impaye_M1 Impaye_M2 Impaye_M3 ;
	do i = 1 to dim(vect_IxD);
	  if vect_IxD(i) = . then vect_IxD(i) = 3;
	    end;
		drop i;
run;
/* Verification du bon fonctionnement de l'imputation */

proc freq data = test_clean ;
	tables Depassement_M1
		Depassement_M2
		Depassement_M3
		Impaye_M1
		Impaye_M2
		Impaye_M3
		NDB_1
		NDB_2
		NDB_3
		NDB_4
		NDB_5
		NDB_6 ;
run ;
/* OK */

/* Vérification de la présence de doublons */


Proc sql ;
	create table doublons
	as select id_client, datdelhis, count (*) as nb_dossier
	from test_clean 
	group by id_client, datdelhis
	having nb_dossier > 1;
	quit ;

/* Résultats : Aucun doublons */

/* Vérification pour les valeurs abérrantes */
proc means data=test_clean min;
	var ANC_ENTR        
	    ANC_RELA_LCL
	    Engagement_prorat 	    					 
	    NBJDEPDP
	    NBJRDB_AT
	    NB_JR_DEB       
	    MVT_AFF_12M 	    			  
	run;
	
	/* Variables ne devant etre que strictement négatives */
	
	proc means data=test_clean max;
	var SOLD_DIB ; /* C'est l'argent que le client doit à la banque, raisonnement inverse à SOLD_CRE */
run ;

/* Pas de problèmes */

/* ================================================================================= */
/* PARTIE 3 : Duplication du nettoyage Base Test Fin                                                */
/* ================================================================================= */


data test_cleanf ;
	set test_clean ;
run ;
/* Sauvegarde de la base nettoyer dans librairie perso */

data pcs.test_cleanf ;
	set test_cleanf ;
run ;


/********** Fin du code **********/