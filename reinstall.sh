#!/bin/bash

# Pour débugguer ce script, si besoin, taper la commande :
# <shell utilisé> -x <nom du fichier>
# Exemple :
# /bin/bash -x reinstall.sh
# Ou encore
# bash -x reinstall.sh

## Ce script sert à réinstaller tous les programmes Linux tout en l'exécutant.

### DÉFINITION DES VARIABLES GLOBALES ###

## HEADER
# Si vous souhaitez mettre d'autres caractères à la place d'une ligne, changez le caractère entre les double guillemets
LINE_CHAR="-"

## CHRONOMÈTRE
# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer le timer, changer la valeur de "sleep".
# Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
SLEEP=sleep\ 1.5 # NE PAS SUPPRIMER L'ANTISLASH, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE

INSTALL_VAL=0

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
R_TAB="$C_ROUGE$TAB>>>>"
V_TAB="$C_VERT$TAB>>>>"
# En cas de mauvaise valeur rentrée avec un "read"
READ_VAL="$R_TAB Veuillez rentrer une valeur valide [o, oui, y, yes, n, no, non] $C_RESET"

## GESTION D'ERREURS
# Codes de sortie d'erreur
EXIT_ERR_NON_ROOT=67
# Pour les cas d'erreurs possibles (la raison est mise entre les deux chaînes de caractères au moment où l'erreur se produit)
ERROR_OUTPUT_1="$R_TAB>>> Une erreur s'est produite lors de l'installation :"
ERROR_OUTPUT_2="$C_ROUGE Arrêt de l'installation$C_RESET"

# Argument 1 d'installation de paquets
PACK_NAME=$1

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

	# Décommenter la ligne ci dessous pour activer le chronomètre avant l'affichage du header
#    $SLEEP
	echo -ne $color    # Afficher la ligne du haut selon la couleur de la variable $color
	draw_header_line $LINE_CHAR
    # Commenter la ligne du dessous pour que le prompt "##>" soit de la même couleur que la ligne du dessus
#    echo -ne $C_RESET
	echo "##> "$1
	draw_header_line $LINE_CHAR
	echo -ne $color
	$SLEEP
}

## DÉFINITION DES FONCTIONS D'INSTALLATION


# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager()
{
	echo "$J_TAB Détection de votre gestionnaire de paquet :$C_RESET"

    which zypper &> /dev/null && OS_FAMILY="opensuse"
    which pacman &> /dev/null && OS_FAMILY="archlinux"
    which dnf &> /dev/null && OS_FAMILY="fedora"
    which apt-get &> /dev/null && OS_FAMILY="debian"
    which emerge &> /dev/null && OS_FAMILY="gentoo"

	# Si, après l'appel de la fonction, la string contenue dans la variable $OS_FAMILY est toujours à "void"
	if [ "$OS_FAMILY" = "void" ]; then
		echo "$R_TAB ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ !!!"
		echo "$R_TAB Abandon"
		echo "$C_RESET"
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
    	echo "$R_TAB Abandon"
    	echo "$C_RESET"
    	exit 1          # Quitter le programme en cas d'erreur
    fi

    # Sinon, si le script est exécuté en root
    echo "$J_TAB Assurez-vous d'avoir lu le script et sa documentation avant de l'exécuter."
    echo -n "$J_TAB Êtes-vous sûr de savoir ce que vous faites ? (oui/non) $C_RESET"; echo ""
    read rep
    case ${rep,,} in
        "o" | "oui" | "y" | "yes")
            echo "$V_TAB Vous avez confirmé vouloir exécuter ce script. C'est parti !!! $C_RESET"; echo ""
            install_dir=/tmp/reinstall_tmp.d
            if [ -d "$install_dir" ]; then
                rm -rf $install_dir
            fi
            echo "$J_TAB Création du dossier d'installation temporaire dans \"/tmp\" $C_RESET"
            mkdir $install_dir && cd $install_dir
            echo "$V_TAB Le dossier d'installation temporaire a été créé avec succès dans \"/tmp\" $C_RESET"; echo ""
            ;;
        "n" | "non" | "no")
            echo "$R_TAB Le script ne sera pas exécuté"
            echo "$R_TAB Abandon $C_RESET"
            exit 1
            ;;
		*)
			echo $READ_VAL
			detect_root
    esac
}

