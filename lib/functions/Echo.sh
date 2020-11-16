#!/usr/bin/env bash

# /////////////////////////////////////////////////////////////////////////////////////////////// #

## INCLUSION DES VARIABLES DU SCRIPT PRINCIPAL
# shellcheck source=../variables/colors.sh
source ../variables/colors.sh

# shellcheck source=../variables/filesystem.sh
source ../variables/filesystem.sh

# shellcheck source=../variables/colors.sh
source ../variables/text.sh


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### DÉFINITION DES VARIABLES LOCALES (CE FICHIER PEUT AINSI ËTRE RÉUTILISÉ DANS UN AUTRE PROJET EN NE MODIFIANT QUE LES VALEURS DES VARIABLES CI-DESSOUS) | DEFINING VARIABLES
COL_BLUE=$COL_BLUE
COL_CYAN=$COL_CYAN
COL_GREEN=$COL_GREEN
COL_RESET=$COL_RESET    # Couleur d'affichage de texte par défaut du terminal | Default terminal text display color
COL_RED=$COL_RED
COL_YELLOW=$COL_YELLOW

# Fichier de logs | Logs file
FILE_LOG_PATH=$FILE_LOG_PATH    # Chemin | Path

TXT_G_TAB=$TXT_G_TAB    # Texte en vert  + 2 chevrons | Green text
TXT_R_TAB=$TXT_R_TAB    # Texte en rouge + 2 chevrons | Red text
TXT_Y_TAB=$TXT_Y_TAB    # Texte en jaune + 1 chevron  | Yellow text


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### DÉFINITION DES FONCTIONS D'AFFICHAGE DE TEXTE | DEFINING TEXT DISPLAY FUNCTIONS

## FONCTIONS SANS REDIRECTIONS VERS UN FICHIER DE LOGS | FUNCTIONS WITHOUT REDIRECTIONS TOWARDS A LOGS FILE

# Fonctions servant à colorer d'une autre couleur une partie d'un texte (jeu de mots entre "déco(ration)" et "echo", suivi de la première lettre du nom du type de message (passage à une nouvelle sous-étape (N), d'échec (E) ou de succès (S))) |
# Functions used to color a part of text with another color (pun between "deco(ration)" and "echo", followed by the first letter of the message type name (moving to a new sub-step (N), error (E) or success (S))).
function Decho() { local string=$1; echo "$COL_CYAN$string$COL_RESET"; }    # Coloration d'une partie d'un simple message écrit via la commande "echo" | Colouring a part of a simple message written via the "echo" command.
function DechoE() { local string=$1; echo "$COL_CYAN$string$COL_RED"; }     # Message d'erreur | Error message
function DechoH() { local string=$1; echo "$COL_BLUE$string$COL_CYAN"; }    # Texte de header  | Header text
function DechoN() { local string=$1; echo "$COL_CYAN$string$COL_YELLOW"; }  # Message de changement de sous-étape | New sub-step move message
function DechoS() { local string=$1; echo "$COL_CYAN$string$COL_GREEN"; }   # Message de succès | Success message

# -----------------------------------------------

# Affichage d'un message sans redirections vers le fichier de logs.
function EchoNewstep() { local string=$1; echo "$TXT_Y_TAB $string$COL_RESET"; }   # Message de changement de sous-étape | New sub-step move message.
function EchoError() { local string=$1; echo "$TXT_R_TAB $string$COL_RESET"; }     # Message d'erreur | Error message
function EchoSuccess() { local string=$1; echo "$TXT_G_TAB $string$COL_RESET"; }   # Message de success | Success message

# -----------------------------------------------

# Affichage d'un message dont le temps de pause peut être choisi en deuxième argument | Displaying a message whose pause time can be chosen as second argument.
function EchoErrorTimer() { local string=$1; timer=$2; echo "$TXT_R_TAB $string$COL_RESET"; sleep "$timer"; }     # Message d'erreur | Error message
function EchoNewstepTimer() { local string=$1; timer=$2; echo "$TXT_Y_TAB $string$COL_RESET"; sleep "$timer"; }   # Message de changement de sous-étape | New sub-step move message.
function EchoSuccessTimer() { local string=$1; timer=$2; echo "$TXT_G_TAB $string$COL_RESET"; sleep "$timer"; }   # Message de success | Success message

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #

## FONCTIONS AVEC REDIRECTIONS VERS UN FICHIER DE LOGS UNIQUEMENT | FUNCTIONS WITH REDIRECTIONS TOWARDS A LOGS FILE ONLY

