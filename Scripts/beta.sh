#!/usr/bin/env bash

# Script de réinstallation minimal pour les cours de BTS SIO en version Bêta
# Version Bêta 2.0

# Pour débugguer ce script en cas de besoin, tapez la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

# Ou débugguez le en utilisant l'excellent utilitaire Shellcheck :
#	En ligne -> https://www.shellcheck.net/
#	En ligne de commandes -> shellcheck beta.sh
#		--> Commande d'installation de l'utilitaire : sudo $gestionnaire_de_paquets $option_d'installation shellcheck



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



############### DÉCLARATION DES VARIABLES GLOBALES ET AFFECTATION DE LEURS VALEURS ###############

## ARGUMENTS
# Arguments à placer après la commande d'exécution du script pour qu'il s'exécute
ARG_USERNAME=$1		# Premier argument : Le nom du compte de l'utilisateur
ARG_DEBUG=$2		# Utilitaire de déboguage


## COULEURS
# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
COL_BLUE=$(tput setaf 4)		# Bleu foncé	--> Couleur des headers à n'écrire que dans le fichier de logs
COL_CYAN=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers
COL_GREEN=$(tput setaf 82)		# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape
COL_RED=$(tput setaf 196) 	  	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape
COL_RESET=$(tput sgr0)     		# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal
COL_YELLOW=$(tput setaf 226)	# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes


## DATE
# Enregistrement de la date au format YYYY-MM-DD hh-mm-ss (année-mois-jour heure-minute-seconde). Cette variable peut être utilisée pour écrire une partie du nom d'un dossier ou d'un fichier
DATE_TIME=$(date +"%Y-%m-%d %Hh-%Mm-%Ss")


## DOSSIERS
# Définition du dossier personnel de l'utilisateur
DIR_HOMEDIR="/home/${ARG_USERNAME}"				# Dossier personnel de l'utilisateur

# Définition du dossier temporaire et de son chemin
DIR_TMP_NAME="Linux-reinstall.tmp.d"			# Nom du dossier temporaire
DIR_TMP_PARENT="/tmp"							# Dossier parent du dossier temporaire
DIR_TMP_PATH="$DIR_TMP_PARENT/$DIR_TMP_NAME"	# Chemin complet du dossier temporaire

# Définition des sous-dossiers du dossier temporaire
DIR_INSTALL_NAME="Install"		# Dossier contenant les fichiers temporaires enregistrant les commandes de recherche et d'installation de paquets selon le gestionnaire de paquets utilisé
DIR_LOG_NAME="Logs"				# Dossier contenant le fichier de logs
DIR_PACKAGES_NAME="Packages"	# Dossier contenant les fichiers enregistrant les paquets non-trouvés ou dont l'installation a échoué

DIR_INSTALL_PATH="$DIR_TMP_PATH/$DIR_INSTALL_NAME"		# Chemin du dossier contenant le fichier de script
DIR_LOG_PATH="$DIR_TMP_PATH/$DIR_LOG_NAME"				# Chemin du dossier contenant le fichier de logs
DIR_PACKAGES_PATH="$DIR_TMP_PATH/$DIR_PACKAGES_NAME"	# Chemin du dossier contenant les fichiers listant les paquets absents de la base de données du gestionnaire de paquets ou impossibles à installer

# Définition du dossier d'installation de logiciels indisponibles via les gestionnaires de paquets
DIR_SOFTWARE_NAME="Logiciels.Linux-reinstall.d"
DIR_SOFTWARE_PATH="$DIR_HOMEDIR/$DIR_SOFTWARE_NAME"


## FICHIERS
# Définition du nom et du chemin du fichier de logs
FILE_LOG_NAME="Linux-reinstall $DATE_TIME.log"		# Nom du fichier de logs
FILE_LOG_PATH="$PWD/$FILE_LOG_NAME"					# Chemin du fichier de logs depuis la racine, dans le dossier actuel (il est mis à jour pendant l'initialisation du script)

# Définition du nom et du chemin du fichier de script de traitement des paquets à installer
FILE_SCRIPT_NAME="Packs.sh"
FILE_SCRIPT_PATH="$DIR_INSTALL_PATH/$FILE_SCRIPT_NAME"

# Définition des noms et des chemins des fichiers listant les paquets absents de la base de données du gestionnaire de paquets ou dont l'installation a échouée
FILE_PACKAGES_DB_NAME="Packages not found.txt"
FILE_PACKAGES_DB_PATH="$DIR_PACKAGES_PATH/$FILE_PACKAGES_DB_NAME"

FILE_PACKAGES_INST_NAME="Packages not installed.txt"
FILE_PACKAGES_INST_PATH="$DIR_PACKAGES_PATH/$FILE_PACKAGES_INST_NAME"

# Définition des noms et des chemins des fichiers contenant les commandes de recherche et d'installation de paquets selon le gestionnaire de paquets de l'utilisateur
FILE_INSTALL_HD_NAME="hd_search.tmp"
FILE_INSTALL_HD_PATH="$DIR_INSTALL_PATH/$FILE_INSTALL_HD_NAME"

FILE_INSTALL_DB_NAME="db_search.tmp"
FILE_INSTALL_DB_PATH="$DIR_INSTALL_PATH/$FILE_INSTALL_DB_NAME"

FILE_INSTALL_INST_NAME="inst.tmp"
FILE_INSTALL_INST_PATH="$DIR_INSTALL_PATH/$FILE_INSTALL_INST_NAME"


## TEXTE
# Affichage du nombre de colonnes sur le terminal
TXT_COLS=$(tput cols)

# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret,
# changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes
# (une ligne de chaque caractère).
TXT_HEADER_LINE_CHAR="-"		# Caractère à afficher en boucle pour créer une ligne des headers de changement d'étapes

# Affichage de chevrons avant une chaîne de caractères (par exemple)
TXT_TAB=">>>>"

# Affichage de chevrons suivant l'encodage de la couleur d'une chaîne de caractères
TXT_G_TAB="$COL_GREEN$TXT_TAB$TXT_TAB"		# Encodage de la couleur en vert et affichage de 4 * 2 chevrons
TXT_R_TAB="$COL_RED$TXT_TAB$TXT_TAB"		# Encodage de la couleur en rouge et affichage de 4 * 2 chevrons
TXT_Y_TAB="$COL_YELLOW$TXT_TAB"				# Encodage de la couleur en jaune et affichage de 4 chevrons


## VERSION
# Version actuelle du script
VER_SCRIPT="2.0"



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



############################################# DÉFINITIONS DES FONCTIONS #############################################


#### DÉFINITION DES FONCTIONS INDÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####



#### DÉFINITION DES FONCTIONS D'AFFICHAGE DE TEXTE
# Fonction servant à colorer d'une autre couleur une partie du texte de changement de sous-étape (jeu de mots entre "déco(ration)" et "echo"), suivi de la première lettre du nom du type de message (passage, échec ou cuccès)
function DechoN() { local string=$1; echo "$COL_CYAN$string$COL_YELLOW"; }

# Affichage d'un message de changement de sous-étape en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs, en jaune, avec des chevrons et sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function EchoNewstep() { local string=$1; echo "$TXT_Y_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep .5; }

# Affichage d'un message de changement de sous-étape dont le temps de pause du script peut être choisi en argument
function EchoNewstepCustomTimer() { local string=$1; timer=$2; echo "$TXT_Y_TAB $string$COL_RESET"; sleep "$timer"; }

# Affichage d'un message de changement de sous-étape sans redirections vers le fichier de logs
function EchoNewstepNoLog() { local string=$1; echo "$TXT_Y_TAB $string$COL_RESET"; }


# Fonction servant à colorer d'une autre couleur une partie du message d'échec de sous-étape (jeu de mots entre "déco(ration)" et "echo"), suivi de la première lettre du nom du type de message (passage, échec ou succès)
function DechoE() { local string=$1; echo "$COL_CYAN$string$COL_RED"; }

# Appel de la fonction "EchoErrorNoLog" en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoError() { local string=$1; echo "$TXT_R_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep .5; }

# Affichage d'un message d'échec de sous-étape dont le temps de pause du script peut être choisi en argument
function EchoErrorCustomTimer() { local string=$1; timer=$2; echo "$TXT_R_TAB $string$COL_RESET"; sleep "$timer"; }

# Affichage d'un message d'échec de sous-étape sans redirections vers le fichier de logs
function EchoErrorNoLog() { local string=$1; echo "$TXT_R_TAB $string$COL_RESET"; }


# Fonction servant à colorer d'une autre couleur une partie du texte de réussite de sous-étape (jeu de mots entre "déco(ration)" et "echo"), suivi de la première lettre du nom du type de message (passage, échec ou succès)
function DechoS() { local string=$1; echo "$COL_CYAN$string$COL_GREEN"; }

# Appel de la fonction "EchoSuccessNoLog" en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoSuccess() { local string=$1; echo "$TXT_G_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOG_PATH"; sleep .5; }

# Affichage d'un message de succès de sous-étape dont le temps de pause du script peut être choisi en argument
function EchoSuccessCustomTimer() { local string=$1; timer=$2; echo "$TXT_G_TAB $string$COL_RESET"; sleep "$timer"; }

# Affichage d'un message de succès sans redirections vers le fichier de logs
function EchoSuccessNoLog() { local string=$1; echo "$TXT_G_TAB $string$COL_RESET"; }


# Fonction de saut de ligne pour la zone de texte du terminal et pour le fichier de logs
function Newline() { echo "" | tee -a "$FILE_LOG_PATH"; }


# Fonction servant à colorer d'une autre couleur une partie de texte simple, coloré selon la couleur d'affichage de texte par défaut du terminal (jeu de mots entre "déco(ration)" et "echo")
function Decho() { local string=$1; echo "$COL_CYAN$string$COL_RESET"; }

# Fonction servant à colorer d'une autre couleur une partie du texte d'un header (jeu de mots entre "déco(ration)" et "echo"), suivi de la première lettre du mot "header"
function DechoH() { local string=$1; echo "$COL_BLUE$string$COL_CYAN"; }


