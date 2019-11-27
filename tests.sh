#!/bin/bash

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
# En cas de mauvaise valeur rentrée avec un "read"
READ_VAL="$R_TAB Veuillez rentrer une valeur valide [oui, non] $C_RESET"

get_dist_package_manager()
{
	echo "$J_TAB Détection de votre gestionnaire de paquet :$C_RESET"

    which zypper &> /dev/null && OS_FAMILY="opensuse"
    which pacman &> /dev/null && OS_FAMILY="archlinux"
    which dnf &> /dev/null && OS_FAMILY="fedora"
    which apt-get &> /dev/null && OS_FAMILY="debian"
    which emerge &> /dev/null && OS_FAMILY="gentoo"

	# Si, après l'appel de la fonction, la string contenue dans la variable $OS_FAMILY est toujours nulle
	if [ "$OS_FAMILY" = "void" ]; then
		echo "$ERROR_OUTPUT_1 ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ !!!$ERROR_OUTPUT_2"
		exit 1
	else
		echo "$V_TAB Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY) $C_RESET"; echo ""
	fi
}

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
			apt-get -y install $package_name
			echo "$J_TAB Détection de la réussite de l'installation $C_RESET"
			if ! which $pack_name > /dev/null; then
				echo "$R_TAB Échec de l'installation de $pack_name $C_RESET"
			else
				echo "$V_TAB Succès de l'installation de $pack_name  $C_RESET"
			fi
			;;
		gentoo)
			echo "$V_TAB Installation de $package_name$C_RESET"
			$SLEEP_INST
			emerge $package_name
			;;
	esac
    echo ""
}


snap_install()
{
    snap_name=$@
    which $snap_name > /dev/null
	if 
    snap install $snap_name
}


pack_install tree
snap_install discord