check_internet_connection()
{
	script_header "$C_HEADER_LINE VÉRIFICATION DE LA CONNEXION À INTERNET $C_HEADER_LINE"; echo "$C_RESET";
	if ping -q -c 1 -W 1 google.com >/dev/null; then
		echo "$V_TAB Votre ordinateur est connecté à internet $C_RESET"
		echo ""
	else
	echo "$ERROR_OUTPUT_1 ERREUR::AUCUNE CONNEXION À INTERNET !!$ERROR_OUTPUT_2"
		exit 1
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté (ÉTAPE IMPORTANTE, NE PAS MODIFIER, SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
dist_upgrade()
{
    ## MISE À JOUR DES PAQUETS
    script_header "$C_HEADER_LINE MISE À JOUR DU SYSTÈME $C_HEADER_LINE";
    echo "$C_RESET"
    case "$OS_FAMILY" in
		opensuse)
			sudo zypper -y update
			;;
		archlinux)
			sudo pacman --noconfirm -Syu
			;;
		fedora)
			sudo dnf -y update
			;;
		debian)
			sudo apt-get -y update; sudo apt-get -y upgrade
			;;
		gentoo)
			sudo emerge -u world
			;;
	esac
	echo "$V_TAB Mise à jour du système effectuée avec succès $C_RESET"; echo ""
}

# Obtention de la commande d'installation selon le gestionnaire de paquets supporté
get_dist_cmd_install()
{
	case $OS_FAMILY in
		opensuse)
			echo "zypper -y install"
			;;
		archlinux)
			echo "pacman --noconfirm -S"
			;;
		fedora)
			echo "dnf -y install"
			;;
		debian)
			echo "apt-get -y install"
			;;
		gentoo)
			echo "emerge"
			;;
	esac
}

# Pour installer des paquets directement depuis les dépôts officiels de la distribution utilisée
dist_package_install()
{
	if test -z "$cmd_install"; then
		cmd_install=$(get_dist_cmd_install)
	fi

	if test $INSTALL_VAL; then
		echo "Installation de " $PACK_NAME "(commande : " $get_cmd_install $package_name ")"
		return
	fi
}

## Suppression des paquets obsolètes
autoremove()
{
    script_header "$C_HEADER_LINE AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES $C_HEADER_LINE"; echo ""
    echo "$C_RESET"
	echo "$J_TAB Souhaitez vous supprimer les paquets obsolètes ? (oui/non) $C_RESET"
	read autoremove_rep
	case ${autoremove_rep,,} in
		"o" | "oui" | "y" | "yes")
			echo "$V_TAB Suppression des paquets $C_RESET"; echo ""
    		case "$OS_FAMILY" in
        		opensuse)
            		zypper
            		;;
        		archlinux)
            		pacman -Qdt
            		;;
        		fedora)
            		dnf autoremove
            		;;
        		debian)
            		apt-get autoremove
            		;;
        		gentoo)
            		emerge -uDN @world      # D'abord, vérifier qu'aucune tâche d'installation est active
            		emerge --depclean -a    # Suppression des paquets obsolètes. Demande à l'utilisateur s'il souhaite supprimer ces paquets
            		eix-test-obsolete       # Tester s'il reste des paquets obsolètes
            		;;
			esac
			echo "$V_TAB Auto-suppression des paquets obsolètes effectuée avec succès $C_RESET"; echo ""
			;;
		"n" | "non" | "no")
			echo "$V_TAB Les paquets obsolètes ne seront pas supprimés $C_RESET"; echo ""
			;;
		*)
			echo $READ_VAL
	esac
}

# Fin de l'installation
is_installation_done()
{
	script_header "$C_HEADER_LINE FIN DE L'INSTALLATION $C_HEADER_LINE"; echo ""
    echo "$V_TAB Installation terminée. Suppression du dossier d'installation temporaire dans \"/tmp\" $C_RESET"
    rm -rf $install_dir
}


################### DÉBUT DU SCRIPT ###################
## Affichage du header de bienvenue
script_header "$C_HEADER_LINE BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES LINUX !!!!! $C_HEADER_LINE"
# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager
# Détection du mode super-administrateur (root)
detect_root
# Détection de la connexion à Internet
check_internet_connection
# Mise à jour des paquets actuels
dist_upgrade



# Suppression des paquets obsolètes
autoremove
# Fin de l'installation
is_installation_done