## DÉFINITION DES FONCTIONS DE CRÉATION DE HEADERS
# Fonction de création et d'affichage de lignes selon le nombre de colonnes de la zone de texte du terminal
function DrawLine()
{
	#***** Paramètres *****
	local line_color=$1			# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction
	local line_char=$2			# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction

	#***** Code *****
	# Définition de la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	# Si la chaîne de caractère du paramètre $line_color (qui contient l'encodage de la couleur du texte) n'est pas vide,
	# alors on écrit l'encodage de la couleur dans le terminal, qui affiche la couleur, et non son encodage en texte.

	# L'encodage de la couleur peut être écrit via la commande "tput cols $encodage_de_la_couleur"
	# Elle est vide tant que le paramètre "$line_color" n'est pas passé en argument lors de l'appel de la fonction ET qu'une
	# valeur de la commande "tput setaf" ne lui est pas retournée.

	# Comme on souhaite écrire les caractères composant la ligne du header à la suite de la string d'encodage de la couleur, on utilise les options
	# '-n' (pas de sauts de ligne) et '-e' (interpréter les antislashs) de la commande "echo" pour ne pas faire un saut de ligne après la fin de la
	#  chaîne de caractères, pour écrire la prochaîne chaîne de caractères directement à la suite de la ligne.

	# Étant donné que toutes les colonnes de la ligne sont utilisées, les caractères suivants seront écris à la ligne, comme si un saut de ligne a été fait
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

	return
}

# Fonction de création de base d'un header (Couleur et caractère de ligne, couleur et chaîne de caractères)
function HeaderBase()
{
	#***** Paramètres *****
	local line_color=$1		# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction
	local line_char=$2		# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction
	local string_color=$3		# Définition de la couleur de la chaîne de caractères du header
	local string=$4			# Chaîne de caractères affichée dans chaque header
	local wait_t=$5			# Temps de pause après l'affichage du header

	#***** Code *****
	# Définition de la couleur de la ligne du caractère souhaité.
	# Ce code produit le même résultat que la première condition de la fonction "DrawLine", mais il a été
	# réécrit ici car aucune partie d'une fonction ne peut être utilisée individuellement depuis une autre fonction
#	if test "$line_color" == ""; then
#		echo -ne "$line_color"
#	fi

	DrawLine "$line_color" "$line_char"
	echo "$string_color" "##>" "$string$COL_RESET"
	DrawLine "$line_color" "$line_char"
	echo ""
	echo ""

	sleep "$wait_t"

	return
}

# Fonction d'affichage des headers lors d'un changement d'étape
function HeaderStep()
{
	#***** Paramètre *****
	# Chaîne de caractères contenant la phrase à afficher
	local string=$1

	# ***** Code *****
	HeaderBase "$COL_CYAN" "$TXT_HEADER_LINE_CHAR" "$COL_CYAN" "$string" "1.5" 2>&1 | tee -a "$FILE_LOG_PATH"

	return
}

# Fonction d'affichage de headers lors du passage à une nouvelle catégorie de paquets lors de l'installation de ces derniers
function HeaderInstall()
{
	#***** Paramètre *****
	# Chaîne de caractères contenant la phrase à afficher
	local string=$1

	# ***** Code *****
	HeaderBase "$COL_YELLOW" "$TXT_HEADER_LINE_CHAR" "$COL_GREEN" "$string" "1.5"  2>&1 | tee -a "$FILE_LOG_PATH"

	return
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger)
function HandleErrors()
{
	#***** Paramètre *****
	local error_string=$1		# Chaîne de caractères du type d'erreur à afficher
	local advise_string=$2	# Chaîne de caractères affichants un conseil pour orienter l'utilisateur vers la meilleure solution en cas de problème

	# ***** Code *****
	HeaderBase "$COL_RED" "$TXT_HEADER_LINE_CHAR" "$COL_RED" "ERREUR FATALE : $error_string" "1.5" 2>&1 | tee -a "$FILE_LOG_PATH"

	EchoErrorNoLog "Une erreur fatale s'est produite :" 2>&1 | tee -a "$FILE_LOG_PATH"
	EchoError "$error_string"
	Newline

	EchoError "$advise_string"
	Newline

	EchoError "Arrêt de l'installation"
	Newline

	# Si le fichier de logs se trouve toujours dans le dossier actuel (en dehors du dossier personnel de l'utilisateur)
	if test ! -f "$DIR_HOMEDIR/$FILE_LOG_NAME"; then
		mv -v "$FILE_LOG_PATH" "$DIR_HOMEDIR" 2>&1 | tee -a "$DIR_HOMEDIR/$FILE_LOG_NAME"
		FILE_LOG_PATH="$DIR_HOMEDIR/$FILE_LOG_NAME"
	fi

	EchoError "En cas de bug, veuillez m'envoyer le fichier de logs situé à l'adresse suivante : $(DechoE "$FILE_LOG_PATH")"
	Newline

	exit 1
}


#### DÉFINITION DES FONCTIONS DE CRÉATION DE FICHIERS ET DE DOSSIERS
# Fonction de création de dossiers ET d'attribution récursive des droits de lecture et d'écriture à l'utilisateur
# LORS DE SON APPEL, LA SORTIE DE CETTE FONCTION DOIT ÊTRE REDIRIGÉE SOIT VERS LE TERMINAL ET LE FICHIER DE LOGS, SOIT VERS LE FICHIER DE LOGS UNIQUEMENT
function Makedir()
{
	#***** Paramètres *****
	local parent=$1		# Emplacement depuis la racine du dossier parent du dossier à traiter
	local name=$2			# Nom du dossier à traiter (dans son dossier parent)
	local sleep_blk=$3	# Temps de pause du script avant et après la création d'une ligne d'un bloc d'informations sur le traitement du dossier
	local sleep_txt=$4	# Temps d'affichage des messages de passage à une nouvelle sous-étape, d'échec ou de succès lors du traitement du dossier

	#***** Autres variables *****
	local path="$parent/$name"	# Chemin du dossier à traiter
	local block_char="\""		# Caractère composant la ligne (c'est un double quote ("), cependant, pour que le script ne l'interprète pas comme un guillemet fermant, on ajoute un antislash juste devant)

	#***** Code *****
	# On commence par dessiner la première ligne du bloc
	sleep "$sleep_blk"
	DrawLine "$COL_RESET" "$block_char"
	echo ""	# On ne redirige aucun saut de ligne vers le fichier de logs, pour éviter de les afficher en double en cas d'appel de la fonction avec redirections

	EchoNewstepCustomTimer "Traitement du dossier $(DechoN "$name") dans le dossier parent $(DechoN "$parent/")" "$sleep_txt"
	echo ""

	# Si le dossier à traiter n'existe pas
	if test ! -d "$path"; then
		EchoNewstepCustomTimer "Création du dossier $(DechoN "$name") dans le dossier parent $(DechoN "$parent/")" "$sleep_txt"
		echo ""

		mkdir -v "$path"

		# On vérifie si le dossier a bien été créé, en vérifiant le code de retour de la commande "mkdir"
		if test "$?" != "0"; then
			HandleErrors "LE DOSSIER $(DechoE "$name") N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER PARENT $(DechoE "$parent/")" "Essayez de le créer manuellement" \
		else
			echo ""

			EchoSuccessCustomTimer "Le dossier $(DechoS "$name") a été créé avec succès dans le dossier $(DechoS "$parent/")" "$sleep_txt"
			echo ""
		fi

		# On change les droits du dossier nouvellement créé par le script
		# Comme ce dernier est exécuté en mode super-utilisateur, tout dossier ou fichier créé appartient à l'utilisateur root.
		# Pour attribuer récursivement la propriété du dossier à l'utilisateur normal, on appelle la commande chown avec pour arguments :
		#		- Le nom de l'utilisateur à qui donner les droits
		#		- Le chemin du dossier cible

		EchoNewstepCustomTimer "Changement récursif des droits du nouveau dossier $(DechoN "$path/") de $(DechoN "$USER") en $(DechoN "$ARG_USERNAME")" "$sleep_txt"
		echo ""

		# On vérifie si l'utilisateur possède déjà le dossier à créer (dans le cas où le dossier est créé dans un dossier n'appartenant pas à l'utilisateur (par exemple, quand il est créé dans le dossier "/tmp"))
		if test "$(stat -c '%U' "$path")" == "$ARG_USERNAME"; then
			EchoSuccessCustomTimer "Vous possédez déjà le dossier $(DechoS "$path/")" "$sleep_txt"
			echo ""

			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo ""

			return
		else
			chown -Rv "${ARG_USERNAME}" "$path"

			if test "$?" != "0"; then
				echo ""

				EchoErrorCustomTimer "Impossible de changer les droits du dossier $(DechoE "$path/")" "$sleep_txt"
				EchoErrorCustomTimer "Pour changer les droits du dossier $(DechoE "$path/") de manière récursive," "$sleep_txt"
				EchoErrorCustomTimer "utilisez la commande :" "$sleep_txt"
				echo "	chown -R ${ARG_USERNAME} $path"
				echo ""

				EchoErrorCustomTimer "Fin du traitement du dossier $(DechoE "$path/")" "$sleep_txt"
				DrawLine "$COL_RESET" "$block_char"		# On dessine la deuxième et dernière ligne du bloc
				sleep "$sleep_blk"
				echo ""
				echo ""

				return
			else
				echo ""

				EchoSuccessCustomTimer "Les droits du dossier $(DechoS "$name") ont été changés avec succès" "$sleep_txt"
				echo ""

				EchoSuccessCustomTimer "Fin du traitement du dossier $(DechoS "$path/")" "$sleep_txt"
				DrawLine "$COL_RESET" "$block_char"
				sleep "$sleep_blk"
				echo ""
				echo ""

				return
			fi
		fi

	# Sinon, si le dossier à créer existe déjà dans son dossier parent ET que ce dossier contient AU MOINS un fichier ou dossier
	elif test -d "$path" && test "$(ls -A "$path")"; then
		EchoNewstepCustomTimer "Un dossier non-vide portant exactement le même nom $(DechoN "$name") se trouve déjà dans le dossier cible $(DechoN "$parent/")" "$sleep_txt"
		EchoNewstepCustomTimer "Suppression du contenu du dossier $(DechoN "$path/")" "$sleep_txt"
		echo ""

		# ATTENTION À NE PAS MODIFIER LA COMMANDE SUIVANTE", À MOINS DE SAVOIR EXACTEMENT CE QUE VOUS FAITES !!!
		# Pour plus d'informations sur cette commande complète --> https://github.com/koalaman/shellcheck/wiki/SC2115
		rm -rfv "${path/:?}/"*

		if test "$?" != "0"; then
			echo ""

			EchoErrorCustomTimer "Impossible de supprimer le contenu du dossier $(DechoE "$path/")" "$sleep_txt";
			EchoErrorCustomTimer "Le contenu de tout fichier du dossier $(DechoE "$path/") portant le même nom qu'un des fichiers téléchargés sera écrasé" "$sleep_txt"
			echo ""

			EchoErrorCustomTimer "Fin du traitement du dossier $(DechoE "$path/")" "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo ""
			echo ""

			return
		else
			echo ""

			EchoSuccessCustomTimer "Suppression du contenu du dossier $(DechoS "$path/") effectuée avec succès" "$sleep_txt"
			echo ""

			EchoSuccessCustomTimer "Fin du traitement du dossier $(DechoS "$path/")" "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo ""
			echo ""
		fi

		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent ET que ce dossier est vide
	elif test -d "$path"; then
		EchoSuccessCustomTimer "Le dossier $(DechoS "$path/") existe déjà et est vide" "$sleep_txt"
		echo ""

		EchoSuccessCustomTimer "Fin du traitement du dossier $(DechoS "$path/")" "$sleep_txt"
		DrawLine "$COL_RESET" "$block_char"
		sleep "$sleep_blk"
		echo ""

		return
	fi
}

