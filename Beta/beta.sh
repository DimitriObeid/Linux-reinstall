#!/bin/bash

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
#		--> Commande d'installation : sudo $commande_d'installation_de_paquets shellcheck



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



################### DÉCLARATION DES VARIABLES ET AFFECTATION DE LEURS VALEURS ###################

## ARGUMENTS
# Arguments à placer après la commande d'exécution du script pour qu'il s'exécute
SCRIPT_USERNAME=$1		# Premier argument : Le nom du compte de l'utilisateur


## CHRONOMÈTRE

# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer une durée de chronométrage, changez la valeur de la commande "sleep" voulue.
# Pour désactiver cette fonctionnalité, mettez la valeur de la commande "sleep" à 0.
# NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SCRIPT_SLEEP=sleep\ .5			# Temps d'affichage d'un texte de sous-étape
SCRIPT_SLEEP_HEADER=sleep\ 1.5	# Temps d'affichage d'un header uniquement, avant d'afficher le reste de l'étape, lors d'un changement d'étape
SCRIPT_SLEEP_INST=sleep\ .5		# Temps d'affichage du nom du paquet, avant d'afficher le reste de l'étape, lors de l'installation d'un nouveau paquet


## COULEURS

# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
SCRIPT_C_CYAN=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers
SCRIPT_C_JAUNE=$(tput setaf 226) 	# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes
SCRIPT_C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal
SCRIPT_C_ROUGE=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape
SCRIPT_C_VERT=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape


# DATE
# Variable permettant l'écriture de la date et de l'heure actuelle dans le nom d'un fichier
SCRIPT_DATE=$(date +"%Y-%m-%d %H-%M-%S")


## DOSSIERS ET FICHIERS
# Définition du dossier personnel de l'utilisateur
SCRIPT_HOMEDIR="/home/${SCRIPT_USERNAME}"	# Dossier personnel de l'utilisateur

# Création du dossier temporaire et définition du chemin vers ce dossier temporaire
SCRIPT_TMPDIR="Linux-reinstall.tmp.d"					# Nom du dossier temporaire
SCRIPT_TMPPARENT="/tmp"									# Dossier parent du dossier temporaire
SCRIPT_TMPPATH="$SCRIPT_TMPPARENT/$SCRIPT_TMPDIR"		# Chemin complet du dossier temporaire

# Création de fichiers
SCRIPT_LOG="Linux-reinstall.log"		# Nom du fichier de logs
SCRIPT_LOGPATH="$PWD/$SCRIPT_LOG"		# Chemin du fichier de logs depuis la racine, dans le dossier actuel


## TEXTE
# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret,
# changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes
# (une ligne de chaque caractère).
SCRIPT_HEADER_LINE_CHAR="-"
SCRIPT_COLS=$(tput cols)	# Affichage du nombre de colonnes sur le terminal
SCRIPT_TAB=">>>>"			# Nombre de chevrons à afficher avant les chaînes de caractères jaunes, vertes et rouges

# Affichage de chevrons suivant l'encodage de la couleur d'une chaîne de caractères
SCRIPT_J_TAB="$SCRIPT_C_JAUNE$SCRIPT_TAB"				# Encodage de la couleur en jaune et affichage de 4 chevrons
SCRIPT_R_TAB="$SCRIPT_C_ROUGE$SCRIPT_TAB$SCRIPT_TAB"	# Encodage de la couleur en rouge et affichage de 4 * 2 chevrons
SCRIPT_V_TAB="$SCRIPT_C_VERT$SCRIPT_TAB$SCRIPT_TAB"		# Encodage de la couleur en vert et affichage de 4 * 2 chevrons

# Saut de ligne
SCRIPT_VOID=""


## VERSION
# Version actuelle du script
SCRIPT_VERSION="2.0"



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



############################################# DÉFINITIONS DES FONCTIONS #############################################


#### DÉFINITION DES FONCTIONS INDÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####


## DÉFINITION DES FONCTIONS DE DÉCORATION DU SCRIPT
# Affichage d'un message en jaune avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function j_echo() { j_string=$1; echo "$SCRIPT_J_TAB $j_string $SCRIPT_C_RESET" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP; }

# Affichage d'un message en rouge avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function r_echo_nolog() { r_n_string=$1; echo "$SCRIPT_R_TAB $r_n_string $SCRIPT_C_RESET"; }
# Appel de la fonction précédemment créée redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function r_echo() { r_string=$1; r_echo_nolog "$r_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP; }

# Affichage d'un message en vert avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function v_echo_nolog() { v_n_string=$1; echo "$SCRIPT_V_TAB $v_n_string $SCRIPT_C_RESET"; }
# Appel de la fonction précédemment créée redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function v_echo() { v_string=$1; v_echo_nolog "$v_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP; }


