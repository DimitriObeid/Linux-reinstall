#!/bin/bash

# Script de réinstallation minimal pour les cours de BTS SIO en version Bêta
# Version Bêta 1.5

# Pour débugguer ce script en cas de besoin, taper la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

# Ou débugguer sur Shell Check : https://www.shellcheck.net/


################### DÉFINITION DES VARIABLES ###################

## CHRONOMÈTRE

# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer le timer, changer la valeur de "sleep".
# Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
# NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SLEEP_HEADER=sleep\ 1.5   	# Temps d'affichage d'un changement d'étape
SLEEP_INST=sleep\ .5    	# Temps d'affichage lors de l'installation d'un nouveau paquet
SLEEP_INST_CAT=sleep\ 1 	# Temps d'affichage d'un changement de catégories de paquets lors de l'étape d'installation

## COULEURS

# Couleurs pour mieux lire les étapes de l'exécution du script
C_HEADER_LINE=$(tput setaf 6)   # Bleu cyan. Définition de l'encodage de la couleur du texte du header. /!\ Ne modifier l'encodage de la couleur du header qu'ici ET SEULEMENT ici /!\
C_JAUNE=$(tput setaf 226) 		# Jaune clair
C_RESET=$(tput sgr0)        	# Restaurer la couleur originale du texte affiché selon la configuration du profil du terminal
C_ROUGE=$(tput setaf 196)   	# Rouge clair
C_VERT=$(tput setaf 82)     	# Vert clair

## AFFICHAGE DE TEXTE

# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret, changez le caractère entre les double guillemets.
# Ne mettez pas plus de deux caractères si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes.
HEADER_LINE_CHAR="-"
# Affichage de colonnes
COLS=$(tput cols)
# Nombre de chevrons avant les chaînes de caractères jaunes, vertes et rouges, et saut de ligne
TAB=">>>>"
J_TAB="$C_JAUNE$TAB"
R_TAB="$C_ROUGE$TAB$TAB"
V_TAB="$C_VERT$TAB$TAB"
VOID=""

## GESTION DE PAQUETS

# Variable contenant le nom de la famille de distributions du gestionnaire de paquets supporté.
# Si la chaîne de caractères de la variable est toujours vide après la définition de la variable,
# Alors le gestionnaire de paquets n'est pas supporté.
OS_FAMILY=""


################### DÉFINITION DES FONCTIONS ###################

## DÉFINITION DES FONCTIONS DE DÉCORATION DU SCRIPT
# Affichage de texte en jaune avec des chevrons
j_echo() { j_string=$1; echo "$J_TAB $j_string $C_RESET";}
# Affichage de texte en rouge avec des chevrons
r_echo() { r_string=$1; echo "$R_TAB $r_string $C_RESET";}
# Affichage de texte en vert avec des chevrons
v_echo() { v_string=$1; echo "$V_TAB $v_string $C_RESET";}

## CRÉATION DES HEADERS
# Afficher les lignes des headers pour la bienvenue et le passage à une autre étape du script
draw_header_line()
{
	line_char=$1	# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction
	line_color=$2	# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction

	# Pour définir la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	if test "$line_color" != ""; then
		echo -n -e "$line_color"
	fi

	# Pour afficher le caractère souhaité sur toute la ligne
	for i in $(eval echo "{1..$COLS}"); do
		echo -n "$line_char"
	done

	# Pour définir la couleur de ce qui suit le dernier caractère
	if test "$line_color" != ""; then
		echo -n -e "$C_RESET"		# La couleur de ce qui suit est déjà définie avec les paramètres des chaînes de caractères suivantes
	fi
}

# Affichage du texte des headers
script_header()
{
	header_string=$1

	# Pour définir la couleur de la ligne du caractère souhaité
	if test "$header_color" = ""; then
        # Définition de la couleur de la ligne. Ne pas ajouter de '$' avant le nom de la variable "header_color", sinon la couleur souhaitée ne s'affiche pas
		header_color=$C_HEADER_LINE
	fi

	echo "$VOID"
	# Décommenter la ligne ci dessous pour activer le chronomètre avant l'affichage du header
#   $SLEEP
	draw_header_line "$HEADER_LINE_CHAR" "$header_color"
	echo "$header_color" "##>" "$header_string"
	draw_header_line "$HEADER_LINE_CHAR" "$header_color"
	echo "$VOID" "$VOID"

	$SLEEP_HEADER
}

# Fonction de gestion d'erreurs
handle_error()
{
	error_result=$1

	if test "$error_color" = ""; then
		error_color=$C_ROUGE
	fi

	echo "$VOID"
	# Décommenter la ligne ci dessous pour activer le chronomètre avant l'affichage du header
#   $SLEEP
	draw_header_line "$HEADER_LINE_CHAR" "$error_color"
	echo "$error_color" "##> $error_result"		# Pour afficher une autre couleur pour le texte, remplacer l'appel de variable "$error_color" par ce que vous souhaitez
	draw_header_line "$HEADER_LINE_CHAR" "$error_color"

	echo "$VOID"
	r_echo "Une erreur s'est produite lors de l'installation --> $error_result --> Arrêt de l'installation"
	echo "$VOID"
	exit 1
}


