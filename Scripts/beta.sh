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
#		--> Commande d'installation de l'utilitaire : sudo $gestionnaire de paquets $option_d'installation shellcheck



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



################### DÉCLARATION DES VARIABLES ET AFFECTATION DE LEURS VALEURS ###################

## ARGUMENTS
# Arguments à placer après la commande d'exécution du script pour qu'il s'exécute
SCRIPT_USERNAME=$1		# Premier argument : Le nom du compte de l'utilisateur


## CHRONOMÈTRE

# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer une durée de chronométrage, changez la valeur de la commande "sleep" voulue.
# Pour désactiver cette fonctionnalité, mettez la valeur de la commande "sleep" à 0.
# ATTENTION À NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE LA COMMANDE "sleep" NE SERA PAS INTERPRÉTÉE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SCRIPT_SLEEP_0_5=sleep\ .5		# Met le script en pause pendant 0,5 seconde. Exemple d'utilisation : temps d'affichage d'un texte de sous-étape
SCRIPT_SLEEP_1_5=sleep\ 1.5		# Met le script en pause pendant 1,5 seconde. Exemple d'utilisation : temps d'affichage d'un header uniquement, avant l'affichage du reste de l'étape lors d'un changement d'étape
SCRIPT_SLEEP_1=sleep\ 1			# Met le script en pause pendant une seconde. Exemple d'utilisation : temps d'affichage du nom du paquet avant l'affichage du reste de l'étape lors de l'installation d'un nouveau paquet


## COULEURS

# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
SCRIPT_C_CYAN=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers
SCRIPT_C_ERR=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape
SCRIPT_C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal
SCRIPT_C_STEP=$(tput setaf 226) 	# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes
SCRIPT_C_SUCC=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape


# DATE
# Variable permettant l'écriture de la date et de l'heure actuelle dans le nom d'un fichier
SCRIPT_DATE=$(date +"%Y-%m-%d %Hh-%Mm-%Ss")


## DOSSIERS ET FICHIERS
# Définition du dossier personnel de l'utilisateur
SCRIPT_HOMEDIR="/home/${SCRIPT_USERNAME}"	# Dossier personnel de l'utilisateur

# Création du dossier temporaire et définition du chemin vers ce dossier temporaire
SCRIPT_TMPDIR="Linux-reinstall.tmp.d"				# Nom du dossier temporaire
SCRIPT_TMPPARENT="/tmp"								# Dossier parent du dossier temporaire
SCRIPT_TMPPATH="$SCRIPT_TMPPARENT/$SCRIPT_TMPDIR"	# Chemin complet du dossier temporaire

# Création de fichiers
SCRIPT_LOG="Linux-reinstall $SCRIPT_DATE.log"		# Nom du fichier de logs
SCRIPT_LOGPATH="$PWD/$SCRIPT_LOG"					# Chemin du fichier de logs depuis la racine, dans le dossier actuel


## TEXTE
# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret,
# changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes
# (une ligne de chaque caractère).
SCRIPT_HEADER_LINE_CHAR="-"
SCRIPT_COLS=$(tput cols)	# Affichage du nombre de colonnes sur le terminal
SCRIPT_TAB=">>>>"				# Nombre de chevrons à afficher avant les chaînes de caractères jaunes, vertes et rouges

# Affichage de chevrons suivant l'encodage de la couleur d'une chaîne de caractères
SCRIPT_J_TAB="$SCRIPT_C_STEP$SCRIPT_TAB"				# Encodage de la couleur en jaune et affichage de 4 chevrons
SCRIPT_R_TAB="$SCRIPT_C_ERR$SCRIPT_TAB$SCRIPT_TAB"	# Encodage de la couleur en rouge et affichage de 4 * 2 chevrons
SCRIPT_V_TAB="$SCRIPT_C_SUCC$SCRIPT_TAB$SCRIPT_TAB"		# Encodage de la couleur en vert et affichage de 4 * 2 chevrons


## VERSION
# Version actuelle du script
SCRIPT_VERSION="2.0"



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



############################################# DÉFINITIONS DES FONCTIONS #############################################


#### DÉFINITION DES FONCTIONS INDÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####


## DÉFINITION DES FONCTIONS D'AFFICHAGE DE TEXTE
# Affichage d'un message en jaune avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function EchoNewstepNolog() { e_nws_n_string=$1; echo "$SCRIPT_J_TAB $j_n_string $SCRIPT_C_RESET"; }

# Appel de la fonction précédemment créée redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoNewstep() { e_nws_string=$1; EchoNewstepNolog "$j_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP_0_5; }

# Affichage d'un message en rouge avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function EchoErrorNolog() { e_err_n_string=$1; echo "$SCRIPT_R_TAB $e_err_n_string $SCRIPT_C_RESET"; }

# Appel de la fonction précédemment créée redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoError() { e_err_string=$1; EchoErrorNolog "$e_err_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP_0_5; }

