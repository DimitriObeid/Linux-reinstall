#!/bin/bash

# Test de beta.sh, avec une nouvelle optimisation de l'affichage des headers

# Script de réinstallation minimal en Bêta

# Pour débugguer ce script en cas de besoin, taper la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

## Ce script sert à réinstaller tous les programmes Linux tout en l'exécutant.

### DÉFINITION DES VARIABLES GLOBALES ###

## HEADER
# Si vous souhaitez mettre d'autres caractères à la place d'une ligne, changez le caractère entre les double guillemets
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

## GESTION D'ERREURS
# Pour les cas d'erreurs possibles (la raison est mise entre les deux chaînes de caractères au moment où l'erreur se produit)
ERROR_OUTPUT_1="$R_TAB Une erreur s'est produite lors de l'installation -->"
ERROR_OUTPUT_2="$C_ROUGE Arrêt de l'installation$C_RESET"

## CRÉATION DES HEADERS
# Afficher les lignes des headers pour la bienvenue et le passage à une autre étape du script
draw_header_line()
{
	cols=$(tput cols)
	char=$1
	color=$2
	if test "$color" != ""; then
		echo -ne $color
	fi
	for i in $(eval echo "{1..$cols}"); do
		echo -n $char
	done
	if test "$color" != ""; then
		echo -ne $C_RESET
	fi
}

# Affichage du texte des headers
script_header()
{
    color=$2
	if test "$color" = ""; then
        # Définition de la couleur des lignes
		color=$C_HEADER_LINE
	fi

	echo ""
	# Décommenter la ligne ci dessous pour activer le chronomètre avant l'affichage du header
#   $SLEEP
	echo -ne $color    # Afficher la ligne du haut selon la couleur de la variable $color
	draw_header_line $LINE_CHAR
    # Commenter la ligne du dessous pour que le prompt "##>" soit de la même couleur que la ligne du dessus
#    echo -ne $C_RESET
	echo "##> "$1 $color
	draw_header_line $LINE_CHAR
	echo -ne $C_RESET
	$SLEEP_TAB
}

## DÉFINITION DES FONCTIONS D'INSTALLATION


# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager()
{
	echo "$J_TAB Détection de votre gestionnaire de paquet :$C_RESET"

    which zypper &> /dev/null && OS_FAMILY="opensuse"
    which pacman &> /dev/null && OS_FAMILY="archlinux"
    which dnf &> /dev/null && OS_FAMILY="fedora"
    which apt &> /dev/null && OS_FAMILY="debian"
    which emerge &> /dev/null && OS_FAMILY="gentoo"

	# Si, après l'appel de la fonction, la string contenue dans la variable $OS_FAMILY est toujours nulle
	if [ "$OS_FAMILY" = "void" ]; then
		echo "$ERROR_OUTPUT_1 ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ !!!$ERROR_OUTPUT_2"
		exit 1
	else
		echo "$V_TAB Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY) $C_RESET"; echo ""
	fi
}

# Détection du mode super-administrateur (root)
detect_root()
{
    # Si le script n'est pas exécuté en root
    if [ "$EUID" -ne 0 ]; then
    	echo "$R_TAB Ce script doit être exécuté en tant qu'administrateur (root)."
    	echo "$R_TAB Placez sudo devant votre commande :"
    	echo "$R_TAB sudo $0"  # $0 est le nom du fichier shell en question avec le "./" placé devant (argument 0)
    	echo "$ERROR_OUTPUT_1 ERREUR : SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL !$ERROR_OUTPUT_2"
    	echo "$C_RESET"
    	exit 1          # Quitter le programme en cas d'erreur
    fi

    # Sinon, si le script est exécuté en root
    echo "$J_TAB Assurez-vous d'avoir lu le script et sa documentation avant de l'exécuter."
    echo -n "$J_TAB Êtes-vous sûr de savoir ce que vous faites ? (oui/non) $C_RESET"; echo ""
	rep_launch_script()
	{
		read rep
		case ${rep,,} in
	        "oui")
	            echo "$V_TAB Vous avez confirmé vouloir exécuter ce script. C'est parti !!! $C_RESET";
				return
	            ;;
	        "non")
				echo ""
	            echo "$R_TAB Le script ne sera pas exécuté"
	            echo "$R_TAB Abandon $C_RESET"
	            exit 1
	            ;;
			*)
				echo ""
				echo "$R_TAB Veuillez rentrer une valeur valide (oui/non) $C_RESET"
				rep_launch_script
				;;
	    esac
	}
	rep_root
}

