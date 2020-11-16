#!/usr/bin/env bash

# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### ARGUMENTS
## ARGUMENTS OBLIGATOIRES | MANDATORY ARGUMENTS
# Arguments à placer après la commande d'exécution du script pour qu'il s'exécute.
ARG_LANG=$2         # Premier argument : La langue dans laquelle exécuter le script
ARG_USERNAME=$1		# Deuxième argument : Le nom du compte de l'utilisateur.
ARG_INSTALL=$3      # Troisième argument : Le type de paquets à installer (version SIO (travail) ou personnelle (travail + logiciels pour un usage presonnel)).

# -----------------------------------------------

## ARGUMENTS OPTIONNELS | OPTIONAL ARGUMENTS
ARG_DEBUG=$4		# Argument servant d'utilitaire de déboguage.

ARG_DEBUG_VAL="debug"   # Valeur de l'agument de déboguage.
ARGV=("$@")             # Tableau d'arguments.

# -----------------------------------------------