## DÉFINITION DES FONCTIONS DE CRÉATION DES HEADERS
# Fonction de création et d'affichage des lignes des headers
function draw_header_line()
{
	line_color=$1	# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction
	line_char=$2	# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction

	# Définition de la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	if test "$line_color" != ""; then
		echo -n -e "$line_color"
	fi

	# Affichage du caractère souhaité sur toute la ligne. Pour cela, on commence à la lire à partir de la première colonne (1),
	# puis, on parcourt toute la colonne jusqu'à la fin de la ligne. À chaque fin de boucle, un caractère est affiché, coloré
	# selon l'encodage de la couleur stocké dans la variable délimité par la valeur retournée par la commande "tput cols"
	# (affichage du nombre de colonnes séparant la bordure gauche de la bordure droite de la zone de texte du terminal),
	# dont la variable "$SCRIPT_COLS" stocke la commande d'exécution.
	for i in $(eval echo "{1..$SCRIPT_COLS}"); do
		echo -n "$line_char"
	done

	# Définition (ici, réintialisation) la couleur des caractères suivant le dernier caractère de la ligne du header.
	# En pratique, La couleur des caractères suivants est déjà encodée quand ils sont appelés. Cette réinitialisation
	# de la couleur du texte n'est qu'une mini sécurité permettant d'éviter d'avoir la couleur du prompt encodée avec
	# la couleur des headers si l'exécution du script est interrompue de force avec un "CTRL + C" ou un "CTRL + Z", par
	# exemple.
	if test "$line_color" != ""; then
        echo -n -e "$SCRIPT_C_RESET"
	fi

	return
}

# Fonction de création de base d'un header (Couleur et caractère de ligne, couleur et chaîne de caractères)
function header_base()
{
	# Définition de la couleur de la ligne du caractère souhaité.
	# Il s'agit du même code définissant la première condition de la fonction "draw_header_line",
	# mais il a été réécrit ici pour définir l'affichage de la véritable couleur sur chaque caractère lors de l'appel de la
	# fonction "script_header()", car les conditions d'une fonction ne peuvent pas être utilisées depuis une autre fonction
	if test "$header_base_line_color" == ""; then
        # Définition de la couleur de la ligne.
        # Ne pas ajouter de '$' avant le nom de la variable "header_color", sinon la couleur souhaitée ne s'affiche pas
		header_base_line_color=$1
	fi

	# Ligne
	header_base_line_char=$2				# Caractère composant chaque colonne d'une ligne d'un header

	# Chaîne de caractères
	header_base_string_color=$3		# Définition de la couleur de la chaîne de caractères
	header_base_string=$4			# Chaîne de caractères affichée dans chaque header
	
	echo "$SCRIPT_VOID"

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SCRIPT_SLEEP_HEADER
	draw_header_line "$header_base_line_color" "$header_base_line_char" "$SCRIPT_C_RESET" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	# Affichage une autre couleur pour le texte
	echo "$header_base_string_color""##>" "$header_base_string" "$SCRIPT_C_RESET" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	draw_header_line "$header_base_line_color" "$header_base_line_char" "$SCRIPT_C_RESET" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	echo "$SCRIPT_VOID"

	echo "$SCRIPT_VOID"

	$SCRIPT_SLEEP_HEADER

	return
}

# Fonction d'affichage des headers lors d'un changement d'étape
function script_header()
{
	header_string=$1	# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	header_base "$SCRIPT_C_CYAN" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_CYAN" "$header_string"

	return
}

# Fonction d'affichage de headers lors du passage à une nouvelle catégorie de paquets lors de l'installation de ces derniers
function header_install()
{
	install_string=$1	# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	header_base "$SCRIPT_C_JAUNE" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_VERT" "$install_string"

	return
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger)
function handle_errors()
{
	error_string=$1		# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	header_base "$SCRIPT_C_ROUGE" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_ROUGE" "ERREUR FATALE : $error_string"

	r_echo_nolog "Une erreur fatale s'est produite :" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	r_echo_nolog "$error_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	echo "$SCRIPT_VOID"

	r_echo_nolog "Arrêt de l'installation" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	echo "$SCRIPT_VOID"

	# En cas d'erreurs de lancement du script (mauvais argument ou aucun argument)
	mv "$SCRIPT_LOG" "$SCRIPT_HOMEDIR"

	# Si le fichier de logs se trouve toujours dans le dossier actuel (si le script a été exécuté depuis un autre dossier)
	if test "$SCRIPT_LOGPATH" != "$SCRIPT_HOMEDIR/$SCRIPT_LOG"; then
		mv "$SCRIPT_LOG" "$SCRIPT_HOMEDIR"
	fi

	echo "En cas de bug, veuillez m'envoyer le fichier de logs situé dans votre dossier personnel. Il porte le nom de \"$SCRIPT_LOG\""
	echo "$SCRIPT_VOID"

	exit 1
}


