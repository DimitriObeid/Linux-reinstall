#!/usr/bin/env bash

# Script de réinstallation minimal pour les cours de BTS SIO en version Bêta
# Version Bêta 2.0

# Pour débugguer ce script en cas de besoin, tapez la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

# Ou débugguez le en utilisant l'excellent utilitaire Shell Check :
#	En ligne -> https://www.shellcheck.net/
#	En ligne de commandes -> shellcheck beta.sh
#		--> Commande d'installation de l'utilitaire : sudo $gestionnaire_de_paquets $option_d'installation shellcheck



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



############### DÉCLARATION DES VARIABLES GLOBALES ET AFFECTATION DE LEURS VALEURS ###############

## ARGUMENTS
# Arguments à placer après la commande d'exécution du script pour qu'il s'exécute
ARG_USERNAME=$1		# Premier argument : Le nom du compte de l'utilisateur


## CHRONOMÈTRE
# Mettre en pause le script pendant un certain temps pour mieux lire chaque message.
# Pour changer une durée de chronométrage, changez la valeur de la commande "sleep" voulue.
# Pour désactiver cette fonctionnalité, mettez la valeur de la commande "sleep" à 0.
# ATTENTION À NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE LA COMMANDE "sleep" NE SERA PAS INTERPRÉTÉE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
TIM_0_5=sleep\ .5			# Met le script en pause pendant 0,5 seconde. Exemple d'utilisation : temps d'affichage d'un texte de sous-étape
TIM_1=sleep\ 1				# Met le script en pause pendant une seconde. Exemple d'utilisation : temps d'affichage du nom du paquet avant l'affichage du reste de l'étape lors de l'installation d'un nouveau paquet
TIM_1_5=sleep\ 1.5		# Met le script en pause pendant 1,5 seconde. Exemple d'utilisation : temps d'affichage d'un header uniquement, avant l'affichage du reste de l'étape lors d'un changement d'étape


## COULEURS
# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
COL_BLUE=$(tput setaf 4)				# Bleu foncé	--> Couleur des headers à n'écrire que dans le fichier de logs
COL_CYAN=$(tput setaf 6)				# Bleu cyan		--> Couleur des headers
COL_GREEN=$(tput setaf 82)		 	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape
COL_RED=$(tput setaf 196) 	  	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape
COL_RESET=$(tput sgr0)     			# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal
COL_YELLOW=$(tput setaf 226) 		# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes


# DATE
# Enregistrement de la date au format YYYY-MM-DD hh-mm-ss (année-mois-jour heure-minute-seconde). Cette variable peut être utilisée pour écrire une partie du nom d'un dossier ou d'un fichier
DATE_TIME=$(date +"%Y-%m-%d %Hh-%Mm-%Ss")


## DOSSIERS
# Définition du dossier personnel de l'utilisateur
DIR_HOMEDIR="/home/${ARG_USERNAME}"					# Dossier personnel de l'utilisateur

# Définition du dossier temporaire et de son chemin
DIR_TMPDIR="Linux-reinstall.tmp.d"					# Nom du dossier temporaire
DIR_TMPPARENT="/tmp"												# Dossier parent du dossier temporaire
DIR_TMPPATH="$DIR_TMPPARENT/$DIR_TMPDIR"		# Chemin complet du dossier temporaire

# Définition du dossier d'installation de logiciels indisponibles via les gestionnaires de paquets
DIR_SOFTWARE="Logiciels.Linux-reinstall.d"


## FICHIERS
# Définition du nom et du chemin du fichier de logs
FILE_LOGNAME="Linux-reinstall $DATE_TIME.log"		# Nom du fichier de logs
FILE_LOGPATH="$PWD/$FILE_LOGNAME"								# Chemin du fichier de logs depuis la racine, dans le dossier actuel (il est mis à jour pendant l'initialisation du script)


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
TXT_R_TAB="$COL_RED$TXT_TAB$TXT_TAB"			# Encodage de la couleur en rouge et affichage de 4 * 2 chevrons
TXT_Y_TAB="$COL_YELLOW$TXT_TAB"						# Encodage de la couleur en jaune et affichage de 4 chevrons


## VERSION
# Version actuelle du script
VER_SCRIPT="2.0"



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



############################################# DÉFINITIONS DES FONCTIONS #############################################


#### DÉFINITION DES FONCTIONS INDÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####



#### DÉFINITION DES FONCTIONS D'AFFICHAGE DE TEXTE
# Fonction servant à colorer d'une autre colueur une partie du texte de changement de sous-étape (jeu de mots entre "déco(ration)" et "echo"), suivi de la première lettre du nom du type de message (passage, échec ou cuccès)
function DechoN() { string=$1; echo "$COL_CYAN$string$COL_YELLOW"; }

# Affichage d'un message de changement de sous-étape en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs, en jaune, avec des chevrons et sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function EchoNewstep() { string=$1; echo "$TXT_Y_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOGPATH"; $TIM_0_5; }

# Affichage d'un message de changement de sous-étape dont le temps de pause du script peut être choisi en argument
function EchoNewstepCustomTimer() { string=$1; timer=$2; echo "$TXT_Y_TAB $string$COL_RESET"; sleep "$timer"; }

# Affichage d'un message de changement de sous-étape sans redirections vers le fichier de logs
function EchoNewstepNoLog() { string=$1; echo "$TXT_Y_TAB $string$COL_RESET"; }


# Fonction servant à colorer d'une autre colueur une partie du message d'échec de sous-étape (jeu de mots entre "déco(ration)" et "echo"), suivi de la première lettre du nom du type de message (passage, échec ou succès)
function DechoE() { string=$1; echo "$COL_CYAN$string$COL_RED"; }

# Appel de la fonction "EchoErrorNoLog" en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoError() { string=$1; echo "$TXT_R_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOGPATH"; $TIM_0_5; }

# Affichage d'un message d'échec de sous-étape dont le temps de pause du script peut être choisi en argument
function EchoErrorCustomTimer() { string=$1; timer=$2; echo "$TXT_R_TAB $string$COL_RESET"; sleep "$timer"; }

# Affichage d'un message d'échec de sous-étape sans redirections vers le fichier de logs
function EchoErrorNoLog() { string=$1; echo "$TXT_R_TAB $string $COL_RESET"; }


# Fonction servant à colorer d'une autre colueur une partie du texte de réussite de sous-étape (jeu de mots entre "déco(ration)" et "echo"), suivi de la première lettre du nom du type de message (passage, échec ou succès)
function DechoS() { string=$1; echo "$COL_CYAN$string$COL_GREEN"; }

# Appel de la fonction "EchoSuccessNoLog" en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoSuccess() { string=$1; echo "$TXT_G_TAB $string$COL_RESET" 2>&1 | tee -a "$FILE_LOGPATH"; $TIM_0_5; }

