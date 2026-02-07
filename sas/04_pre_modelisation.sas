/* ================================================================================= */
/* PARTIE 1 : Stabilité en risque et stabilité en volume (echantillon apprentissage)                                                */
/* ================================================================================= */


data pcs.train_modele; 
set pcs.train_varx_conforme;
length trim $6. ; 

if Datdelhis in (202301 202302 202303) then trim = "2023Q1"; 	
if Datdelhis in (202304 202305 202306) then trim = "2023Q2"; 		
if Datdelhis in (202307 202308 202309) then trim = "2023Q3"; 		
if Datdelhis in (202310 202311 202312) then trim = "2023Q4"; 	
run; 	
	
/* Changer la variable à chaque fois */

%macro suivi_stabilites(liste_trim=,var=) ;
		
		%let i=1 ;
		%let trim=%scan(&liste_trim.,&i.," ") ;

		%do %while (&trim. ne ) ;

			ods output OneWayFreqs=rep&i. ;
				proc freq data=pcs.train_modele ; 
					tables &var. / missing ;
					where trim="&trim." ;
				run ;
			ods output close ;

			ods output CrossTabFreqs=Txdef&i. ;
				proc freq data=pcs.train_modele ; 
					tables &var.*Ddefaut_NDB / missing ;
					where trim="&trim." ;
				run ;
			ods output close ;

			data rep&i. ;
				set rep&i. (keep=&var. Frequency Percent) ;
				trim="&trim." ;
			run ;

			data Txdef&i. ;
				set Txdef&i. (keep=&var. Ddefaut_NDB Frequency RowPercent _Type_
								where=(_Type_="11" and Ddefaut_NDB=1)) ;
				trim="&trim." ;
			drop _type_ DDefaut_NDB ;
			run ;

			%if (&i.=1) %then %do ;
				data rep_&var. ;
					set rep&i. ;
				run ;
				data Txdef_&var. ;
					set  Txdef&i. ;
				run ;
			%end ;
			%else %do ;
				proc append base=rep_&var. data=rep&i. ; run ;
				proc append base=Txdef_&var. data=Txdef&i. ; run ;
			%end ;

			%let i=%eval(&i.+1) ;
			%let trim=%scan(&liste_trim.,&i.," ") ;
		%end ;

	%mend ;

	%suivi_stabilites(liste_trim=2023Q1 2023Q2 2023Q3 2023Q4,
						var= 
						 ) ;
ods output Association=association ;
	ods output ParameterEstimates=param ;


/* Exportation Excel des etudes de stabilité en risque et en volume */

%macro export_excel_graph(liste_vars=, outfile=);

    /* 1. Ouverture du fichier Excel */
    ods excel file="&outfile." 
        options(embedded_titles='yes' 
                sheet_interval='none' 
                autofilter='all'
                absolute_column_width='15'); /* Largeur de colonne propre */

    %let i = 1;
    %let cur_var = %scan(&liste_vars., &i., " ");

    /* Boucle sur chaque variable */
    %do %while (&cur_var. ne );

        /* --- ÉTAPE A : PRÉPARATION DES DONNÉES (PIVOT) --- */

        /* 1. VOLUME : On pivote pour avoir les modalités en colonnes */
        /* On trie d'abord par trimestre pour que l'axe temps soit correct */
        proc sort data=work.REP_&cur_var.; by trim &cur_var.; run;

        proc transpose data=work.REP_&cur_var. 
                       out=work.Wide_REP_&cur_var.(drop=_name_) 
                       prefix=Vol_Mod_; /* Préfixe pour les colonnes (ex: Vol_Mod_0) */
            by trim;        /* Les lignes seront les trimestres */
            id &cur_var.;   /* Les colonnes seront les modalités */
            var Percent;    /* La valeur à l'intérieur est le pourcentage */
        run;

        /* 2. RISQUE : On pivote le taux de défaut */
        proc sort data=work.TXDEF_&cur_var.; by trim &cur_var.; run;

        proc transpose data=work.TXDEF_&cur_var. 
                       out=work.Wide_TXDEF_&cur_var.(drop=_name_) 
                       prefix=Risk_Mod_; 
            by trim;
            id &cur_var.;
            var RowPercent; /* C'est ton Taux de Défaut */
        run;

        /* --- ÉTAPE B : EXPORT VERS EXCEL --- */

        /* Création de l'onglet pour la variable */
        ods excel options(sheet_interval="now" sheet_name="&cur_var.");

        title1 "Evolution des VOLUMES (%) - &cur_var.";
        title2 "Lignes = Trimestres | Colonnes = Modalités";
        proc print data=work.Wide_REP_&cur_var. noobs label;
        run;

        /* Petit saut de ligne visuel */
        ods excel options(sheet_interval="none");
        title; 

        title1 "Evolution du RISQUE (Taux Défaut %) - &cur_var.";
        title2 "Comparaison de la stabilité du risque par modalité";
        proc print data=work.Wide_TXDEF_&cur_var. noobs label;
        run;

        /* Nettoyage des tables temporaires */
        proc datasets lib=work nolist; 
            delete Wide_REP_&cur_var. Wide_TXDEF_&cur_var.; 
        quit;

        /* Variable suivante */
        %let i = %eval(&i.+1);
        %let cur_var = %scan(&liste_vars., &i., " ");
    %end;

    ods excel close;
    title; 

