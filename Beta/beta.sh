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

## CHRONOMÈTRE

# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer le timer, changer la valeur de "sleep".
# Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
# NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SLEEP_HEADER=sleep\ 1.5   	# Temps d'affichage d'un header uniquement, avant d'afficher le reste de l'étape, lors d'un changement d'étape
SLEEP_INST=sleep\ .5    	# Temps d'affichage du nom du paquet, avant d'afficher le reste de l'étape, lors de l'installation d'un nouveau paquet
SLEEP_INST_CAT=sleep\ 1 	# Temps d'affichage d'un changement de catégories de paquets lors de l'étape d'installation


## COULEURS

# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
C_HEADER=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers.
C_JAUNE=$(tput setaf 226) 		# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes.
C_PACK_CATS=$(tput setaf 6)		# Bleu cyan		--> Couleur d'affichage des messages de passage à la prochaine catégorie de paquets.
C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal.
C_ROUGE=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape.
C_VERT=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape.

## TEXTE

# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret,
# changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes
# (une ligne de chaque caractère).
HEADER_LINE_CHAR="-"
# Affichage de colonnes sur le terminal
COLS=$(tput cols)
# Nombre de dièses (hash) précédant et suivant une chaîne de caractères
HASH="#####"
# Nombre de chevrons avant les chaînes de caractères jaunes, vertes et rouges
TAB=">>>>"
# Affichage de chevrons précédant l'encodage de la couleur d'une chaîne de caractères
J_TAB="$C_JAUNE$TAB"
R_TAB="$C_ROUGE$TAB$TAB"
V_TAB="$C_VERT$TAB$TAB"
# Saut de ligne
VOID=""


## VERSION

# Version actuelle du script
SCRIPT_VERSION="2.0"


################### DÉFINITION DES FONCTIONS ###################

## DÉFINITION DES FONCTIONS DE DÉCORATION DU SCRIPT
# Affichage d'un message de changement de catégories de paquets propre à la partie d'installation des paquets (encodé en bleu cyan,
# entouré de dièses et appelant la variable de chronomètre pour chaque passage à une autre catégorie de paquets)
cats_echo() { cats_string=$1; echo "$C_PACK_CATS$HASH $cats_string $HASH $C_RESET"; $SLEEP_INST_CAT;}
# Affichage d'un message en jaune avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
j_echo() { j_string=$1; echo "$J_TAB $j_string $C_RESET";}
# Affichage d'un message en rouge avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
r_echo() { r_string=$1; echo "$R_TAB $r_string $C_RESET";}
# Affichage d'un message en vert avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
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

	# Pour définir (ici, réintialiser) la couleur des caractères suivant le dernier caractère de la ligne du header.
	# En pratique, La couleur des caractères suivants est déjà encodée quand ils sont appelés. Cette réinitialisation
	# de la couleur du texte n'est qu'une mini sécurité permettant d'éviter d'avoir la couleur du prompt encodée avec
	# la couleur des headers si l'exécution du script est interrompue de force avec un "CTRL + C" ou un "CTRL + Z", par
	# exemple.
	if test "$line_color" != ""; then
        echo -n -e "$C_RESET"
	fi
}

# Affichage du texte des headers
script_header()
{
	header_string=$1

	# Pour définir la couleur de la ligne du caractère souhaité
	if test "$header_color" = ""; then
        # Définition de la couleur de la ligne.
        # Ne pas ajouter de '$' avant le nom de la variable "header_color", sinon la couleur souhaitée ne s'affiche pas
		header_color=$C_HEADER
	fi

	echo "$VOID"

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SLEEP_HEADER
	draw_header_line "$HEADER_LINE_CHAR" "$header_color"
	# Pour afficher une autre couleur pour le texte, remplacez l'appel de variable "$header_color" ci-dessous par la couleur que vous souhaitez
	echo "$header_color" "##>" "$header_string"
	draw_header_line "$HEADER_LINE_CHAR" "$header_color"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	echo "$VOID"

	echo "$VOID"

	$SLEEP_HEADER
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger)
handle_errors()
{
	error_result=$1

	if test "$error_color" = ""; then
		error_color=$C_ROUGE
	fi

	echo "$VOID" "$VOID"

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SLEEP_HEADER
	draw_header_line "$HEADER_LINE_CHAR" "$error_color"
	# Pour afficher une autre couleur pour le texte, remplacez l'appel de variable "$error_color" ci-dessous par la couleur que vous souhaitez
	echo "$error_color" "##> $error_result"
	draw_header_line "$HEADER_LINE_CHAR" "$error_color"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	echo "$VOID"

	echo "$VOID"

	$SLEEP_HEADER
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
    	# Le paramètre "$0" ci-dessous est le nom du fichier shell en question avec le "./" placé devant (argument 0).
    	# Si ce fichier est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
    	r_echo "$C_RESET	sudo $0"
		r_echo "Ou connectez vous directement en tant que super-administrateur"
		r_echo "Et tapez cette commande :"
		r_echo "$C_RESET	$0"
		handle_errors "ERREUR : SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"
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
    command -v zypper &> /dev/null && OS_FAMILY="opensuse"
    command -v pacman &> /dev/null && OS_FAMILY="archlinux"
    command -v dnf &> /dev/null && OS_FAMILY="fedora"
    command -v apt &> /dev/null && OS_FAMILY="debian"
    command -v emerge &> /dev/null && OS_FAMILY="gentoo"

	# Si, après la recherche de la commande, la chaîne de caractères contenue dans la variable $OS_FAMILY est toujours nulle (aucune commande trouvée)
	if test "$OS_FAMILY" = ""; then
		handle_errors "ERREUR : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ"
	else
		v_echo "Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY)"
	fi
}

