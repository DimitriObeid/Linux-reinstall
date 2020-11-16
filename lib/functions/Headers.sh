#!/usr/bin/env bash

#### INCLUSION DES VARIABLES DU SCRIPT PRINCIPAL
# shellcheck source=../variables/colors.sh
source ../variables/colors.sh || echo "../variables/.sh : not found" && exit 1

# shellcheck source=../variables/filesystem.sh
source ../variables/filesystem.sh || echo "../variables/filesystem.sh : not found" && exit 1

# shellcheck source=../variables/text.sh
source ../variables/text.sh || echo "../variables/text.sh : not found" && exit 1


#### INCLUSION DES FONCTIONS | INCLUDING FUNCTIONS
# shellcheck source="Echo.sh"
source "Echo.sh"


#### DÉFINITION DES VARIABLES LOCALES | INCLUDING VARIABLES


## DÉFINITION DES FONCTIONS DE CRÉATION DE HEADERS
# Fonction de création et d'affichage de lignes selon le nombre de colonnes de la zone de texte du terminal.
function DrawLine()
{
	#***** Paramètres *****
	local line_color=$1			# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction.
	local line_char=$2			# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction.

	#***** Code *****
	# Définition de la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère.
	# Si la chaîne de caractère du paramètre $line_color (qui contient l'encodage de la couleur du texte) n'est pas vide,
	# alors on écrit l'encodage de la couleur dans le terminal, qui affiche la couleur, et non son encodage en texte.

	# L'encodage de la couleur peut être écrit via la commande "tput cols $encodage_de_la_couleur".
	# Elle est vide tant que le paramètre "$line_color" n'est pas passé en argument lors de l'appel de la fonction ET qu'une
	# valeur de la commande "tput setaf" ne lui est pas retournée.

	# Comme on souhaite écrire les caractères composant la ligne du header à la suite de la string d'encodage de la couleur, on utilise les options
	# '-n' (pas de sauts de ligne) et '-e' (interpréter les antislashs) de la commande "echo" pour ne pas faire un saut de ligne après la fin de la
	#  chaîne de caractères, pour écrire la prochaîne chaîne de caractères directement à la suite de la ligne.

	# Étant donné que toutes les colonnes de la ligne sont utilisées, les caractères suivants seront écris à la ligne, comme si un saut de ligne a été fait.
	if test "$line_color" != ""; then
		echo -ne "$line_color"
	fi

	# Affichage du caractère souhaité sur toute la ligne. Pour cela, en utilisant une boucle "for", on commence à la lire à partir
	# de la première colonne (1), puis, on parcourt toute la ligne jusqu'à la fin de la zone de texte du terminal. À chaque appel
	# de la commande "echo", un caractère est affiché et coloré selon l'encodage défini et écrit ci-dessus.

	# La variable 'i' de la boucle "for i in" a été remplacée par un underscore '_' pour que Shellcheck arrête d'envoyer un message d'avertissement
	# ("warning") en raison de la non-déclaration de la variable 'i', bien que cela ne change strictement rien lors de l'exécution du script.
	for _ in $(eval echo "{1..$TXT_COLS}"); do
		echo -n "$line_char"
	done

	# Définition (ici, réintialisation) de la couleur des caractères suivant le dernier caractère de la ligne du header
	# en utilisant le même bout de code que la première condition, pour écrire l'encodage de la couleur de base du terminal
	# (il est recommandé d'appeller la commande "tput sgr0" pour réinitialiser la couleur selon les options du profil
	# du terminal). Comme tout encodage de couleur, le texte brut ne sera pas affiché sur le terminal.

	# En pratique, La couleur des caractères suivants est déjà encodée quand ils sont appelés via une des fonctions d'affichage.
	# Cette réinitialisation de la couleur du texte n'est qu'une mini-sécurité permettant d'éviter d'avoir la couleur de l'invite de
	# commandes encodée avec la couleur des headers si l'exécution du script est interrompue de force avec la combinaison "CTRL + C"
	# ou mise en pause avec la combinaison "CTRL + Z", par exemple.
	if test "$line_color" != ""; then
        echo -ne "$COL_RESET"
	fi

	# Étant donné que l'on a utilisé l'option '-n' de la commande "echo", on effectue un saut de ligne.
	echo ""

	return
}

