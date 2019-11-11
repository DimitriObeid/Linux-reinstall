#!/bin/bash

# Pour débugguer ce script, si jamais, taper la commande :
# <shell utilisé> -x <nom du fichier>
# Exemple : 
# /bin/bash -x reinstall.sh
# Ou encore
# bash -x reinstall.sh

## Ce script sert à réinstaller tous les programmes Linux en l'exécutant.

# Couleurs pour mieux lire les étapes de l'exécution du script
vert='\33[1;32m'
jaune='\33[1;33m'
rouge='\33[0;91m'
defaut_cou="\33[39m"

# Mises à jour selon le gestionnaire de paquets
apt_upd="apt update && apt upgrade"     # Pour les distributions basées sur Debian (Ubuntu, Mint, Kali, ...)
dnf_upd="dnf update && dnf upgrade"     # Pour les distributions basées sur Red Hat (Fedora, ...)
pac_upd="pacman -Syu"                   # Pour les distributions basées sur Arch Linux (Manjaro, ...)

pack_upg=$apt_upd || $dnf_upd || $pac_upd

# Installation selon le gestionnaire de paquets
apt_inst="apt install"
dnf_inst="dnf install"
pac_inst="pacman -S"

pack_inst=$apt_inst || $dnf_inst || $pac_inst

# Pour installer des paquets directement depuis un site web (DE PRÉFÉRENCE UN SITE OFFICIEL ET SÉCURISÉ (exemple : Github, Source Forge, etc...))
wget_install()
{
    # Installation de wget si le binaire n'est pas installé
    if [ ! /usr/bin/wget ]; then
        echo "$jaune>>> La commande \"wget\" manque à l'appel, souhaitez vous l'installer ? $defaut_cou"
        read wget_rep
        case $wget_rep in
            "o" | "oui" | "y" | "yes")
                echo "$vert>>> Installation de wget $defaut_cou"
                $pack_inst wget
                echo "$vert>>> wget a été installé avec succès $defaut_cou"
                ;;
            *)
                echo "$rouge>>> wget ne sera pas installé $defaut_cou"
                ;;
        esac
    fi
    
    # Installation de youtube-dl (pour télécharger des vidéos YouTube plus facilement)
    youtube_dl_dir="/usr/local/bin/youtube-dl"
    if [ ! -f $youtube_dl_dir ]; then
        wget https://yt-dl.org/downloads/latest/youtube-dl -O $youtube_dl_dir
        chmod a+rx $youtube_dl_dir
        # youtube-dl -U # Pour mettre à jour youtube-dl
    else
        echo "$vert>>> Le paquet \"youtube-dl\" est déjà installé sur votre ordinateur"
    fi
}

# Pour installer des paquets directement depuis les dépôts officiels de la distribution utilisée
packages_to_install()
{
    commandes="neofetch tree sl"
    jeux="bsdgames pacman "
    images="gimp inkscape"
    internet="thunderbird"
    logiciels="snapd k4dirstat"
    modelisation="blender"
    programmation="atom codeblocks emacs libsfml-dev libcsfml-dev python-pip valgrind"
    video="vlc"
    lamp="apache2 php libapache2-mod-php mariadb-server php-mysql php-curl php-gd php-intl php-json php-mbstring php-xml php-zip"
    
    paquets=$commandes $jeux $images $internet $logiciels $modelisation $programmation $video $lamp
    $pack_inst $paquets # Mettre dans une boucle for pour écrire en temps réel les étapes d'installation des paquets
   
    # Installation de Git si Git n'est pas installé
    if [ ! /usr/git* ]; then
        echo "$jaune>>> La commande \"git\" manque à l'appel, souhaitez vous l'installer ? $defaut_cou"
        read git_rep
        case $git_rep in
            "o" | "oui" | "y" | "yes")
                echo "$vert>>> Installation de git $defaut_cou"
                $pack_inst git
                echo "$vert>>> git a été installé avec succès $defaut_cou"
                ;;
            *)
                echo "$rouge>>> git ne sera pas installé $defaut_cou"
                ;;
        esac
    fi
    
    return
}

update_packages()
{
    echo "$jaune>>> Mise à jour des paquets $defaut_cou"
    $pack_upg
    echo "$jaune>>> Mise à jour des paquet terminée $defaut_cou"
}

detect_linux_distro()
{
    version=`lsb_release -ds`
    echo "Ajout des dépôts pour $version"
}

detect_root()
{
    # Si le script n'est pas exécuté en root
    if [ "$EUID" -ne 0 ]; then
    	echo "$rouge>>> Ce script doit être exécuté en tant qu'administrateur (root)."
    	echo "$rouge>>> Placez sudo devant votre commande :"
    	echo "$rouge>>> sudo $0"  # $0 est le nom du fichier shell en question avec le "./" placé devant (argument 0)
    	echo "$rouge>>> Ou bien connectez vous directement en tant qu'administrateur en tapant :"
    	echo "$rouge>>> su"
    	echo "$rouge>>> Puis exécutez de nouveau le script"
    	echo "$rouge>>> Abandon"
    	exit 1          # Quitter le programme en cas d'erreur
    fi

    # Sinon, si le script est exécuté en root
    echo "$jaune>>> Assurez-vous d'avoir lu et compris le script avant de l'exécuter."
    echo -n "$jaune>>> Êtes-vous sûr de savoir ce que vous faites ? (o/n) $defaut_cou"
    read rep
    case $rep in
        "o" | "oui" | "y" | "yes")
            echo "$vert>>> Vous avez confirmé vouloir exécuter ce script. C'est parti !!! $defaut_cou"
            ;;
        *)
            echo "$rouge>>> Pour lire le script, entrez la commande suivante :"
            echo "$rouge>>> cat reinstall.sh"
            echo "$rouge>>> Abandon"
            exit 1
            ;;
    esac
}

detect_root
detect_linux_distro
packages_to_install
wget_install
