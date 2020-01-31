#!/bin/bash

# Script de réinstallation minimal pour les cours de BTS SIO en version Bêta
# Version Bêta 2.0

# Pour débugguer ce script en cas de besoin, tapez la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

# Ou débugguez le en utilisant Shell Check : https://www.shellcheck.net/


################### DÉCLARATION DES VARIABLES ET AFFECTATION DE LEURS VALEURS ###################

# ARGUMENTS
# Arguments à placer après la commande d'exécution du script pour qu'il s'exécute
SCRIPT_USER_NAME=$1		# Premier argument : Le nom du compte de l'utilisateur

## CHRONOMÈTRE

# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer le timer, changer la valeur de "sleep".
# Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
# NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SCRIPT_SLEEP=sleep\ .5			# Temps d'affichage d'un texte de sous-étape
SCRIPT_SLEEP_HEADER=sleep\ 1.5	# Temps d'affichage d'un header uniquement, avant d'afficher le reste de l'étape, lors d'un changement d'étape
SCRIPT_SLEEP_INST=sleep\ .5		# Temps d'affichage du nom du paquet, avant d'afficher le reste de l'étape, lors de l'installation d'un nouveau paquet
SCRIPT_SLEEP_INST_CAT=sleep\ 1	# Temps d'affichage d'un changement de catégories de paquets lors de l'étape d'installation


## COULEURS

# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
SCRIPT_C_HEADER=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers.
SCRIPT_C_JAUNE=$(tput setaf 226) 	# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes.
SCRIPT_C_PACK_CATS=$(tput setaf 6)	# Bleu cyan		--> Couleur d'affichage des messages de passage à la prochaine catégorie de paquets.
SCRIPT_C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal.
SCRIPT_C_ROUGE=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape.
SCRIPT_C_VERT=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape.

# DOSSIERS CRÉÉS
# Définition du dossier parent des dossiers créés
SCRIPT_HOMEDIR="/home/${SCRIPT_USER_NAME}"		# Dossier parent du dossier temporaire (dossier personnel de l'utilisateur)

# Création du dossier temporaire et définition des chemins vers ce dossier temporaire
SCRIPT_TMPDIR="Linux-reinstall.tmp.d"			# Nom du dossier temporaire
SCRIPT_TMPPATH="${SCRIPT_HOMEDIR}/$SCRIPT_TMPDIR"	# Chemin complet du dossier temporaire


# RESSOURCES
SCRIPT_REPO="https://github.com/DimitriObeid/Linux-reinstall"

## TEXTE

# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret,
# changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes
# (une ligne de chaque caractère).
SCRIPT_HEADER_LINE_CHAR="-"
SCRIPT_COLS=$(tput cols)	# Affichage de colonnes sur le terminal
SCRIPT_HASH="#####"			# Nombre de dièses (hash) précédant et suivant une chaîne de caractères
SCRIPT_TAB=">>>>"			# Nombre de chevrons avant les chaînes de caractères jaunes, vertes et rouges

# Affichage de chevrons précédant l'encodage de la couleur d'une chaîne de caractères
SCRIPT_J_TAB="$SCRIPT_C_JAUNE$SCRIPT_TAB"				# Encodage de la couleur en jaune et affichage de 4 chevrons
SCRIPT_R_TAB="$SCRIPT_C_ROUGE$SCRIPT_TAB$SCRIPT_TAB"	# Encodage de la couleur en rouge et affichage de 4 chevrons
SCRIPT_V_TAB="$SCRIPT_C_VERT$SCRIPT_TAB$SCRIPT_TAB"		# Encodage de la couleur en vert et affichage de 4 chevrons

# Saut de ligne
SCRIPT_VOID=""


## VERSION

# Version actuelle du script
SCRIPT_VERSION="2.0"


################### DÉFINITION DES FONCTIONS ###################