# Affichage d'un message de succès de sous-étape dont le temps de pause du script peut être choisi en argument
function EchoSuccessCustomTimer() { string=$1; timer=$2; echo "$TXT_G_TAB $string$COL_RESET"; sleep "$timer"; }

# Affichage d'un message de succès sans redirections vers le fichier de logs
function EchoSuccessNoLog() { string=$1; echo "$TXT_G_TAB $string$COL_RESET"; }


# Fonction de saut de ligne pour la zone de texte du terminal et pour le fichier de logs
function Newline() { echo "" | tee -a "$FILE_LOGPATH"; }

# Fonction de saut de ligne pour le fichier de logs uniquement (utiliser la fonction "Newline" en redirigeant sa sortie vers le fichier de logs provoque un saut de deux lignes au lieu d'une)
function NewlineLog() { echo "" >> "$FILE_LOGPATH"; }


## DÉFINITION DES FONCTIONS DE CRÉATION DE HEADERS
# Fonction de création et d'affichage des lignes des headers
function DrawHeaderLine()
{
	line_color=$1			# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction
	line_char=$2			# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction

	# Définition de la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	# Si la chaîne de caractère de la variable $line_color (qui contient l'encodage de la couleur du texte) n'est pas vide,
	# alors on écrit l'encodage de la couleur dans le terminal, qui affiche la couleur, et non son encodage en texte.

	# L'encodage de la couleur peut être écrit via la commande "tput cols $encodage_de_la_couleur"
	# Elle est vide tant que le paramètre "$line_color" n'est pas passé en argument lors de l'appel de la fonction ET qu'une
	# valeur de la commande "tput setaf" ne lui est pas retournée.

	# Comme on souhaite écrire les caractères composant la ligne du header à la suite de la string d'encodage de la couleur, on utilise
	# les options '-n' et '-e' de la commande "echo" pour ne pas faire un saut de ligne entre la string et les caractères de la ligne
	if test "$line_color" != ""; then
		echo -ne "$line_color"
	fi


	# Affichage du caractère souhaité sur toute la ligne. Pour cela, en utilisant une boucle "for", on commence à la lire à partir
	# de la première colonne (1), puis, on parcourt toute la ligne jusqu'à la fin de la zone de texte du terminal. À chaque appel
	# de la commande "echo", un caractère est affiché et coloré selon l'encodage défini et écrit ci-dessus.

	# La variable 'i' de la boucle "for i in" a été remplacé par un underscore '_' pour que Shellcheck arrête d'envoyer un message d'avertissement
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
	line_color=$1		# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction
	line_char=$2		# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction
	string_color=$3		# Définition de la couleur de la chaîne de caractères du header
	string=$4			# Chaîne de caractères affichée dans chaque header

	# Définition de la couleur de la ligne du caractère souhaité.
	# Ce code produit le même résultat que la première condition de la fonction "DrawHeaderLine", mais il a été
	# réécrit ici car aucune partie d'une fonction ne peut être utilisée individuellement depuis une autre fonction
	if test "$line_color" == ""; then
        # Définition de la couleur de la ligne.
		# Ne pas ajouter de '$' avant le nom de la variable "header_color", sinon la couleur souhaitée ne s'affiche pas
		echo -ne "$line_color"
	fi

	DrawHeaderLine "$line_color" "$line_char"
	# Affichage une autre couleur pour le texte
	echo "$string_color""##>" "$string" "$COL_RESET"
	DrawHeaderLine "$line_color" "$line_char"

	# Ne pas appeler la fonction "Newline" ici, car cette dernière est automatiquement réappelée lors de la redirection de la fonction "HeaderBase"
	# vers le terminal et le fichier de logs, puis une troisième fois dans les fonctions "ScriptHeader" et "HeaderInstall" (dans le cas où on appelle
	# la fonction "Newline" ici, puis une seule et unique fois dans une des deux fonctions suivantes)

	return
}

# Fonction d'affichage des headers lors d'un changement d'étape
function ScriptHeader()
{
	string=$1

	Newline

	HeaderBase "$COL_CYAN" "$TXT_HEADER_LINE_CHAR" "$COL_CYAN" "$string" 2>&1 | tee -a "$FILE_LOGPATH"

	Newline
	Newline

	$TIM_1_5

	return
}

# Fonction d'affichage de headers lors du passage à une nouvelle catégorie de paquets lors de l'installation de ces derniers
function HeaderInstall()
{
	string=$1

	Newline

	HeaderBase "$COL_STEP" "$TXT_HEADER_LINE_CHAR" "$COL_SUCC" "$string"  2>&1 | tee -a "$FILE_LOGPATH"
	Newline
	Newline

	$TIM_1_5

	return
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger)
function HandleErrors()
{
	#***** Paramètre *****
	string=$1

	# ***** Code
	Newline

	HeaderBase "$COL_ERR" "$TXT_HEADER_LINE_CHAR" "$COL_ERR" "ERREUR FATALE : $string" 2>&1 | tee -a "$FILE_LOGPATH"
	Newline
	Newline

	$TIM_1_5

	EchoErrorNoLog "Une erreur fatale s'est produite :" 2>&1 | tee -a "$FILE_LOGPATH"
	EchoErrorNoLog "$string" 2>&1 | tee -a "$FILE_LOGPATH"
	Newline

	EchoErrorNoLog "Arrêt de l'installation" 2>&1 | tee -a "$FILE_LOGPATH"
	Newline

	# Si le fichier de logs se trouve toujours dans le dossier actuel (si le script a été exécuté depuis un autre dossier)
	if test ! -f "$DIR_HOMEDIR/$FILE_LOGNAME"; then
		mv -v "$FILE_LOGNAME" "$DIR_HOMEDIR" >> "$FILE_LOGPATH"
	fi

	EchoError "En cas de bug, veuillez m'envoyer le fichier de logs situé à l'adresse suivante : $(DechoE "$FILE_LOGPATH")"
	Newline

	exit 1
}


