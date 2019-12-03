#!/bin/bash

# Script de réinstallation minimal en version Alpha
# Version Alpha 2.0

# Pour débugguer ce script en cas de besoin, taper la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

# Ou débugguer sur Shell Check : https://www.shellcheck.net/


### DÉFINITION DES VARIABLES ###

## HEADER
# Si vous souhaitez mettre un autre caractère à la place d'un tiret, changez le caractère entre les double guillemets
LINE_CHAR="-"

## CHRONOMÈTRE
# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer le timer, changer la valeur de "sleep".
# Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
# NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SLEEP_TAB=sleep\ 1.5    # Temps d'affichage d'un changement d'étape
SLEEP_INST=sleep\ .5    # Temps d'affichage lors de l'installation d'un nouveau paquet
SLEEP_INST_CAT=sleep\ 1 # Temps d'affichage d'un changement de catégories de paquets lors de l'étape d'installation

## COULEURS
# Couleurs pour mieux lire les étapes de l'exécution du script
C_ROUGE=$(tput setaf 196)   # Rouge clair
C_VERT=$(tput setaf 82)     # Vert clair
C_JAUNE=$(tput setaf 226)   # Jaune clair
C_RESET=$(tput sgr0)        # Restaurer la couleur originale du texte affiché selon la configuration du profil du terminal
C_HEADER_LINE=$(tput setaf 6)      # Bleu cyan. Définition de l'encodage de la couleur du texte du header. /!\ Ne modifier l'encodage de couleurs du header qu'ici ET SEULEMENT ici /!\

## AFFICHAGE DE TEXTE
# Nombre de chevrons avant les chaînes de caractères vertes et rouges
TAB=">>>>"
J_TAB="$C_JAUNE$TAB"
R_TAB="$C_ROUGE$TAB$TAB"
V_TAB="$C_VERT$TAB$TAB"
VOID=""

## CRÉATION DES HEADERS
# Afficher les lignes des headers pour la bienvenue et le passage à une autre étape du script
draw_header_line()
{
	line_cols=$(tput cols)
	line_char=$1
	line_color=$2

	# Pour définir la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	if test "$line_color" != ""; then
		echo -ne "$line_color"
	fi

	# Pour afficher le caractère souhaité sur toute la ligne
	for i in $(eval echo "{1..$line_cols}"); do
		echo -n "$line_char"
	done

	# Pour définir la couleur de ce qui suit le dernier caractère
	if test "$line_color" != ""; then
		echo -ne "$line_color"
	fi
}

# Affichage du texte des headers
script_header()
{
    header_color=$2

	# Pour définir la couleur de la ligne du caractère souhaité
	if test "$header_color" = ""; then
        # Définition de la couleur de la ligne
		header_color=$C_HEADER_LINE
	fi

	echo "$VOID"
	# Décommenter la ligne ci dessous pour activer le chronomètre avant l'affichage du header
#   $SLEEP
	echo -ne "$header_color"     # Afficher la ligne du haut selon la couleur de la variable $color
	draw_header_line $LINE_CHAR
    # Commenter la ligne du dessous pour que le prompt "##>" soit de la même couleur que la ligne du dessus
#    echo -ne $C_RESET
	echo "##> $1 $header_color"
	draw_header_line $LINE_CHAR
	echo -ne "$C_RESET"
	$SLEEP_TAB
}

# Fonction de gestion d'erreurs
handle_error()
{
	error_result=$1
	error_color=$2

	if test "$error_color" = ""; then
		error_color=$C_RED
	fi

	echo "$VOID"
	echo -ne "$error_color"
	draw_header_line $LINE_CHAR "$error_color"
	echo "##> $1"
	draw_header_line $LINE_CHAR "$error_color"

	echo -en "$R_TAB Une erreur s'est produite lors de l'installation --> $error_result --> Arrêt de l'installation $C_RESET"
	echo "$VOID"
	exit 1
}