# Fonction de création de fichiers ET d'attribution des droits de lecture et d'écriture à l'utilisateur
# LORS DE SON APPEL, LA SORTIE DE CETTE FONCTION DOIT ÊTRE REDIRIGÉE SOIT VERS LE TERMINAL ET LE FICHIER DE LOGS, SOIT VERS LE FICHIER DE LOGS UNIQUEMENT
function Makefile()
{
	#***** Paramètres *****
	local parent=$1		# Emplacement depuis la racine du dossier parent du fichier à traiter
	local name=$2			# Nom du fichier à traiter (dans son dossier parent)
	local sleep_blk=$3	# Temps de pause du script avant et après la création d'un bloc d'informations sur le traitement du fichier
	local sleep_txt=$4	# Temps d'affichage des messages de passage à une nouvelle sous-étape, d'échec ou de succès

	#***** Autres variables *****
	local path="$parent/$name"		# Chemin du fichier à traiter
	local block_char="'"						# Caractère composant la ligne

	#***** Code *****
	# On commence par dessiner la première ligne du bloc
	sleep "$sleep_blk"
	DrawLine "$COL_RESET" "$block_char"
	echo ""

	EchoNewstepCustomTimer "Traitement du fichier $(DechoN "$name")" "$sleep_txt"
	echo ""

	# Si le fichier à traiter n'existe pas, on le crée avec l'aide de la commande "touch"
	if test ! -s "$path"; then
        EchoNewstepCustomTimer "Création du fichier $(DechoN "$name") dans le dossier $(DechoN "$parent/")" "$sleep_txt"
		echo ""

		touch "$path"

		# On vérifie que le fichier a bien été créé, en vérifiant le code de retour de la commande "touch"
		if test "$?" != "0"; then
			HandleErrors "LE FICHIER $(DechoE "$name") N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER $(DechoE "$parent/")" "Essayez de le créer manuellement"
		else
			EchoSuccessCustomTimer "Le fichier $(DechoS "$name") a été créé avec succès dans le dossier $(DechoS "$parent/")" "$sleep_txt"
			echo ""
		fi

		# On change les droits du fichier créé par le script
		# Comme il est exécuté en mode super-utilisateur, tout dossier ou fichier créé appartient à l'utilisateur root.
		# Pour attribuer les droits de lecture, d'écriture et d'exécution (rwx) à l'utilisateur normal, on appelle
		# la commande chown avec pour arguments :
		#		- Le nom de l'utilisateur à qui donner les droits
		#		- Le chemin du dossier cible

		EchoNewstepCustomTimer "Changement des droits du nouveau fichier $(DechoN "$path") de $(DechoN "$USER") en $(DechoN "$ARG_USERNAME")" "$sleep_txt"
		echo ""

		# On vérifie si l'utilisateur possède déjà le dossier à créer (dans le cas où le dossier est créé dans un dossier n'appartenant pas à l'utilisateur (par exemple, quand il est créé dans le dossier "/tmp"))
		if test "$(stat -c '%U' "$path")" == "$ARG_USERNAME"; then
			EchoSuccessCustomTimer "Vous possédez déjà le fichier $(DechoS "$path")" "$sleep_txt"
			echo ""

			# On dessine la deuxième et dernière ligne du bloc
			EchoSuccessCustomTimer "Fin du traitement du fichier $(DechoS "$path")" "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo ""
			echo ""

			return

		else
			chown -v "${ARG_USERNAME}" "$path"

			# On vérifie que les droits ont bien été changés, en vérifiant le code de retour de la commande "chown"
			if test "$?" != "0"; then
				echo ""

				EchoErrorCustomTimer "Impossible de changer les droits du fichier $(DechoE "$path")" "$sleep_txt"
				EchoErrorCustomTimer "Pour changer les droits du fichier $(DechoE "$path")," "$sleep_txt"
				EchoErrorCustomTimer "utilisez la commande :" "$sleep_txt"
				echo "	chown ${ARG_USERNAME} $path"
				echo ""

				EchoErrorCustomTimer "Fin du traitement du fichier $(DechoE "$path")" "$sleep_txt"
				DrawLine "$COL_RESET" "$block_char"
				sleep "$sleep_blk"
				echo ""
				echo ""

				return
			else
				echo ""
				EchoSuccessCustomTimer "Les droits du fichier $(DechoS "$parent") ont été changés avec succès" "$sleep_txt"
				echo ""

				EchoSuccessCustomTimer "Fin du traitement du fichier $(DechoS "$path")" "$sleep_txt"
				DrawLine "$COL_RESET" "$block_char"
				sleep "$sleep_blk"
				echo ""
				echo ""

				return
			fi
		fi

	# Sinon, si le fichier à créer existe déjà ET qu'il est vide
	elif test -f "$path" && test -s "$path"; then
		EchoSuccessCustomTimer "Le fichier $(DechoS "$name") existe déjà dans le dossier $(DechoS "$parent/")" "$sleep_txt"
		echo ""

		EchoSuccessCustomTimer "Fin du traitement du fichier $(DechoS "$path")" "$sleep_txt"
		DrawLine "$COL_RESET" "$block_char"
		echo ""

		return

	# Sinon, si le fichier à créer existe déjà ET qu'il n'est pas vide
	elif test -f "$path" && test ! -s "$path"; then
		true > "$path" \

		if test "$?" != "0"; then
			EchoErrorCustomTimer "Le contenu du fichier $(DechoE "$path") n'a pas été écrasé" "$sleep_txt"
			echo ""

			EchoErrorCustomTimer "Fin du traitement du fichier $(DechoE "$path")" "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo ""
			echo ""

		else
			EchoSuccessCustomTimer "Le contenu du fichier $(DechoS "$path") a été écrasé avec succès" "$sleep_txt"
			echo ""

			EchoSuccessCustomTimer "Fin du traitement du fichier $(DechoS "$path")" "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo ""
			echo ""
		fi

		return
	fi
}


