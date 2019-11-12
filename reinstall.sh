#!/bin/bash

# Pour débugguer ce script, si jamais, taper la commande :
# <shell utilisé> -x <nom du fichier>
# Exemple :
# /bin/bash -x reinstall.sh
# Ou encore
# bash -x reinstall.sh

## Ce script sert à réinstaller tous les programmes Linux tout en l'exécutant.

#
install_val=0

# Couleurs pour mieux lire les étapes de l'exécution du script
C_ROUGE=$(tput setaf 1)
C_VERT=$(tput setaf 2)
C_JAUNE=$(tput setaf 3)
C_RESET=$(tput sgr0)

# On détecte le gestionnaire de paquets de la distribution utilisée
get_dist_package_manager()
{
    which zypper &> /dev/null && OS_FAMILY="opensuse"
    which pacman &> /dev/null && OS_FAMILY="archlinux"
    which dnf &> /dev/null && OS_FAMILY="fedora"
    which apt-get &> /dev/null && OS_FAMILY="debian"
    which emerge &> /dev/null && OS_FAMILY="gentoo"
}

# Gestion d'erreurs
handle_error()
{
    result=$1
    if test $result -eq 0; then
        return
    else
        echo "$C_ROUGE>>> Erreur lors de l'installation, souhaitez vous arrêter l'installation ? (o/n)"
        read stop_script
        case $stop_script in
            "n" | "non")
                echo "$DEFAULT"
                return
                ;;
            *)
                echo "$C_ROUGE>>> Abandon $C_RESET"
                exit 1
                ;;
        esac
    fi
}

# Détection du mode super-administrateur (root)
detect_root()
{
    # Si le script n'est pas exécuté en root
    if [ "$EUID" -ne 0 ]; then
    	echo "$C_ROUGE>>> Ce script doit être exécuté en tant qu'administrateur (root)."
    	echo ">>> Placez sudo devant votre commande :"
    	echo ">>> sudo $0"  # $0 est le nom du fichier shell en question avec le "./" placé devant (argument 0)
    	echo ">>> Abandon"
    	echo "$C_RESET"
    	exit 1          # Quitter le programme en cas d'erreur
    fi

    # Sinon, si le script est exécuté en root
    echo "$C_JAUNE>>> Détection de votre gestionnaire de paquet $C_RESET"
    $OS_FAMILY = "void"
    get_dist_package_manager
    if [ "$OS_FAMILY" = "void" ]; then  # Si, après l'appel de la fonction, la string contenue dans la variable $OS_FAMILY est toujours à "void"
        echo "$C_ROUGE>>> ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ !!!"
        echo ">>> Abandon"
        echo "$C_RESET"
        exit 1
    else
        echo "$C_VERT>>> Le gestionnaire de paquets de votre distribution est supporté $C_RESET"
    fi
    echo "$C_JAUNE>>> Assurez-vous d'avoir lu la documentation du script avant de l'exécuter."
    echo -n "$C_JAUNE>>> Êtes-vous sûr de savoir ce que vous faites ? (o/n) $C_RESET"
    read rep
    case $rep in
        "o" | "oui" | "y" | "yes")
            echo "$C_VERT>>> Vous avez confirmé vouloir exécuter ce script. C'est parti !!! $C_RESET"
            install_dir=/tmp/reinstall_tmp.d
            if [ -d "$install_dir" ]; then
                rm -rf $install_dir
            fi
            echo "$C_JAUNE>>> Création du dossier d'installation temporaire dans \"/tmp\" $C_RESET"
            mkdir $install_dir && cd $install_dir
            ;;
        *)
            echo "$C_ROUGE>>> Pour lire le script, entrez la commande suivante :"
            echo ">>> cat reinstall.sh"
            echo ">>> Abandon"
            echo "$C_RESET"
            exit 1
            ;;
    esac
}

# Mise à jour des paquets actuels
dist_upgrade()
{
    echo "$C_VERT>>> Mise à jour du système $C_RESET"
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
	echo "$C_VERT>>> Mise à jour du système effectuée avec succès $C_RESET"
}

# Pour installer des paquets directement depuis les dépôts officiels de la distribution utilisée
packages_to_install()
{
    package_name=$1

    get_cmd_install()
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

    # Si la longueur de la chaîne de caractères est égale à 0
    if test -z "$cmd_install"; then
		cmd_install=$(get_cmd_install) dépôts
	fi
    if test install_val -eq 1; then
        echo "Installation de : " $package_name "(commande :" $cmd_install $package_name ")"
        return
    fi
    $cmd_install $package_name
}


# Pour installer des paquets directement depuis un site web (DE PRÉFÉRENCE UN SITE OFFICIEL, CONNU ET SÉCURISÉ (exemple : Source Forge, etc...))
wget_install()
{
    # Installation de wget si le binaire n'est pas installé
    if [ ! /usr/bin/wget ]; then
        echo "$C_JAUNE>>> La commande \"wget\" manque à l'appel, souhaitez vous l'installer ? $C_RESET"
        read wget_rep
        case $wget_rep in
            "o" | "oui" | "y" | "yes")
                echo "$C_VERT>>> Installation de wget $C_RESET"
                $pack_inst wget
                echo "$C_VERT>>> wget a été installé avec succès $C_RESET"
                ;;
            *)
                echo "$C_ROUGE>>> wget ne sera pas installé $C_RESET"
                ;;
        esac
    else
        echo "$C_VERT>>> Le paquet \"wget\" est déjà installé sur votre ordinateur $C_RESET"
    fi
}

# Pour installer des logiciels disponibles dans la logithèque de la distribution (Steam), indisponibles dans les gestionnaires de paquets et la logithèque (VMware) ou mis à jour plus rapidement ou uniquement sur le site officiel du paquet (youtube-dl).
software_install()
{
    # Installation de Steam
    steam_exe=/usr/games/steam
    if [ ! -f $steam_exe ]; then
        echo "$C_VERT>>> Téléchargement de Steam $C_RESET"
        wget media.steampowered.com/client/installer/steam.deb
        echo "$C_VERT>>> Décompression de Steam $C_RESET"
        # dpkg -i
    else
        echo "$C_VERT>>> Steam est déjà installé sur votre ordinateur $C_RESET"
    fi

    # Installation de youtube-dl (pour télécharger des vidéos YouTube plus facilement)
    youtube_dl_exe="/usr/local/bin/youtube-dl"
    if [ ! -f $youtube_dl_exe ]; then
        wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin
        chmod a+rx $youtube_dl_exe
        # youtube-dl -U # Pour mettre à jour youtube-dl
    else
        echo "$C_VERT>>> Le paquet \"youtube-dl\" est déjà installé sur votre ordinateur $C_RESET"
    fi
}

is_installation_done()
{
    echo "$C_VERT>>> Installation terminée. Suppression du dossier d'installation temporaire dans \"/tmp\" $C_RESET"
    rm -rf $install_dir
}

get_dist_package_manager
# handle_error # Supprimer cette ligne quand j'aurai une fonction fonctionnelle à utiliser dans une condition
detect_root
dist_upgrade
is_installation_done