# Demande à l'utilisateur s'il souhaite vraiment lancer le script, s'il a bien été exécuté en tant qu'utilisateur root
launch_script()
{
	script_header "LANCEMENT DU SCRIPT"

	j_echo "Assurez-vous d'avoir lu au moins le mode d'emploi (Mode d'emploi.odt) avant de lancer l'installation."
    j_echo "Êtes-vous sûr de savoir ce que vous faites ? (oui/non)"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	read_launch_script()
	{
        # Demande à l'utilisateur d'entrer une réponse
		read -r rep_launch

		# Les deux virgules suivant directement le "launch" signifient que les mêmes réponses avec des majuscules sont permises
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
            # Si une réponse différente de "oui" ou de "non" est rentrée
			*)
				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
				# On rappelle la fonction "read_launch_script" en boucle tant qu"une réponse différente de "oui" ou de "non" est entrée
				read_launch_script
				;;
	    esac
	}
	# Appel de la fonction "read_launch_script", car même si la fonction est définie dans la fonction "launch_script", elle n'est pas lue automatiquement
	read_launch_script
}


## CONNEXION À INTERNET ET MISES À JOUR
# Vérification de la connexion à Internet
check_internet_connection()
{
	script_header "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à internet
	if ping -q -c 1 -W 1 google.com > /dev/null; then
		v_echo "Votre ordinateur est connecté à Internet"
	else
		handle_errors "ERREUR : AUCUNE CONNEXION À INTERNET"
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté
# (ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE PAS MODIFIER CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
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

	echo "$VOID"

	v_echo "Mise à jour du système effectuée avec succès"
}

## DÉFINITION DES FONCTIONS D'INSTALLATION
# Téléchargement des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets, puis installation des paquets
pack_install()
{
	# Si vous souhaitez mettre tous les paquets en tant que multiples arguments (tableau d'arguments), remplacez le "$1"
	# ci-dessous par "$@" et enlevez les doubles guillemets "" entourant chaque variable "$package_name" suivant la commande
	# d'installation de votre distribution.
	package_name=$1

	# Pour éviter de retaper ce qui ne fait pas partie de la commande d'installation pour chaque gestionnaire de paquets
	pack_manager_install()
	{
		$SLEEP_INST

		# $@ --> Tableau dynamique d'arguments permettant d'appeller la commande d'installation complète du gestionnaire de paquets et ses options
		# ATTENTION 
		"$@" "$package_name"
		v_echo "Le paquet \"$package_name\" a été correctement installé"
		echo "$VOID"

		$SLEEP_INST
	}

	# On cherche à savoir si le paquet souhaité est déjà installé sur le disque en utilisant des redirections.
	# Si c'est le cas, le script affiche que le paquet est déjà installé et ne perd pas de temps à le réinstaller.
	# Sinon, le script installe le paquet manquant.

	j_echo "Installation de $package_name"

	# Installation du paquet souhaité selon la commande d'installation du gestionnaire de paquets de la distribution de l'utilisateur
	case $OS_FAMILY in
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
}

# Pour installer des paquets via le gestionnaire de paquets Snap
snap_install()
{
    snap install "$@"    # Utilisation d'un tableau dynamique d'arguments pour ajouter des options
	echo "$VOID"
}

## DÉFINITION DES FONCTIONS DE PARAMÉTRAGE
# Détection de Sudo
#set_sudo()
{
	script_header "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"
	
    j_echo "$J_TAB Détection de sudo $C_RESET"
	command -v sudo /dev/null 2>&1 || {}
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

				v_echo "Les paquets obsolètes ne seront pas supprimés"
				v_echo "Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets"
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


## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION
script_header "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION"

v_echo "Vous pouvez désormais quitter votre ordinateur pour chercher un café"
v_echo "La partie d'installation de vos programmes commence véritablement"
echo "$VOID"

sleep 3

# Installations prioritaires
cats_echo "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
pack_install curl
pack_install python-pip
pack_install snapd
pack_install wget
echo "$VOID"

# Commandes
cats_echo "INSTALLATION DES COMMANDES PRATIQUES"
pack_install neofetch
pack_install tree
echo "$VOID"

# Logiciels de cryptage et de sécurité
cats_echo "INSTALLATION DES LOGICIELS DE CRYPTAGE ET DE SÉCURITÉ"
pack_install veracrypt

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
echo "$VOID"

# Logiciels de nettoyage de disque
cats_echo "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"
pack_install k4dirstat
echo "$VOID"

# Internet
cats_echo "INSTALLATION DES CLIENTS INTERNET"
snap_install discord --stable
pack_install thunderbird
echo "$VOID"

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
echo "$VOID"

# Librairies
cats_echo "INSTALLATION DES LIBRAIRIES"
pack_install python3.7
echo "$VOID"

# Réseau
cats_echo "INSTALLATION DES LOGICIELS RÉSEAU"
pack_install wireshark
echo "$VOID"

# Vidéo
cats_echo "INSTALLATION DES LOGICIELS VIDÉO"
pack_install vlc
echo "$VOID"

cats_echo "INSTALLATION DE WINE"
pack_install wine-stable
echo "$VOID"

v_echo "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS ! FIN DE L'INSTALLATION"


# Suppression des paquets obsolètes
autoremove
# Fin de l'installation
is_installation_done