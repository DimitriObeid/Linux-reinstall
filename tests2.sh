#!/bin/bash

# Script de réinstallation minimal en Bêta
# Version Bêta 1.3

# Pour débugguer ce script en cas de besoin, taper la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

# Ou débugguer sur Shell Check : https://www.shellcheck.net/


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
ECHO_OUTPUT="echo \"\""
VOID=""

## GESTION D'ERREURS
# Pour les cas d'erreurs possibles (la raison est mise entre les deux chaînes de caractères au moment où l'erreur se produit)
ERROR_OUTPUT_1="$R_TAB Une erreur s'est produite lors de l'installation -->"
ERROR_OUTPUT_2="$C_ROUGE Arrêt de l'installation $C_RESET"

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
	if [ "$OS_FAMILY" = "void" ]; then
		echo "$ERROR_OUTPUT_1 ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ !!!$ERROR_OUTPUT_2"
		exit 1
	else
		echo "$V_TAB Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY) $C_RESET"; echo $VOID
	fi
}

pack_install()
{
#	Exemples de command -v
#	$ command -v foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
#	$ type foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
#	$ hash foo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
    package_name=$@
	case $OS_FAMILY in
		opensuse)
			# 2>&1 : File descriptor. 1 est la sortie standard stdout, tandis que 2 est la sortie d'erreur : stderr
			command -v $package_name >/dev/null 2>&1 || (echo >&2 "$J_TAB $package_name n'est pas installé"; echo $VOID; echo "$V_TAB Installation de $package_name $C_RESET")
			$SLEEP_INST
			zypper -y install $package_name
			;;
		archlinux)
			command -v $package_name >/dev/null 2>&1 || (echo >&2 "$J_TAB $package_name n'est pas installé"; echo $VOID; echo "$V_TAB Installation de $package_name $C_RESET")
			$SLEEP_INST
			pacman --noconfirm -S $package_name
			;;
		fedora)
			command -v $package_name >/dev/null 2>&1 || (echo >&2 "$J_TAB $package_name n'est pas installé"; echo $VOID; echo "$V_TAB Installation de $package_name $C_RESET")
			$SLEEP_INST
			dnf -y install $package_name
			;;
		debian)
			command -v $package_name >/dev/null 2>&1 || (echo >&1 "$V_TAB $package_name est déjà installé $C_RESET"; return) || (echo >&2 "$J_TAB $package_name n'est pas installé"; echo $VOID; echo "$V_TAB Installation de $package_name $C_RESET"; apt -y install $package_name)
			$SLEEP_INST
			;;
		gentoo)
			command -v $package_name >/dev/null 2>&1 || (echo >&2 "$J_TAB $package_name n'est pas installé"; echo $VOID; echo "$V_TAB Installation de $package_name $C_RESET")
			$SLEEP_INST
			emerge $package_name
			;;
	esac
}

get_dist_package_manager
pack_install sl
pack_install tree