# Affichage d'un message en vert avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function EchoSuccessNolog() { e_succ_n_string=$1; echo "$SCRIPT_V_TAB $e_succ_n_string $SCRIPT_C_RESET"; }

# Appel de la fonction précédemment créée redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoSuccess() { e_succ_string=$1; EchoSuccessNolog "$e_succ_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP_0_5; }

# Fonction de saut de ligne pour la zone de texte du terminal et pour le fichier de logs
function Newline() { echo "" | tee -a "$SCRIPT_LOGPATH"; }

# Fonction de saut de ligne uniquement pour le fichier de logs (utiliser la fonction précédente en redirigeant sa sortie vers le fichier de logs provoque un saut de deux lignes au lieu d'une)
function Newlogline() { echo "" >> "$SCRIPT_LOGPATH"; }


## DÉFINITION DES FONCTIONS DE CRÉATION DES HEADERS
# Fonction de création et d'affichage des lignes des headers
function DrawHeaderLine()
{
	line_color=$1	# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction
	line_char=$2	# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction

	# Définition de la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	# Si la chaîne de caractère de la variable $line_color (qui contient l'encodage de la couleur du texte) est vide,
	# alors on écrit l'encodage de la couleur dans le terminal, qui affiche la couleur, et non son encodage en texte.
	# L'encodage de la couleur peut être écrit via la commande "tput cols $encodage_de_la_couleur"
	if test "$line_color" != ""; then
		echo -n -e "$line_color"
	fi

	# Affichage du caractère souhaité sur toute la ligne. Pour cela, en utilisant une boucle "for", on commence à la lire à partir
	# de la première colonne (1), puis, on parcourt toute la ligne jusqu'à la fin de la zone de texte du terminal. À chaque appel
	# de la commande "echo", un caractère est affiché et coloré selon l'encodage défini et écrit ci-dessus.
	for i in $(eval echo "{1..$SCRIPT_COLS}"); do
		echo -n "$line_char"
	done

	# Définition (ici, réintialisation) de la couleur des caractères suivant le dernier caractère de la ligne du header
	# en utilisant le même bout de code que la première condition, pour écrire l'encodage de la couleur de base du terminal
	# (il est recommandé d'appeller la commande "tput cols sgr0" pour réinitialiser la couleur selon les options du profil
	# du terminal). Comme tout encodage de couleur, le texte brut ne sera pas affiché sur le terminal.
	# En pratique, La couleur des caractères suivants est déjà encodée quand ils sont appelés via une des fonctions d'affichage.
	# Cette réinitialisation de la couleur du texte n'est qu'une mini-sécurité permettant d'éviter d'avoir la couleur de l'invite de
	# commandes encodée avec la couleur des headers si l'exécution du script est interrompue de force avec la combinaison "CTRL + C"
	# ou mise en pause avec la combinaison "CTRL + Z", par exemple.
	if test "$line_color" != ""; then
        echo -n -e "$SCRIPT_C_RESET"
	fi

	return
}

# Fonction de création de base d'un header (Couleur et caractère de ligne, couleur et chaîne de caractères)
function HeaderBase()
{
	# Couleur de ligne
	header_base_line_color=$1

	# Définition de la couleur de la ligne du caractère souhaité.
	# Ce code produit le même résultat que la première condition de la fonction "DrawHeaderLine", mais il a été
	# réécrit ici car aucune partie d'une fonction ne peut être utilisée individuellement depuis une autre fonction
	if test "$header_base_line_color" == ""; then
        # Définition de la couleur de la ligne.
        # Ne pas ajouter de '$' avant le nom de la variable "header_color", sinon la couleur souhaitée ne s'affiche pas
		echo -n -e "$header_base_line_color"
	fi

	# Ligne
	header_base_line_char=$2		# Caractère composant chaque colonne d'une ligne d'un header

	# Chaîne de caractères
	header_base_string_color=$3		# Définition de la couleur de la chaîne de caractères
	header_base_string=$4			# Chaîne de caractères affichée dans chaque header

	Newline

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SCRIPT_SLEEP_1_5
	DrawHeaderLine "$header_base_line_color" "$header_base_line_char" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	# Affichage une autre couleur pour le texte
	echo "$header_base_string_color""##>" "$header_base_string" "$SCRIPT_C_RESET" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	DrawHeaderLine "$header_base_line_color" "$header_base_line_char" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	Newline

	Newline

	$SCRIPT_SLEEP_1_5

	return
}

# Fonction d'affichage des headers lors d'un changement d'étape
function ScriptHeader()
{
	script_header_string=$1	# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	HeaderBase "$SCRIPT_C_CYAN" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_CYAN" "$script_header_string"

	return
}