#### DÉFINITION DES FONCTIONS D'INSTALLATION
# Optimisation de la partie d'installation du script
function OptimizeInstallation()
{
	#***** Paramètres *****
	local parent=$1		# Dossier parent du fichier script à exécuter
	local file=$2		# Nom du fichier script à exécuter
	local cmd=$3		# Commande du gestionnaire de paquets à exécuter
	local package=$4	# Nom du paquet
	local type=$5		# Type de commande envoyée (recherche sur le disque dur, dans la base de données ou installation de paquets)

	#***** Autres variables *****
	local parent="$DIR_INSTALL_PATH"
	local block_char="="

	getval_name="getval.tmp"
	getval_path="$DIR_INSTALL_PATH/$getval_name"

	#**** Code *****
	# On vérifie si tous les arguments sont bien appelés (IMPORTANT POUR UNE INSTALLATION SANS PROBLÈMES)
	if test -z "$parent" || test -z "$file" || test -z "$cmd" || test -z "$package" || test -z "$type"; then
		HandleErrors "UN OU PLUSIEURS ARGUMENTS MANQUENT À LA FONCTION $(DechoE "OptimizeInstallation")" \
			"Vérifiez quels arguments manquent à la fonction"
	fi

	# On vérifie si la valeur de l'argument correspond à un type de commande
	case "$type" in
		"HD")
			EchoNewstep "Vérification de la présence du paquet $(DechoN "$package") sur votre système"
			Newline
			;;
		"DB")
			EchoNewstep "Vérification de la présence du paquet $(DechoN "$package") dans la base de données du gestionnaire $(DechoN "$PACK_MAIN_PACKAGE_MANAGER")"
			Newline
			;;
		"INST")
			EchoNewstep "Installation du paquet $(DechoN "$package")"
			Newline
			;;
		*)
			HandleErrors "LA VALEUR DE LA CHAÎNE DE CARACTÈRES PASSÉE EN CINQUIÈME ARGUMENT $(DechoE "$type") NE CORRESPOND À AUCUNE DES TROIS CHAÎNES ATTENDUES" \
				"Les trois chaînes de caractères attendues sont :
				 $(DechoE "HD") pour la recherche de paquets sur le système,
				 $(DechoE "DB") pour la recherche de paquets dans la base de données du gestionnaire de paquets
				 $(DechoE "INST") pour l'installation de paquets
				 "
	esac

	# Exécution du script
	(cd "$parent" && ./"$file" "$FILE_LOG_PATH" "$cmd"; echo "$?" > "$getval_path")

	GETVAL=$(cat "$getval_path")
	echo "$GETVAL"

	case "$GETVAL" in
		"1")
			case "$type" in
				"HD")
					EchoNewstep "Le paquet $(DechoN "$package") n'est pas installé sur votre système"
					Newline

					EchoNewstep "Préparation de l'installation du paquet $(DechoN "$package")"
					Newline
					sleep 1
					;;
				"DB")
					EchoError "Le paquet $(DechoE "$package") n'a pas été trouvé dans la base de données du gestionnaire $(DechoE "$PACK_MAIN_PACKAGE_MANAGER")"
					EchoError "Écriture du nom du paquet $(DechoE "$package") dans le fichier $(DechoE "$DIR_PACKAGES_PATH")"
					Newline

					# S'il n'existe pas, on crée le fichier contenant les noms des paquets introuvables dans la base de données
					if test ! -f "$FILE_PACKAGES_DB_PATH"; then
						Makefile "$DIR_PACKAGES_PATH" "$FILE_PACKAGES_DB_NAME" "0" "0" >> "$FILE_LOG_PATH"
						echo "Gestionnaire de paquets : $PACK_MAIN_PACKAGE_MANAGER" > "$FILE_PACKAGES_DB_PATH"
						echo "" >> "$FILE_PACKAGES_DB_PATH"
					fi

					echo "$package_name" >> "$FILE_PACKAGES_DB_PATH"

					EchoError "Abandon de l'installation du paquet $(DechoE "$package")"
					Newline

					Drawline "$COL_RESET" "$block_char" 2>&1 | tee -a "$FILE_LOG_PATH"
					Newline
					Newline
					;;
				"INST")
					EchoError "Impossible d'installer le paquet $(DechoE "$package")"
					Newline

					# S'il n'existe pas, on crée le fichier contenant les noms des paquets dont l'installation a échouée
					if test ! -f "$FILE_PACKAGES_INST_PATH"; then
						Makefile "$DIR_PACKAGES_PATH" "$FILE_PACKAGES_INST_NAME" "0" "0" >> "$FILE_LOG_PATH"

						echo "Gestionnaire de paquets : $PACK_MAIN_PACKAGE_MANAGER" > "$FILE_PACKAGES_INST_PATH"
						echo "" >> "$FILE_PACKAGES_INST_PATH"
					fi

					echo "$package" >> "$FILE_PACKAGES_INST_PATH"

					EchoError "Abandon de l'installation du paquet $(DechoE "$package")"
					Newline

					Drawline "$COL_RESET" "$block_char" 2>&1 | tee -a "$FILE_LOG_PATH"
					Newline
					Newline
					;;
			esac
			;;
		"2")
			HandleErrors "AUCUNE COMMANDE N'EST PASSÉE EN ARGUMENT" \
				"Veuillez passer le chemin vers le fichier de logs en premier argument, puis la commande souhaitée (recherche (système ou base de données) ou installation) en deuxième argument"
			;;
		"3")
			HandleErrors "AUCUNE COMMANDE N'EST PASSÉE EN DEUXIÈME ARGUMENT" \
				"Veuillez passer le nom de la commande souhaitée (recherche (système ou base de données) ou installation) en deuxième argument"
			;;
		"4")
			HandleErrors "UNE ERREUR INCONNUE S'EST PRODUITE PENDANT L'EXÉCUTION DU SCRIPT" \
				""
			;;
		"0")
			case "$type" in
				"HD")
					EchoSuccess "Le paquet $(DechoS "$package") est déjà installé sur votre système"
					Newline

					Drawline "$COL_RESET" "$block_char" 2>&1 | tee -a "$FILE_LOG_PATH"
					Newline
					Newline
					;;
				"DB")
					EchoSuccess "Le paquet $(DechoS "$package") a été trouvé dans la base de données du gestionnaire $(DechoS "$PACK_MAIN_PACKAGE_MANAGER")"
					;;
				"INST")
					EchoSuccess "Le paquet $(DechoS "$package") a bien été installé"
					;;
			esac
			;;
		#*)
		#	HandleErrors "UNE ERREUR S'EST PRODUITE LORS DE LA LECTURE DE LA SORTIE DE LA COMMANDE $(DechoE "$cmd")" \
		#		"Vérifiez ce qui a causé cette erreur"
		#	;;
	esac
}

# Installation d'un paquet selon le gestionnaire de paquets, ainsi que sa commande de recherche de paquets dans le système de l'utilisateur,
# sa commande de recherche de paquets dans sa base de données, ainsi que sa commande d'installation de paquets
function PackInstall()
{
	#***** Paramètres *****
	local package_manager_name=$1		# Nom du gestionnaire de paquets
	local package_name=$2				# Nom du paquet à installer

	#***** Autres variables *****
	local block_char="="		# Caractère composant la ligne

	#***** Code *****
	# S'il n'existe pas, on crée le dossier contenant des informations concernant les éventuels paquets non-trouvés dans la base de données
	# du gestionnaire de paquets ou les éventuels paquets impossibles à installer sur le disque dur de l'utilisateur
	if test ! -d "$DIR_PACKAGES_PATH"; then
		Makedir "$DIR_TMP_PATH" "$DIR_PACKAGES_NAME" "0" "0" >> "$FILE_LOG_PATH"
	fi

	# Si le fichier contenant la commande de recherche sur le système n'existe pas
	if test ! -f "$FILE_INSTALL_HD_PATH"; then
		Makefile "$DIR_INSTALL_PATH" "$FILE_INSTALL_HD_NAME" "0" "0" >> "$FILE_LOG_PATH"
	fi

	# Si le fichier contenant la commande de recherche dans la base de données n'exite pas
	if test ! -f "$FILE_INSTALL_DB_PATH"; then
		Makefile "$DIR_INSTALL_PATH" "$FILE_INSTALL_DB_NAME" "0" "0" >> "$FILE_LOG_PATH"
	fi

	# Si le fichier contenant la commande d'installation n'existe pas
	if test ! -f "$FILE_INSTALL_INST_PATH"; then
		Makefile "$DIR_INSTALL_PATH" "$FILE_INSTALL_INST_NAME" "0" "0" >> "$FILE_LOG_PATH"
	fi

	DrawLine "$COL_RESET" "$block_char" 2>&1 | tee -a "$FILE_LOG_PATH"
	sleep 1
	Newline

	EchoNewstep "Traitement du paquet $(DechoN "$package_name")"
	Newline

	# On définit les commandes de recherche et d'installation de paquets selon le nom du gestionnaire de paquets passé en premier argument.
	# Également, on permet l'insensibilité à la casse au cas où l'utilisateur veut ajouter un paquet dans la liste de paquets à installer et qu'il passe
	# en premier argument le nom du gestionnaire de paquets avec ou sans majuscule (par exemple : PackInstall "snap" paquet OU PackInstall "Snap" paquet).
	case ${package_manager_name,,} in
		"$PACK_MAIN_PACKAGE_MANAGER")
			case ${PACK_MAIN_PACKAGE_MANAGER,,} in
				"apt")
					echo apt-cache policy "$package_name" | grep "$package_name" > "$FILE_INSTALL_HD_PATH"
					echo apt-cache show "^$package_name\$" > "$FILE_INSTALL_DB_PATH"
					echo apt-get -y install "$package_name" > "$FILE_INSTALL_INST_PATH"
					;;
			#	"dnf")
			#		search_pack_hdrive_command=""
			#		search_pack_db_command=""
			#		echo dnf -y install "$package_name" > "$FILE_INSTALL_INST_PATH"
			#		;;
			#	"pacman")
			#		echo pacman -Q "$package_name" > "$FILE_INSTALL_HD_PATH"
			#		search_pack_db_command=""
			#		echo pacman --noconfirm -S "$package_name" > "$FILE_INSTALL_INST_PATH"
			esac
			;;
		"snap")
			echo snap list "$package_name" > "$FILE_INSTALL_HD_PATH"
			# search_pack_db_command=""
			snap install "$*" > "$FILE_INSTALL_INST_PATH"
			;;
		"")
			HandleErrors "AUCUN NOM DE GESTIONNAIRE DE PAQUETS N'A ÉTÉ PASSÉ EN ARGUMENT" \
				"Passez un gestionnaire de paquets supporté en argument (pour rappel, les gestionnaires de paquets supportés sont $(DechoE "APT"), $(DechoE "DNF") et $(DechoE "Pacman"). Si vous avez rajouté un gestionnaire de paquets, n'oubliez pas d'inclure ses commandes de recherche et d'installation de paquets)"
				;;
			*)
			EchoError "Le nom du gestionnaire de paquets passé en premier argument $(DechoE "$package_manager_name") ne correspond à aucun gestionnaire de paquets présent sur votre système"
			EchoError "Vérifiez que le nom du gestionnaire de paquets passé en arguments ne contienne pas de majuscules et corresponde EXACTEMENT au nom de la commande"
			Newline

			HandleErrors "LE NOM DU GESTIONNAIRE DE PAQUETS PASSÉ EN PREMIER ARGUMENT ($(DechoE "$package_manager_name")) NE CORRESPOND À AUCUN GESTIONNAIRE DE PAQUETS PRÉSENT SUR VOTRE SYSTÈME" \
				"Désolé, ce gestionnaire de paquets n'est pas supporté ¯\_(ツ)_/¯"
			;;
	esac

	## RECHERCHE DU PAQUET SUR LE SYSTÈME DE L'UTILISATEUR
	var_file_content=$(cat "$FILE_INSTALL_HD_PATH")	# On récupère la commande stockée dans le fichier contenant la commande de recherche sur le système, puis on assigne son contenu en tant que valeur d'une variable à passer en argument lors de l'appel de la fonction "OptimizeInstallation"
	var_type="HD"	# On enregistre la valeur du troisième paramètre de la fonction "OptimizeInstallation" pour mieux le récupérer lors du test

	# On appelle en premier lieu la commande de recherche de paquets installés sur le système de l'utilisateur, puis on quitte la fonction "PackInstall" si le paquet recherché est déjà installé sur le disque dur de l'utilisateur
	OptimizeInstallation "$DIR_INSTALL_PATH" "$FILE_SCRIPT_NAME" "$var_file_content" "$package_name" "$var_type"

	if test "$var_type" == "HD" && test "$GETVAL" == "1"; then
		return
	fi

	## RECHERCHE DU PAQUET DANS LA BASE DE DONNÉES DU GESTIONNAIRE DE PAQUETS DE L'UTILISATEUR
	var_file_content=$(cat "$FILE_INSTALL_DB_PATH")	# On récupère la commande stockée dans le fichier contenant la commande de recherche dans la base de données, puis on assigne son contenu en tant que valeur d'une variable à passer en argument lors de l'appel de la fonction "OptimizeInstallation"
	var_type="DB"

	# On appelle en deuxième lieu la commande de recherche de paquets dans la base de données du gestionnaire de paquets de l'utilisateur, puis on quitte la fonction "PackInstall" si le paquet recherché est absent de la base de données
	OptimizeInstallation "$DIR_INSTALL_PATH" "$FILE_SCRIPT_NAME" "$var_file_content" "$package_name" "$var_type"

	if test "$var_type" == "DB" && test "$GETVAL" == "1"; then
		return
	fi

	## INSTALLATION DU PAQUET SUR LE SYSTÈME DE L'UTILISATEUR
	var_file_content=$(cat "$FILE_INSTALL_INST_PATH")	# On récupère la commande stockée dans le fichier contenant la commande d'installation de paquets, puis on assigne son contenu en tant que valeur d'une variable à passer en argument lors de l'appel de la fonction "OptimizeInstallation"
	var_type="INST"

	# On appelle en troisième et dernier lieu la commande d'installation de paquets, puis on quitte la fonction "PackInstall" si le paquet n'a pas pu être installé
	OptimizeInstallation "$DIR_INSTALL_PATH" "$FILE_SCRIPT_NAME" "$var_file_content" "$package_name" "$var_type"

	if test "$var_type" == "INST" && test "$GETVAL" == "1"; then
		return
	fi

	return
}