## DÉFINITION DES FONCTIONS DE DÉCORATION DU SCRIPT
# Affichage d'un message de changement de catégories de paquets propre à la partie d'installation des paquets (encodé en bleu cyan,
# entouré de dièses et appelant la variable de chronomètre pour chaque passage à une autre catégorie de paquets)
cats_echo() { cats_string=$1; echo "$SCRIPT_C_PACK_CATS$SCRIPT_HASH $cats_string $SCRIPT_HASH $SCRIPT_C_RESET"; $SCRIPT_SLEEP_INST_CAT;}

# Affichage d'un message en jaune avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
j_echo() { j_string=$1; echo "$SCRIPT_J_TAB $j_string $SCRIPT_C_RESET"; $SCRIPT_SLEEP;}

# Affichage d'un message en rouge avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
r_echo() { r_string=$1; echo "$SCRIPT_R_TAB $r_string $SCRIPT_C_RESET"; $SCRIPT_SLEEP;}

# Affichage d'un message en vert avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
v_echo() { v_string=$1; echo "$SCRIPT_V_TAB $v_string $SCRIPT_C_RESET"; $SCRIPT_SLEEP;}

## CRÉATION DES HEADERS
# Afficher les lignes des headers pour la bienvenue et le passage à une autre étape du script
draw_header_line()
{
	line_char=$1	# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction
	line_color=$2	# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction

	# Définition de la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	if test "$line_color" != ""; then
		echo -n -e "$line_color"
	fi

	# Affichage du caractère souhaité sur toute la ligne. Pour cela, on commence à la lire à partir de la première colonne (1),
	# puis, on parcourt toute la colonne jusqu'à la fin de la ligne. À chaque fin de boucle, un caractère est affiché, coloré
	# selon l'encodage de la couleur stocké dans la variable

	# délimité par la valeur retournée par
	# "tput cols" (affichage du nombre de colonnes séparant la bordure gauche de la bordure droite de la zone
	# de texte du terminal), dont la variable "$SCRIPT_COLS" stocke la commande d'exécution.
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

# Affichage du texte des headers
script_header()
{
	header_string=$1	# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	# Définition de la couleur de la ligne du caractère souhaité.
	# Il s'agit du même code définissant la première condition de la fonction "draw_header_line",
	# mais il a été réécrit ici pour définir l'affichage de la véritable couleur sur chaque caractère lors de l'appel de la
	# fonction "script_header()", car les conditions d'une fonction ne peuvent pas être utilisées depuis une autre fonction
	if test "$header_color" = ""; then
        # Définition de la couleur de la ligne.
        # Ne pas ajouter de '$' avant le nom de la variable "header_color", sinon la couleur souhaitée ne s'affiche pas
		header_color=$SCRIPT_C_HEADER
	fi

	echo "$SCRIPT_VOID"

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SCRIPT_SLEEP_HEADER
	draw_header_line "$SCRIPT_HEADER_LINE_CHAR" "$header_color"
	# Affichage une autre couleur pour le texte, remplacez l'appel de variable "$header_color" ci-dessous par la couleur que vous souhaitez
	echo "$header_color" "##>" "$header_string"
	draw_header_line "$SCRIPT_HEADER_LINE_CHAR" "$header_color"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	echo "$SCRIPT_VOID"

	echo "$SCRIPT_VOID"

	$SCRIPT_SLEEP_HEADER
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger)
handle_errors()
{
	error_result=$1		# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	# Même chose que dans la première condition de la fonction "script_header"
	if test "$error_color" = ""; then
		error_color=$SCRIPT_C_ROUGE
	fi

	echo "$SCRIPT_VOID" "$SCRIPT_VOID"

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SCRIPT_SLEEP_HEADER
	draw_header_line "$SCRIPT_HEADER_LINE_CHAR" "$error_color"
	# Affichage d'une autre couleur pour le texte, remplacez l'appel de variable "$error_color" ci-dessous par la couleur que vous souhaitez
	echo "$error_color" "##> ERREUR FATALE : $error_result"
	draw_header_line "$SCRIPT_HEADER_LINE_CHAR" "$error_color"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	echo "$SCRIPT_VOID"

	echo "$SCRIPT_VOID"

	$SCRIPT_SLEEP_HEADER
	r_echo "Une erreur fatale s'est produite :"
	r_echo "$error_result"
	echo "$SCRIPT_VOID"

	r_echo "Arrêt de l'installation"
	echo "$SCRIPT_VOID"

	exit 1
}


## DÉFINITION DES FONCTIONS D'EXÉCUTION
# Détection de l'exécution du script en mode super-administrateur (root)
script_init()
{
	# Si le script n'est pas lancé en mode super-utilistaeur
	if test "$EUID" -ne 0; then
    	r_echo "Ce script doit être exécuté en tant que super-administrateur (root)."
    	r_echo "Exécutez ce script en plaçant$C_RESET sudo$C_ROUGE devant votre commande :"
		echo "$SCRIPT_VOID"

    	# Le paramètre "$0" ci-dessous est le nom du fichier shell en question avec le "./" placé devant (argument 0).
    	# Si ce fichier est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
    	r_echo "$SCRIPT_C_RESET	sudo $0 $USER \$PWD"
		echo "$SCRIPT_VOID"

		r_echo "Ou connectez vous directement en tant que super-administrateur"
		r_echo "Et tapez cette commande :"
		r_echo "$SCRIPT_C_RESET	$0 $USER \$PWD"

		handle_errors "ERREUR : SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"

	# Sinon, si le script est lancé en mode super-utilisateur
	else
		# Si aucun argument n'est entré
		if test -z "${SCRIPT_USER_NAME}"; then
			r_echo "Veuillez lancer le script en plaçant votre nom devant la commande d'exécution du script,"
			r_echo "puis celui du chemin du fichier Shell depuis la racine."
			r_echo "$SCRIPT_C_RESET	sudo $0 votre_nom_d'utilisateur \$PWD"

			handle_errors "L'ARGUMENT MANQUE À L'APPEL"

		# Sinon, si l'argument attendu est entré
		else
            # Si la veleur de l'argument ne correspond pas au nom de l'utilisateur
			if test "$(pwd | cut -d '/' -f-3 | cut -d '/' -f3-)" != "${SCRIPT_USER_NAME}"; then
				r_echo "Veuillez entrer correctement votre nom d'utilisateur"
				echo "$SCRIPT_VOID"

				r_echo "Si vous avez exécuté le script en dehors de votre dossier personnel ou d'un de ses sous-dossiers,"
				r_echo "veuillez copier ou déplacer le script dans un répertoire de votre dossier personnel et réexécuter le script."

				handle_errors "LA CHAÎNE DE CARACTÈRES PASSÉE EN PREMIER ARGUMENT NE CORRESPOND PAS À VOTRE NOM D'UTILISATEUR"

			# Sinon, si la valeur de l'argument correspond au nom de l'utilisateur
			elif test "$(pwd | cut -d '/' -f-3 | cut -d '/' -f3-)" == "${SCRIPT_USER_NAME}"; then
				v_echo "Vous avez correctement entré votre nom d'utilisateur"
				v_echo "Lancement du script"

				return
			fi
		fi
	fi
}

# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager()
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
launch_script()
{
	script_header "LANCEMENT DU SCRIPT"

	j_echo "Assurez-vous d'avoir lu au moins le mode d'emploi (Mode d'emploi.odt) avant de lancer l'installation."
    j_echo "Êtes-vous sûr de savoir ce que vous faites ? (oui/non)"
	echo "$SCRIPT_VOID"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	read_launch_script()
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

## CONNEXION À INTERNET ET MISES À JOUR
# Vérification de la connexion à Internet
check_internet_connection()
{
	script_header "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à Internet (pour le savoir, on ping le serveur DNS d'OpenDNS (ping 1.1.1.1))
	if ping -q -c 1 -W 1 opendns.com > /dev/null; then
		v_echo "Votre ordinateur est connecté à Internet"

		return
	# Sinon, si l'ordinateur n'est pas connecté à Internet
	else
		r_echo "Aucune connexion à Internet n'est détectée"
		echo "$SCRIPT_VOID"

		handle_errors "AUCUNE CONNEXION À INTERNET"
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté
# (ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE PAS MODIFIER CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
dist_upgrade()
{
	script_header "MISE À JOUR DU SYSTÈME"

	# On récupère la commande du gestionnaire de paquets stocké dans la variable "$SCRIPT_OS_FAMILY",
	# puis on appelle sa commande de mise à jour des paquets installés
	case "$SCRIPT_OS_FAMILY" in
		opensuse)
			zypper -y update
			;;
		archlinux)
			pacman --noconfirm -Syu
			;;
		fedora)
			dnf -y update
			;;
		debian)
			apt -y update; apt -y upgrade
			;;
		gentoo)
			emerge -u world
			;;
	esac

	echo "$SCRIPT_VOID"

	v_echo "Mise à jour du système effectuée avec succès"

	return
}

