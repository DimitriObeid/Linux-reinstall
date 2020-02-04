#!/bin/sh

################### DÉCLARATION DES VARIABLES ET AFFECTATION DE LEURS VALEURS ###################

## COULEURS

# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
SH_C_STEP=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers.
SH_C_JAUNE=$(tput setaf 226) 	# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes.
SH_C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal.
SH_C_ROUGE=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape.
SH_C_VERT=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape.


## TEXTE

# Affichage de texte
SH_HASH="#####"


################### DÉFINITION DES FONCTIONS ###################

# Affichage du message de changement d'étapes du script
step_echo() { cats_string=$1; echo "$SH_C_STEP$SH_HASH $cats_string $SH_HASH $SH_C_RESET"; }

# Affichage d'un message en jaune avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
j_echo() { j_string=$1; echo "$SH_C_JAUNE $j_string $SH_C_RESET"; }

# Affichage d'un message en rouge avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
r_echo() { r_string=$1; echo "$SH_C_ROUGE $r_string $SH_C_RESET"; }

# Affichage d'un message en vert avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
v_echo() { v_string=$1; echo "$SH_C_VERT $v_string $SH_C_RESET"; }

handle_errors()
{
    r_echo "##### UNE ERREUR FATALE S'EST PRODUITE #####"

    error_string="$1"

    r_echo "Une erreur fatale s'est produite"
    r_echo "$error_string"
    r_echo "Abandon"
    
    exit 1
}

get_package_manager()
{
    step_echo "DÉTECTION DE VOTRE GESTIONNAIRE DE PAQUETS"

    which zypper > /dev/null && SH_OS_FAMILY="opensuse"
    which pacman > /dev/null && SH_OS_FAMILY="archlinux"
    which dnf > /dev/null && SH_OS_FAMILY="fedora"
    which apt > /dev/null && SH_OS_FAMILY="debian"
    which emerge > /dev/null && SH_OS_FAMILY="gentoo"

    if [ "$SH_OS_FAMILY" = "" ]; then
        handle_errors "VOTRE GESTIONNAIRE DE PAQUETS N'EST PAS SUPPORTÉ"
    else
        v_echo "Votre gestionnaire de paquets est supporté ($SH_OS_FAMILY)"
    fi
    
    return
}

sys_update()
{
    step_echo "MISE À JOUR DU SYSTÈME"

	case "$SH_OS_FAMILY" in
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

    return
}

install_essential()
{
    cmd_name="$1"

    j_echo "Installation du paquet $cmd_name"

    case $SH_OS_FAMILY in
        opensuse)
            sudo zypper -y install "$cmd_name"
            ;;
        archlinux)
            sudo pacman --noconfirm -S "$cmd_name"
            ;;
        fedora)
            sudo dnf -y install "$cmd_name"
            ;;
        debian)
            sudo apt -y install "$cmd_name"
            ;;
        gentoo)
            sudo emerge "$cmd_name"
            ;;
    esac

    v_echo "Le paquet $cmd_name a été installé avec succès"
    echo ""

    return
}

check_packs()
{
    pack=$1

    j_echo "Vérification de la présence du paquet $pack"

    which "$pack" > /dev/null \
        || echo "Le paquet $pack n'est pas installé sur votre système"; install_essential "$pack" \
        && echo "Le paquet $pack est déjà installé sur votre système"
}

# Détection du gestionnaire de paquets
get_package_manager

# Mise à jour du système
sys_update

# Installation des paquets essentiels
step_echo "INSTALLATION DES PAQUETS ESSENTIELS"
install_essential wget
install_essential bash