## DÉFINITION DES FONCTIONS D'INSTALLATION
# Téléchargement des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets, puis installation des paquets
function pack_install()
{
	# Si vous souhaitez mettre tous les paquets en tant que multiples arguments (tableau d'arguments), remplacez le "$1"
	# ci-dessous par "$@" et enlevez les doubles guillemets "" entourant chaque variable "$package_name" de la fonction
	package_name=$1

	function pack_full_install()
	{
		j_echo "Installation du paquet $package_name"
		$SCRIPT_SLEEP_INST

		# $@ --> Tableau dynamique d'arguments permettant d'appeller la commande d'installation complète du gestionnaire de paquets et ses options
		"$@" "$package_name" 2>&1 | tee -a "$SCRIPT_LOGPATH"
		v_echo "Le paquet \"$package_name\" a été correctement installé"
		echo "$SCRIPT_VOID"

		$SCRIPT_SLEEP_INST
	}

	# Installation du paquet souhaité selon la commande d'installation du gestionnaire de paquets de la distribution de l'utilisateur
	# Pour chaque gestionnaire de paquets, on appelle la fonction "pack_full_install()" en passant en argument la commande d'installation
	# complète, avec l'option permettant d'installer le paquet sans demander à l'utilisateur s'il souhaite installer le paquet
	case $SCRIPT_OS_FAMILY in
		opensuse)
			pack_manager_install zypper -y install
			;;
		archlinux)
			pack_manager_install pacman --noconfirm -S
			;;
		fedora)
			pack_full_install dnf -y install
			return
			;;
		debian)
			pack_full_install apt -y install
			;;
		gentoo)
			pack_manager_install emerge
			;;
	esac

	return
}

# Installation de paquets via le gestionnaire de paquets Snap
function snap_install()
{
	j_echo "Installation du paquet $*"
    snap install "$@" \
		|| {
				r_echo "L'installation du paquet \"$*\" a échoué"
				echo "$SCRIPT_VOID"

				return
		 	} \
		&& v_echo "Installation du paquet \"$*\" effectuée avec succès"
	echo "$SCRIPT_VOID"

	return
}


## DÉFINITION DES FONCTIONS DE CRÉATION DE FICHIERS ET DE DOSSIERS
# Fonction de création de dossiers ET d'attribution récursive des droits de lecture et d'écriture à l'utilisateur
function makedir()
{
	dirparent=$1					# Emplacement de création du dossier depuis la racine (dossier parent)
	dirname=$2						# Nom du dossier à créer dans son dossier parent
	dirpath="$dirparent/$dirname"	# Chemin complet du dossier

	if test ! -d "$dirpath"; then
		j_echo "Création du dossier \"$dirname\" dans le dossier \"$dirparent\""
		mkdir -v "$dirpath" >> "$SCRIPT_LOGPATH" \
			|| handle_errors "LE DOSSIER \"$dirname\" N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER PARENT \"$dirparent\"" \
			&& v_echo "Le dossier \"$dirname\" a été créé avec succès dans le dossier \"$dirparent\""
		echo "$SCRIPT_VOID"

		# On change les droits du dossier créé par le script
		# Comme il est exécuté en mode super-utilisateur, le dossier créé appartient totalement au super-utilisateur.
		# Pour attribuer les droits de lecture, d'écriture et d'exécution (rwx) à l'utilisateur normal, on appelle
		# la commande chown avec pour arguments :
		#		- Le nom de l'utilisateur à qui donner les droits
		#		- Le chemin du dossier cible
		#		- Ici, la variable contenant la redirection
		chown -R -v "$SCRIPT_USERNAME" "$dirpath" >> "$SCRIPT_LOGPATH" \
			|| {
				r_echo "Impossible de changer les droits du dossier \"$dirpath\""
				r_echo "Pour changer les droits du dossier \"$dirpath\" de manière récursive,"
				r_echo "utilisez la commande :"
				echo "	chown -R $SCRIPT_USERNAME $dirpath"

				return
			} \
			&& v_echo "Les droits du dossier $dirpath ont été changés avec succès"
		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent
	# MAIS que ce dossier contient AU MOINS un fichier ou dossier
	elif test -d "$dirpath" && test "$(ls -A "$dirpath")"; then
		j_echo "Un dossier non-vide portant exactement le même nom se trouve déjà dans le dossier cible \"$dirparent\""
		j_echo "Suppression du contenu du dossier \"$dirpath\""
		echo "$SCRIPT_VOID"

		# ATTENTION À NE PAS MODIFIER LA LIGNE " rm -r -f "${dirpath/*}" ", À MOINS DE SAVOIR EXACTEMENT CE QUE VOUS FAITES
		# Pour plus d'informations --> https://github.com/koalaman/shellcheck/wiki/SC2115
		rm -r -f -v "${dirpath/:?}/"* 2>&1 | tee -a "$SCRIPT_LOGPATH" \
			|| {
				r_echo "Impossible de supprimer le contenu du dossier \"$dirpath";
				r_echo "Le contenu de tout fichier du dossier \"$dirpath\" portant le même nom qu'un des fichiers téléchargés sera écrasé"
				return
				} \
			&& { v_echo "Suppression du contenu du dossier \"$dirpath\" effectuée avec succès"; }

			return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent
	# ET que ce dossier est vide
	elif test -d "$dirpath"; then
		v_echo "Le dossier \"$dirpath\" existe déjà"

		return
	fi
}

