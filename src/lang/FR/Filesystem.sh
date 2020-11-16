#!/usr/bin/env bash

## FONCTION "Makedir"
# Traitement
    MSG_MKDIR_PROCESSING_BEGIN="Traitement du dossier $(DechoN "$name") dans le dossier parent $(DechoN "$parent/")"
    MSG_MKDIR_PROCESSING_END_FAIL="Fin du traitement du dossier $(DechoE "$path/")"
    MSG_MKDIR_PROCESSING_END_SUCC="Fin du traitement du dossier $(DechoS "$path/")"


# Dossier non-vide
    MSG_MKDIR_NONEMPTY_1="Un dossier non-vide portant exactement le même nom ($(DechoN "$name")) se trouve déjà dans le dossier cible $(DechoN "$parent/")"
    MSG_MKDIR_NONEMPTY_2="Suppression du contenu du dossier $(DechoN "$path/")"
    
    MSG_MKDIR_NONEMPTY_SUCC="Suppression du contenu du dossier $(DechoS "$path/") effectuée avec succès."
    MSG_MKDIR_NONEMPTY_FAIL_1="Impossible de supprimer le contenu du dossier $(DechoE "$path/")"
    MSG_MKDIR_NONEMPTY_FAIL_2="Le contenu de tout fichier du dossier $(DechoE "$path/") portant le même nom qu'un des fichiers créés ou téléchargés sera écrasé"
    

# Dossier existant
    MSG_MKDIR_EXISTS="Le dossier $(DechoS "$path/") existe déjà dans le dossier $(DechoS "$parent/") et est vide"
    
    
# Dossier non-existant : Création
    MSG_MKDIR_CREATE_MSG="Création du dossier $(DechoN "$name") dans le dossier parent $(DechoN "$parent/")"
    
    MSG_MKDIR_CREATE_FAIL="LE DOSSIER $(DechoE "$name") N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER PARENT $(DechoE "$parent/")"
    MSG_MKDIR_CREATE_FAIL_ADV="Vérifiez si la commande $(DechoE "mkdir") existe."
    MSG_MKDIR_CREATE_SUCC="Le dossier $(DechoS "$name") a été créé avec succès dans le dossier $(DechoS "$parent/")"
    

# Dossier non-existant : Changement des droits
    MSG_MKDIR_CHMOD="Changement récursif des droits du nouveau dossier $(DechoN "$path/") de $(DechoN "$USER") en $(DechoN "$ARG_USERNAME")"
    
    MSG_MKDIR_CHMOD_SUCC="Les droits du dossier $(DechoS "$name") ont été changés avec succès de $(DechoS "$USER") en $(DechoS "$ARG_USERNAME")"
    MSG_MKDIR_CHMOD_FAIL_1="Impossible de changer les droits du dossier $(DechoE "$path/")"
    MSG_MKDIR_CHMOD_FAIL_2="Pour changer les droits du dossier $(DechoE "$path/") de manière récursive, utilisez la commande suivante"

    
## FONCTION "Makefile"
# Traitement
    MSG_MKFILE_PROCESSING_BEGIN="Traitement du fichier $(DechoN "$name")"
    MSG_MKFILE_PROCESSING_END_FAIL="Fin de traitement du ficier $(DechoE "$name")"
    MSG_MKFILE_PROCESSING_END_SUCC="Fin de traitement du fichier $(DechoS "$name")"
    
# Fichier non-vide
    MSG_MKFILE_NONEMPTY_1="Le fichier $(DechoN "$path") existe déjà et n'est pas vide"
    MSG_MKFILE_NONEMPTY_2="Écrasement des données du fichier $(DechoN "$path")"
    
    MSG_MKFILE_NONEMPTY_SUCC="Le contenu du fichier $(DechoS "$path") a été écrasé avec succès"
    MSG_MKFILE_NONEMPTY_FAIL_1="Le contenu du fichier $(DechoE "$path") n'a pas été écrasé"

    
## 
