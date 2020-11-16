#!/usr/bin/env bash

# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### COULEURS | COLORS
## ENCODAGES | ENCODING
# Encodage des couleurs pour mieux lire les étapes de l'exécution du script.
COL_BLUE=$(tput setaf 4)		# Bleu foncé	--> Couleur des headers à n'écrire que dans le fichier de logs.
COL_CYAN=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers.
COL_GREEN=$(tput setaf 82)		# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape.
COL_RED=$(tput setaf 196) 	  	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape.
COL_RESET=$(tput sgr0)     		# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal.
COL_YELLOW=$(tput setaf 226)	# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes.

# -----------------------------------------------