# Fonction de création de fichiers ET d'attribution des droits de lecture et d'écriture à l'utilisateur
function makefile()
{
	file_dirparent=$1	# Dossier parent du fichier à créer
	filename=$2			# Nom du fichier à créer
	filepath="$file_dirparent/$filename"

	# Si le fichier à créer n'existe pas
	if test ! -f "$filepath"; then
		touch "$file_dirparent/$filename" 2>&1 | tee -a "$SCRIPT_LOGPATH" \
			|| handle_errors "LE FICHIER \"$filename\" n'a pas pu être créé dans le dossier \"$file_dirparent\"" \
			&& v_echo "Le fichier \"$filename\" a été créé avec succès dans le dossier \"$file_dirparent\""

		chown -v "$SCRIPT_USERNAME" "$filepath" >> "$SCRIPT_LOGPATH" \
			|| {
				r_echo "Impossible de changer les droits du fichier \"$filepath\""
				r_echo "Pour changer les droits du fichier \"$filepath\","
				r_echo "utilisez la commande :"
				echo "	chown $SCRIPT_USERNAME $filepath"

				return
			} \
			&& v_echo "Les droits du fichier $filepath ont été changés avec succès"

		return

	# Sinon, si le fichier à créer existe déjà ou qu'il n'est pas vide
	elif test -f "$filepath" || test -s "$filepath"; then
		true > "$filepath" \
			|| r_echo_nolog "Le contenu du fichier \"$filepath\" n'a pas été écrasé" >> "$SCRIPT_LOGPATH" \
			&& v_echo_nolog "Le contenu du fichier \"$filepath\" a été écrasé avec succès" >> "$SCRIPT_LOGPATH"

		return
	fi
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

#### DÉFINITION DES FONCTIONS DÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####



## DÉFINITION DES FONCTIONS D'INITIALISATION
# Création du fichier de logs pour répertorier chaque sortie de commande (sortie standard STDOUT ou sortie d'erreurs STDERR)
function create_log_file()
{
	# On évite d'appeler les fonctions d'affichage propre "v_echo()" ou "r_echo()" pour éviter d'écrire deux fois le même texte,
	# vu que ces fonctions appellent chacune une commande écrivant dans le fichier de logs

	# Si le fichier de logs n'existe pas, le script le crée via la fonction "makefile"
	makefile "$PWD" "$SCRIPT_LOG" > /dev/null
	echo "$SCRIPT_VOID" >> "$SCRIPT_LOGPATH" 	# Au moment de la création du fichier de logs, la variable "$SCRIPT_LOGPATH" correspond au dossier actuel de l'utilisateur

	v_echo_nolog "Fichier de logs créé avec succès" >> "$SCRIPT_LOGPATH"
	echo "$SCRIPT_VOID" >> "$SCRIPT_LOGPATH"

	# Récupération d'éléments servant à mieux identifier le système d'exploitation de l'utilisateur
	echo "Kernel : $(uname -s)" >> "$SCRIPT_LOGPATH"							# Récupération du nom du noyau
	echo "Version du Kernel : $(uname -r)" >> "$SCRIPT_LOGPATH"		# Récupération du numéro de version du noyau
	# Récupération des informations sur le système d'exploitation de l'utilisateur
	echo "Informations sur le système d'exploitation :" >> "$SCRIPT_LOGPATH"
	echo "$SCRIPT_VOID" "$SCRIPT_VOID" >> "$SCRIPT_LOGPATH"
	
	cat "/etc/os-release" >> "$SCRIPT_LOGPATH"
	echo "$SCRIPT_VOID" "$SCRIPT_VOID" >> "$SCRIPT_LOGPATH"

	v_echo_nolog "Fin des informations sur le système d'exploitation" >> "$SCRIPT_LOGPATH"
	echo "$SCRIPT_VOID" >> "$SCRIPT_LOGPATH"

	return
}

# Détection de l'exécution du script en mode super-utilisateur (root)
function script_init()
{
	# On appelle la fonction de création du fichier de logs
	create_log_file

	# Si le script n'est pas lancé en mode super-utilisateur
	if test "$EUID" -ne 0; then
    	r_echo "Ce script doit être exécuté en tant que super-utilisateur (root)"
    	r_echo "Exécutez ce script en plaçant$C_RESET sudo$C_ROUGE devant votre commande :"
		echo "$SCRIPT_VOID"

    	# Le paramètre "$0" ci-dessous est le nom du fichier shell en question avec le "./" placé devant (argument 0).
    	# Si ce fichier est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
    	echo "	sudo $0 votre_nom_d'utilisateur"
		echo "$SCRIPT_VOID"

		r_echo "Ou connectez vous directement en tant que super-utilisateur"
		r_echo "Et tapez cette commande :"
		echo "	$0 votre_nom_d'utilisateur"

		handle_errors "SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"

	# Sinon, si le script est lancé en mode super-utilisateur, on vérifie que la commande d'exécution du script soit accompagnée d'un argument
	else
		# Si aucun argument n'est entré
		if test -z "${SCRIPT_USERNAME}"; then
			r_echo "Veuillez lancer le script en plaçant votre nom d'utilisateur après la commande d'exécution du script :"
			echo "	sudo $0 votre_nom_d'utilisateur"

			handle_errors "VOUS N'AVEZ PAS PASSÉ VOTRE NOM D'UTILISATEUR EN ARGUMENT"

		# Sinon, si l'argument attendu est entré
		else
            # Si la valeur de l'argument ne correspond pas au nom de l'utilisateur
			if test "$(pwd | cut -d '/' -f-3 | cut -d '/' -f3-)" != "${SCRIPT_USERNAME}"; then
				r_echo "Veuillez entrer correctement votre nom d'utilisateur"
				echo "$SCRIPT_VOID"

				r_echo "Si vous avez exécuté le script en dehors de votre dossier personnel ou d'un de ses sous-dossiers,"
				r_echo "veuillez y retourner, et réexécuter le script."

				handle_errors "LA CHAÎNE DE CARACTÈRES PASSÉE EN PREMIER ARGUMENT NE CORRESPOND PAS À VOTRE NOM D'UTILISATEUR"

			# Sinon, si la valeur de l'argument correspond au nom de l'utilisateur
			else
				# On déplace le fichier de logs vers le dossier personnel de l'utilisateur
				mv -v "$SCRIPT_LOG" "$SCRIPT_HOMEDIR" >> "$SCRIPT_HOMEDIR/$SCRIPT_LOG" \
					|| handle_errors "IMPOSSIBLE DE DÉPLACER LE FICHIER DE LOGS VERS LE DOSSIER $SCRIPT_HOMEDIR" \
					&& SCRIPT_LOGPATH="$SCRIPT_HOMEDIR/$SCRIPT_LOG"

				v_echo_nolog "Vous avez correctement entré votre nom d'utilisateur" >> "$SCRIPT_LOGPATH"
				v_echo_nolog "Lancement du script" >> "$SCRIPT_LOGPATH"

				return
			fi
		fi
	fi
}

# Détection du gestionnaire de paquets de la distribution utilisée
function get_dist_package_manager()
{
	script_header "DÉTECTION DE VOTRE GESTIONNAIRE DE PAQUETS"

	# On cherche la commande du gestionnaire de paquets de la distribution de l'utilisateur dans les chemins de la variable d'environnement "$PATH" en l'exécutant.
	# On redirige chaque sortie ("stdout (sortie standard) si la commande est trouvée" et "stderr(sortie d'erreurs) si la commande n'est pas trouvée")
	# de la commande vers /dev/null (vers rien) pour ne pas exécuter la commande.

	# Pour en savoir plus sur les redirections en Shell UNIX, consultez ce lien -> https://www.tldp.org/LDP/abs/html/io-redirection.html
    command -v zypper &> /dev/null && SCRIPT_OS_FAMILY="opensuse"
    command -v pacman &> /dev/null && SCRIPT_OS_FAMILY="archlinux"
    command -v dnf &> /dev/null && SCRIPT_OS_FAMILY="fedora"
    command -v apt &> /dev/null && SCRIPT_OS_FAMILY="debian"
    command -v emerge &> /dev/null && SCRIPT_OS_FAMILY="gentoo"

	# Si, après la recherche de la commande, la chaîne de caractères contenue dans la variable $SCRIPT_OS_FAMILY est toujours nulle (aucune commande trouvée)
	if test "$SCRIPT_OS_FAMILY" = ""; then
		handle_errors "LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ"
	else
		v_echo "Le gestionnaire de paquets de votre distribution est supporté ($SCRIPT_OS_FAMILY)"
	fi
}

# Demande à l'utilisateur s'il souhaite vraiment lancer le script, puis connecte l'utilisateur en mode super-utilisateur
function launch_script()
{
	script_header "LANCEMENT DU SCRIPT"

	j_echo "Assurez-vous d'avoir lu au moins le mode d'emploi (Mode d'emploi.odt) avant de lancer l'installation."
    j_echo "Êtes-vous sûr de bien vouloir lancer l'installation ? (oui/non)"
	echo "$SCRIPT_VOID"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	function read_launch_script()
	{
        # On demande à l'utilisateur d'entrer une réponse
		read -r -p "Entrez votre réponse : " rep_launch

		# Dans le cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non"
		# Les deux virgules suivant directement le "launch" signifient que les mêmes réponses avec des majuscules sont permises
		case ${rep_launch,,} in
	        "oui")
				echo "$SCRIPT_VOID"

				v_echo "Vous avez confirmé vouloir exécuter ce script."
				v_echo "C'est parti !!!"

				return
	            ;;
	        "non")
				echo "$SCRIPT_VOID"

				r_echo "Le script ne sera pas exécuté"
	            r_echo "Abandon"
				echo "$SCRIPT_VOID"

				exit 1
	            ;;
            # Si une réponse différente de "oui" ou de "non" est rentrée
			*)
				echo "$SCRIPT_VOID"

				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
				echo "$SCRIPT_VOID"

				# On rappelle la fonction "read_launch_script" en boucle tant qu"une réponse différente de "oui" ou de "non" est entrée
				read_launch_script
				;;
	    esac
	}
	# Appel de la fonction "read_launch_script", car même si la fonction est définie dans la fonction "launch_script", ses instructions ne sont pas lues automatiquement
	read_launch_script
}