#### DÉFINITION DES FONCTIONS DE CRÉATION DE FICHIERS ET DE DOSSIERS
# Fonction de création de dossiers ET d'attribution récursive des droits de lecture et d'écriture à l'utilisateur
# LORS DE SON APPEL, LA SORTIE DE CETTE FONCTION DOIT ÊTRE REDIRIGÉE SOIT VERS LE TERMINAL ET LE FICHIER DE LOGS, SOIT VERS LE FICHIER DE LOGS UNIQUEMENT
function Makedir()
{
	#***** Paramètres *****
	dir_parent=$1		# Emplacement depuis la racine du dossier parent du dossier à créer
	dir_name=$2			# Nom du dossier à créer (dans son dossier parent)
	dir_sleep=$3		# Temps d'affichage des messages de passage à une nouvelle sous-étape, d'échec ou de succès

	#***** Autres variables *****
		# Chemin
	dir_path="$dir_parent/$dir_name"

	#***** Code *****
	if test ! -d "$dir_path"; then
		EchoNewstepCustomTimer "Création du dossier $(DechoN "$dir_name") dans le dossier $(DechoN "$dir_parent")" "$dir_sleep"
		# Attention à ne pas supprimer le '/' suivant immédiatement la variable "$dir_path"
		mkdir -v "$dir_path" >> "$FILE_LOGPATH" \
			|| HandleErrors "LE DOSSIER $(DechoE "$dir_name") N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER PARENT $(DechoE "$dir_parent")" \
			&& EchoSuccessCustomTimer "Le dossier $(DechoS "$dir_name") a été créé avec succès dans le dossier $(DechoS "$dir_parent")" "$dir_sleep"
		echo ""	# On ne redirige pas les sauts de ligne vers le fichier de logs, pour éviter de les afficher en double en cas d'appel de la fonction avec redirections

		# On change les droits du dossier créé par le script
		# Comme il est exécuté en mode super-utilisateur, le dossier créé appartient totalement au super-utilisateur.
		# Pour attribuer les droits de lecture, d'écriture et d'exécution (rwx) à l'utilisateur normal, on appelle
		# la commande chown avec pour arguments :
		#		- Le nom de l'utilisateur à qui donner les droits
		#		- Le chemin du dossier cible
		#		- Ici, la variable contenant la redirection
		chown -Rv "${ARG_USERNAME}" "$dir_path" >> "$FILE_LOGPATH" \
			|| {
				EchoErrorCustomTimer "Impossible de changer les droits du dossier $(DechoE "$dir_path")" "$dir_sleep"
				EchoErrorCustomTimer "Pour changer les droits du dossier $(DechoE "$dir_path") de manière récursive," "$dir_sleep"
				EchoErrorCustomTimer "utilisez la commande :" "$dir_sleep"
				echo "	chown -R ${ARG_USERNAME} $dir_path"

				return
			} \
			&& EchoSuccessCustomTimer "Les droits du dossier $(DechoS "$dir_name") ont été changés avec succès" "$dir_sleep"
			echo ""

		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent ET que ce dossier contient AU MOINS un fichier ou dossier
	elif test -d "$dir_path" && test "$(ls -A "$dir_path/")"; then
		EchoNewstepCustomTimer "Un dossier non-vide portant exactement le même nom se trouve déjà dans le dossier cible $(DechoN "$dir_parent")" "$dir_sleep"
		EchoNewstepCustomTimer "Suppression du contenu du dossier $(DechoN "$dir_path")" "$dir_sleep"

		# ATTENTION À NE PAS MODIFIER LA COMMANDE SUIVANTE", À MOINS DE SAVOIR EXACTEMENT CE QUE VOUS FAITES !!!
		# Pour plus d'informations sur cette commande complète --> https://github.com/koalaman/shellcheck/wiki/SC2115
		rm -rfv "${dir_path/:?}/"* \
			|| {
				EchoErrorCustomTimer "Impossible de supprimer le contenu du dossier $(DechoE "$dir_path")" "$dir_sleep";
				EchoErrorCustomTimer "Le contenu de tout fichier du dossier $(DechoE "$dir_path") portant le même nom qu'un des fichiers téléchargés sera écrasé" "$dir_sleep"
				echo ""

				return
			} && \
			{
				EchoSuccessCustomTimer "Suppression du contenu du dossier $(DechoS "$dir_path") effectuée avec succès" "$dir_sleep"
				echo ""
			}

		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent ET que ce dossier est vide
	elif test -d "$dir_path/"; then
		EchoSuccessCustomTimer "Le dossier $(DechoS "$dir_path") existe déjà" "$dir_sleep"

		return
	fi
}

# Fonction de création de fichiers ET d'attribution des droits de lecture et d'écriture à l'utilisateur
# LORS DE SON APPEL, LA SORTIE DE CETTE FONCTION DOIT ÊTRE REDIRIGÉE SOIT VERS LE TERMINAL ET LE FICHIER DE LOGS, SOIT VERS LE FICHIER DE LOGS UNIQUEMENT
function Makefile()
{
	#***** Paramètres *****
	file_parent=$1		# Emplacement depuis la racine du dossier parent du fichier à créer
	file_name=$2			# Nom du fichier à créer (dans son dossier parent)
	file_sleep=$3			# Temps d'affichage des messages de passage à une nouvelle sous-étape, d'échec ou de succès

	#***** Autres variables *****
		# Chemin
	file_path="$file_parent/$file_name"

	#***** Code *****
	# Si le fichier à créer n'existe pas
	if test ! -s "$file_path"; then
		touch "$file_path" >> "$FILE_LOGPATH" \
			|| HandleErrors "LE FICHIER $(DechoE "$file_name") n'a pas pu être créé dans le dossier $(DechoE "$file_parent")" \
			&& EchoSuccessCustomTimer "Le fichier $(DechoS "$file_name") a été créé avec succès dans le dossier $(DechoS "$file_parent")" "$file_sleep"
		echo ""

		# On vérifie si la valeur de l'argument correspond au nom de l'utilisateur pour éviter d'afficher un message d'erreur s'il rentre un mauvais nom en argument
		if test "$(pwd | cut -d '/' -f-3 | cut -d '/' -f3-)" = "${ARG_USERNAME}"; then
			chown -v "${ARG_USERNAME}" "$file_path" >> "$FILE_LOGPATH" \
			|| {
				EchoErrorCustomTimer "Impossible de changer les droits du fichier $(DechoE "$file_path")" "$file_sleep"
				EchoErrorCustomTimer "Pour changer les droits du fichier $(DechoE "$file_path")," "$file_sleep"
				EchoErrorCustomTimer "utilisez la commande :" "$file_sleep"
				echo "	chown ${ARG_USERNAME} $file_path"

				return
			} \
			&& EchoSuccessCustomTimer "Les droits du fichier $(DechoS "$file_parent") ont été changés avec succès" "$file_sleep"

			echo ""

			return
		fi

	# Sinon, si le fichier à créer existe déjà ET qu'il est vide
	elif test -f "$file_path" && test -s "$file_path"; then
		EchoSuccessCustomTimer "Le fichier $(DechoS "$file_name") existe déjà dans le dossier $(DechoS "$file_parent")" "$file_sleep"

		return

	# Sinon, si le fichier à créer existe déjà ET qu'il n'est pas vide
elif test -f "$file_path" && test ! -s "$file_path"; then
		true > "$file_path" \
			|| EchoErrorCustomTimer "Le contenu du fichier $(DechoE "$file_path") n'a pas été écrasé" "$file_sleep" \
			&& EchoSuccessCustomTimer "Le contenu du fichier $(DechoS "$file_path") a été écrasé avec succès" "$file_sleep"
		Newline

		return
	fi
}