## DÉFINITION DES FONCTIONS D'INSTALLATION
# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager()
{
	script_header "DÉTECTION DE VOTRE GESTIONNAIRE DE PAQUETS"
	echo "$J_TAB Détection de votre gestionnaire de paquet :$C_RESET"

    command -v zypper &> /dev/null && OS_FAMILY="opensuse"
    command -v pacman &> /dev/null && OS_FAMILY="archlinux"
    command -v dnf &> /dev/null && OS_FAMILY="fedora"
    command -v apt &> /dev/null && OS_FAMILY="debian"
    command -v emerge &> /dev/null && OS_FAMILY="gentoo"

	# Si, après l'appel de la fonction, la string contenue dans la variable $OS_FAMILY est toujours nulle
	if test "$OS_FAMILY" = "void"; then
		handle_error "ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ"
	else
		echo "$V_TAB Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY) $C_RESET"; echo "$VOID"
	fi
}

# Détection du mode super-administrateur (root)
detect_root()
{
    # Si le script n'est pas exécuté en root
    if [ "$EUID" -ne 0 ]; then
    	echo "$R_TAB Ce script doit être exécuté en tant qu'administrateur (root)."
    	echo "$R_TAB Placez sudo devant votre commande :"
		echo "$R_TAB sudo $0"  # $0 est le nom du fichier shell en question avec le "./" placé devant (argument 0). S'il est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
		handle_error "ERREUR : SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"
    	echo "$C_RESET"
    	exit 1
    fi

    # Sinon, si le script est exécuté en root
    echo "$J_TAB Assurez-vous d'avoir lu au moins le mode d'emploi avant de lancer l'installation."
    echo -n "$J_TAB Êtes-vous sûr de savoir ce que vous faites ? (oui/non) $C_RESET"; echo "$VOID"

	# Fonction d'entrée de réponse sécurisée et optimisée
	read_launch_script()
	{
		read -r rep_launch
		case ${rep_launch,,} in
	        "oui")
				echo "$VOID"
	            echo "$V_TAB Vous avez confirmé vouloir exécuter ce script. C'est parti !!! $C_RESET";
				return
	            ;;
	        "non")
				echo "$VOID"
	            echo "$R_TAB Le script ne sera pas exécuté"
	            echo "$R_TAB Abandon $C_RESET"
	            exit 1
	            ;;
			*)
				echo "$VOID"
				echo "$R_TAB Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\" $C_RESET"
				read_launch_script
				;;
	    esac
	}
	read_launch_script
}

check_internet_connection()
{
	script_header "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à internet
	if ping -q -c 1 -W 1 google.com >/dev/null; then
		echo "$V_TAB Votre ordinateur est connecté à Internet $C_RESET"
	else
		handle_error "ERREUR : AUCUNE CONNEXION À INTERNET !"
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté
# (ÉTAPE IMPORTANTE, NE PAS MODIFIER, SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
dist_upgrade()
{
	script_header "MISE À JOUR DU SYSTÈME"

	echo "$VOID"
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
	echo "$V_TAB Mise à jour du système effectuée avec succès $C_RESET"
}

# Installation des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets
# Installation des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets
pack_install()
{
	package_name=$@
	case $OS_FAMILY in
		opensuse)
			echo "$V_TAB Installation de $package_name $C_RESET"
			$SLEEP_INST
			zypper -y install "$package_name"
			echo "$VOID"
			;;
		archlinux)
			echo "$V_TAB Installation de $package_name $C_RESET"
			$SLEEP_INST
			pacman --noconfirm -S "$package_name"
			echo "$VOID"
			;;
		fedora)
			echo "$V_TAB Installation de $package_name $C_RESET"
			$SLEEP_INST
			dnf -y install "$package_name"
			echo "$VOID"
			;;
		debian)
			echo "$V_TAB Installation de $package_name $C_RESET"
			$SLEEP_INST
			apt -y install "$package_name"
			echo "$VOID"
			;;
		gentoo)
			echo "$V_TAB Installation de $package_name $C_RESET"
			$SLEEP_INST
			emerge "$package_name"
			echo "$VOID"
			;;
	esac
}