## DÉFINITION DES FONCTIONS DE CONNEXION À INTERNET ET DE MISES À JOUR
# Vérification de la connexion à Internet
function check_internet_connection()
{
	script_header "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à Internet (pour le savoir, on ping le serveur DNS d'OpenDNS avec la commande ping 1.1.1.1)
	if ping -q -c 1 -W 1 opendns.com > /dev/null; then
		v_echo "Votre ordinateur est connecté à Internet"

		return
	# Sinon, si l'ordinateur n'est pas connecté à Internet
	else
		handle_errors "AUCUNE CONNEXION À INTERNET"
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté
# (ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE PAS MODIFIER CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
function dist_upgrade()
{
	script_header "MISE À JOUR DU SYSTÈME"

	# On récupère la commande du gestionnaire de paquets stocké dans la variable "$SCRIPT_OS_FAMILY",
	# puis on appelle sa commande de mise à jour des paquets installés
	case "$SCRIPT_OS_FAMILY" in
		opensuse)
			zypper -y update 2>&1 | tee -a "$SCRIPT_LOGPATH"
			;;
		archlinux)
			pacman --noconfirm -Syu 2>&1 | tee -a "$SCRIPT_LOGPATH"
			;;
		fedora)
			dnf -y update 2>&1 | tee -a "$SCRIPT_LOGPATH"
			;;
		debian)
			apt -y update; apt -y upgrade 2>&1 | tee -a "$SCRIPT_LOGPATH"
			;;
		gentoo)
			emerge -u world 2>&1 | tee -a "$SCRIPT_LOGPATH"
			;;
	esac

	echo "$SCRIPT_VOID"

	v_echo "Mise à jour du système effectuée avec succès"

	return
}