# Fonction de création de base d'un header (Couleur et caractère de ligne, couleur et chaîne de caractères).
function HeaderBase()
{
	#***** Paramètres *****
	local line_color=$1		# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction.
	local line_char=$2		# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction.
	local string_color=$3	# Définition de la couleur de la chaîne de caractères du header.
	local string=$4			# Chaîne de caractères affichée dans chaque header.
	local wait_t=$5			# Temps de pause après l'affichage du header/

	#***** Code *****
	echo ""

	DrawLine "$line_color" "$line_char"
	echo "$string_color" "##>" "$string$COL_RESET"
	DrawLine "$line_color" "$line_char"
	echo ""

	sleep "$wait_t"

	return
}

# Fonction d'affichage des headers lors d'un changement d'étape.
function HeaderStep()
{
	#***** Paramètre *****
	# Chaîne de caractères contenant la phrase à afficher.
	local string=$1

	# ***** Code *****
	HeaderBase "$COL_CYAN" "$TXT_HEADER_LINE_CHAR" "$COL_CYAN" "$string" "1.5" 2>&1 | tee -a "$FILE_LOG_PATH"

	return
}

# Fonction d'affichage de headers lors du passage à une nouvelle catégorie de paquets lors de l'installation de ces derniers.
function HeaderInstall()
{
	#***** Paramètre *****
	# Chaîne de caractères contenant la phrase à afficher.
	local string=$1

	# ***** Code *****
	HeaderBase "$COL_YELLOW" "$TXT_HEADER_LINE_CHAR" "$COL_GREEN" "$string" "1.5"  2>&1 | tee -a "$FILE_LOG_PATH"

	return
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger).
function HandleErrors()
{
	#***** Paramètres *****
	local return_code=$1       # Code de retour de la dernière commande lancée
	local error_string=$2            # Chaîne de caractères du type d'erreur à afficher.
	local advise_string=$3     # Chaîne de caractères affichants un conseil pour orienter l'utilisateur vers la meilleure solution en cas de problème.
    local lineno=$4            # Ligne à laquelle le message d'erreur s'est produite.

	# ***** Code *****
	if test "$return_code" -eq 0; then
        return
    else
        HeaderBase "$COL_RED" "$TXT_HEADER_LINE_CHAR" "$COL_RED" "$(EchoError "$MSG_HNDERR_FATAL") : $error_string" "1.5" 2>&1 | tee -a "$FILE_LOG_PATH"

        EchoErrorTee "$MSG_HNDERR_FATAL_HAP :" 2>&1 | tee -a "$FILE_LOG_PATH"
        EchoErrorTee "$error_string"
        Newline

        EchoErrorTee "$advise_string"
        Newline

        EchoErrorTee "$MSG_HNDERR_FATAL_LINE $lineno."
        Newline

        EchoErrorTee "$MSG_HNDERR_FATAL_STOP."
        Newline

        # TODO : Modifier la détection d'arguments
        # Si l'argument de débug n'est pas passé lors de l'exécution du script (donc un seul argument est passé).
        if test "$#" -eq 1; then
            # Si le fichier de logs se trouve toujours dans le dossier actuel (en dehors du dossier personnel de l'utilisateur).
            if test ! -f "$DIR_HOMEDIR/$FILE_LOG_NAME"; then
                mv -v "$FILE_LOG_PATH" "$DIR_HOMEDIR" 2>&1 | tee -a "$DIR_HOMEDIR/$FILE_LOG_NAME" || { EchoError "$MSG_HNDERR_MV_FAIL."; Newline; exit 1; }

                FILE_LOG_PATH="$DIR_HOMEDIR/$FILE_LOG_NAME"
            fi
            EchoErrorTee "$MSG_HNDERR_IFBUG."
            Newline
        else
            EchoErrorTee "$MSG_HNDERR_SEND."
            EchoErrorTee "$MSG_HNDERR_SEND_PATH"
            Newline
        fi

        exit 1
    fi
}