# Pour installer des paquets Snap
snap_install()
{
    snap_name=$@
    snap install "$snap_name"
}

# Installer un paquet depuis un PPA (gestionnaire de paquets privé)
# pour télécharger des paquets absents des dépôts officiels
PPA_install()
{
	script_header "AJOUT DE DÉPÔTS PPA ET TÉLÉCHARGEMENT DE PAQUETS DEPUIS CES DÉPÔTS"
	suse_ppa=""
	arch_ppa=""
	fedora_ppa=""
	debian_ppa=""
	gentoo_ppa=""

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

# Installer sudo sur Debian et ajouter l'utilisateur actuel à la liste des sudoers
set_sudo()
{
    script_header "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS";
    echo "$J_TAB Détection de sudo $C_RESET"
    if ! command -v sudo > /dev/null ; then
        pack_install sudo
    else
        echo "$V_TAB \"sudo\" est déjà installé sur votre système d'exploitation $C_RESET"; echo "$VOID"
    fi
	# Si l'utilisateur ne bénéficie pas des privilèges root

	# Astuce : Essayer de parser le fichier sudoers et de récupérer la ligne : "root    ALL=(ALL) ALL", puis le contenu de la ligne du dessous. Si elle est vide, alors on ouvre Visudo et on laisse l'utilisateur rentrer la ligne "user root    ALL=(ALL) NOPASSWORD"
    if [ $USER != sudoers ]; then
		echo "$J_TAB AJOUT DE L'UTILISATEUR ACTUEL À LA LISTE DES SUDOERS $C_RESET"
		echo "$J_TAB LISEZ ATTENTIVEMENT CE QUI SUIT !!!!!!!! $C_RESET"
		echo "L'éditeur de texte Visudo (éditeur basé sur Vi spécialement créé pour modifier le fichier protégé /etc/sudoers)"
		echo "va s'ouvrir pour que vous puissiez ajouter votre compte utilisateur à la liste des sudoers afin de bénéficier"
		echo "des privilèges d'administrateur avec la commande sudo sans avoir à vous connecter en mode super-utilisateur."; echo "$VOID"
		echo "$J_TAB La ligne à ajouter se trouve dans la section \"#User privilege specification\". Sous la ligne $C_RESET"
		echo "root    ALL=(ALL) ALL"; echo "$VOID"
		echo "$J_TAB Tapez : $C_RESET"
		echo "$USER	ALL=(ALL) NOPASSWD:ALL"; echo "$VOID"
		echo "$J_TAB Si vous avez bien compris (ou mieux, noté) la procédure à suivre, tapez EXACTEMENT \"compris\" pour ouvrir Visudo"
		echo "$J_TAB Ou tapez EXACTEMENT \"quitter\" si vous souhaitez configurer le fichier \"/etc/visudo\" plus tard $C_RESET"

		# Fonction d'entrée de réponse sécurisée et optimisée
		read_visudo()
		{
			read -r visudo_rep
			case ${visudo_rep,,} in
				"compris")
					visudo
					usermod -aG sudo $USER
					# SI USERMOD = MODIFIÉ; ALORS
					#	AFFICHER "sudoers modifié"
					# SINON
					#	AFFICHER "sudoers non modifié"
					;;
				"quitter")
					return
					;;
				*)
				#	echo "$VOID"
				#	echo "$R_TAB Veuillez taper EXACTEMENT \"compris\" pour ouvrir Visudo,"
				#	echo "$R_TAB ou \"quitter\" pour configurer le fichier \"/etc/sudoers\" plus tard $C_RESET"
					read_visudo
					;;
			esac
		}
		read_visudo
    else
        echo "$V_TAB Vous avez déjà les permissions du mode sudo $C_RESET"
    fi
}