%mend;

/* --- LANCEMENT --- */
/* Rappel : Mets juste le nom du fichier, pas C:/... si tu es sur serveur */
%let chemin_export = /home/u64383858/Crédit scoring/Analyse_Stabilites.xlsx; 

%let mes_variables = NBJDEPDP_C
					SFMois_AG_C
					MVT_AFF_12M_C
					ANC_RELA_LCL_C
					SOLD_DIB_C
					segment_c
					Arrieres_adate_C
					incident_passe_C ; 

%export_excel_graph(liste_vars=&mes_variables., outfile=&chemin_export.);


/************************************ANC_RELA_LCL_C******************************************/
/* Retraiment*/

data pcs.train_modele ;
	set pcs.train_modele ;
	if ANC_RELA_LCL_C = 1 then ANC_RELA_LCL_C = 0 ;
run ;

data pcs.train_modele ;
	set pcs.train_modele ;
	if ANC_RELA_LCL_C = 2 then ANC_RELA_LCL_C = 1 ;
run ;

/* Vérification sur la table la plus récente */
proc freq data= pcs.train_modele ;
tables ANC_RELA_LCL_C*DDefaut_NDB;
run ;

/* Pas de problème */

/* Stabilité en risque et en volume sur ANC_RELA_LCL_C retraité */

%macro suivi_stabilites(liste_trim=,var=) ;
		
		%let i=1 ;
		%let trim=%scan(&liste_trim.,&i.," ") ;

		%do %while (&trim. ne ) ;

			ods output OneWayFreqs=rep&i. ;
				proc freq data=pcs.train_modele ; 
					tables &var. / missing ;
					where trim="&trim." ;
				run ;
			ods output close ;

			ods output CrossTabFreqs=Txdef&i. ;
				proc freq data=pcs.train_modele ; 
					tables &var.*Ddefaut_NDB / missing ;
					where trim="&trim." ;
				run ;
			ods output close ;

			data rep&i. ;
				set rep&i. (keep=&var. Frequency Percent) ;
				trim="&trim." ;
			run ;

			data Txdef&i. ;
				set Txdef&i. (keep=&var. Ddefaut_NDB Frequency RowPercent _Type_
								where=(_Type_="11" and Ddefaut_NDB=1)) ;
				trim="&trim." ;
			drop _type_ DDefaut_NDB ;
			run ;

			%if (&i.=1) %then %do ;
				data rep_&var. ;
					set rep&i. ;
				run ;
				data Txdef_&var. ;
					set  Txdef&i. ;
				run ;
			%end ;
			%else %do ;
				proc append base=rep_&var. data=rep&i. ; run ;
				proc append base=Txdef_&var. data=Txdef&i. ; run ;
			%end ;

			%let i=%eval(&i.+1) ;
			%let trim=%scan(&liste_trim.,&i.," ") ;
		%end ;

	%mend ;

	%suivi_stabilites(liste_trim=2023Q1 2023Q2 2023Q3 2023Q4,
						var= ANC_RELA_LCL_C
						 ) ;
ods output Association=association ;
	ods output ParameterEstimates=param ;

/* Exportation Excel */ 

/* --- ETAPE 1 : PIVOT DU VOLUME (Répartition) --- */
/* On trie d'abord pour être sûr que les trimestres sont dans l'ordre */
proc sort data=work.REP_ANC_RELA_LCL_C; 
    by trim ANC_RELA_LCL_C; 
run;

