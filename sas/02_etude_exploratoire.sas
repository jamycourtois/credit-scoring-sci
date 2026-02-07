
/* ================================================================================= */
/* PARTIE 1 : Etude Exploratoire (echantillon apprentissage)                                                */
/* ================================================================================= */

/************************************Stats Des Uni******************************************/


/* Variable cible */

/*Stockages des proportions des modalitées de la variable cible */
proc freq data= pcs.train_cleanf noprint;
	tables DDefaut_NDB / out=prop_defaut;
run;

/* Graphique en Barre sur la variable cible */
proc sgplot data=prop_defaut NOBORDER;
	title "Distribution de la variable cible : DDefaut_NDB (en %)";
	vbarparm category=DDefaut_NDB response=PERCENT / datalabel;
	format PERCENT 6.2; 
	yaxis  label="Pourcentage (%)";
	styleattrs wallcolor=white;
	run;
title;

/* On est sur un portefeuille de client dit "low default" dans lequel la proportion
d'individu ayant fait défaut à 12 mois est de 0,88 % sur l'ensemble de notre base de donnée. 


/* SUIVI DES TAUX DE POSITIF PAR DATE DE DEMANDE */
	%MACRO suivi_taux_de_defaut_GLOBAL (liste_date=) ;
		%LET cpt=1 ;
		%LET date=%SCAN(&liste_date.,&cpt.," ") ;
		%DO %WHILE (&date. ne ) ;
			ODS OUTPUT OneWayFreqs=Freq ;
				PROC FREQ DATA=pcs.train_cleanf (WHERE=(datdelhis=&date.)) ;
					TABLES DDefaut_NDB  / missing ;
				RUN ;
			ODS OUTPUT CLOSE ;
			DATA Freq ;
				SET Freq (KEEP=Percent CumFrequency DDefaut_NDB where=(DDefaut_NDB=1)) ;
				date=&date. ;
				drop DDefaut_NDB ;
			RUN ;
			%IF (&cpt.=1) %THEN %DO ;
				DATA suivi_taux_positif ;
					SET Freq ;
				run ;
			%END ;
			%ELSE %DO ;
				PROC APPEND BASE= suivi_taux_positif  DATA=Freq ; RUN ;
			%END ;

			%LET cpt=%EVAL(&cpt.+1) ;
			%LET date=%SCAN(&liste_date.,&cpt.," ") ;
		%END ;

	%MEND ;

	%suivi_taux_de_defaut_GLOBAL (liste_date=202301 202302 202303 202304 202305 202306 202307 202308 202309 202310 202311 202312) ;

/* Graphique suivi des taux positif par date de demande */

/* Définition du titre du graphique */
title "Suivi de la proportion de défaut par date d'originition du prêt en 2023 (portefeuille clientèle SCI)";
proc sgplot data=suivi_taux_positif NOBORDER ;
	series x=date y=Percent / markers datalabel;
	yaxis min=0 max=1 label="Proportion de Défaut (%)" grid; 
	xaxis type=linear integer label="Année 2023";
run;
title;

/************************************Stats Des Multi******************************************/

/*Variables cible et quantitatives Kruskal-Wallis */	
		%MACRO liaison_var_cible_quanti (liste_var_cible=,liste_var_quanti=) ;
			
			%LET cpt=1 ;
			%LET var1=%SCAN(&liste_var_cible.,&cpt.," ") ;
			
			%DO %WHILE (&var1. ne ) ;

				ODS OUTPUT KruskalWallisTest= test_kruskal ;
					PROC NPAR1WAY wilcoxon DATA= pcs.train_cleanf  ;
						CLASS &var1. ;
						VAR &liste_var_quanti. ;
					RUN ;
				ODS OUTPUT CLOSE ;

				DATA test_kruskal;
					SET test_kruskal (KEEP=variable chiSquare Prob) ;
					LENGTH Variable_cible $20. ;
					Variable_cible="&var1." ;
				RUN ;

				%IF (&cpt.=1) %THEN %DO ;
					DATA sortie_testKW ;
						SET test_kruskal ;
					RUN ;
				%END ;
				%ELSE %DO ;
					PROC APPEND BASE= sortie_testKW data= test_kruskal ; RUN ;
				%END ;

			%LET cpt=%EVAL(&cpt.+1) ;
			%LET var1=%SCAN(&liste_var_cible.,&cpt.," ") ;
			%END ;

		%MEND ;

		%liaison_var_cible_quanti (liste_var_cible=DDefaut_NDB,
									liste_var_quanti=ANC_RELA_LCL
														ANC_ENTR
														Engagement_prorat
														MVT_AFF_12M
														NBJDEPDP
														NBJRDB_AT
														NB_JR_DEB
														NJRS_DEP_DA
														SFMois_AG
														SOLD_CRE
														SOLD_DIB ) ;

		PROC SORT DATA= sortie_testKW OUT= Liaison_cible_quanti ; BY DESCENDING chiSquare ; RUN ;

/* Matrice de corrélation (Pearson) - Variable Quantitative */

proc corr data = pcs.train_cleanf out = corr_quanti ;
	var ANC_RELA_LCL
		ANC_ENTR
		Engagement_prorat
		MVT_AFF_12M
		NBJDEPDP
		NBJRDB_AT
		NB_JR_DEB
		NJRS_DEP_DA
		SFMois_AG
		SOLD_CRE
		SOLD_DIB ;
run ;

/* Variable Cible et Qualitatives V de Kramer */
ODS OUTPUT Chisq = chi2 ;
proc freq data = pcs.train_cleanf ;
	tables DDefaut_NDB *
		(CODETAJUR
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
		Top_pro_lib
		segment
		NDB_1
		NDB_2
		NDB_3
		NDB_4
		NDB_5
		NDB_6)/ MISSING chisq;
run ;

ODS OUTPUT CLOSE ;

Data Chi2_V_Cramer ;
set chi2 (Where = (Statistic = "V de Cramer") Keep = Table statistic Value) ;
V_Cramer = abs(Value) ;
Drop Statistic Value;
run;

Proc sort data = Chi2_V_Cramer  out = Liaison_cible_quali ; by descending V_Cramer ;
run ;

Proc univariate data = Liaison_cible_quali ; VAR V_Cramer; Histogram V_Cramer; run ;

/* Après avoir finalisé l'etude exploratoire de la base de données, nous allons entammer 
la transformation de nos variables explicatives afin de les rendre conforme à l'utilisation 
de la régression logistique. Nous rappelons que suite à l'etude des liaisons de variables 
avec notre variable cible nous concervons les variables avec un pouvoir discriminatif 
satisfaisant. Les voicis :

Var quantis : MVT_AFF_12M, NBJDEPDP, NBJRDB_AT, NB_JR_DEB, NJRS_DEP_DA, SFMois_AG,
SOLD_CRE, SOLD_DIB, ANC_RELA_LCL

Var qualis : Depassement, Depassement_M1, Depassement_M2, Depassement_M3, Impaye ,Impaye_M1,
Impaye_M2, Impaye_M3, segment, NDB_1, NDB_2, NDB_3, NDB_4, NDB_5, NDB_6
													
A ce stade nous disposons de 24 variables potentielle pouvant intégrer notre modèle
pour un nombre de place compris entre 8 et 12 maximum. */

				
/********** Fin du code **********/