# Vérification de l'enregistrement d'une valeur dans la variable "$FILE_LOG_PATH" |
# Checking the recording of a value in the variable "$FILE_LOG_PATH".
function CheckLog()
{
    if test -z "$FILE_LOG_PATH"; then
        EchoErrorNoLog "No path provided for the log file."
        echo ""
        
        exit 1
    fi
}

# La fonction ci-dessus doit être appelée avant l'écriture du texte dans une des fonctions suivantes |
# The above function must be called before writing the text in one of the following functions.

# -----------------------------------------------


# Affichage d'un message en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs, selon sa couleur d'affichage, avec des chevrons et sans avoir à encoder la couleur au début et la fin de la chaîne de caractères |
# Display a message by redirecting standard and error outputs to the log file, according to its display color, with chevrons and without having to encode the color at the beginning and the end of the string
function EchoErrorLog() { local string=$1; CheckLog && echo "$TXT_R_TAB $string$COL_RESET" >> "$FILE_LOG_PATH"; sleep .5; }     # Message d'erreur | Error message
function EchoNewstepLog() { local string=$1; CheckLog && echo "$TXT_Y_TAB $string$COL_RESET" >> "$FILE_LOG_PATH"; sleep .5; }   # Message de changement de sous-étape | New sub-step moving message
function EchoSuccessLog() { local string=$1; CheckLog && echo "$TXT_G_TAB $string$COL_RESET" >> "$FILE_LOG_PATH"; sleep .5; }   # Message de succès | Success message

# -----------------------------------------------

# Affichage d'un message dont le temps de pause peut être choisi en deuxième argument | Displaying a message whose pause time can be chosen as second argument.
function EchoErrorTimerLog() { local string=$1; timer=$2; CheckLog && echo "$TXT_R_TAB $string$COL_RESET" >> "$FILE_LOG_PATH"; sleep "$timer"; }    # Message d'erreur | Error message
function EchoNewstepTimerLog() { local string=$1; timer=$2; CheckLog && echo "$TXT_Y_TAB $string$COL_RESET" >> "$FILE_LOG_PATH"; sleep "$timer"; }  # Message de changement de sous-étape | New sub-step move message.
function EchoSuccessTimerLog() { local string=$1; timer=$2; CheckLog echo "$TXT_G_TAB $string$COL_RESET" >> "$FILE_LOG_PATH"; sleep "$timer"; }     # Message de success | Success message

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #

## FONCTIONS AVEC REDIRECTIONS VERS LE TERMINAL ET UN FICHIER DE LOGS | FUNCTIONS WITH REDIRECTIONS TOWARDS THE TERMINAL AND A LOG FILE

# Affichage d'un message en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs, selon sa couleur d'affichage, avec des chevrons et sans avoir à encoder la couleur au début et la fin de la chaîne de caractères |
# Display a message by redirecting standard and error outputs to the log file, according to its display color, with chevrons and without having to encode the color at the beginning and the end of the string
function EchoErrorTee() { local string=$1; CheckLog && echo "$TXT_R_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep .5; }     # Message d'erreur | Error message
function EchoNewstepTee() { local string=$1; CheckLog && echo "$TXT_Y_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep .5; }   # Message de changement de sous-étape | New sub-step moving message
function EchoSuccessTee() { local string=$1; CheckLog && echo "$TXT_G_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep .5; }   # Message de succès | Success message

# -----------------------------------------------

# Affichage d'un message dont le temps de pause peut être choisi en deuxième argument | Displaying a message whose pause time can be chosen as second argument.
function EchoErrorTimerTee() { local string=$1; timer=$2; CheckLog && echo "$TXT_R_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep "$timer"; }    # Message d'erreur | Error message
function EchoNewstepTimerTee() { local string=$1; timer=$2; CheckLog && echo "$TXT_Y_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep "$timer"; }  # Message de changement de sous-étape | New sub-step move message.
function EchoSuccessTimerTee() { local string=$1; timer=$2; CheckLog echo "$TXT_G_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep "$timer"; }     # Message de success | Success message


# /////////////////////////////////////////////////////////////////////////////////////////////// #

## FONCTIONS DE SAUT DE LIGNE

# Redirection de la sortie de la commande "echo" dans le fichier de logs uniquement | Redirecting the output of the "echo" command to the log file only
function EchoLog() { CheckLog && echo "" >> "$FILE_LOG_PATH"; }

# Redirection de la sortie de la commande "echo" dans le fichier de logs et vers le terminal | Redirecting the output of the "echo" command to the log file and the terminal
function Newline() { CheckLog && echo "" | tee -a "$FILE_LOG_PATH"; }