## DÉFINITION DES FONCTIONS D'EXÉCUTION
# Détection de l'exécution du script en mode super-administrateur (root)
detect_root()
{
    # Si le script n'est pas exécuté en root
    if test "$EUID" -ne 0; then
    	r_echo "Ce script doit être exécuté en tant que super-administrateur (root)."
    	r_echo "Exécutez ce script en plaçant$C_RESET sudo$C_ROUGE devant votre commande :"
    	r_echo "$C_RESET	sudo $0"  # $0 est le nom du fichier shell en question avec le "./" placé devant (argument 0). S'il est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
		r_echo "Ou connectez vous directement en tant que super-administrateur"
		r_echo "Et tapez cette commande :"
		r_echo "$C_RESET	$0"
		handle_error "ERREUR : SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"
    	exit 1
    fi
}

# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager()
{
	script_header "DÉTECTION DE VOTRE GESTIONNAIRE DE PAQUETS"

	j_echo " Détection de votre gestionnaire de paquet"

    command -v zypper &> /dev/null && OS_FAMILY="opensuse"
    command -v pacman &> /dev/null && OS_FAMILY="archlinux"
    command -v dnf &> /dev/null && OS_FAMILY="fedora"
    command -v apt &> /dev/null && OS_FAMILY="debian"
    command -v emerge &> /dev/null && OS_FAMILY="gentoo"

	# Si, après l'appel de la fonction, la string contenue dans la variable $OS_FAMILY est toujours nulle
	if test "$OS_FAMILY" = ""; then
		handle_error "ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ"
	else
		v_echo "Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY)"
		echo "$VOID"
	fi
}

# Lancement du script s'il a bien été exécuté en tant que root
launch_script()
{
	j_echo "Assurez-vous d'avoir lu au moins le mode d'emploi avant de lancer l'installation."
    j_echo "Êtes-vous sûr de savoir ce que vous faites ? (oui/non)"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	read_launch_script()
	{
		read -r rep_launch

		case ${rep_launch,,} in
	        "oui")
				echo "$VOID"

	            v_echo "Vous avez confirmé vouloir exécuter ce script. C'est parti !!!"
				return
	            ;;
	        "non")
				echo "$VOID"

	            r_echo "Le script ne sera pas exécuté"
	            r_echo "Abandon"
				echo "$VOID"
	            exit 1
	            ;;
			*)
				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
				read_launch_script
				;;
	    esac
	}
	read_launch_script
}


## CONNECTIVITÉ ET MISES À JOUR
# Vérification de la connexion à Internet
check_internet_connection()
{
	script_header "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à internet
	if ping -q -c 1 -W 1 google.com >/dev/null; then
		v_echo "Votre ordinateur est connecté à Internet"
	else
		handle_error "ERREUR : AUCUNE CONNEXION À INTERNET"
		exit 1
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté
# (ÉTAPE IMPORTANTE, NE PAS MODIFIER, SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
dist_upgrade()
{
	script_header "MISE À JOUR DU SYSTÈME"

	case "$OS_FAMILY" in
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
	v_echo "Mise à jour du système effectuée avec succès"
}

## DÉFINITION DES FONCTIONS D'INSTALLATION
# Installation des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets
pack_install()
{
	# Si vous souhaitez mettre tous les paquets en tant que multiples arguments (tableau d'arguments), remplacez le'$1'
	# du dessous par '$@' et enlevez les doubles guillemets "" entourant chaque variable $package_name après la commande
	# d'installation de la ou des distributions de votre choix.
	package_name=$1

	# Pour éviter de retaper ce qui ne fait pas partie de la commande d'installation pour chaque gestionnaire de paquets
	cmd_args_f()
	{
		v_echo "Installation de $package_name"
		$SLEEP_INST
		$@    # Tableau dynamique d'arguments permettant d'appeller la commande d'installation complète du gestionnaire de paquets et ses options

		echo "$VOID"
	}

	case $OS_FAMILY in
		opensuse)
			cmd_args_f zypper -y install "$package_name"
			;;
		archlinux)
			cmd_args_f pacman --noconfirm -S "$package_name"
			;;
		fedora)
			cmd_args_f dnf -y install "$package_name"
			;;
		debian)
			cmd_args_f apt -y install "$package_name"
			;;
		gentoo)
			cmd_args_f emerge "$package_name"
			;;
	esac
}

# Pour installer des paquets Snap
snap_install()
{
    snap install "$@"    # Tableau dynamique d'arguments

	echo "$VOID"
}