## CRÉATION DE DOSSIERS
# Fonction de création rapide de dossiers
makedir()
{
	dirparent=$1					# Emplacement de création du dossier depuis la racine (dossier parent)
	dirname=$2						# Nom du dossier à créer dans son dossier parent
	dirpath="$dirparent/$dirname"	# Chemin complet du dossier

	if test ! -d "$dirpath"; then
		j_echo "Création du dossier \"$dirname\" dans le dossier \"$dirparent\""
		mkdir "$dirpath" \
			|| handle_errors "LE DOSSIER \"$dirname\" N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER \"$dirparent\" ($SCRIPT_TMPPATH)" \
			&& v_echo "Le dossier \"$dirname\" a été créé avec succès dans le dossier \"$dirparent\""

		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent
	# MAIS que ce dossier contient AU MOINS un fichier ou dossier
	elif test -d "$dirpath" && test "$(ls -A "$dirpath")"; then
		j_echo "Un dossier non-vide portant exactement le même nom se trouve déjà dans le dossier cible \"$dirparent\""
		j_echo "Suppression du contenu du dossier \"$dirpath\""
		echo "$SCRIPT_VOID"

		# ATTENTION À NE PAS MODIFIER LA LIGNE " rm -r -f "${dirpath/*}" ", À MOINS DE SAVOIR CE QUE VOUS FAITES
		# Pour plus d'informations --> https://github.com/koalaman/shellcheck/wiki/SC2115
		rm -r -f "${dirpath/:?}/"* \
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

## DÉFINITION DES FONCTIONS D'INSTALLATION
# Téléchargement des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets, puis installation des paquets
pack_install()
{
	# Si vous souhaitez mettre tous les paquets en tant que multiples arguments (tableau d'arguments), remplacez le "$1"
	# ci-dessous par "$@" et enlevez les doubles guillemets "" entourant chaque variable "$package_name" suivant la commande
	# d'installation de votre distribution.
	package_name=$1

	pack_manager_check_pack()
	{
		case $SCRIPT_OS_FAMILY in
			opensuse)
				;;
			archlinux)
				;;
			fedora)
				dnf list "$package_name"
				;;
			debian)
				dpkg -s "$package_name"
				;;
			gentoo)
				;;
		esac
	}

	# Cette fonction permet d'éviter de retaper ce qui ne fait pas partie de la commande d'installation pour chaque gestionnaire de paquets
	pack_manager_install()
	{
		$SCRIPT_SLEEP_INST

		# $@ --> Tableau dynamique d'arguments permettant d'appeller la commande d'installation complète du gestionnaire de paquets et ses options
		# ATTENTION à ne pas mettre le "$@" et le "$package_name" entre les mêmes guillemets, sinon le nom du paquet à installer sera considéré comme
		# faisant partie du tableau d'arguments stockant la commande d'installation complète du gestionnaire de paquets
		"$@" "$package_name"

        command -v "$package_name" > /dev/null \
            || r_echo "Le paquet $package_name n'a pas été installé sur votre système" \
            && v_echo "Le paquet \"$package_name\" a été correctement installé"
		echo "$SCRIPT_VOID"

		# Appel de la commande "sleep" mettant en pause le script pendant 0,5 secondes, le temps que l'utilisateur voit si un paquet a bien été installé
		$SCRIPT_SLEEP_INST
	}

	j_echo "Installation de $package_name"

	# Installation du paquet souhaité selon la commande d'installation du gestionnaire de paquets de la distribution de l'utilisateur
	case $SCRIPT_OS_FAMILY in
		opensuse)
			pack_manager_install zypper -y install
			;;
		archlinux)
			pack_manager_install pacman --noconfirm -S
			;;
		fedora)
			pack_manager_install dnf -y install
			;;
		debian)
			pack_manager_install apt -y install
			;;
		gentoo)
			pack_manager_install emerge
			;;
	esac

	return
}