# Fonction d'affichage de headers lors du passage à une nouvelle catégorie de paquets lors de l'installation de ces derniers
function HeaderInstall()
{
	header_install_string=$1	# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	HeaderBase "$SCRIPT_C_STEP" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_SUCC" "$header_install_string"

	return
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger)
function HandleErrors()
{
	error_string=$1		# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	HeaderBase "$SCRIPT_C_ERR" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_ERR" "ERREUR FATALE : $error_string"

	EchoErrorNolog "Une erreur fatale s'est produite :" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	EchoErrorNolog "$error_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	Newline

	EchoErrorNolog "Arrêt de l'installation" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	Newline

	# Si le fichier de logs se trouve toujours dans le dossier actuel (si le script a été exécuté depuis un autre dossier)
	if test ! -f "$SCRIPT_HOMEDIR/$SCRIPT_LOG"; then
		mv -v "$SCRIPT_LOG" "$SCRIPT_HOMEDIR" >> "$SCRIPT_LOGPATH"
	fi

	echo "En cas de bug, veuillez m'envoyer le fichier de logs situé dans votre dossier personnel. Il porte le nom de $SCRIPT_C_STEP\"$SCRIPT_LOG\"$SCRIPT_C_RESET"
	Newline

	exit 1
}


## DÉFINITION DES FONCTIONS D'INSTALLATION
# Téléchargement des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets, puis installation des paquets
function PackInstall()
{
	# Si vous souhaitez mettre tous les paquets en tant que multiples arguments (tableau d'arguments), remplacez le "$1"
	# ci-dessous par "$@" et enlevez les doubles guillemets "" entourant chaque variable "$package_name" de la fonction
	package_name=$1		# Argument de la fonction "PackInstall" contenant le nom du paquet à installer
	is_installed=0		# Variable servant à enregistrer la présence d'un paquet

	# Adaptation de la commande de vérification de présence de paquets selon le gestionnaire de paquets
	function PackManagerList()
	{
		list_command="$*"

		# Cette ligne sert à m'assurer que le code fonctionne
		EchoNewstep "Vérification de la présence du paquet $SCRIPT_C_CYAN$package_name" # >> "$SCRIPT_LOGPATH"
		"$($list_command "$package_name")" 2>&1 | grep -o "$package_name" >> "$SCRIPT_LOGPATH" \
			|| {
					is_installed=0
					PackManagerInstall "$*"
				} \
			&& {
				is_installed=1
				EchoSuccess "Le paquet $SCRIPT_C_CYAN$package_name$SCRIPT_C_SUCC est déjà installé"
				Newline

				Newline
			}

		return
	}

	# Adaptation de la commande d'installation selon le gestionnaire de paquets
	function PackManagerInstall()
	{
		install_command=$*

		if test "$is_installed" = 0; then
			EchoNewstep "Installation du paquet $package_name"
			$SCRIPT_SLEEP_1

			# On appelle la commande d'installation du gestionnaire de paquets,
			# puis on assigne la valeur de la variable "is_installed" à 1 si l'opération est un succès (&&)
			"$($install_command "$package_name")" 2>&1 | tee -a "$SCRIPT_LOGPATH" \
				|| {
						EchoError "Le paquet $SCRIPT_C_CYAN$package_name$SCRIPT_C_ERR est introuvable dans les dépôts de votre gestionnaire de paquets"
						Newline

						Newline

						return
					} \
				&& is_installed=1
			$SCRIPT_SLEEP_1
			Newline

			# On vérifie que le paquet à installer a été correctement installé
			EchoNewstep "Vérification de l'installation du paquet \"$package_name\"" # >> "$SCRIPT_LOGPATH"
			if test "$is_installed" = 1; then
				EchoSuccess "Le paquet $SCRIPT_C_CYAN$package_name$SCRIPT_C_SUCC a été installé avec succès"
				is_installed=0
				Newline

				Newline

			else
				EchoError "L'installation du paquet $SCRIPT_C_CYAN$package_name$SCRIPT_C_ERR a échoué"
				Newline

				Newline
			fi
		fi

		return
	}

	# Installation du paquet souhaité selon la commande d'installation du gestionnaire de paquets de la distribution de l'utilisateur
	# Pour chaque gestionnaire de paquets, on appelle la fonction "pack_full_install()" en passant en argument la commande d'installation
	# complète, avec l'option permettant d'installer le paquet sans demander à l'utilisateur s'il souhaite installer le paquet
	case $SCRIPT_PACK_MANAGER in
		"Zypper")
			PackManagerInstall zypper -y install
			;;
		"Pacman")
      		PackManagerList pacman -Q
#			PackManagerInstall pacman --noconfirm -S
			;;
		"DNF")
			PackManagerInstall dnf -y install
			;;
		"APT")
			PackManagerList apt list --installed
#			PackManagerInstall apt -y install
			;;
		"Emerge")
			PackManagerInstall emerge
			;;
	esac

	return
}