# Installer un paquet depuis un PPA (Private Package Manager ; Gestionnaire de Paquets Privé)
ppa_install()
{
	script_header "AJOUT DE DÉPÔTS PPA ET TÉLÉCHARGEMENT DE PAQUETS DEPUIS CES DÉPÔTS"

	case $OS_FAMILY in
		opensuse)
			;;
		archlinux)

			;;
		fedora)
			;;
		debian)

			;;
		gentoo)
			;;
	esac
}

# Suppression des paquets obsolètes
autoremove()
{
	script_header "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"

	j_echo "Souhaitez vous supprimer les paquets obsolètes ? (oui/non)"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il souhaite supprimer les paquets obsolètes
	read_autoremove()
	{
		read -r autoremove_rep

		case ${autoremove_rep,,} in
			"oui")
				echo "$VOID"
				j_echo "Suppression des paquets"
				echo "$VOID"

	    		case "$OS_FAMILY" in
	        		opensuse)
	            		j_echo "Le gestionnaire de paquets Zypper n'a pas de commande de suppression automatique de tous les paquets obsolètes"
						j_echo "Référez vous à la documentation du script ou à celle de Zypper pour supprimer les paquets obsolètes"
	            		;;
	        		archlinux)
	            		pacman -Qdt
	            		;;
	        		fedora)
	            		dnf autoremove
	            		;;
	        		debian)
	            		apt autoremove
	            		;;
	        		gentoo)
	            		emerge -uDN @world      # D'abord, vérifier qu'aucune tâche d'installation est active
	            		emerge --depclean -a    # Suppression des paquets obsolètes. Demande à l'utilisateur s'il souhaite supprimer ces paquets
	            		eix-test-obsolete       # Tester s'il reste des paquets obsolètes
	            		;;
				esac

				echo "$VOID"
				v_echo "Auto-suppression des paquets obsolètes effectuée avec succès"
				return
				;;
			"non")
				echo "$VOID"
				j_echo "Les paquets obsolètes ne seront pas supprimés"
				j_echo "Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets"
				return
				;;
			*)
				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
				read_autoremove
				;;
		esac
	}
	read_autoremove
}

# Fin de l'installation
is_installation_done()
{
	script_header "FIN DE L'INSTALLATION"
    v_echo "Installation terminée. Votre distribution Linux est prête à l'emploi"

	echo "$VOID"
}

################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################

## APPEL DES FONCTIONS DE CONSTRUCTION
# Détection du mode super-administrateur (root)
detect_root
# Affichage du header de bienvenue
script_header "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX !!!!!"
v_echo "Début de l'installation"
# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager
# Assurance que l'utilisateur soit sûr de lancer le script
launch_script
# Détection de la connexion à Internet
check_internet_connection
# Mise à jour des paquets actuels
dist_upgrade


## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION
script_header "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION"

# Installations prioritaires
j_echo "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"; $SLEEP_INST_CAT
pack_install curl
pack_install snapd
pack_install wget
echo "$VOID"

# Commandes
j_echo "INSTALLATION DES COMMANDES PRATIQUES"; $SLEEP_INST_CAT
pack_install neofetch
pack_install tree
echo "$VOID"

# Internet
echo "$J_TAB INSTALLATION DES CLIENTS INTERNET $C_RESET"; $SLEEP_INST_CAT
snap_install discord --stable
pack_install thunderbird
echo "$VOID"

# Librairies
j_echo "INSTALLATION DES LIBRAIRIES"; $SLEEP_INST_CAT
pack_install python3.7
pack_install python-pip
echo "$VOID"

# Logiciels
j_echo "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"; $SLEEP_INST_CAT
pack_install k4dirstat
echo "$VOID"

# Programmation
j_echo "INSTALLATION DES OUTILS DE DÉVELOPPEMENT"; $SLEEP_INST_CAT
snap_install atom --classic		# Atom IDE
snap_install code --classic		# Visual Studio Code
pack_install emacs
pack_install g++
pack_install gcc
pack_install git
pack_install valgrind
echo "$VOID"

# Vidéo
j_echo "INSTALLATION DES LOGICIELS VIDÉO"; $SLEEP_INST_CAT
pack_install vlc
echo "$VOID"

# LAMP
j_echo "INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP"; $SLEEP_INST_CAT
pack_install apache2			# Apache
pack_install php				# PHP
pack_install libapache2-mod-php
pack_install mariadb-server		# Un serveur MariaDB (Si vous souhaitez un seveur MySQL, remplacez "mariadb-server" par mysql-server)
pack_install php-mysql
pack_install php-curl
pack_install php-gd
pack_install php-intl
pack_install php-json
pack_install php-mbstring
pack_install php-xml
pack_install php-zip

v_echo "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVAEC SUCCÈS ! FIN DE L'INSTALLATION"


# Suppression des paquets obsolètes
autoremove
# Fin de l'installation
is_installation_done