# Installation de logiciels absents de la base de données de tous les gestionnaires de paquets
function SoftwareInstall()
{
	#***** Paramètres *****
	local software_web_link=$1		# Adresse de téléchargement du logiciel (téléchargement via la commande "wget"), SANS LE NOM DE L'ARCHIVE
	local software_archive=$2		# Nom de l'archive contenant les fichiers du logiciel
	local software_name=$3			# Nom du logiciel
	local software_comment=$4		# Affichage d'un commentaire descriptif du logiciel lorsque l'utilisateur passe le curseur de sa souris pas dessus le fichier ".desktop"
	local software_exec=$5			# Adresse du fichier exécutable du logiciel
	local software_icon=$6			# Emplacement du fichier image de l'icône du logiciel
	local software_type=$7			# Détermine si le fichier ".desktop" pointe vers une application, un lien ou un dossier
	local software_category=$8		# Catégorie(s) du logiciel (jeu, développement, bureautique, etc...)

	#***** Autres variables *****
	# Dossiers
 	local software_inst_path="$DIR_SOFTWARE_PATH/$software_name"					# Dossier d'installation du logiciel
	local software_shortcut_dir="$DIR_HOMEDIR/Bureau/Linux-reinstall.links"	# Dossier de stockage des raccourcis vers les fichiers exécutables des logiciels téléchargés

	# Fichiers
	local software_dl_link="$software_web_link/$software_archive"				# Lien de téléchargement de l'archive

	#***** Code *****
	EchoNewstep "Téléchargement du logiciel $(DechoN "$software_name")"

	# On crée un dossier dédié au logiciel dans le dossier d'installation de logiciels
	Makedir "$DIR_SOFTWARE_NAME" "$software_name" "2" "1" 2>&1 | tee -a "$FILE_LOG_PATH"
	if test wget -v "$software_dl_link" -O "$software_inst_path" >> "$FILE_LOG_PATH"; then \
		EchoSuccess "Le logiciel $(DechoS "$software_name") a été téléchargé avec succès"
		Newline

	else
		EchoError "Échec du téléchargement du logiciel $(DechoE "$software_name")"
		Newline

		return
	fi

	# On décompresse l'archive téléchargée selon le format de comporession
	EchoNewstep "Décompression de l'archive $(DechoN "$software_archive")"
	{
		case "$software_archive" in
			"*.zip")
				unzip "$DIR_SOFTWARE_NAME/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.7z")
				7z e "$DIR_SOFTWARE_NAME/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.rar")
				unrar e "$DIR_SOFTWARE_NAME/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.tar.gz")
				tar -zxvf "$DIR_SOFTWARE_NAME/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.tar.bz2")
				tar -jxvf "$DIR_SOFTWARE_NAME/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			*)
				EchoError "Le format de fichier de l'archive $(DechoE "$software_archive") n'est pas supporté"

				return
				;;
		esac
	} 2>&1 | tee -a "$FILE_LOG_PATH"

	# On vérifie que le dossier contenant les fichiers desktop (servant de raccourci) existe, pour ne pas encombrer le bureau de l'utilisateur
	if test ! -d "$software_shortcut_dir"; then
		EchoNewstep "Création d'un dossier contenant les raccourcis vers les logiciels téléchargés via la commande wget (pour ne pas encombrer votre bureau)"
		Newline

		Makedir "$DIR_HOMEDIR/Bureau/" "Linux-reinstall.link" "2" "1" 2>&1 | tee -a "$FILE_LOG_PATH"
		EchoSuccess "Le dossier  vous pourrez déplacer les raccourcis sur votre bureau sans avoir à les modifier"
	fi

	EchoNewstep "Création d'un lien symbolique pointant vers le fichier exécutable du logiciel $(DechoN "$software_name")"
	ln -s "$software_exec" "$software_name"

	if test "$?" != "0"; then
		EchoError "Impossible de créer un lien symbolique pointant vers $(DechoE "$software_exec")"
	else
		EchoSuccess "Le lien symbolique a été créé avec succès"
		Newline
	fi

	EchoNewstep "Création du raccourci vers le fichier exécutable du logiciel $(DechoN "$software_name")"
	{
		echo "[Desktop Entry]"
		echo "Name=$software_name"
		echo "Comment=$software_comment"
		echo "Exec=$software_inst_path/$software_exec"
		echo "Icon=$software_icon"
		echo "Type=$software_type"
		echo "Categories=$software_category;"
	} > "$software_shortcut_dir/$software_name.desktop" \
	&& EchoSuccess "Le fichier $(DechoS "$software_name.desktop") a été créé avec succès dans le dossier $(DechoS "$software_shortcut_dir")"
	Newline

	EchoNewstep "Suppression de l'archive $(DechoN "$software_archive")"
	rm -f "$software_inst_path/$software_archive" \

	if test "$?" != "0"; then
		EchoError "La suppression de l'archive $(DechoE "$software_archive") a échouée"
	else
		EchoSuccess "L'archive $(DechoS "$software_archive") a été correctement supprimée"
		Newline
	fi
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

#### DÉFINITION DES FONCTIONS DÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####



## DÉFINITION DES FONCTIONS D'INITIALISATION
# Détection du passage des arguments au script
function CheckArgs()
{
	# Si le script n'est pas lancé en mode super-utilisateur (root)
	if test "$EUID" -ne 0; then
		EchoErrorNoLog "Ce script doit être exécuté en tant que super-utilisateur (root)"
		EchoErrorNoLog "Exécutez ce script en plaçant la commande $(DechoE "sudo") devant votre commande :"

		# La variable "$0" ci-dessous est le nom du fichier shell en question avec le "./" placé devant (argument 0).
		# Si ce fichier est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
		echo "	sudo $0 votre_nom_d'utilisateur"
		echo ""

		EchoErrorNoLog "Ou connectez vous directement en tant que super-utilisateur"
		EchoErrorNoLog "Et tapez cette commande :"
		echo "	$0 votre_nom_d'utilisateur"
		echo ""

		EchoErrorNoLog "SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"
		EchoErrorNoLog "Relancez le script avec les droits de super-utilisateur (avec la commande $(DechoE "sudo")) ou en vous connectant en mode root"
		echo ""

		exit 1
	# Sinon, si le script est lancé en mode super-utilisateur sans argument
	elif test -z "${ARG_USERNAME}"; then
		EchoErrorNoLog "Veuillez lancer le script en plaçant votre nom d'utilisateur après la commande d'exécution du script :"
		echo "	sudo $0 votre_nom_d'utilisateur"
		echo ""

		EchoErrorNoLog "VOUS N'AVEZ PAS PASSÉ VOTRE NOM D'UTILISATEUR EN ARGUMENT"
		EchoErrorNoLog "Entrez votre nom d'utilisateur juste après le nom du script"
		echo ""

		exit 1
	# Sinon, si le premier argument passé ne correspond à aucun compte d'utilisateur existant
	elif ! id -u "${ARG_USERNAME}" > /dev/null; then
		EchoErrorNoLog "NOM D'UTILISATEUR INCORRECT"
		EchoErrorNoLog "Veuillez entrer correctement votre nom d'utilisateur"
		echo ""

		exit 1
	fi

	# On vérifie si l'utilisateur passe une chaîne de caractères "debug" en deuxième argument
	# Je me sers de cette fonction pour effectuer des tests surmon script, sans attendre que ce dernier arrive à l'étape souhaitée. Son contenu est susceptible de changer énormément
	if test "debug" = "${ARG_DEBUG}"; then
		# On redéfinit le nom et le chemin du fichier de logs est redéfini pour qu'il soit facilement trouvable par le script de déboguage
		FILE_LOG_NAME="Linux-reinstall.log"
		FILE_LOG_PATH="$PWD/$FILE_LOG_NAME"

		# On récupère l'identifiant du processus (PID)
		echo "PID : $$"
		Newline

		## APPEL DES FONCTIONS D'INITIALISATION
		CreateLogFile			# On appelle la fonction de création du fichier de logs. À partir de maintenant, chaque sortie peut être redirigée vers un fichier de logs existant
		Mktmpdir				# Puis la fonction de création du dossier temporaire
		GetMainPackageManager	# Puis la fonction de détection du gestionnaire de paquets principal de la distribution de l'utilisateur
		WritePackScript			# Puis la fonction de création de scripts d'installation

		# APPEL DES FONCTIONS À TESTER
		EchoNewstepNoLog "Test de la fonction d'installation"
		Newline

		HeaderStep "TEST D'INSTALLATION DE PAQUETS"
		PackInstall "apt" "nano"
		PackInstall "apt" "emacs"

		exit 0

	# Si un deuxième argument est passé ET si la valeur du second argument ne correspond pas à la valeur attendue ("debug")
	elif test ! -z "${ARG_DEBUG}" && test ! "debug" = "${ARG_DEBUG}" ; then
		EchoError "LA CHAÎNE DE CARACTÈRES PASSÉE EN DEUXIÈME ARGUMENT NE CORRESPOND PAS À LA VALEUR ATTENDUE : ($(DechoE "debug"))"
		EchoError "Si vous souhaitez tester une fonction du script, passez la valeur $(DechoE "debug") sans faire de fautes"

		exit 1
	fi
}