# Installation de paquets via le gestionnaire de paquets Snap
function SnapInstall()
{
	EchoNewstep "Installation du paquet $*"
    snap install "$@" \
		|| {
				EchoError "L'installation du paquet $SCRIPT_C_CYAN$*$SCRIPT_C_ERR a échoué"
				Newline

				return
		 	} \
		&& EchoSuccess "Installation du paquet $SCRIPT_C_CYAN$*$SCRIPT_C_SUCC effectuée avec succès"
	Newline

	return
}

# Installation d'autres logiciels
function SoftwareInstall()
{
	software_name=$1	# Nom du logiciel
	software_link=$2	# Adresse de téléchargement du logiciel (téléchargement via la commande "wget")

	EchoNewstep "Installation de $SCRIPT_C_CYAN$software_name"
	Newline

	# On crée un dossier dédié au logiciel dans le dossier d'installation de logiciels
	mkdir "$SOFTWARE_DIR/$software_name"
	wget "$software_link"
}


## DÉFINITION DES FONCTIONS DE CRÉATION DE FICHIERS ET DE DOSSIERS
# Fonction de création de dossiers ET d'attribution récursive des droits de lecture et d'écriture à l'utilisateur
function Makedir()
{
	parentdir=$1					# Emplacement de création du dossier depuis la racine (dossier parent)
	dirname=$2						# Nom du dossier à créer dans son dossier parent
	dirpath="$parentdir/$dirname"	# Chemin complet du dossier

	if test ! -d "$dirpath"; then
		EchoNewstep "Création du dossier \"$dirname\" dans le dossier \"$parentdir\""
		mkdir -v "$dirpath" >> "$SCRIPT_LOGPATH" \
			|| HandleErrors "LE DOSSIER \"$dirname\" N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER PARENT \"$parentdir\"" \
			&& EchoSuccess "Le dossier \"$dirname\" a été créé avec succès dans le dossier \"$parentdir\""
		Newline

		# On change les droits du dossier créé par le script
		# Comme il est exécuté en mode super-utilisateur, le dossier créé appartient totalement au super-utilisateur.
		# Pour attribuer les droits de lecture, d'écriture et d'exécution (rwx) à l'utilisateur normal, on appelle
		# la commande chown avec pour arguments :
		#		- Le nom de l'utilisateur à qui donner les droits
		#		- Le chemin du dossier cible
		#		- Ici, la variable contenant la redirection
		chown -R -v "$SCRIPT_USERNAME" "$dirpath" >> "$SCRIPT_LOGPATH" \
			|| {
				EchoError "Impossible de changer les droits du dossier \"$dirpath\""
				EchoError "Pour changer les droits du dossier \"$dirpath\" de manière récursive,"
				EchoError "utilisez la commande :"
				echo "	chown -R $SCRIPT_USERNAME $dirpath"

				return
			} \
			&& EchoSuccess "Les droits du dossier $dirpath ont été changés avec succès"

		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent
	# MAIS que ce dossier contient AU MOINS un fichier ou dossier
	elif test -d "$dirpath" && test "$(ls -A "$dirpath")"; then
		EchoNewstep "Un dossier non-vide portant exactement le même nom se trouve déjà dans le dossier cible \"$parentdir\""
		EchoNewstep "Suppression du contenu du dossier \"$dirpath\""
		Newline

		# ATTENTION À NE PAS MODIFIER LA COMMANDE " rm -r -f -v "${dirpath/:?}/"* ", À MOINS DE SAVOIR EXACTEMENT CE QUE VOUS FAITES !!!
		# Pour plus d'informations sur cette commande complète --> https://github.com/koalaman/shellcheck/wiki/SC2115
		rm -r -f -v "${dirpath/:?}/"* 2>&1 | tee -a "$SCRIPT_LOGPATH" \
			|| {
				EchoError "Impossible de supprimer le contenu du dossier \"$dirpath";
				EchoError "Le contenu de tout fichier du dossier \"$dirpath\" portant le même nom qu'un des fichiers téléchargés sera écrasé"

				return
				} \
			&& { EchoSuccess "Suppression du contenu du dossier \"$dirpath\" effectuée avec succès"; }

			return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent ET que ce dossier est vide
	elif test -d "$dirpath"; then
		EchoSuccess "Le dossier \"$dirpath\" existe déjà"

		return
	fi
}