#### DÉFINITION DES FONCTIONS D'INSTALLATION DE PAQUETS DEPUIS UN GESTIONNAIRE DE PAQUETS
## VARIABLES
		# Vérification de la présence d'un paquet dans la base de données du gestionnaire
	packages_not_found_dir="$DIR_TMPPATH/Packages not found"	# Chemin du fichier contenant les paquets introuvables dans la base données du gestionnaire de paquets
	packages_not_found_file="Packages not found.txt"
	packages_not_installed="Packages not installed.txt"
	packages_not_found_file_path="$packages_not_found_dir/$packages_not_found_file"

		# Commandes des gestionnaires de paquets
	

		# Vérification de la présence d'un paquet
	exists_in_package_manager_database="False"
	is_installed="False"		# Variable servant à enregistrer la présence d'un paquet sur le disque dur de l'utilisateur

## FONCTIONS
# Vérification de l'existence du paquet dans la base de données du gestionnaire de paquets.
#     Mettre ce commentaire dans la doc, puis le supprimer du script --> S'il n'existe pas, le nom est envoyé dans un fichier texte pour indiquer à l'utilisateur quels sont les paquets à télécharger sur Internet pour récupérer et compiler leur code source s'il le souhaite
function PackManagerCheck()
{
	#***** Paramètres *****
		# Nom du paquet à installer
	package_name=$1
		# Commande complète de recherche du paquet dans la base de données du gestionnaire de paquets# Commandes du gestionnaire de paquets
	search_command="$*"

	#***** Code *****
	EchoNewstep "Vérification de la présence du paquet $(DechoN "$package_name") dans la base de données du gestionnaire $(DechoN "$PACK_MAIN_PACKAGE_MANAGER")"
	if test "$($search_command "$package_name")"; then
		EchoSuccess "Le paquet $(DechoS "$package_name") a été trouvé dans la base de données du gestionnaire $(DechoS "$PACK_MAIN_PACKAGE_MANAGER")"
		Newline

		return
	else
		EchoError "Le paquet $(DechoE "$package_name") n'a pas été trouvé dans la base de données du gestionnaire $(DechoE "$PACK_MAIN_PACKAGE_MANAGER")"
		Newline

		if test ! -d "$packages_not_found_dir"; then
			Makedir "$DIR_TMPPATH" "$packages_not_found_dir" 2>&1 | tee -a "$FILE_LOGPATH"
		fi

		Makefile "$packages_not_found_dir" "" 2>&1 | tee -a "$FILE_LOGPATH"

		if test -f "$packages_not_found_file_path"; then
			echo "$package_name" >> "$packages_not_found_file_path"
			return
		fi

		return
	fi
}

# Adaptation de la commande de vérification de présence de paquets selon le gestionnaire de paquets
function PackManagerList()
{
	#***** Paramètres *****
		# Nom du paquet à installer
	package_name=$1
		# Commande complète de recherche du paquet sur le disque dur de l'utilisateur
	list_command="$*"

	#***** Code *****
	# Cette ligne sert à m'assurer que le code fonctionne
	EchoNewstep "Vérification de la présence du paquet $(DechoN "$package_name")" # >> "$FILE_LOGPATH"
	"$($list_command)" "$package_name" 2>&1 | grep -o "$package_name" >> "$FILE_LOGPATH" \
		|| PackManagerInstall "$*" \
		&& {
			is_installed="True"
			EchoSuccess "Le paquet $(DechoS "$package_name") est déjà installé"
			Newline

			Newline
		}

	return
}

# Adaptation de la commande d'installation selon le gestionnaire de paquets
function PackManagerInstall()
{
	#***** Paramètres *****
		# Nom du paquet à installer
	package_name=$1
		# Commande complète d'installation de paquet
	install_command="$*"

	#***** Code *****
	if test "$is_installed" == "False"; then
		EchoNewstep "Installation du paquet $(DechoN "$package_name")"
		$TIM_1

		# On appelle la commande d'installation du gestionnaire de paquets,
		# puis on assigne la valeur de la variable "is_installed" à 1 si l'opération est un succès (&&)
		"$($install_command)" "$package_name" 2>&1 | tee -a "$FILE_LOGPATH" \
			|| {
				EchoError "Le paquet $(DechoE "$package_name") est introuvable dans les dépôts de votre gestionnaire de paquets"
				Newline

				Newline

				return
			} \
			&& is_installed="True"
		Newline

		$TIM_1

		# On vérifie que le paquet à installer a été correctement installé
		EchoNewstep "Vérification de l'installation du paquet $(DechoN "$package_name")" # >> "$FILE_LOGPATH"
		if test "$is_installed" == "True"; then
			EchoSuccess "Le paquet $(DechoS "$package_name") a été installé avec succès"
			# On remet la valeur de la variable "is_installed" à "False"
			is_installed="False"
			Newline

			Newline

		else
			EchoError "L'installation du paquet $(DechoE "$package_name") a échoué"
			Newline

			Newline
		fi
	fi

	return
}

# Téléchargement des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets, puis installation des paquets
function PackInstall()
{
	# Installation du paquet souhaité selon la commande d'installation du gestionnaire de paquets de la distribution de l'utilisateur
	# Pour chaque gestionnaire de paquets, on appelle la fonction "PackManagerCheck" pour vérifier la présence du paquet dans la base de données du gestionnaire,
	# puis on appelle la fonction "PackManagerList" pour vérifier si le paquet désiré est déjà installé sur le disque dur de l'utilisateur.
	# Enfin, on appelle la fonction "PackManagerInstall" pour installer le paquet tout en forçant le choix de l'utilisateur
	case $PACK_MAIN_PACKAGE_MANAGER in
		"APT")
			PackManagerCheck apt-get show
			PackManagerList apt-get list --installed
			PackManagerInstall apt-get -y install
			;;
		"DNF")
			PackManagerCheck
			PackManagerList
			PackManagerInstall dnf -y install
			;;
		"Emerge")
			PackManagerCheck
			PackManagerList
			PackManagerInstall emerge
			;;
		"Pacman")
			PackManagerCheck
	    	PackManagerList pacman -Q
			# PackManagerInstall pacman --noconfirm -S
			;;
		"Zypper")
			PackManagerCheck
			PackManagerList
			PackManagerInstall zypper -y install
			;;
	esac

	return
}

# Installation de paquets via le gestionnaire de paquets Snap
function SnapInstall()
{
    PackManagerCheck
	PackManagerList
	PackManagerInstall snap install "$@"	# Ce tableau d'arguments sert à utiliser les options de téléchargement passées en argument

	return
}