# Création du fichier de logs pour répertorier chaque sortie de commande (sortie standard (STDOUT) ou sortie d'erreurs (STDERR))
function CreateLogFile()
{
	# Récupération des informations sur le système d'exploitation de l'utilisateur, me permettant de corriger tout bug pouvant survenir sur une distribution Linux précise
	# Tout ce qui se trouve entre les accolades suivantes est envoyé dans le fichier de logs
	{
		# Le script crée d'abord le fichier de logs dans le dossier actuel (pour cela, on passe la valeur de la variable d'environnement $PWD en premier argument de la fonction "Makefile")
		Makefile "$PWD" "$FILE_LOG_NAME" "0" "0"
		echo ""

		# On évite d'appeler les fonctions d'affichage propre "EchoSuccess" ou "EchoError" (sans le "NoLog") pour éviter
		# d'écrire deux fois le même texte, vu que ces fonctions appellent chacune une commande écrivant dans le fichier de logs
		EchoSuccessNoLog "Fichier de logs créé avec succès"
		echo ""

		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" "RÉCUPÉRATION DES INFORMATIONS SUR LE SYSTÈME DE L'UTILISATEUR" "0"

		# Étant donné que chaque ligne du header est écrite avec la commande "echo -n" interdisant un saut de ligne, il faut appeler deux fois la commande "echo "" " pour ainsi faire un saut de ligne
		# La fonction Newline redirige déjà un saut de ligne vers le fichier de logs et le terminal, mais comme ce bloc d'instructions est envoyé dans le fichier de logs, l'appel de cette fonction compte pour un double appel de la commande "echo "" "
		# Récupération des informations sur le système d'exploitation de l'utilisateur contenues dans le fichier "/etc/os-release"
		EchoNewstepNoLog "Informations sur le système d'exploitation de l'utilisateur $(DechoN "${ARG_USERNAME}") :"
		cat "/etc/os-release"
		echo ""

		EchoSuccessNoLog "Fin de la récupération d'informations sur le système d'exploitation"
		echo ""
	} > "$FILE_LOG_PATH"	# Au moment de la création du fichier de logs, la variable "$FILE_LOG_PATH" correspond au dossier actuel de l'utilisateur
}

# Création du dossier temporaire où sont stockés les fichiers et dossiers temporaires
function Mktmpdir()
{
	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" \
			"CRÉATION DU DOSSIER TEMPORAIRE $COL_JAUNE\"$DIR_TMP$COL_BLUE\" DANS LE DOSSIER $COL_JAUNE\"$DIR_TMP_PARENT\"$COL_RESET" "0"

		Makedir "$DIR_TMP_PARENT" "$DIR_TMP_NAME" "0" "0"		# Dossier principal
		Makedir "$DIR_TMP_PATH" "$DIR_LOG_NAME" "0" "0"			# Dossier d'enregistrement des fichiers de logs
	} >> "$FILE_LOG_PATH"

	# Avant de déplacer le fichier de logs, on vérifie si l'utilisateur a passé la valeur "debug" en tant que deuxième argument (vérification importante, étant donné que le chemin et le nom du fichier sont redéfinis dans ce cas)
	# Si c'est le cas, le fichier de logs n'est déplacé nulle part ailleurs dans l'arborescence
	# Si ce n'est pas le cas, une fois le dossier temporaire créé, on y déplace le fichier de logs tout en vérifiant s'il ne s'y trouve pas déjà
	if test -z "${ARG_DEBUG}" && test ! -f "$DIR_LOG_PATH/$FILE_LOG_NAME"; then
		# Étant donné que la fonction "Mktmpdir" est appelée après la fonction de création du fichier de logs (CreateLogFile) dans la fonction "ScriptInit", il est possible d'appeler la fonction "HandleErrors" sans que le moindre bug ne se produise
		mv -v "$FILE_LOG_NAME" "$DIR_LOG_PATH" >> "$FILE_LOG_PATH" \

		if test "$?" != "0"; then
			HandleErrors "IMPOSSIBLE DE DÉPLACER LE FICHIER DE LOGS VERS LE DOSSIER $(DechoE "$DIR_LOG_PATH")" "" \
		else
			FILE_LOG_PATH="$DIR_LOG_PATH/$FILE_LOG_NAME"	# Une fois que le fichier de logs est déplacé dans le dossier temporaire, on redéfinit le chemin du fichier de logs de la variable "$FILE_LOG_PATH"
		fi
	fi
}

# Détection du gestionnaire de paquets de la distribution utilisée
function GetMainPackageManager()
{
	HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" "DÉTECTION DU GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION" "0" >> "$FILE_LOG_PATH"

	# On cherche la commande du gestionnaire de paquets de la distribution de l'utilisateur dans les chemins de la variable d'environnement "$PATH" en l'exécutant.
	# On redirige chaque sortie ("STDOUT (sortie standard) si la commande est trouvée" et "STDERR (sortie d'erreurs) si la commande n'est pas trouvée")
	# de la commande vers /dev/null (vers rien) pour ne pas exécuter la commande.

	# Pour en savoir plus sur les redirections en Shell UNIX, consultez ce lien -> https://www.tldp.org/LDP/abs/html/io-redirection.html
	command -v apt-get &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="apt"
	command -v dnf &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="dnf"
	command -v pacman &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="pacman"

	# Si, après la recherche de la commande, la chaîne de caractères contenue dans la variable $PACK_MAIN_PACKAGE_MANAGER est toujours nulle (aucune commande trouvée)
	if test "$PACK_MAIN_PACKAGE_MANAGER" = ""; then
		# Étant donné que la fonction "GetMainPackageManager" est appelée après la fonction de création du fichier de logs (CreateLogFile) dans la fonction "ScriptInit", il est possible d'appeler la fonction "HandleErrors" sans que le moindre bug ne se produise
		HandleErrors "AUCUN GESTIONNAIRE DE PAQUETS PRINCIPAL SUPPORTÉ TROUVÉ" "Les gestionnaires de paquets supportés sont : $(DechoE "APT"), $(DechoE "DNF") et $(DechoE "Pacman")"
	else
		EchoSuccessNoLog "Gestionnaire de paquets principal trouvé : $(DechoS "$PACK_MAIN_PACKAGE_MANAGER")" >> "$FILE_LOG_PATH"
	fi

	Newline
}

# Création du script de traitement de paquets à installer
function WritePackScript()
{
	# Création du dossier contenant le script de traitement de paquets et les fichiers contenant les commandes de recherche et d'installation de paquets
	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" "ÉCRITURE DU SCRIPT DE TRAITEMENT DE PAQUETS" "0"

		Makedir "$DIR_TMP_PATH" "$DIR_INSTALL_NAME" "0" "0"						# On crée le dossier contenant les fichiers temporaires contenant les commandes de recherche et d'installation des paquets
		Makefile "$DIR_TMP_PATH/$DIR_INSTALL_NAME" "$FILE_SCRIPT_NAME" "0" "0"	# On crée le fichier de script
	} >> "$FILE_LOG_PATH"

	# On écrit le contenu du script dans le fichier de script en utilisant un here document
	(
		cat <<-'NEWSCRIPT'
		#!/usr/bin/env bash

		LOG=$1
		CMD=$2

		if test -z "${LOG}" && test -z "${CMD}"; then
			exit 2
		elif test -z "${CMD}"; then
			exit 3
		elif test -s "${LOG}" && test -s "${CMD}"; then
			"$CMD" || exit 1
			exit 0
		else
			exit 4
		fi
		NEWSCRIPT
	) > "$FILE_SCRIPT_PATH"

	# On rend le fichier script exécutable
	{
	EchoNewstepNoLog "Attribution des droits d'exécution sur le fichier script $(DechoN "$FILE_SCRIPT_PATH")"
		echo ""
	} >> "$FILE_LOG_PATH"

	chmod +x -v "$FILE_SCRIPT_PATH" 2>&1 | tee -a "$FILE_LOG_PATH"

	if test "$?" != "0"; then
		HandleErrors "IMPOSSIBLE DE CHANGER LES DROITS D'EXÉCUTION DU FICHIER SCRIPT DE TRAITEMENT DE PAQUETS" ""
	else
		echo ""

		EchoSuccessNoLog "Les droits d'exécution ont été attribués avec succès sur le fichier script de traitement de paquets" >> $FILE_LOG_PATH
	fi
}