# Fonction de création de fichiers ET d'attribution des droits de lecture et d'écriture à l'utilisateur
function Makefile()
{
	file_parentdir=$1	# Dossier parent du fichier à créer
	filename=$2			# Nom du fichier à créer
	filepath="$file_parentdir/$filename"

	# Si le fichier à créer n'existe pas
	if test ! -s "$filepath"; then
		touch "$file_parentdir/$filename" 2>&1 | tee -a "$SCRIPT_LOGPATH" \
			|| HandleErrors "LE FICHIER \"$filename\" n'a pas pu être créé dans le dossier \"$file_parentdir\"" \
			&& EchoSuccess "Le fichier \"$filename\" a été créé avec succès dans le dossier \"$file_parentdir\""

		chown -v "$SCRIPT_USERNAME" "$filepath" >> "$SCRIPT_LOGPATH" \
			|| {
				EchoError "Impossible de changer les droits du fichier \"$filepath\""
				EchoError "Pour changer les droits du fichier \"$filepath\","
				EchoError "utilisez la commande :"
				echo "	chown $SCRIPT_USERNAME $filepath"

				return
			} \
			&& EchoSuccess "Les droits du fichier $filepath ont été changés avec succès"

		return

	# Sinon, si le fichier à créer existe déjà ou qu'il n'est pas vide
	elif test -s "$filepath"; then
		true > "$filepath" \
			|| EchoErrorNolog "Le contenu du fichier \"$filepath\" n'a pas été écrasé" >> "$SCRIPT_LOGPATH" \
			&& EchoSuccessNolog "Le contenu du fichier \"$filepath\" a été écrasé avec succès" >> "$SCRIPT_LOGPATH"

		return
	fi
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

#### DÉFINITION DES FONCTIONS DÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####



## DÉFINITION DES FONCTIONS D'INITIALISATION
# Création du fichier de logs pour répertorier chaque sortie de commande (sortie standard STDOUT ou sortie d'erreurs STDERR)
function CreateLogFile()
{
	# On évite d'appeler les fonctions d'affichage propre "EchoSuccess()" ou "EchoError()" pour éviter d'écrire deux fois le même texte,
	# vu que ces fonctions appellent chacune une commande écrivant dans le fichier de logs

	# Si le fichier de logs n'existe pas, le script le crée via la fonction "Makefile"
	Makefile "$PWD" "$SCRIPT_LOG" > /dev/null
	Newlogline

	# Au moment de la création du fichier de logs, la variable "$SCRIPT_LOGPATH" correspond au dossier actuel de l'utilisateur
	EchoSuccessNolog "Fichier de logs créé avec succès" >> "$SCRIPT_LOGPATH"
	Newlogline

	# Récupération des informations sur le système d'exploitation de l'utilisateur contenues dans le fichier "/etc/os-release"
	EchoNewstepNolog "Informations sur le système d'exploitation de l'utilisateur $SCRIPT_USERNAME :" >> "$SCRIPT_LOGPATH"
	cat "/etc/os-release" >> "$SCRIPT_LOGPATH"
	Newlogline

	EchoSuccessNolog "Fin de la récupération d'informations sur le système d'exploitation" >> "$SCRIPT_LOGPATH"
	Newlogline >> "$SCRIPT_LOGPATH"

	return
}

# Détection de l'exécution du script en mode super-utilisateur (root)
function ScriptInit()
{
	# On appelle la fonction de création du fichier de logs
	CreateLogFile

	# Si le script n'est pas lancé en mode super-utilisateur
	if test "$EUID" -ne 0; then
    	EchoError "Ce script doit être exécuté en tant que super-utilisateur (root)"
    	EchoError "Exécutez ce script en plaçant$C_RESET sudo$C_ROUGE devant votre commande :"
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
		if test -z "${SCRIPT_USERNAME}"; then
			EchoError "Veuillez lancer le script en plaçant votre nom d'utilisateur après la commande d'exécution du script :"
			echo "	sudo $0 votre_nom_d'utilisateur"

			HandleErrors "VOUS N'AVEZ PAS PASSÉ VOTRE NOM D'UTILISATEUR EN ARGUMENT"

		# Sinon, si l'argument attendu est entré
		else
            # Si la valeur de l'argument ne correspond pas au nom de l'utilisateur
			if test "$(pwd | cut -d '/' -f-3 | cut -d '/' -f3-)" != "${SCRIPT_USERNAME}"; then
				EchoError "Veuillez entrer correctement votre nom d'utilisateur"
				Newline

				EchoError "Si vous avez exécuté le script en dehors de votre dossier personnel ou d'un de ses sous-dossiers,"
				EchoError "retournez-y pour réexécuter le script sans problèmes."

				HandleErrors "LA CHAÎNE DE CARACTÈRES PASSÉE EN PREMIER ARGUMENT NE CORRESPOND PAS À VOTRE NOM D'UTILISATEUR"

			# Sinon, si la valeur de l'argument correspond au nom de l'utilisateur
			else
				# On demande à l'utilisateur de bien confirmer son nom, au cas où son compte utilisateur cohabite avec d'autres comptes
				EchoNewstep "Nom d'utilisateur entré :$SCRIPT_C_RESET $SCRIPT_USERNAME"
				EchoNewstep "Est-ce correct ? (oui/non)"
				Newline

				# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
				# Les deux virgules suivant directement le "rep_ScriptInit" entre les accolades signifient que les mêmes réponses avec des
				# majuscules sont permises, peu importe où elles se situent dans la chaîne de caractères (pas de sensibilité à la casse).
				function ReadScriptInit()
				{
					read -r -p "Entrez votre réponse : " rep_script_init
					echo "$rep_script_init" >> "$SCRIPT_LOGPATH"
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

				# On déplace le fichier de logs vers le dossier personnel de l'utilisateur tout en vérifiant s'il ne s'y trouve pas déjà
				if test ! -f "$SCRIPT_HOMEDIR/$SCRIPT_LOG"; then
                    mv -v "$SCRIPT_LOG" "$SCRIPT_HOMEDIR" >> "$SCRIPT_HOMEDIR/$SCRIPT_LOG" \
                        || HandleErrors "IMPOSSIBLE DE DÉPLACER LE FICHIER DE LOGS VERS LE DOSSIER $SCRIPT_HOMEDIR" \
                        && SCRIPT_LOGPATH="$SCRIPT_HOMEDIR/$SCRIPT_LOG"
                fi

				return
			fi
		fi
	fi
}

# Détection du gestionnaire de paquets de la distribution utilisée
function GetDistPackageManager()
{
	ScriptHeader "DÉTECTION DE VOTRE GESTIONNAIRE DE PAQUETS"

	# On cherche la commande du gestionnaire de paquets de la distribution de l'utilisateur dans les chemins de la variable d'environnement "$PATH" en l'exécutant.
	# On redirige chaque sortie ("STDOUT (sortie standard) si la commande est trouvée" et "STDERR (sortie d'erreurs) si la commande n'est pas trouvée")
	# de la commande vers /dev/null (vers rien) pour ne pas exécuter la commande.

	# Pour en savoir plus sur les redirections en Shell UNIX, consultez ce lien -> https://www.tldp.org/LDP/abs/html/io-redirection.html
    command -v zypper &> /dev/null && SCRIPT_PACK_MANAGER="Zypper"
    command -v pacman &> /dev/null && SCRIPT_PACK_MANAGER="Pacman"
    command -v dnf &> /dev/null && SCRIPT_PACK_MANAGER="DNF"
    command -v apt &> /dev/null && SCRIPT_PACK_MANAGER="APT"
    command -v emerge &> /dev/null && SCRIPT_PACK_MANAGER="Emerge"

	# Si, après la recherche de la commande, la chaîne de caractères contenue dans la variable $SCRIPT_PACK_MANAGER est toujours nulle (aucune commande trouvée)
	if test "$SCRIPT_PACK_MANAGER" = ""; then
		HandleErrors "AUCUN GESTIONNAIRE DE PAQUETS SUPPORTÉ TROUVÉ"
	else
		EchoSuccess "Gestionnaire de paquets trouvé : $SCRIPT_PACK_MANAGER"
	fi
}

# Demande à l'utilisateur s'il souhaite vraiment lancer le script, puis connecte l'utilisateur en mode super-utilisateur
function LaunchScript()
{
	ScriptHeader "LANCEMENT DU SCRIPT"

	EchoNewstep "Assurez-vous d'avoir lu au moins le mode d'emploi (Mode d'emploi.odt) avant de lancer l'installation."
    EchoNewstep "Êtes-vous sûr de bien vouloir lancer l'installation ? (oui/non)"
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	function ReadLaunchScript()
	{
        # On demande à l'utilisateur d'entrer une réponse
		read -r -p "Entrez votre réponse : " rep_launch_script
		echo "$rep_launch_script" >> "$SCRIPT_LOGPATH"
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

				EchoNewstep "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
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

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté
# (ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE PAS MODIFIER CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
function DistUpgrade()
{
	ScriptHeader "MISE À JOUR DU SYSTÈME"

	EchoSuccess "Mise à jour du système en cours"
	Newline

	# On récupère la commande du gestionnaire de paquets stocké dans la variable "$SCRIPT_PACK_MANAGER",
	# puis on appelle sa commande de mise à jour des paquets installés
	case "$SCRIPT_PACK_MANAGER" in
		"Zypper")
			zypper -y update | tee -a "$SCRIPT_LOGPATH"
			;;
		"Pacman")
			pacman --noconfirm -Syu | tee -a "$SCRIPT_LOGPATH"
			;;
		"DNF")
			dnf -y update | tee -a "$SCRIPT_LOGPATH"
			;;
		"APT")
			# APT renvoie souvent un message d'avertissement en cas d'utilisation de ce dernier dans un script :
			# 	--> "warnstr: apt does not have a stable CLI interface. Use with caution in scripts."

			# Ce n'est pas un message problématique, mais il est assez ennuyeux, car il arrive à chaque appel de la commande
			# Pour y remédier, je renvoie ses sorties d'erreur vers un fichier temporaire, avant de renvoyer ces messages dans le fichier de logs
			# (il est impossible de rediriger directement une sortie d'erreur vers un fichier ET de rediriger tout de suite après la sortie standard
			# vers ce même fichier ET vers le terminal (apt-get -y update 2>> "$SCRIPT_LOGPATH" | tee -a "$SCRIPT_LOGPATH") <-- Code problématique)
			tmpapt="$SCRIPT_TMPPATH/aptEchoErrors.log"

			Makefile "$SCRIPT_TMPPATH" "aptEchoErrors.log"
			Newline

			apt -y update 2>> "$tmpapt" 1>> "$SCRIPT_LOGPATH" /dev/tty && apt -y upgrade 2>&1 | tee -a "$SCRIPT_LOGPATH"
			;;
		"Emerge")
			emerge -u world 2>&1 | tee -a "$SCRIPT_LOGPATH"
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

	sudoers_old="/etc/sudoers - $SCRIPT_DATE.old"

    EchoNewstep "Détection de sudo $SCRIPT_C_RESET"

	# On effectue un test pour savoir si la commande "sudo" est installée sur le système de l'utilisateur
	command -v sudo > /dev/null 2>&1 \
		|| {
				EchoNewstep "La commande \"sudo\" n'est pas installé sur votre système"
				PackInstall sudo
			} \
		&& EchoSuccess "La commande \"sudo\" est déjà installée sur votre système";
	Newline

	EchoNewstep "Le script va tenter de télécharger un fichier \"sudoers\" déjà configuré"
	EchoNewstep "depuis le dossier des fichiers ressources de mon dépôt Git : "
	echo ">>>> https://github.com/DimitriObeid/Linux-reinstall/tree/master/Ressources"
	Newline

	EchoNewstep "Souhaitez vous le télécharger PUIS l'installer maintenant dans le dossier \"/etc/\" ? (oui/non)"
	Newline

	echo ">>>> REMARQUE : Si vous disposez déjà des droits de super-utilisateur, ce n'est pas la peine de le faire !"
	echo ">>>> Si vous avez déjà un fichier sudoers modifié, une sauvegarde du fichier actuel sera effectuée dans le même dossier"
	Newline

	function ReadSetSudo()
	{
		read -r -p "Entrez votre réponse : " rep_set_sudo
		echo "$rep_set_sudo" >> "$SCRIPT_LOGPATH"

		# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
		case ${rep_set_sudo,,} in
			"oui")
				Newline

				# Sauvegarde du fichier "/etc/sudoers" existant en "sudoers.old"
				EchoNewstep "Création d'une sauvegarde de votre fichier sudoers existant nommée \"sudoers $SCRIPT_DATE.old\""
				cat "/etc/sudoers" > "$sudoers_old" \
					|| { EchoError "Impossible de créer une sauvegarde du fichier sudoers"; return; } \
					&& EchoSuccess "Le fichier de sauvegarde \"$sudoers_old\" a été créé avec succès"
				Newline

				# Téléchargement du fichier sudoers configuré
				EchoNewstep "Téléchargement du fichier sudoers depuis le dépôt Git $SCRIPT_REPO"
				sleep 1
				Newline

				wget https://raw.githubusercontent.com/DimitriObeid/Linux-reinstall/master/Ressources/sudoers -O "$SCRIPT_TMPPATH/sudoers" \
					|| { EchoError "Impossible de télécharger le fichier \"sudoers\""; return; } \
					&& EchoSuccess "Fichier \"sudoers\" téléchargé avec succès"
				Newline

				# Déplacement du fichier vers le dossier "/etc/"
				EchoNewstep "Déplacement du fichier \"sudoers\" vers \"/etc/\""
				mv "$SCRIPT_TMPPATH/sudoers" /etc/sudoers \
					|| { EchoError "Impossible de déplacer le fichier \"sudoers\" vers le dossier \"/etc/\""; return; } \
					&& { EchoSuccess "Fichier sudoers déplacé avec succès vers le dossier "; }
				Newline

				# Ajout de l'utilisateur au groupe "sudo"
				EchoNewstep "Ajout de l'utilisateur ${SCRIPT_USERNAME} au groupe sudo"
				usermod -aG root "${SCRIPT_USERNAME}" 2>&1 | tee -a "$SCRIPT_LOGPATH" \
					|| { EchoError "Impossible d'ajouter l'utilisateur \"$SCRIPT_USERNAME\" à la liste des sudoers"; return; } \
					&& { EchoSuccess "L'utilisateur ${SCRIPT_USERNAME} a été ajouté au groupe sudo avec succès"; }

				return
				;;
			"non")
				Newline

				EchoSuccess "Le fichier \"/etc/sudoers\" ne sera pas modifié"

				return
				;;
			*)
				Newline

				EchoNewstep "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
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
		read -r -p "Entrez votre réponse : " rep_autoremove
		echo "$rep_autoremove" >> "$SCRIPT_LOGPATH"

		case ${rep_autoremove,,} in
			"oui")
				Newline

				EchoNewstep "Suppression des paquets"
				Newline

	    		case "$SCRIPT_PACK_MANAGER" in
	        		"Zypper")
	            		EchoNewstep "Le gestionnaire de paquets Zypper n'a pas de commande de suppression automatique de tous les paquets obsolètes"
						EchoNewstep "Référez vous à la documentation du script ou à celle de Zypper pour supprimer les paquets obsolètes"
	            		;;
	        		"Pacman")
	            		pacman --noconfirm -Qdt
	            		;;
	        		"DNF")
	            		dnf -y autoremove
	            		;;
	        		"APT")
	            		apt -y autoremove
	            		;;
	        		"Emerge")
	            		emerge -uDN @world      # D'abord, vérifier qu'aucune tâche d'installation est active
	            		emerge --depclean -a    # Suppression des paquets obsolètes. Demande à l'utilisateur s'il souhaite supprimer ces paquets
	            		eix-test-obsolete       # Tester s'il reste des paquets obsolètes
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

				EchoNewstep "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
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

	EchoSuccess "Suppression du dossier temporaire $SCRIPT_TMPPATH"
	rm -r -f -v "$SCRIPT_TMPPATH" >> "$SCRIPT_LOGPATH" \
		|| EchoError "Suppression du dossier temporaire impossible. Essayez de le supprimer à la main" \
		&& EchoSuccess "Le dossier temporaire \"$SCRIPT_TMPPATH\" a été supprimé avec succès"
	Newline

    EchoSuccess "Installation terminée. Votre distribution Linux est prête à l'emploi"
	Newline

	EchoNewstep "Note :$SCRIPT_C_RESET Si vous avez constaté un bug ou tout autre problème lors de l'exécution du script"
	echo "vous pouvez m'envoyer le fichier de logs situé dans votre dossier personnel."
	echo "Il porte le nom de $SCRIPT_C_STEP$SCRIPT_LOG"

    # On tue le processus de connexion en mode super-utilisateur
	sudo -k
	Newline

	return
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #


################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################



## APPEL DES FONCTIONS D'INITIALISATION ET DE PRÉ-INSTALLATION
# Détection du mode super-administrateur (root) et de la présence de l'argument contenant le nom d'utilisateur
ScriptInit

# Affichage du header de bienvenue
ScriptHeader "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX : VERSION $SCRIPT_VERSION !!!!!"
EchoSuccess "Début de l'installation"

# Détection du gestionnaire de paquets de la distribution utilisée
GetDistPackageManager

# Assurance que l'utilisateur soit sûr de lancer le script
LaunchScript

# Création du dossier temporaire où sont stockés les fichiers temporaires
ScriptHeader "CRÉATION DU DOSSIER TEMPORAIRE \"$SCRIPT_TMPDIR\" DANS LE DOSSIER \"$SCRIPT_TMPPARENT\""
Makedir "$SCRIPT_TMPPARENT" "$SCRIPT_TMPDIR"

# Détection de la connexion à Internet
CheckInternetConnection

# Mise à jour des paquets actuels
DistUpgrade


## INSTALLATIONS PRIORITAIRES ET CONFIGURATIONS DE PRÉ-INSTALLATION
ScriptHeader "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
PackInstall curl
PackInstall snapd
PackInstall wget

command -v curl snapd wget >> "$SCRIPT_LOGPATH" \
	|| HandleErrors "AU MOINS UNE DES COMMANDES D'INSTALLATION MANQUE À L'APPEL" \
	&& EchoSuccess "Les commandes importantes d'installation ont été installées avec succès"