#### DÉFINITION DE LA FONCTION D'INSTALLATION DES LOGICIELS ABSENTS DES BASES DE DONNÉES DES GESTIONNAIRES DE PAQUETS
# Installation de logiciels absents de la base de données de tous les gestionnaires de paquets
function SoftwareInstall()
{
	#***** Paramètres *****
	software_web_link=$1		# Adresse de téléchargement du logiciel (téléchargement via la commande "wget"), SANS LE NOM DE L'ARCHIVE
	software_archive=$2			# Nom de l'archive contenant les fichiers du logiciel
	software_name=$3			# Nom du logiciel
	software_comment=$4			# Affichage d'un commentaire descriptif du logiciel lorsque l'utilisateur passe le curseur de sa souris pas dessus le fichier ".desktop"
	software_exec=$5			# Adresse du fichier exécutable du logiciel
	software_icon=$6			# Emplacement du fichier image de l'icône du logiciel
	software_type=$7			# Détermine si le fichier ".desktop" pointe vers une application, un lien ou un dossier
	software_category=$8		# Catégorie(s) du logiciel (jeu, développement, bureautique, etc...)

	#***** Autres variables *****
		# Dossiers
	software_inst_dir="$DIR_SOFTWARE/$software_name"					# Dossier d'installation du logiciel
	software_shortcut_dir="$DIR_HOMEDIR/Bureau/Linux-reinstall.links"	# Dossier de stockage des raccourcis vers les fichiers exécutables des logiciels téléchargés

		# Fichiers
	software_dl_link="$software_web_link/$software_archive"				# Lien de téléchargement de l'archive


	#***** Code *****
	EchoNewstep "Téléchargement de $COL_CYAN$software_name"

	# On crée un dossier dédié au logiciel dans le dossier d'installation de logiciels
	Makedir "$DIR_SOFTWARE" "$software_name" "1" 2>&1 | tee -a "$FILE_LOGPATH"
	wget -v "$software_dl_link" -O "$software_inst_dir" >> "$FILE_LOGPATH" \
		|| EchoError "Échec du téléchargement du logiciel $software_name" \
		&& EchoSuccess "Le logiciel $software_name a été téléchargé avec succès"
	Newline

	# On décompresse l'archive téléchargée selon le format de comporession
	EchoNewstep "Décompression de l'archive $(DechoN "$software_archive")"
	{
		case "$software_archive" in
			"*.zip")
				unzip "$DIR_SOFTWARE/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.7z")
				7z e "$DIR_SOFTWARE/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.rar")
				unrar e "$DIR_SOFTWARE/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.tar.gz")
				tar -zxvf "$DIR_SOFTWARE/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.tar.bz2")
				tar -jxvf "$DIR_SOFTWARE/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
		esac
	} 2>&1 | tee -a "$FILE_LOGPATH"

	# On vérifie que le dossier contenant les fichiers desktop (servant de raccourci) existe, pour ne pas encombrer le bureau de l'utilisateur
	if test ! -d "${ARG_USERNAME}/Bureau/Linux-reinstall.links"; then
		EchoNewstep "Création d'un dossier contenant les raccourcis vers les logiciels téléchargés via la commande wget (pour ne pas encombrer votre bureau)"
		Newline

		Makedir "${ARG_USERNAME}/Bureau/" "Linux-reinstall.link" "1" 2>&1 | tee -a "$FILE_LOGPATH"
		EchoSuccess "Vous pourrez déplacer les raccourcis sur votre bureau sans avoir à les modifier"
	fi

	EchoNewstep "Création d'un lien symbolique pointant vers le fichier exécutable du logiciel $(DechoN "$software_name")"
	ln -s "$software_exec" "$software_name" \
		|| EchoError "Impossible de créer un lien symbolique pointant vers $(DechoE "$software_exec")" \
		&& EchoSuccess "Le lien symbolique a été créé avec succès"
	Newline

	EchoNewstep "Création du raccourci vers le fichier exécutable du logiciel $(DechoN "$software_name")"
	echo "[Desktop Entry]
		Name=$software_name
		Comment=$software_comment
		Exec=$software_inst_dir/$software_exec
		Icon=$software_icon
		Type=$software_type
		Categories=$software_category;" > "$software_shortcut_dir/$software_name.desktop"
	EchoSuccess "Le fichier $(DechoS "$software_name.desktop") a été créé avec succès dans le dossier $(DechoS "$software_shortcut_dir")"
	Newline

	EchoNewstep "Suppression de l'archive $(DechoN "$software_archive")"
	rm -f "$software_inst_dir/$software_archive" \
		|| EchoError "La suppression de l'archive $(DechoE "$software_archive") a échouée" \
		&& EchoSuccess "L'archive $(DechoS "$software_archive") a été correctement supprimée"
	Newline
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

#### DÉFINITION DES FONCTIONS DÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####



## DÉFINITION DES FONCTIONS D'INITIALISATION
# Création du fichier de logs pour répertorier chaque sortie de commande (sortie standard STDOUT ou sortie d'erreurs STDERR)
function CreateLogFile()
{
	# Si le fichier de logs n'existe pas, le script le crée via la fonction "Makefile"
	Makefile "$PWD" "$FILE_LOGNAME" "0" | tee -a "$FILE_LOGPATH"
	NewlineLog	# On appelle la fonction "NewlineLog" pour rediriger le saut de ligne vers le fichier de logs, car les sauts de ligne de la fonction Makefile ne sont pas redirigés vers le fichier de logs

	# On évite d'appeler les fonctions d'affichage propre "EchoSuccess" ou "EchoError" (sans le "NoLog") pour éviter
	# d'écrire deux fois le même texte, vu que ces fonctions appellent chacune une commande écrivant dans le fichier de logs
	EchoSuccessNoLog "Fichier de logs créé avec succès" >> "$FILE_LOGPATH"
	NewlineLog

	# Tout ce qui se trouve entre ces accolades est envoyé dans le fichier de logs
	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" "RÉCUPÉRATION DES INFORMATIONS SUR LE SYSTÈME DE L'UTILISATEUR"

		Newline

		# Récupération des informations sur le système d'exploitation de l'utilisateur contenues dans le fichier "/etc/os-release"
		EchoNewstepNoLog "Informations sur le système d'exploitation de l'utilisateur $(DechoN "${ARG_USERNAME}") :"
		cat "/etc/os-release"
		NewlineLog

		EchoSuccessNoLog "Fin de la récupération d'informations sur le système d'exploitation"
	} >> "$FILE_LOGPATH"

	# Au moment de la création du fichier de logs, la variable "$FILE_LOGPATH" correspond au dossier actuel de l'utilisateur

	return
}

# Création du dossier temporaire où sont stockés les fichiers et dossiers temporaires
function Mktmpdir()
{
	NewlineLog

	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" \
			"CRÉATION DU DOSSIER TEMPORAIRE $COL_JAUNE\"$DIR_TMPDIR$COL_BLUE\" DANS LE DOSSIER $COL_JAUNE\"$DIR_TMPPARENT\"$COL_RESET"

		Newline

		Makedir "$DIR_TMPPARENT" "$DIR_TMPDIR" "0"		# Dossier principal
		Makedir "$DIR_TMPPATH" "Logs" "0"				# Dossier d'enregistrement des fichiers de logs
	} >> "$FILE_LOGPATH"
}