check_internet_connection()
{
	if ping -q -c 1 -W 1 google.com >/dev/null; then
		echo "$V_TAB Votre ordinateur est connecté à internet $C_RESET"
	else
	echo "$ERROR_OUTPUT_1 ERREUR : AUCUNE CONNEXION À INTERNET !!$ERROR_OUTPUT_2"
		exit 1
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté (ÉTAPE IMPORTANTE, NE PAS MODIFIER, SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
dist_upgrade()
{
	echo ""
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
	echo "$V_TAB Mise à jour du système effectuée avec succès $C_RESET"; echo ""
}

# Installation des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets
pack_install()
{
    package_name=$@
	case $OS_FAMILY in
		opensuse)
			echo "$V_TAB Installation de $package_name$C_RESET"
			$SLEEP_INST
			zypper -y install $package_name
			;;
		archlinux)
            echo "$V_TAB Installation de $package_name$C_RESET"
			$SLEEP_INST
			pacman --noconfirm -S $package_name
			;;
		fedora)
            echo "$V_TAB Installation de $package_name$C_RESET"
			$SLEEP_INST
			dnf -y install $package_name
			;;
		debian)
			echo "$V_TAB Installation de $package_name$C_RESET"
			$SLEEP_INST
			apt -y install $package_name
			;;
		gentoo)
			echo "$V_TAB Installation de $package_name$C_RESET"
			$SLEEP_INST
			emerge $package_name
			;;
	esac
    echo ""
}

# Pour installer
snap_install()
{
    snap_name=$@
    snap install $snap_name
}

# Installer un paquet (.deb)
software_install()
{
	ops_soft_links=""
	arc_soft_links=""
	fed_soft_links=""
	deb_soft_links=""
	gen_soft_links=""

	case $OS_FAMILY in
		opensuse)
			;;
		archlinux)
			;;
		fedora)
			;;
		debian)
			wget $deb_soft_links
			dpkg -i $deb_soft_links
			;;
		gentoo)
			;;
	esac
}

# Installer sudo sur Debian et ajouter l'utilisateur actuel à la liste des sudoers
set_sudo()
{
    script_header "DÉTECTION DE SUDO";
    echo "$J_TAB Détection de sudo $C_RESET"
    if ! which sudo > /dev/null ; then
        pack_install sudo
    else
        echo "$V_TAB \"sudo\" est déjà installé sur votre système d'exploitation $C_RESET"; echo ""
    fi
    if [  ]; then
		echo "$J_TAB AJOUT DE L'UTILISATEUR ACTUEL À LA LISTE DES SUDOERS $C_RESET"
		echo "$J_TAB LISEZ ATTENTIVEMENT CE QUI SUIT !!!!!!!! $C_RESET"
		echo "L'éditeur de texte Visudo (éditeur basé sur Vi spécialement créé pour modifier le fichier protégé /etc/sudoers)"
		echo "va s'ouvrir pour que vous puissiez ajouter votre compte utilisateur à la liste des sudoers afin de bénéficier"
		echo "des privilèges d'administrateur avec la commande sudo sans avoir à vous connecter en mode super-utilisateur."; echo ""
		echo "$J_TAB La ligne à ajouter se trouve dans la section \"#User privilege specification\". Sous la ligne $C_RESET"
		echo "root    ALL=(ALL) ALL"; echo ""
		echo "$J_TAB Tapez : $C_RESET"
		echo "$USER	ALL=(ALL) NOPASSWD:ALL"; echo ""
		echo "$J_TAB Si vous avez bien compris la procédure à suivre, tapez EXACTEMENT \"compris\" pour ouvrir Visudo"
		echo "$J_TAB ou \"quitter\" si vous souhaitez configurer le fichier \"/etc/visudo\" plus tard $C_RESET"
		read_rep_f()
		{
			read visudo_rep
			case ${visudo_rep,,} in
				"compris")
					visudo
					usermod -aG sudo $USER
					;;
				"quitter")
					return
					;;
				*)
					echo ""
					echo "$R_TAB Veuillez taper EXACTEMENT \"compris\" pour ouvrir Visudo,"
					echo "$R_TAB ou \"quitter\" pour configurer le fichier \"/etc/sudoers\" plus tard $C_RESET"
					read_rep_f
					;;
			esac
		}
		read_rep_f
    else
        echo "$V_TAB Vous avez déjà les permissions du mode sudo $C_RESET"
    fi
	# Récupérer le 'NAME' dans une string, puis vérifier que l'affectation soit bien à Debian
}