# Initialisation du script
function ScriptInit()
{
	CheckArgs				# On appelle la fonction de vérification des arguments passés au script
	CreateLogFile			# Puis la fonction de création du fichier de logs. À partir de maintenant, chaque sortie peut être redirigée vers un fichier de logs existant
	Mktmpdir 				# Puis la fonction de création du dossier temporaire
	GetMainPackageManager	# Puis la fonction de détection du gestionnaire de paquets principal de la distribution de l'utilisateur
	WritePackScript			# Puis la fonction de création de scripts d'installation

	# On écrit dans le fichier de logs que l'on passe à la première étape "visible dans le terminal", à savoir l'étape d'initialisation du script
	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_CYAN" \
			"VÉRIFICATION DES INFORMATIONS PASSÉES EN ARGUMENT" "0" >> "$FILE_LOG_PATH"
	} >> "$FILE_LOG_PATH"

	# On demande à l'utilisateur de bien confirmer son nom d'utilisateur, au cas où son compte utilisateur cohabite avec d'autres comptes
	EchoNewstep "Nom d'utilisateur entré :$COL_RESET ${ARG_USERNAME}"
	EchoNewstep "Est-ce correct ? (oui/non)"
	Newline

	# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
	# Les deux virgules suivant directement le "rep_ScriptInit" entre les accolades signifient que les mêmes réponses avec des
	# majuscules sont permises, peu importe où elles se situent dans la chaîne de caractères (pas de sensibilité à la casse).
	function ReadScriptInit()
	{
		read -rp "Entrez votre réponse : " rep_script_init
		echo "$rep_script_init" >> "$FILE_LOG_PATH"
		Newline

		case ${rep_script_init,,} in
			"oui" | "yes")
				EchoSuccess "Lancement du script"

				return
				;;
			"non" | "no")
				EchoError "Abandon"
				Newline

				exit 0
				;;
			*)
				EchoError "Réponses attendues : $(DechoE "oui") ou $(DechoE "non") (pas de sensibilité à la casse)"
				Newline

				ReadScriptInit
				;;
		esac
	}

	ReadScriptInit

	return
}

# Demande à l'utilisateur s'il souhaite vraiment lancer le script, puis connecte l'utilisateur en mode super-utilisateur
function LaunchScript()
{
	HeaderStep "LANCEMENT DU SCRIPT"

	EchoNewstep "Assurez-vous d'avoir lu au moins le mode d'emploi $(DechoN "(Mode d'emploi.odt)") avant de lancer l'installation."
    EchoNewstep "Êtes-vous sûr de bien vouloir lancer l'installation ? (oui/non)"
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	function ReadLaunchScript()
	{
        # On demande à l'utilisateur d'entrer une réponse
		read -rp "Entrez votre réponse : " rep_launch_script
		echo "$rep_launch_script" >> "$FILE_LOG_PATH"
		Newline

		# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
		case ${rep_launch_script,,} in
	        "oui")
				EchoSuccess "Vous avez confirmé vouloir exécuter ce script."
				EchoSuccess "C'est parti !!!"

				return
	            ;;
	        "non")
				EchoError "Le script ne sera pas exécuté"
	            EchoError "Abandon"
				Newline

				exit 0
	            ;;
            # Si une réponse différente de "oui" ou de "non" est rentrée
			*)
				Newline

				EchoNewstep "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")"
				Newline

				# On rappelle la fonction "ReadLaunchScript" en boucle tant qu"une réponse différente de "oui" ou de "non" est entrée
				ReadLaunchScript
				;;
	    esac
	}
	# Appel de la fonction "ReadLaunchScript", car même si la fonction est définie dans la fonction "LaunchScript", ses instructions ne sont pas lues automatiquement
	ReadLaunchScript
}


## DÉFINITION DES FONCTIONS DE CONNEXION À INTERNET ET DE MISES À JOUR
# Vérification de la connexion à Internet
function CheckInternetConnection()
{
	HeaderStep "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à Internet (pour le savoir, on ping le serveur DNS d'OpenDNS avec la commande ping 1.1.1.1)
	if ping -q -c 1 -W 1 opendns.com 2>&1 | tee -a "$FILE_LOG_PATH"; then
		EchoSuccess "Votre ordinateur est connecté à Internet"

		return
	# Sinon, si l'ordinateur n'est pas connecté à Internet
	else
		HandleErrors "AUCUNE CONNEXION À INTERNET" "Vérifiez que vous êtes bien connecté à Internet, puis relancez le script"
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets principal supporté
# (ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE PAS MODIFIER CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS PRINCIPAL (PAS DE SNAP OU DE FLATPAK) !!!)
function DistUpgrade()
{
	#***** Variables *****
	# Noms du dossier et des fichiers temporaires contenant les commandes de mise à jour selon le gestionnaire de paquets principal de l'utilisateur
	local update_d_name="Update"		# Dossier contenant les fichiers
	local pack_upg_f_name="pack.tmp"	# Fichier contenant la commande de mise à jour des paquets

	# Chemins du dossier et des fichiers temporaires contenant les commandes de mise à jour selon le gestionnaire de paquets principal de l'utilisateur
	local update_d_path="$DIR_TMP_PATH/$update_d_name"			# Chemin du dossier
	local pack_upg_f_path="$update_d_path/$pack_upg_f_name"		# Chemin du fichier contenant la commande de mise à jour des paquets

	# Vérification du succès des mises à jour
	local packs_updated="0"

	#***** Code *****
	HeaderStep "MISE À JOUR DU SYSTÈME"

	# On crée le dossier contenant les commandes de mise à jour
	if test ! -d "$update_d_path"; then
		Makedir "$DIR_TMP_PATH" "$update_d_name" "0" "0" >> "$FILE_LOG_PATH"
	fi

	# On récupère la commande de mise à jour du gestionnaire de paquets principal enregistée dans la variable "$PACK_MAIN_PACKAGE_MANAGER",
	case "$PACK_MAIN_PACKAGE_MANAGER" in
		"apt")
			echo apt-get -y upgrade > "$pack_upg_f_path"
			;;
		"dnf")
			echo dnf -y update > "$pack_upg_f_path"
			;;
		"pacman")
			echo pacman --noconfirm -Syu > "$pack_upg_f_path"
			;;
	esac

	# On met à jour les paquets
	EchoNewstep "Mise à jour des paquets"
	Newline

	bash "$pack_upg_f_path" # | tee -a "$FILE_LOG_PATH"

	if test "$?" -eq 0; then
		packs_updated="1"
		EchoSuccess "Tous les paquets ont été mis à jour"
		Newline

	else
		EchoError "Une ou plusieurs erreurs ont eu lieu lors de la mise à jour des paquets"
		Newline
	fi

	# On vérifie maintenant si le cache et les paquets ont bien été mis à jour
	# Si les paquets ont été mis à jour avec succès
	if test $packs_updated = "1"; then
		EchoSuccess "Les paquets ont été mis à jour avec succès"
		Newline

	# Sinon, si rien n'a été mis à jour
	else
		EchoError "La mise à jour des paquets a échouée"
		Newline
	fi

	return
}


## DÉFINITION DES FONCTIONS DE PARAMÉTRAGE
# Détection et installation de Sudo
function SetSudo()
{
	HeaderStep "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"

	# On crée une backup du fichier de configuration "sudoers" au cas où l'utilisateur souhaite revenir à son ancienne configuration
	local sudoers_old="/etc/sudoers - $DATE_TIME.old"

    EchoNewstep "Détection de sudo $COL_RESET"

	# On effectue un test pour savoir si la commande "sudo" est installée sur le système de l'utilisateur
	command -v sudo > /dev/null 2>&1 \

	if test "$?" != "0"; then
			EchoNewstep "La commande $(DechoN "sudo") n'est pas installé sur votre système"
			PackInstall "$PACK_MAIN_PACKAGE_MANAGER" "sudo"
	else
		EchoSuccess "La commande $(DechoS "sudo") est déjà installée sur votre système"
		Newline
	fi

	EchoNewstep "Le script va tenter de télécharger un fichier $(DechoN "sudoers") déjà configuré"
	EchoNewstep "depuis le dossier des fichiers ressources de mon dépôt Git : "
	echo ">>>> https://github.com/DimitriObeid/Linux-reinstall/tree/Beta/Ressources"
	Newline

	EchoNewstep "Souhaitez vous le télécharger PUIS l'installer maintenant dans le dossier $(DechoN "/etc/") ? (oui/non)"
	Newline

	echo ">>>> REMARQUE : Si vous disposez déjà des droits de super-utilisateur, ce n'est pas la peine de le faire !"
	echo ">>>> Si vous avez déjà un fichier sudoers modifié, une sauvegarde du fichier actuel sera effectuée dans le même dossier,"
	echo "	tout en arborant sa date de sauvegarde dans son nom (par exemple :$COL_CYAN sudoers - $DATE_TIME.old $COL_RESET)"
	Newline

	function ReadSetSudo()
	{
		read -rp "Entrez votre réponse : " rep_set_sudo
		echo "$rep_set_sudo" >> "$FILE_LOG_PATH"

		# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
		case ${rep_set_sudo,,} in
			"oui" | "yes")
				Newline

				# Sauvegarde du fichier "/etc/sudoers" existant en "sudoers.old"
				EchoNewstep "Création d'une sauvegarde de votre fichier $(DechoN "sudoers") existant nommée $(DechoN "sudoers $DATE_TIME.old")"
				cat "/etc/sudoers" > "$sudoers_old"

				if test "$?" != "0"; then
					EchoError "Impossible de créer une sauvegarde du fichier $(DechoE "sudoers")"
					Newline

					return
				else
					EchoSuccess "Le fichier de sauvegarde $(DechoS "$sudoers_old") a été créé avec succès"
					Newline
				fi

				# Téléchargement du fichier sudoers configuré
				EchoNewstep "Téléchargement du fichier sudoers depuis le dépôt Git $SCRIPT_REPO"
				sleep 1
				Newline

				wget https://raw.githubusercontent.com/DimitriObeid/Linux-reinstall/Beta/Ressources/sudoers -O "$DIR_TMP_PATH/sudoers" \

				if test "$?" != "0"; then
					EchoError "Impossible de télécharger le nouveau fichier $(DechoE "sudoers")"

					return
				else
					EchoSuccess "Le nouveau fichier $(DechoS "sudoers") téléchargé avec succès"
					Newline
				fi

				# Déplacement du fichier vers le dossier "/etc/"
				EchoNewstep "Déplacement du fichier $(DechoN "sudoers") vers le dossier $(DechoN "/etc")"
				mv "$DIR_TMP_PATH/sudoers" /etc/sudoers \

				if test "$?" != "0"; then
					EchoError "Impossible de déplacer le fichier $(DechoE "sudoers") vers le dossier $(DechoE "/etc/")"

					return
				else
					EchoSuccess "Fichier $(DechoS "sudoers") déplacé avec succès vers le dossier $(DechoS "/etc/")"
					Newline
				fi

				# Ajout de l'utilisateur au groupe "sudo"
				EchoNewstep "Ajout de l'utilisateur $(DechoN "${ARG_USERNAME}") au groupe sudo"
				usermod -aG root "${ARG_USERNAME}" 2>&1 | tee -a "$FILE_LOG_PATH"

				if test "$?" != "0"; then
					EchoError "Impossible d'ajouter l'utilisateur $(DechoE "${ARG_USERNAME}") à la liste des sudoers"

					return
				else
					EchoSuccess "L'utilisateur $(DechoS "${ARG_USERNAME}") a été ajouté au groupe sudo avec succès"

					return
				fi
				;;
			"non" | "no")
				Newline

				EchoSuccess "Le fichier $(DechoS "/etc/sudoers") ne sera pas modifié"

				return
				;;
			*)
				Newline

				EchoNewstep "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")"
				ReadSetSudo
				;;
		esac
	}
	ReadSetSudo

	return
}