## DÉFINITION DES FONCTIONS DE PARAMÉTRAGE
# Détection et installation de Sudo
function set_sudo()
{
	script_header "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"

	sudoers_old="/etc/sudoers $SCRIPT_DATE.old"

    j_echo "Détection de sudo $SCRIPT_C_RESET"

	# On effectue un test pour savoir si la commande "sudo" est installée sur le système de l'utilisateur
	command -v sudo > /dev/null 2>&1 \
		|| {
				j_echo "La commande \"sudo\" n'est pas installé sur votre système"
				pack_install sudo
			} \
		&& { v_echo "La commande \"sudo\" est déjà installée sur votre système"; }
	echo "$SCRIPT_VOID"

	j_echo "Le script va tenter de télécharger un fichier \"sudoers\" déjà configuré"
	j_echo "depuis le dossier des fichiers ressources de mon dépôt Git : "
	echo ">>>> https://github.com/DimitriObeid/Linux-reinstall/tree/master/Ressources"
	echo "$SCRIPT_VOID"

	j_echo "Souhaitez vous le télécharger PUIS l'installer maintenant dans le dossier \"/etc/\" ? (oui/non)"
	echo "$SCRIPT_VOID"

	echo ">>>> REMARQUE : Si vous disposez déjà des droits de super-utilisateur, ce n'est pas la peine de le faire !"
	echo ">>>> Si vous avez déjà un fichier sudoers modifié, une sauvegarde du fichier actuel sera effectuée dans le même dossier"
	echo "$SCRIPT_VOID"

	function read_set_sudo()
	{
		read -r -p "Entrez votre réponse : " rep_sudo

		case ${rep_sudo,,} in
			"oui")
				echo "$SCRIPT_VOID"

				# Téléchargement du fichier sudoers configuré
				j_echo "Téléchargement du fichier sudoers depuis le dépôt Git $SCRIPT_REPO"
				sleep 1
				echo "$SCRIPT_VOID"

				wget https://raw.githubusercontent.com/DimitriObeid/Linux-reinstall/master/Ressources/sudoers -O "$SCRIPT_TMPPATH/sudoers" \
					|| { r_echo "Impossible de télécharger le fichier \"sudoers\""; return; } \
					&& v_echo "Fichier \"sudoers\" téléchargé avec succès"
				echo "$SCRIPT_VOID"

				# Sauvegarde du fichier "/etc/sudoers" existant en "sudoers.old"
				j_echo "Création d'une sauvegarde de votre fichier sudoers existant nommée \"sudoers $SCRIPT_DATE.old\""
				cat "/etc/sudoers" > "$sudoers_old" \
					|| { r_echo "Impossible de créer une sauvegarde du fichier sudoers"; return; } \
					&& v_echo "Le fichier de sauvegarde \"$sudoers_old\" a été créé avec succès"
				echo "$SCRIPT_VOID"

				# Déplacement du fichier vers le dossier "/etc/"
				j_echo "Déplacement du fichier \"sudoers\" vers \"/etc/\""
				mv "$SCRIPT_TMPPATH/sudoers" /etc/sudoers \
					|| { r_echo "Impossible de déplacer le fichier \"sudoers\" vers le dossier \"/etc/\""; return; } \
					&& { v_echo "Fichier sudoers déplacé avec succès vers le dossier "; }
				echo "$SCRIPT_VOID"

				# Ajout de l'utilisateur au groupe "sudo"
				j_echo "Ajout de l'utilisateur ${SCRIPT_USERNAME} au groupe sudo"
				usermod -aG root "${SCRIPT_USERNAME}" 2>&1 | tee -a "$SCRIPT_LOGPATH" \
					|| { r_echo "Impossible d'ajouter l'utilisateur \"$SCRIPT_USERNAME\" à la liste des sudoers"; return; } \
					&& { v_echo "L'utilisateur ${SCRIPT_USERNAME} a été ajouté au groupe sudo avec succès"; }

				return
				;;
			"non")
				echo "$SCRIPT_VOID"

				v_echo "Le fichier \"/etc/sudoers\" ne sera pas modifié"

				return
				;;
			*)
				echo "$SCRIPT_VOID"

				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
				read_set_sudo
				;;
		esac
	}
	read_set_sudo

	return
}