# Pour installer des paquets via le gestionnaire de paquets Snap
snap_install()
{
	snap_name="$*" # Utilisation d'un tableau dynamique d'arguments pour ajouter des options de téléchargement
#	j_echo "Installation du paquet \"$snap_name\""

    snap install "$snap_name"
	echo "$SCRIPT_VOID"

	return
}

## DÉFINITION DES FONCTIONS DE PARAMÉTRAGE
# Détection et installation de Sudo
set_sudo()
{
	script_header "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"

    j_echo "$SCRIPT_J_TAB Détection de sudo $SCRIPT_C_RESET"

	# On effectue un test pour savoir si la commande "sudo" est installée sur le système de l'utilisateur
	command -v sudo > /dev/null 2>&1 \
		|| { j_echo "La commande \"sudo\" n'est pas installé sur votre système"; pack_install sudo ;} \
		&& { v_echo "La commande \"sudo\" est déjà installée sur votre système"; sleep 0.5; }
	echo "$SCRIPT_VOID"

	j_echo "Le script va tenter de télécharger un fichier \"sudoers\" déjà configuré"
	j_echo "depuis le dossier des fichiers ressources de mon dépôt Git : "
	echo ">>>> $SCRIPT_REPO/tree/master/Ressources"
	echo "$SCRIPT_VOID"

	j_echo "Souhaitez vous le télécharger PUIS l'installer maintenant dans le dossier \"/etc/\" ? (oui/non)"
	echo "$SCRIPT_VOID"

	echo ">>>> REMARQUE : Si vous disposez déjà des droits de super-utilisateur, ce n'est pas la peine de le faire !"
	echo ">>>> Si vous avez déjà un fichier sudoers modifié, TOUS les changements effectués seront écrasés"
	echo "$SCRIPT_VOID"

	read_set_sudo()
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

				# Déplacement du fichier vers le dossier "/etc/"
				j_echo "Déplacement du fichier \"sudoers\" vers \"/etc/\""
				mv "$SCRIPT_TMPPATH/sudoers" /etc/sudoers \
					|| { r_echo "Impossible de déplacer le fichier \"sudoers\" vers le dossier \"/etc/\""; return; } \
					&& { v_echo "Fichier sudoers déplacé avec succès vers le dossier "; }
				echo "$SCRIPT_VOID"

				# Ajout de l'utilisateur au groupe "sudo"
				j_echo "Ajout de l'utilisateur ${SCRIPT_USER_NAME} au groupe sudo"
				usermod -aG root "${SCRIPT_USER_NAME}" \
					|| { r_echo "Impossible d'ajouter l'utilisateur \"$SCRIPT_USER_NAME\" à la liste des sudoers"; return; } \
					&& { v_echo "L'utilisateur ${SCRIPT_USER_NAME} a été ajouté au groupe sudo avec succès"; }

				return
				;;
			"non")
				echo "$SCRIPT_VOID"

				j_echo "Le fichier \"/etc/sudoers\" ne sera pas modifié"

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