# Installation de sudo (pour les distributions livrées sans la commande) et configuration du fichier "sudoers" ("/etc/sudoers")
SetSudo


## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION
# Création du dossier "Logiciels.Linux-reinstall.d" dans le dossier personnel de l'utilisateur
ScriptHeader "CRÉATION DU DOSSIER D'INSTALLATION DES LOGICIELS"

SOFTWARE_DIR="Logiciels.Linux-reinstall.d"
Makedir "$SCRIPT_HOMEDIR" "$SOFTWARE_DIR"

# Affichage du message de création du dossier "Logiciels.Linux-reinstall.d"
ScriptHeader "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION"

EchoNewstep "Les logiciels téléchargés via la commande \"wget\" sont déplacés vers le nouveau dossier \"Logiciels.Linux-reinstall\","
EchoNewstep "localisé dans votre dossier personnel"
sleep 1
Newline

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
SnapInstall code --classic	--stable    	# Éditeur de code Visual Studio Code
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

HeaderInstall "INSTALLATION DE WINE"
PackInstall wine-stable

EchoSuccess "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS ! FIN DE L'INSTALLATION"


## INSTALLATIONS SUPPLÉMENTAIRES
# Installation de paquets

## FIN D'INSTALLATION
# Suppression des paquets obsolètes
Autoremove

# Fin de l'installation
IsInstallationDone