# DÉFINITION DES FONCTIONS DE FIN D'INSTALLATION
# Suppression des paquets obsolètes
function autoremove()
{
	script_header "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"

	j_echo "Souhaitez vous supprimer les paquets obsolètes ? (oui/non)"
	echo "$SCRIPT_VOID"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il souhaite supprimer les paquets obsolètes
	function read_autoremove()
	{
		read -r -p "Entrez votre réponse : " rep_autoremove

		case ${rep_autoremove,,} in
			"oui")
				echo "$SCRIPT_VOID"

				j_echo "Suppression des paquets"
				echo "$SCRIPT_VOID"

	    		case "$SCRIPT_OS_FAMILY" in
	        		opensuse)
	            		j_echo "Le gestionnaire de paquets Zypper n'a pas de commande de suppression automatique de tous les paquets obsolètes"
						j_echo "Référez vous à la documentation du script ou à celle de Zypper pour supprimer les paquets obsolètes"
	            		;;
	        		archlinux)
	            		pacman --noconfirm -Qdt
	            		;;
	        		fedora)
	            		dnf -y autoremove
	            		;;
	        		debian)
	            		apt -y autoremove
	            		;;
	        		gentoo)
	            		emerge -uDN @world      # D'abord, vérifier qu'aucune tâche d'installation est active
	            		emerge --depclean -a    # Suppression des paquets obsolètes. Demande à l'utilisateur s'il souhaite supprimer ces paquets
	            		eix-test-obsolete       # Tester s'il reste des paquets obsolètes
	            		;;
				esac

				echo "$SCRIPT_VOID"

				v_echo "Auto-suppression des paquets obsolètes effectuée avec succès"

				return
				;;
			"non")
				echo "$SCRIPT_VOID"

				v_echo "Les paquets obsolètes ne seront pas supprimés"
				v_echo "Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets"

				return
				;;
			*)
				echo "$SCRIPT_VOID"

				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
				read_autoremove
				;;
		esac
	}
	read_autoremove

	return
}