# Détection de l'exécution du script en mode super-utilisateur (root)
function ScriptInit()
{
	# On appelle la fonction de création du fichier de logs
	CreateLogFile

	# Puis la fonction de création du dossier temporaire
	Mktmpdir

	Makefile "/home/dimob/Bureau" "Linux-reinstall.test" "0" 2>&1 | tee -a "$FILE_LOGPATH"

	# On déplace le fichier de logs vers le dossier temporaire tout en vérifiant s'il ne s'y trouve pas déjà
	if test ! -f "$DIR_TMPPATH/Logs/$FILE_LOGNAME"; then
		mv -v "$FILE_LOGNAME" "$DIR_TMPPATH/Logs" >> "$FILE_LOGPATH" \
			|| HandleErrors "IMPOSSIBLE DE DÉPLACER LE FICHIER DE LOGS VERS LE DOSSIER $(DechoE "$DIR_HOMEDIR")" \
			&& FILE_LOGPATH="$DIR_TMPPATH/Logs/$FILE_LOGNAME"	# Une fois que le fichier de logs est déplacé dans le dossier temporaire, on redéfinit le chemin du fichier de logs de la variable "$FILE_LOGPATH"
	fi

	# On écrit dans le fichier de logs que l'on passe à la première étape "visible dans le terminal", à savoir l'étape d'initialisation du script
	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" \
			"VÉRIFICATION DES INFORMATIONS PASSÉES EN ARGUMENT" >> "$FILE_LOGPATH"

		Newline
	} >> "$FILE_LOGPATH"

	# Si le script n'est pas lancé en mode super-utilisateur
	if test "$EUID" -ne 0; then
    	EchoError "Ce script doit être exécuté en tant que super-utilisateur (root)"
    	EchoError "Exécutez ce script en plaçant la commande $(DechoE "sudo") devant votre commande :"
		Newline

    	# Le paramètre "$0" ci-dessous est le nom du fichier shell en question avec le "./" placé devant (argument 0).
    	# Si ce fichier est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
    	echo "	sudo $0 votre_nom_d'utilisateur"
		Newline

		EchoError "Ou connectez vous directement en tant que super-utilisateur"
		EchoError "Et tapez cette commande :"
		echo "	$0 votre_nom_d'utilisateur"

		HandleErrors "SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"

	# Sinon, si le script est lancé en mode super-utilisateur, on vérifie que la commande d'exécution du script soit accompagnée d'un argument
	else
		# Si aucun argument n'est entré
		if test -z "${ARG_USERNAME}"; then
			EchoError "Veuillez lancer le script en plaçant votre nom d'utilisateur après la commande d'exécution du script :"
			echo "	sudo $0 votre_nom_d'utilisateur"

			HandleErrors "VOUS N'AVEZ PAS PASSÉ VOTRE NOM D'UTILISATEUR EN ARGUMENT"

		# Sinon, si l'argument attendu est entré
		else
      # Si la valeur de l'argument ne correspond pas au nom de l'utilisateur
			if test "$(pwd | cut -d '/' -f-3 | cut -d '/' -f3-)" != "${ARG_USERNAME}"; then
				EchoError "Veuillez entrer correctement votre nom d'utilisateur"
				Newline

				EchoError "Si vous avez exécuté le script en dehors de votre dossier personnel ou d'un de ses sous-dossiers,"
				EchoError "retournez-y pour réexécuter le script sans problèmes."

				HandleErrors "LA CHAÎNE DE CARACTÈRES PASSÉE EN PREMIER ARGUMENT NE CORRESPOND PAS À VOTRE NOM D'UTILISATEUR"

			# Sinon, si la valeur de l'argument correspond au nom de l'utilisateur
			else
				# On demande à l'utilisateur de bien confirmer son nom, au cas où son compte utilisateur cohabite avec d'autres comptes
				EchoNewstep "Nom d'utilisateur entré :$COL_RESET ${ARG_USERNAME}"
				EchoNewstep "Est-ce correct ? (oui/non)"
				Newline

				# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
				# Les deux virgules suivant directement le "rep_ScriptInit" entre les accolades signifient que les mêmes réponses avec des
				# majuscules sont permises, peu importe où elles se situent dans la chaîne de caractères (pas de sensibilité à la casse).
				function ReadScriptInit()
				{
					read -r -p "Entrez votre réponse : " rep_script_init
					echo "$rep_script_init" >> "$FILE_LOGPATH"
					Newline

					case ${rep_script_init,,} in
						"oui")
							EchoSuccess "Lancement du script"

							return
							;;
						"non")
							EchoError "Abandon"
							Newline

							exit 1
							;;
						*)
							EchoError "Réponses attendues : \"oui\" ou \"non\" (pas de sensibilité à la casse)"
							EchoError "Abandon"
							Newline

							exit 1
							;;
					esac
				}

				ReadScriptInit

				return
			fi
		fi
	fi
}

# Détection du gestionnaire de paquets de la distribution utilisée
function GetMainPackageManager()
{
	ScriptHeader "DÉTECTION DU GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION"

	# On cherche la commande du gestionnaire de paquets de la distribution de l'utilisateur dans les chemins de la variable d'environnement "$PATH" en l'exécutant.
	# On redirige chaque sortie ("STDOUT (sortie standard) si la commande est trouvée" et "STDERR (sortie d'erreurs) si la commande n'est pas trouvée")
	# de la commande vers /dev/null (vers rien) pour ne pas exécuter la commande.

	# Pour en savoir plus sur les redirections en Shell UNIX, consultez ce lien -> https://www.tldp.org/LDP/abs/html/io-redirection.html
	command -v apt-get &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="APT"
	command -v dnf &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="DNF"
	command -v emerge &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="Emerge"
	command -v pacman &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="Pacman"
  command -v zypper &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="Zypper"

	# Si, après la recherche de la commande, la chaîne de caractères contenue dans la variable $PACK_MAIN_PACKAGE_MANAGER est toujours nulle (aucune commande trouvée)
	if test "$PACK_MAIN_PACKAGE_MANAGER" = ""; then
		HandleErrors "AUCUN GESTIONNAIRE DE PAQUETS PRINCIPAL SUPPORTÉ TROUVÉ"
	else
		EchoSuccess "Gestionnaire de paquets principal trouvé : $(DechoS "$PACK_MAIN_PACKAGE_MANAGER")"
	fi
}