# DÉFINITION DES FONCTIONS DE FIN D'INSTALLATION
# Suppression des paquets obsolètes
function Autoremove()
{
	HeaderStep "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"

	EchoNewstep "Souhaitez vous supprimer les paquets obsolètes ? (oui/non)"
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il souhaite supprimer les paquets obsolètes
	function ReadAutoremove()
	{
		read -rp "Entrez votre réponse : " rep_autoremove
		echo "$rep_autoremove" >> "$FILE_LOG_PATH"

		case ${rep_autoremove,,} in
			"oui" | "yes")
				Newline

				EchoNewstep "Suppression des paquets"
				Newline

	    		case "$PACK_MAIN_PACKAGE_MANAGER" in
					"apt")
	            		apt-get -y autoremove
	            		;;
					"dnf")
		           		dnf -y autoremove
		           		;;
	        		"pacman")
	            		pacman --noconfirm -Qdt
	            		;;
				esac

				Newline

				EchoSuccess "Auto-suppression des paquets obsolètes effectuée avec succès"

				return
				;;
			"non" | "no")
				Newline

				EchoSuccess "Les paquets obsolètes ne seront pas supprimés"
				EchoSuccess "Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets"

				return
				;;
			*)
				Newline

				EchoNewstep "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")"
				ReadAutoremove
				;;
		esac
	}
	ReadAutoremove

	return
}

# Fin de l'installation
function IsInstallationDone()
{
	HeaderStep "INSTALLATION TERMINÉE"

	EchoNewstep "Souhaitez-vous supprimer le dossier temporaire $(DechoN "$DIR_TMP_PATH") ? (oui/non)"
	Newline

	read -rp "Entrez votre réponse : " rep_erase_tmp
	echo "$rep_erase_tmp" >> "$FILE_LOG_PATH"

	case ${rep_erase_tmp,,} in
		"oui")
			EchoNewstep "Déplacement du fichier de logs dans votre dossier personnel"
			Newline

			mv -v "$FILE_LOG_PATH" "$DIR_HOMEDIR" 2>&1 | tee -a "$DIR_HOMEDIR/$FILE_LOG_NAME" && FILE_LOG_PATH=$"$DIR_HOMEDIR" \
				&& EchoSuccess "Le fichier de logs a bien été deplacé dans votre dossier personnel"

			EchoNewstep "Suppression du dossier temporaire $DIR_TMP_PATH"
			rm -rfv "$DIR_TMP_PATH" >> "$FILE_LOG_PATH"

			if test "$?" != "0"; then
				EchoError "Suppression du dossier temporaire impossible. Essayez de le supprimer manuellement"
			else
				EchoSuccess "Le dossier temporaire $(DechoS "$DIR_TMP_PATH") a été supprimé avec succès"
				Newline
			fi
			;;
		*)
			EchoSuccess "Le dossier temporaire $(DechoS "$DIR_TMP_PATH") ne sera pas supprimé"
			;;
	esac

    EchoSuccess "Installation terminée. Votre distribution Linux est prête à l'emploi"
	Newline

	echo "$COL_CYAN\Note :$COL_RESET Si vous avez constaté un bug ou tout autre problème lors de l'exécution du script,"
	echo "vous pouvez m'envoyer le fichier de logs situé dans votre dossier personnel."
	echo "Il porte le nom de $COL_CYAN$FILE_LOG_NAME$COL_RESET"
	Newline

    # On tue le processus de connexion en mode super-utilisateur
	sudo -k

	exit 0
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################



## APPEL DES FONCTIONS D'INITIALISATION ET DE PRÉ-INSTALLATION
# Détection du mode super-administrateur (root) et de la présence de l'argument contenant le nom d'utilisateur
ScriptInit

# Affichage du header de bienvenue
HeaderStep "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX : VERSION $VER_SCRIPT !!!!!"
EchoSuccess "Début de l'installation"

LaunchScript			# Assurance que l'utilisateur soit sûr de lancer le script
CheckInternetConnection	# Détection de la connexion à Internet
DistUpgrade				# Mise à jour des paquets actuels

## INSTALLATIONS PRIORITAIRES ET CONFIGURATIONS DE PRÉ-INSTALLATION
# On déclare une variable "main" et on lui assigne en valeur le nom du gestionnaire de paquet principal stocké dans la variable "$PACK_MAIN_PACKAGE_MANAGER"
main="$PACK_MAIN_PACKAGE_MANAGER"

HeaderStep "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
PackInstall "$main" curl
PackInstall "$main" snapd
PackInstall "$main" wget

command -v curl snap wget >> "$FILE_LOG_PATH" \

if test "$?" != "0"; then
	HandleErrors "AU MOINS UNE DES COMMANDES D'INSTALLATION MANQUE À L'APPEL" "Essayez de  télécharger manuellement ces paquets : $(DechoE "curl"), $(DechoE "snapd") et $(DechoE "wget")" \
else
	EchoSuccess "Les commandes importantes d'installation ont été installées avec succès"
fi

# Installation de sudo (pour les distributions livrées sans la commande) et configuration du fichier "sudoers" ("/etc/sudoers")
SetSudo


## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS DES GESTIONNAIRES DE PAQUETS
HeaderStep "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS DES GESTIONNAIRES DE PAQUETS"

EchoSuccess "Vous pouvez désormais quitter votre ordinateur pour chercher un café"
EchoSuccess "La partie d'installation de vos programmes commence véritablement"
sleep 1

Newline
Newline

sleep 3

# Commandes
HeaderInstall "INSTALLATION DES COMMANDES PRATIQUES"
PackInstall "$main" htop
PackInstall "$main" neofetch
PackInstall "$main" tree

# Développement
HeaderInstall "INSTALLATION DES OUTILS DE DÉVELOPPEMENT"
PackInstall "snap" atom --classic --stable		# Éditeur de code Atom
PackInstall "snap" code --classic	--stable	# Éditeur de code Visual Studio Code
PackInstall "$main" emacs
PackInstall "$main" g++
PackInstall "$main" gcc
PackInstall "$main" git

PackInstall "$main" make
PackInstall "$main" umlet
PackInstall "$main" valgrind

# Logiciels de nettoyage de disque
HeaderInstall "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"
PackInstall "$main" k4dirstat

# Internet
HeaderInstall "INSTALLATION DES CLIENTS INTERNET"
PackInstall "snap" discord --stable
PackInstall "snap" skype --stable
PackInstall "$main" thunderbird

# LAMP
HeaderInstall "INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP"
PackInstall "$main" apache2
PackInstall "$main" php
PackInstall "$main" libapache2-mod-php
PackInstall "$main" mariadb-server		# Pour installer un serveur MariaDB (Si vous souhaitez un seveur MySQL, remplacez "mariadb-server" par "mysql-server"
PackInstall "$main" php-mysql
PackInstall "$main" php-curl
PackInstall "$main" php-gd
PackInstall "$main" php-intl
PackInstall "$main" php-json
PackInstall "$main" php-mbstring
PackInstall "$main" php-xml
PackInstall "$main" php-zip

# Librairies
HeaderInstall "INSTALLATION DES LIBRAIRIES"
PackInstall "$main" python3.7

# Réseau
HeaderInstall "INSTALLATION DES LOGICIELS RÉSEAU"
PackInstall "$main" wireshark

# Vidéo
HeaderInstall "INSTALLATION DES LOGICIELS VIDÉO"
PackInstall "$main" vlc

# Wine
HeaderInstall "INSTALLATION DE WINE"
PackInstall "$main" wine-stable

EchoSuccess "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS DEPUIS LES  GESTIONNAIRES DE PAQUETS !"


## INSTALLATION DES LOGICIELS ABSENTS DES GESTIONNAIRES DE PAQUETS
HeaderStep "INSTALLATION DES LOGICIELS INDISPONIBLES DANS LES BASES DE DONNÉES DES GESTIONNAIRES DE PAQUETS"

EchoNewstep "Les logiciels téléchargés via la commande $(DechoN "wget") sont déplacés vers le nouveau dossier $(DechoN "$DIR_SOFTWARE_NAME"), localisé dans votre dossier personnel"
sleep 1
Newline

# Création du dossier "Logiciels.Linux-reinstall.d" dans le dossier personnel de l'utilisateur
EchoNewstep "Création du dossier d'installation des logiciels"
Newline

Makedir "$DIR_HOMEDIR" "$DIR_SOFTWARE_NAME" "2" "1" 2>&1 | tee -a "$FILE_LOG_PATH"
Newline

# Installation de JMerise
SoftwareInstall "http://www.jfreesoft.com" \
				"JMeriseEtudiant.zip" \
				"JMerise" \
				"JMerise est un logiciel dédié à la modélisation des modèles conceptuels de donnée pour Merise" \
				"JMerise.jar" \
				"" \
				"Application" \
				"Développement"


## INSTALLATIONS SUPPLÉMENTAIRES
# Installation de paquets

## FIN D'INSTALLATION
# Suppression des paquets obsolètes
Autoremove

# Fin de l'installation
IsInstallationDone