# Fin de l'installation
function is_installation_done()
{
	script_header "INSTALLATION TERMINÉE"

	v_echo "Suppression du dossier temporaire $SCRIPT_TMPPATH"
	rm -r -f -v "$SCRIPT_TMPPATH" >> "$SCRIPT_LOGPATH" \
		|| r_echo "Suppression du dossier temporaire impossible. Essayez de le supprimer à la main" \
		&& v_echo "Le dossier temporaire \"$SCRIPT_TMPPATH\" a été supprimé avec succès"
	echo "$SCRIPT_VOID"

    v_echo "Installation terminée. Votre distribution Linux est prête à l'emploi"

	j_echo "Note :$SCRIPT_C_RESET Si vous avez constaté un bug ou tout autre problème lors de l'exécution du script, vous pouvez m'envoyer le fichier de logs situé dans le dossier \"$SCRIPT_LOGPATH\""

    # On tue le processus de connexion en mode super-utilisateur, par précaution
	sudo -k
	echo "$SCRIPT_VOID"

	return
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #


################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################



## APPEL DES FONCTIONS DE CONSTRUCTION
# Détection du mode super-administrateur (root) et de la présence de l'argument contenant le nom d'utilisateur
script_init

# Affichage du header de bienvenue
script_header "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX : VERSION $SCRIPT_VERSION !!!!!"
v_echo "Début de l'installation"

# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager

# Assurance que l'utilisateur soit sûr de lancer le script
launch_script

# Détection de la connexion à Internet
check_internet_connection

# Mise à jour des paquets actuels
dist_upgrade

# Création du dossier temporaire où sont stockés les fichiers temporaires
script_header "CRÉATION DU DOSSIER TEMPORAIRE \"$SCRIPT_TMPDIR\" DANS LE DOSSIER \"$SCRIPT_TMPPARENT\""
makedir "$SCRIPT_TMPPARENT" "$SCRIPT_TMPDIR"


## INSTALLATIONS PRIORITAIRES
script_header "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
pack_install curl
pack_install snapd
pack_install wget

command -v curl snapd wget >> "$SCRIPT_LOGPATH" \
	|| handle_errors "AU MOINS UNE DES COMMANDES D'INSTALLATION MANQUE À L'APPEL" \
	&& v_echo "Les commandes importantes d'installation ont été installées avec succès"

# Installation de sudo (pour les distributions livrées sans la commande) et configuration du fichier "sudoers" ("/etc/sudoers")
set_sudo

## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION
# Création du dossier "Logiciels.Linux-reinstall.d" dans le dossier personnel de l'utilisateur
script_header "CRÉATION DU DOSSIER D'INSTALLATION DES LOGICIELS"

software_dir="Logiciels.Linux-reinstall.d"
makedir "$SCRIPT_HOMEDIR" "$software_dir"

# Affichage du message de création du dossier "Logiciels.Linux-reinstall.d"
script_header "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION"

j_echo "Les logiciels téléchargés via la commande \"wget\" sont déplacés vers le nouveau dossier \"Logiciels.Linux-reinstall\","
j_echo "localisé dans votre dossier personnel"
sleep 1
echo "$SCRIPT_VOID"

v_echo "Vous pouvez désormais quitter votre ordinateur pour chercher un café"
v_echo "La partie d'installation de vos programmes commence véritablement"
sleep 1
echo "$SCRIPT_VOID"

echo "$SCRIPT_VOID"

sleep 3

# Commandes
header_install "INSTALLATION DES COMMANDES PRATIQUES"
pack_install htop
pack_install neofetch
pack_install tree

# Développement
header_install "INSTALLATION DES OUTILS DE DÉVELOPPEMENT"
snap_install atom --classic		# Éditeur de code Atom
snap_install code --classic		# Éditeur de code Visual Studio Code
pack_install emacs
pack_install g++
pack_install gcc
pack_install git
pack_install make
pack_install umlet
pack_install valgrind

# Logiciels de nettoyage de disque
header_install "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"
pack_install k4dirstat

# Internet
header_install "INSTALLATION DES CLIENTS INTERNET"
snap_install discord --stable
pack_install thunderbird

# LAMP
header_install "INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP"
pack_install apache2			# Apache
pack_install php				# PHP
pack_install libapache2-mod-php
pack_install mariadb-server		# Pour installer un serveur MariaDB (Si vous souhaitez un seveur MySQL, remplacez "mariadb-server" par "mysql-server"
pack_install php-mysql
pack_install php-curl
pack_install php-gd
pack_install php-intl
pack_install php-json
pack_install php-mbstring
pack_install php-xml
pack_install php-zip

# Librairies
header_install "INSTALLATION DES LIBRAIRIES"
pack_install python3.7

# Réseau
header_install "INSTALLATION DES LOGICIELS RÉSEAU"
pack_install wireshark

# Vidéo
header_install "INSTALLATION DES LOGICIELS VIDÉO"
pack_install vlc

header_install "INSTALLATION DE WINE"
pack_install wine-stable

v_echo "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS ! FIN DE L'INSTALLATION"


# Suppression des paquets obsolètes
autoremove
# Fin de l'installation
is_installation_done