# Suppression des paquets obsolètes
autoremove()
{
	echo "$J_TAB Souhaitez vous supprimer les paquets obsolètes ? (oui/non) $C_RESET"

	# Fonction d'entrée de réponse sécurisée et optimisée
	read_autoremove()
	{
		read -r autoremove_rep
		case ${autoremove_rep,,} in
			"oui")
				echo "$V_TAB Suppression des paquets $C_RESET"; echo "$VOID"
	    		case "$OS_FAMILY" in
	        		opensuse)
	            		echo "$J_TAB Le gestionnaire de paquets Zypper n'a pas de commande de suppression automatique de tous les paquets obsolètes$C_RESET"
						echo "$J_TAB Référez vous à la documentation du script ou à celle de Zypper pour supprimer les paquets obsolètes$C_RESET"
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
				echo "$V_TAB Auto-suppression des paquets obsolètes effectuée avec succès $C_RESET";
				;;
			"non")
				echo "$R_TAB Les paquets obsolètes ne seront pas supprimés $C_RESET";
				echo "$J_TAB Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets $C_RESET"
				;;
			*)
				echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\" $C_RESET"
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
    echo "$V_TAB Installation terminée. Votre distribution est prête à l'emploi $C_RESET"
}


################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################
## APPEL DES FONCTIONS DE CONSTRUCTION
# Affichage du header de bienvenue
script_header "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX !!!!!"
echo "$J_TAB Début de l'installation"
# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager
# Détection du mode super-administrateur (root)
detect_root
# Détection de la connexion à Internet
check_internet_connection
# Mise à jour des paquets actuels
dist_upgrade
# Téléchargement de Sudo et ajout de l'utilisateur à la liste des sudoers
set_sudo

## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION
script_header "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION";

# Installations prioritaires
echo "$J_TAB INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS $C_RESET"; $SLEEP_INST_CAT
pack_install curl
pack_install git
pack_install snapd
pack_install wget
echo "$VOID"

# Commandes
echo "$J_TAB INSTALLATION DES COMMANDES PRATIQUES $C_RESET"; $SLEEP_INST_CAT
pack_install neofetch
pack_install tree
echo "$VOID"

# Internet
echo "$J_TAB INSTALLATION DES CLIENTS INTERNET $C_RESET"; $SLEEP_INST_CAT
snap_install discord
pack_install thunderbird
echo "$VOID"

# Librairies
echo "$J_TAB INSTALLATION DES LIBRAIRIES $C_RESET"; $SLEEP_INST_CAT
pack_install libcsfml-dev
pack_install libsfml-dev
pack_install python3.7
pack_install python-pip
echo "$VOID"

# Logiciels
echo "$J_TAB INSTALLATION DES LOGICIELS $C_RESET"; $SLEEP_INST_CAT
pack_install k4dirstat

# Machines virtuelles
echo "$J_TAB INSTALLATION DE VMWARE $C_RESET"; $SLEEP_INST_CAT
echo "Feature en attente"; echo "$VOID"
# wget

# Programmation
echo "$J_TAB INSTALLATION DES OUTILS DE DÉVELOPPEMENT $C_RESET"; $SLEEP_INST_CAT
snap_install atom --classic		# Atom IDE
snap_install code --classic		# Visual Studio Code
pack_install valgrind

# Vidéo
echo "$J_TAB INSTALLATION DE VLC $C_RESET"; $SLEEP_INST_CAT
pack_install vlc
echo "$VOID"

# LAMP
echo "$J_TAB INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP $C_RESET"; $SLEEP_INST_CAT
lamp="apache2 php libapache2-mod-php mariadb-server php-mysql php-curl php-gd php-intl php-json php-mbstring php-xml php-zip"
pack_install "$lamp"
echo "$VOID"


# Suppression des paquets obsolètes
script_header "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"
autoremove
# Fin de l'installation
is_installation_done
