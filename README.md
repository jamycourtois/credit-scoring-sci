# Credit Scoring - Portefeuille SCI (LCL)

Projet de credit scoring réalisé dans le cadre du Master Econométrie Financière et Modélisation Quantitative (UPEC), sur des données bancaires réelles fournies par le LCL.

## Objectif

Construction d'un modèle de scoring de crédit par **régression logistique** pour prédire le défaut à 12 mois sur un portefeuille de clientèle SCI (*Société Civile Immobilière*), caractérisé par un taux de défaut faible (*low default portfolio* ~ 0.88%).

## Méthodologie

| Etape | Description | Fichier |
|-------|-------------|---------|
| 1 | **Nettoyage & Echantillonnage** — Split Train/Test stratifié (70/30), traitement des valeurs manquantes et aberrantes | `sas/01_nettoyage_train_test.sas` |
| 2 | **Analyse exploratoire** — Statistiques univariées et bivariées, tests de Kruskal-Wallis, V de Cramer, matrice de corrélation | `sas/02_etude_exploratoire.sas` |
| 3 | **Transformation des variables** — Discrétisation des variables quantitatives, regroupement des modalités qualitatives, croisement de variables (arriérés, incidents) | `sas/03_transformations_variables.sas` |
| 4 | **Pré-modélisation** — Analyse de stabilité en risque et en volume (par trimestre), tests de multicolinéarité (V de Cramer entre variables explicatives) | `sas/04_pre_modelisation.sas` |
| 5 | **Modélisation (Train)** — Régression logistique step-by-step, retraitement des modalités non significatives | `sas/05_modelisation_train.sas` |
| 6 | **Validation OOT** — Application du modèle sur l'échantillon Out-Of-Time (2024) | `sas/06_modelisation_oot.sas` |
| 7 | **Validation Test** — Application du modèle sur l'échantillon de test | `sas/07_modelisation_test.sas` |

## Résultats du modèle final

| Echantillon | Indice de Gini | AUC (ROC) | AIC |
|-------------|---------------|-----------|-----|
| **Train** | 0.761 | 0.881 | 5 015 |
| **Test** | 0.756 | 0.878 | 2 070 |
| **OOT** | 0.805 | 0.903 | 6 754 |

### Variables retenues dans le modèle final

- `Arrieres_adate_C` — Arriérés à date (impayés / dépassements)
- `incident_passe_C` — Historique d'incidents passés (arriérés + défauts externes BdF)
- `SFMois_AG_C` — Solde financier mensuel agrégé
- `SOLD_DIB_C` — Solde débiteur
- `MVT_AFF_12M_C` — Mouvements affectés sur 12 mois
- `segment_c` — Segment de clientèle

## Structure du projet

```
credit-scoring-sci/
├── README.md
├── rapport/
│   └── Projet_Credit_Scoring.pdf
└── sas/
    ├── 01_nettoyage_train_test.sas
    ├── 02_etude_exploratoire.sas
    ├── 03_transformations_variables.sas
    ├── 04_pre_modelisation.sas
    ├── 05_modelisation_train.sas
    ├── 06_modelisation_oot.sas
    └── 07_modelisation_test.sas
```

## Outils

- **SAS** (SAS OnDemand for Academics)
- **LaTeX** (rédaction du rapport)

## Confidentialité

Les données utilisées sont la propriété du LCL et ne sont pas incluses dans ce dépôt.

## Auteurs

- Jamy Courtois
- Dieudonné (co-auteur)