# Demande à l'utilisateur s'il souhaite vraiment lancer le script, puis connecte l'utilisateur en mode super-utilisateur
function LaunchScript()
{
	ScriptHeader "LANCEMENT DU SCRIPT"

	EchoNewstep "Assurez-vous d'avoir lu au moins le mode d'emploi $(DechoN "(Mode d'emploi.odt)") avant de lancer l'installation."
    EchoNewstep "Êtes-vous sûr de bien vouloir lancer l'installation ? (oui/non)"
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	function ReadLaunchScript()
	{
        # On demande à l'utilisateur d'entrer une réponse
		read -r -p "Entrez votre réponse : " rep_launch_script
		echo "$rep_launch_script" >> "$FILE_LOGPATH"
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

				exit 1
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
	ScriptHeader "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à Internet (pour le savoir, on ping le serveur DNS d'OpenDNS avec la commande ping 1.1.1.1)
	if ping -q -c 1 -W 1 opendns.com >> /dev/null; then
		EchoSuccess "Votre ordinateur est connecté à Internet"

		return
	# Sinon, si l'ordinateur n'est pas connecté à Internet
	else
		HandleErrors "AUCUNE CONNEXION À INTERNET"
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets principal supporté
# (ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE PAS MODIFIER CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS PRINCIPAL (PAS DE SNAP OU DE FLATPAK) !!!)
function DistUpgrade()
{
	ScriptHeader "MISE À JOUR DU SYSTÈME"

	EchoSuccess "Mise à jour du système en cours"
	Newline

	# On récupère la commande de mise à jour du gestionnaire de paquets principal enregistée dans la variable "$PACK_MAIN_PACKAGE_MANAGER",
	case "$PACK_MAIN_PACKAGE_MANAGER" in
		"APT")
			# APT renvoie souvent un message d'avertissement en cas d'utilisation de ce dernier dans un script :
			# 	--> "Warning : apt does not have a stable CLI interface. Use with caution in scripts."

			# Ce n'est pas un message problématique, mais il est assez ennuyeux, car il arrive à chaque appel de la commande
			# Pour y remédier, je renvoie ses sorties d'erreur vers un fichier temporaire, avant de renvoyer ces messages dans le fichier de logs
			# (il est impossible de rediriger directement une sortie d'erreur vers un fichier ET de rediriger tout de suite après la sortie standard
			# vers ce même fichier ET vers le terminal (apt-get -y update 2>> "$FILE_LOGPATH" | tee -a "$FILE_LOGPATH") <-- Code problématique)

#			tmpapt="$DIR_TMPPATH/Logs/aptEchoErrors.log"
#
#			Makefile "$DIR_TMPPATH/Logs" "aptEchoErrors.log" "1" 2>&1 | tee -a "$FILE_LOGPATH"
#			Newline

			apt-get -y update | tee -a "$SCRIPT_LOGPATH" && apt-get -y upgrade | tee -a "$FILE_LOGPATH"
			;;
		"DNF")
			dnf -y update | tee -a "$FILE_LOGPATH"
			;;
		"Emerge")
			emerge -u world 2>&1 | tee -a "$FILE_LOGPATH"
			;;
		"Pacman")
			pacman --noconfirm -Syu | tee -a "$FILE_LOGPATH"
			;;
		"Zypper")
			zypper -y update | tee -a "$FILE_LOGPATH"
			;;
	esac

	Newline

	EchoSuccess "Mise à jour du système effectuée avec succès"

	return
}


## DÉFINITION DES FONCTIONS DE PARAMÉTRAGE
# Détection et installation de Sudo
function SetSudo()
{
	ScriptHeader "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"

	sudoers_old="/etc/sudoers - $DATE_TIME.old"

    EchoNewstep "Détection de sudo $COL_RESET"

	# On effectue un test pour savoir si la commande "sudo" est installée sur le système de l'utilisateur
	command -v sudo > /dev/null 2>&1 \
		|| {
			EchoNewstep "La commande $(DechoN "sudo") n'est pas installé sur votre système"
			PackInstall sudo
		} \
		&& EchoSuccess "La commande $(DechoS "sudo") est déjà installée sur votre système";
	Newline

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
		read -r -p "Entrez votre réponse : " rep_set_sudo
		echo "$rep_set_sudo" >> "$FILE_LOGPATH"

		# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
		case ${rep_set_sudo,,} in
			"oui")
				Newline

				# Sauvegarde du fichier "/etc/sudoers" existant en "sudoers.old"
				EchoNewstep "Création d'une sauvegarde de votre fichier $(DechoN "sudoers") existant nommée $(DechoN "sudoers $DATE_TIME.old")"
				cat "/etc/sudoers" > "$sudoers_old" \
					|| { EchoError "Impossible de créer une sauvegarde du fichier $(DechoE "sudoers")"; return; } \
					&& EchoSuccess "Le fichier de sauvegarde $(DechoS "$sudoers_old") a été créé avec succès"
				Newline

				# Téléchargement du fichier sudoers configuré
				EchoNewstep "Téléchargement du fichier sudoers depuis le dépôt Git $SCRIPT_REPO"
				sleep 1
				Newline

				wget https://raw.githubusercontent.com/DimitriObeid/Linux-reinstall/Beta/Ressources/sudoers -O "$DIR_TMPPATH/sudoers" \
					|| { EchoError "Impossible de télécharger le nouveau fichier $(DechoE "sudoers")"; return; } \
					&& EchoSuccess "Le nouveau fichier $(DechoS "sudoers") téléchargé avec succès"
				Newline

				# Déplacement du fichier vers le dossier "/etc/"
				EchoNewstep "Déplacement du fichier \"sudoers\" vers \"/etc/\""
				mv "$DIR_TMPPATH/sudoers" /etc/sudoers \
					|| { EchoError "Impossible de déplacer le fichier $(DechoE "sudoers") vers le dossier $(DechoE "/etc/")"; return; } \
					&& { EchoSuccess "Fichier $(DechoS "sudoers") déplacé avec succès vers le dossier $(DechoS "/etc/")"; }
				Newline

				# Ajout de l'utilisateur au groupe "sudo"
				EchoNewstep "Ajout de l'utilisateur $(DechoN "${ARG_USERNAME}") au groupe sudo"
				usermod -aG root "${ARG_USERNAME}" 2>&1 | tee -a "$FILE_LOGPATH" \
					|| { EchoError "Impossible d'ajouter l'utilisateur $(DechoE "${ARG_USERNAME}") à la liste des sudoers"; return; } \
					&& { EchoSuccess "L'utilisateur $(DechoS "${ARG_USERNAME}") a été ajouté au groupe sudo avec succès"; }

				return
				;;
			"non")
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
	ScriptHeader "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"

	EchoNewstep "Souhaitez vous supprimer les paquets obsolètes ? (oui/non)"
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il souhaite supprimer les paquets obsolètes
	function ReadAutoremove()
	{
		read -rp "Entrez votre réponse : " rep_autoremove
		echo "$rep_autoremove" >> "$FILE_LOGPATH"

		case ${rep_autoremove,,} in
			"oui")
				Newline

				EchoNewstep "Suppression des paquets"
				Newline

	    		case "$PACK_MAIN_PACKAGE_MANAGER" in
					"APT")
	            		apt-get -y autoremove
	            		;;
					"DNF")
		           		dnf -y autoremove
		           		;;
		       		"Emerge")
		           		emerge -uDN @world      # D'abord, vérifier qu'aucune tâche d'installation est active
		           		emerge --depclean -a    # Suppression des paquets obsolètes. Demande à l'utilisateur s'il souhaite supprimer ces paquets
		            	eix-test-obsolete       # Tester s'il reste des paquets obsolètes
		            	;;
	        		"Pacman")
	            		pacman --noconfirm -Qdt
	            		;;
					"Zypper")
		           		EchoNewstep "Le gestionnaire de paquets Zypper n'a pas de commande de suppression automatique de tous les paquets obsolètes"
						EchoNewstep "Référez vous à la documentation du script ou à celle de Zypper pour supprimer les paquets obsolètes"
		           		;;
				esac

				Newline

				EchoSuccess "Auto-suppression des paquets obsolètes effectuée avec succès"

				return
				;;
			"non")
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
	ScriptHeader "INSTALLATION TERMINÉE"

	EchoNewstep "Souhaitez-vous supprimer le dossier temporaire $(DechoN "$DIR_TMPPATH") ?"
	Newline

	read -rp "Entrez votre réponse : " rep_erase_tmp
	echo "$rep_erase_tmp" >> "$FILE_LOGPATH"

	case ${rep_erase_tmp,,} in
		"oui")
			EchoNewstep "Suppression du dossier temporaire $DIR_TMPPATH"
			rm -rfv "$DIR_TMPPATH" >> "$FILE_LOGPATH" \
				|| EchoError "Suppression du dossier temporaire impossible. Essayez de le supprimer à la main" \
				&& EchoSuccess "Le dossier temporaire \"$DIR_TMPPATH\" a été supprimé avec succès"
				Newline
			;;
		*)
			EchoSuccess "Le dossier temporaire $(DechoS "$DIR_TMPPATH") ne sera pas supprimé"
			;;
	esac

    EchoSuccess "Installation terminée. Votre distribution Linux est prête à l'emploi"
	Newline

	echo "$COL_CYAN"
	echo "Note :$COL_RESET Si vous avez constaté un bug ou tout autre problème lors de l'exécution du script,"
	echo "vous pouvez m'envoyer le fichier de logs situé dans votre dossier personnel."
	echo "Il porte le nom de $COL_CYAN$FILE_LOGNAME$COL_RESET"
	Newline

    # On tue le processus de connexion en mode super-utilisateur
	sudo -k

	return
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################