/* On transpose : Lignes=Trimestres, Colonnes=Modalités (0, 1, 2...) */
proc transpose data=work.REP_ANC_RELA_LCL_C 
               out=work.Wide_REP_ANC(drop=_name_) 
               prefix=Vol_Mod_; /* Les colonnes s'appelleront Vol_Mod_0, Vol_Mod_1... */
    by trim;
    id ANC_RELA_LCL_C;
    var Percent;
run;

/* --- ETAPE 2 : PIVOT DU RISQUE (Taux de défaut) --- */
proc sort data=work.TXDEF_ANC_RELA_LCL_C; 
    by trim ANC_RELA_LCL_C; 
run;

proc transpose data=work.TXDEF_ANC_RELA_LCL_C 
               out=work.Wide_TXDEF_ANC(drop=_name_) 
               prefix=Risk_Mod_; /* Les colonnes s'appelleront Risk_Mod_0, Risk_Mod_1... */
    by trim;
    id ANC_RELA_LCL_C;
    var RowPercent;
run;

/* --- ETAPE 3 : EXPORT VERS EXCEL --- */
/* Rappel : Juste le nom du fichier pour éviter l'erreur de chemin serveur */
%let nom_fichier = Analyse_ANC_RELA_LCL.xlsx;

ods excel file= "/home/u64383858/Crédit scoring/Analyse_ANC_RELA_LCL.xlsx"
    options(embedded_titles='yes' 
            sheet_interval='none' 
            sheet_name='ANC_RELA_LCL_C' /* Nom de l'onglet */
            autofilter='all'
            absolute_column_width='15');

    /* Tableau 1 : Volumes */
    title1 "Evolution des VOLUMES (%) - ANC_RELA_LCL_C";
    title2 "Chaque colonne est une modalité (0, 1, 2...)";
    proc print data=work.Wide_REP_ANC noobs label;
    run;

    /* Espace */
    ods excel options(sheet_interval="none");
    title; 

    /* Tableau 2 : Risque */
    title1 "Evolution du RISQUE (Taux Défaut %) - ANC_RELA_LCL_C";
    title2 "Stabilité du risque par modalité";
    proc print data=work.Wide_TXDEF_ANC noobs label;
    run;

ods excel close;

/* ================================================================================= */
/* PARTIE 2 : Multicolinéarité - V de Cramer Var ex (echantillon apprentissage)                                                */
/* ================================================================================= */

/* Variable Canditates aux modèles - V de Kramer */
ODS OUTPUT Chisq = chi2_var_modele ;
proc freq data = pcs.train_modele ;
	tables 			(NBJDEPDP_C
					SFMois_AG_C
					MVT_AFF_12M_C
					ANC_RELA_LCL_C
					SOLD_DIB_C
					segment_c
					Arrieres_adate_C
					incident_passe_C)*
					(NBJDEPDP_C
					SFMois_AG_C
					MVT_AFF_12M_C
					ANC_RELA_LCL_C
					SOLD_DIB_C
					segment_c
					Arrieres_adate_C
					incident_passe_C)/ MISSING chisq;
run ;

ODS OUTPUT CLOSE ;

Data V_Cramer_var_modele ;
set chi2_var_modele (Where = (Statistic = "V de Cramer") Keep = Table statistic Value) ;
V_Cramer = abs(Value) ;
Drop Statistic Value;
run;

/* Analyse du V de cramer entre les varaibles qualitatives et DDfaut_NDB */
ODS OUTPUT Chisq = chi2_VAREX_CIBLE ;
proc freq data = pcs.train_modele ;
	tables 			DDefaut_NDB*
					(NBJDEPDP_C
					SFMois_AG_C
					MVT_AFF_12M_C
					ANC_RELA_LCL_C
					SOLD_DIB_C
					segment_c
					Arrieres_adate_C
					incident_passe_C)/ MISSING chisq;
run ;

ODS OUTPUT CLOSE ;

Data V_Cramer_VAREX_CIBLE ;
set chi2_VAREX_CIBLE (Where = (Statistic = "V de Cramer") Keep = Table statistic Value) ;
V_Cramer = abs(Value) ;
Drop Statistic Value;
run;

Proc sort data = V_Cramer_VAREX_CIBLE  ; 
by descending V_Cramer ;
run ;

/*
Arrieres_adate_C	0.3369101909
segment_c	0.2628611797 (ne pas conserver)
incident_passe_C	0.2571069812
NBJDEPDP_C	0.2117459886 (ne pas conserver)
SFMois_AG_C	0.1375075626
SOLD_DIB_C	0.1242556296
MVT_AFF_12M_C	0.0553456557
ANC_RELA_LCL_C   0.0209842236
 */

/********** Fin du code **********/