## Suppression des paquets obsolètes
autoremove()
{
	echo "$J_TAB Souhaitez vous supprimer les paquets obsolètes ? (oui/non) $C_RESET"
	read_autoremove()
	{
		read autoremove_rep
		case ${autoremove_rep,,} in
			"oui")
				echo "$V_TAB Suppression des paquets $C_RESET"; echo ""
	    		case "$OS_FAMILY" in
	        		opensuse)
	            		echo "$J_TAB Le gestionnaire de paquets Zypper n'a pas de commande de suppression automatiques de tous les paquets obsolètes$C_RESET"
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
				echo "$V_TAB Auto-suppression des paquets obsolètes effectuée avec succès $C_RESET"; echo ""
				;;
			"non")
				echo "$R_TAB Les paquets obsolètes ne seront pas supprimés $C_RESET";
				echo "$J_TAB Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets $C_RESET"
				echo ""
				;;
			*)
				echo $READ_VAL
				read_autoremove
				;;
		esac
	}
}

# Fin de l'installation
is_installation_done()
{
	script_header "FIN DE L'INSTALLATION"
    echo "$V_TAB Installation terminée. Votre distribution est prête à l'emploi $C_RESET"
    rm -rf $install_dir
}


################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################
## APPEL DES FONCTIONS DE CONSTRUCTION
# Affichage du header de bienvenue
script_header "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX !!!!!"
echo "$J_TAB Début de l'installation"
# Détection du gestionnaire de paquets de la distribution utilisée
script_header "DÉTECTION DE VOTRE GESTIONNAIRE DE PAQUETS"
get_dist_package_manager
# Détection du mode super-administrateur (root)
detect_root
# Détection de la connexion à Internet
script_header "VÉRIFICATION DE LA CONNEXION À INTERNET"
check_internet_connection
# Mise à jour des paquets actuels
script_header "MISE À JOUR DU SYSTÈME"
dist_upgrade


## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION
script_header "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION";

# Installations prioritaires
echo "$J_TAB INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS $C_RESET"; $SLEEP_INST_CAT
pack_install curl
pack_install snapd
pack_install wget
set_sudo

# Commandes
echo "$J_TAB INSTALLATION DES COMMANDES $C_RESET"; $SLEEP_INST_CAT
pack_install neofetch
pack_install tree

# Internet
echo "$J_TAB INSTALLATION DES CLIENTS INTERNET $C_RESET"; $SLEEP_INST_CAT
snap_install discord
pack_install thunderbird

# Librairies
echo "$J_TAB INSTALLATION DES LIBRAIRIES $C_RESET"; $SLEEP_INST_CAT
pack_install python3.7
pack_install python-pip

# Logiciels
echo "$J_TAB INSTALLATION DES LOGICIELS $C_RESET"; $SLEEP_INST_CAT
pack_install k4dirstat

# Machines virtuelles
echo "$J_TAB INSTALLATION DE VMWARE $C_RESET"; $SLEEP_INST_CAT
echo "Feature en attente"; echo ""
# wget

# Programmation
echo "$J_TAB INSTALLATION DES OUTILS DE DÉVELOPPEMENT $C_RESET"; $SLEEP_INST_CAT
snap_install atom --classic		# Atom IDE
snap_install code --classic		# Visual Studio Code
pack_install valgrind

# Vidéo
echo "$J_TAB INSTALLATION DE VLC $C_RESET"; $SLEEP_INST_CAT
pack_install vlc

# LAMP
echo "$J_TAB INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP $C_RESET"; $SLEEP_INST_CAT
lamp="apache2 php libapache2-mod-php mariadb-server php-mysql php-curl php-gd php-intl php-json php-mbstring php-xml php-zip"
pack_install $lamp


# Suppression des paquets obsolètes
script_header "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"
autoremove
# Fin de l'installation
is_installation_done