## APPEL DES FONCTIONS D'INITIALISATION ET DE PRÉ-INSTALLATION
# Détection du mode super-administrateur (root) et de la présence de l'argument contenant le nom d'utilisateur
ScriptInit

# Affichage du header de bienvenue
ScriptHeader "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX : VERSION $VER_SCRIPT !!!!!"
EchoSuccess "Début de l'installation"

# Détection du gestionnaire de paquets de la distribution utilisée
GetMainPackageManager

# Assurance que l'utilisateur soit sûr de lancer le script
LaunchScript

# Détection de la connexion à Internet
CheckInternetConnection

# Mise à jour des paquets actuels
DistUpgrade


## INSTALLATIONS PRIORITAIRES ET CONFIGURATIONS DE PRÉ-INSTALLATION
ScriptHeader "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
PackInstall curl
PackInstall snapd
PackInstall wget

command -v curl snap wget >> "$FILE_LOGPATH" \
	|| HandleErrors "AU MOINS UNE DES COMMANDES D'INSTALLATION MANQUE À L'APPEL" \
	&& EchoSuccess "Les commandes importantes d'installation ont été installées avec succès"

# Installation de sudo (pour les distributions livrées sans la commande) et configuration du fichier "sudoers" ("/etc/sudoers")
SetSudo


## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS DES GESTIONNAIRES DE PAQUETS
ScriptHeader "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION"

EchoSuccess "Vous pouvez désormais quitter votre ordinateur pour chercher un café"
EchoSuccess "La partie d'installation de vos programmes commence véritablement"
sleep 1

Newline
Newline

sleep 3

# Commandes
HeaderInstall "INSTALLATION DES COMMANDES PRATIQUES"
PackInstall htop
PackInstall neofetch
PackInstall tree

# Développement
HeaderInstall "INSTALLATION DES OUTILS DE DÉVELOPPEMENT"
SnapInstall atom --classic --stable		# Éditeur de code Atom
SnapInstall code --classic	--stable	# Éditeur de code Visual Studio Code
PackInstall emacs
PackInstall g++
PackInstall gcc
PackInstall git

PackInstall make
PackInstall umlet
PackInstall valgrind

# Logiciels de nettoyage de disque
HeaderInstall "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"
PackInstall k4dirstat

# Internet
HeaderInstall "INSTALLATION DES CLIENTS INTERNET"
SnapInstall discord --stable
PackInstall thunderbird

# LAMP
HeaderInstall "INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP"
PackInstall apache2
PackInstall php
PackInstall libapache2-mod-php
PackInstall mariadb-server		# Pour installer un serveur MariaDB (Si vous souhaitez un seveur MySQL, remplacez "mariadb-server" par "mysql-server"
PackInstall php-mysql
PackInstall php-curl
PackInstall php-gd
PackInstall php-intl
PackInstall php-json
PackInstall php-mbstring
PackInstall php-xml
PackInstall php-zip

# Librairies
HeaderInstall "INSTALLATION DES LIBRAIRIES"
PackInstall python3.7

# Réseau
HeaderInstall "INSTALLATION DES LOGICIELS RÉSEAU"
PackInstall wireshark

# Vidéo
HeaderInstall "INSTALLATION DES LOGICIELS VIDÉO"
PackInstall vlc

# Wine
HeaderInstall "INSTALLATION DE WINE"
PackInstall wine-stable

EchoSuccess "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS DEPUIS LES  GESTIONNAIRES DE PAQUETS !"


## INSTALLATION DES LOGICIELS ABSENTS DES GESTIONNAIRES DE PAQUETS
ScriptHeader "INSTALLATION DES LOGICIELS INDISPONIBLES DANS LES BASES DE DONNÉES DES GESTIONNAIRES DE PAQUETS"

EchoNewstep "Les logiciels téléchargés via la commande $(DechoN "wget") sont déplacés vers le nouveau dossier $(DechoN "$DIR_SOFTWARE"), localisé dans votre dossier personnel"
sleep 1
Newline

# Création du dossier "Logiciels.Linux-reinstall.d" dans le dossier personnel de l'utilisateur
EchoNewstep "Création du dossier d'installation des logiciels"
Makedir "$DIR_HOMEDIR" "$DIR_SOFTWARE" "1"
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