# Suppression des paquets obsolètes
autoremove()
{
	script_header "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"

	j_echo "Souhaitez vous supprimer les paquets obsolètes ? (oui/non)"
	echo "$SCRIPT_VOID"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il souhaite supprimer les paquets obsolètes
	read_autoremove()
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
is_installation_done()
{
	script_header "FIN DE L'INSTALLATION"

	v_echo "Suppression du dossier temporaire $SCRIPT_TMPPATH"
	rm -r -f "$SCRIPT_TMPPATH" \
		|| r_echo "Suppression du dossier temporaire impossible. Essayez de le supprimer à la main" \
		&& v_echo "Le dossier temporaire \"$SCRIPT_TMPPATH\" a été supprimé avec succès"
	echo "$SCRIPT_VOID"

    v_echo "Installation terminée. Votre distribution Linux est prête à l'emploi"
    # On tue le processus
	sudo -k
	echo "$SCRIPT_VOID"

	return
}

################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################

## APPEL DES FONCTIONS DE CONSTRUCTION
# Détection du mode super-administrateur (root)
script_init

# Affichage du header de bienvenue
script_header "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX VERSION $SCRIPT_VERSION !!!!!"
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
script_header "CRÉATION DU DOSSIER TEMPORAIRE \"$SCRIPT_TMPDIR\" DANS LE DOSSIER \"$SCRIPT_HOMEDIR\""
makedir "$SCRIPT_HOMEDIR" "$SCRIPT_TMPDIR"


## INSTALLATIONS PRIORITAIRES
script_header "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
pack_install curl
pack_install snapd
pack_install wget

command -v curl snapd wget > /dev/null 2>&1 \
	|| handle_errors "AU MOINS UNE DES COMMANDES D'INSTALLATION MANQUE À L'APPEL" \
	&& v_echo "Les commandes importantes d'installation ont été installées avec succès"

# Installation de sudo et configuration
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
cats_echo "INSTALLATION DES COMMANDES PRATIQUES"
pack_install htop
pack_install neofetch
pack_install tree
echo "$SCRIPT_VOID"

# Développement
cats_echo "INSTALLATION DES OUTILS DE DÉVELOPPEMENT"
snap_install atom --classic		# Éditeur de code Atom
snap_install code --classic		# Éditeur de code Visual Studio Code
pack_install emacs
pack_install g++
pack_install gcc
pack_install git
pack_install make
pack_install umlet
pack_install valgrind
echo "$SCRIPT_VOID"

# Logiciels de nettoyage de disque
cats_echo "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"
pack_install k4dirstat
echo "$SCRIPT_VOID"

# Internet
cats_echo "INSTALLATION DES CLIENTS INTERNET"
snap_install discord --stable
pack_install thunderbird
echo "$SCRIPT_VOID"

# LAMP
cats_echo "INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP"
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
echo "$SCRIPT_VOID"

# Librairies
cats_echo "INSTALLATION DES LIBRAIRIES"
pack_install python3.7
echo "$SCRIPT_VOID"

# Réseau
cats_echo "INSTALLATION DES LOGICIELS RÉSEAU"
pack_install wireshark
echo "$SCRIPT_VOID"

# Vidéo
cats_echo "INSTALLATION DES LOGICIELS VIDÉO"
pack_install vlc
echo "$SCRIPT_VOID"

cats_echo "INSTALLATION DE WINE"
pack_install wine-stable
echo "$SCRIPT_VOID"

v_echo "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS ! FIN DE L'INSTALLATION"


# Suppression des paquets obsolètes
autoremove
# Fin de l'installation
is_installation_done
