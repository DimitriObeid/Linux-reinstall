#!/bin/bash

# Pour débugguer ce script, si jamais, taper la commande :
# <shell utilisé> -x <nom du fichier>
# Exemple :
# /bin/bash -x reinstall.sh
# Ou encore
# bash -x reinstall.sh

## Ce script sert à réinstaller tous les programmes Linux tout en l'exécutant.


### DÉFINITION DES VARIABLES GLOBALES ###

## HEADER
COLS=$(tput cols)   # Définition des colonnes des headers

## CHRONOMÈTRE
# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape. Pour changer le timer, changer la valeur de "sleep". Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
SLEEP=sleep\ 1.5 # NE PAS SUPPRIMER L'ANTISLASH, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE

# File buffer
INSTALL_VAL=0

# FILES="./.files"

TAB=">>>>>"

## COULEURS
# Couleurs pour mieux lire les étapes de l'exécution du script
C_ROUGE=$(tput setaf 196)   # Rouge clair
C_VERT=$(tput setaf 82)     # Vert clair
C_JAUNE=$(tput setaf 226)   # Jaune clair
C_RESET=$(tput sgr0)        # Restaurer la couleur originale du texte affiché selon la configuration du profil du terminal
C_HEADER_LINE=$(tput setaf 6)      # Bleu cyan. Définition de l'encodage de la couleur du texte du header. /!\ Ne modifier l'encodage de couleurs du header qu'ici ET SEULEMENT ici /!\

# Trouver l'origine d'une éventuelle erreur (les deux premières lignes ne varient pas lors de chaque cas d'erreur)
HEADER_ERR_1="$C_ROUGE>>> Une erreur s'est produite lors de l'installation :"
HEADER_ERR_2="$C_ROUGE Souhaitez vous arrêter l'installation ? (o/n)$C_RESET"
ERR_OR=

# Codes de sortie d'erreur
E_NON_ROOT=67


## DÉBUT DU SCRIPT

# Afficher les lignes des headers pour la bienvenue et le passage à une autre étape du script
line()
{
	cols=$COLS
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

#    $SLEEP
	echo -ne $color    # Afficher la ligne du haut selon la couleur de la variable $color
	line "-"
    # Commenter la ligne du dessous pour que le prompt "##>" soit de la même couleur que la ligne du dessus
#    echo -ne $C_RESET
	echo "##> "$1
	line "-"
	echo -ne $color
	$SLEEP
}

# Gestion de cas d'erreur lors de l'installation du script
handle_error()
{
    result=$1
    ERROR_OUTPUT="$TAB$HEADER_ERR_1$C_JAUNE$ERR_OR$HEADER_ERR_2"
    if test $result -eq 0; then
        return
    else
        echo "$ERROR_OUTPUT"
        read stop_script
        case ${stop_script,,} in
            "n" | "non" | "no")
                echo "$DEFAULT"
                return "$ERROR_OUTPUT"
                ;;
            *)
                echo "$C_ROUGE$TAB>>> Vous avez arrêté l'exécution du script"
                echo "$TAB>>> Abandon $C_RESET"
                script_header "$C_HEADER_LINE FIN DE L'EXÉCUTION DU SCRIPT $C_HEADER_LINE"
                exit $E_NON_ROOT
                ;;
        esac
    fi
}

# On détecte le gestionnaire de paquets de la distribution utilisée
get_dist_package_manager()
{
    which zypper &> /dev/null && OS_FAMILY="opensuse"
    which pacman &> /dev/null && OS_FAMILY="archlinux"
    which dnf &> /dev/null && OS_FAMILY="fedora"
    which apt-get &> /dev/null && OS_FAMILY="debian"
    which emerge &> /dev/null && OS_FAMILY="gentoo"
}

# Détection du mode super-administrateur (root)
detect_root()
{
    # Si le script n'est pas exécuté en root
    if [ "$EUID" -ne 0 ]; then
    	echo "$C_ROUGE$TAB>>> Ce script doit être exécuté en tant qu'administrateur (root)."
    	echo "$TAB>>> Placez sudo devant votre commande :"
    	echo "$TAB>>> sudo $0"  # $0 est le nom du fichier shell en question avec le "./" placé devant (argument 0)
    	echo "$TAB>>> Abandon"
    	echo "$C_RESET"
    	exit 1          # Quitter le programme en cas d'erreur
    fi

    # Sinon, si le script est exécuté en root
    script_header "$C_HEADER_LINE BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES LINUX !!!!! $C_HEADER_LINE"
    echo "$C_JAUNE>>> Détection de votre gestionnaire de paquet :$C_RESET"
    get_dist_package_manager
    if [ "$OS_FAMILY" = "void" ]; then  # Si, après l'appel de la fonction, la string contenue dans la variable $OS_FAMILY est toujours à "void"
        echo "$C_ROUGE$TAB>>> ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ !!!"
        echo "$TAB>>> Abandon"
        echo "$C_RESET"
        exit 1
    else
        echo "$C_VERT$TAB>>> Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY) $C_RESET"; echo ""
    fi
    echo "$C_JAUNE>>> Assurez-vous d'avoir lu la documentation du script avant de l'exécuter."
    echo -n "$C_JAUNE>>> Êtes-vous sûr de savoir ce que vous faites ? (o/n) $C_RESET"; echo ""
    read rep
    case ${rep,,} in
        "o" | "oui" | "y" | "yes")
            echo "$C_VERT$TAB>>> Vous avez confirmé vouloir exécuter ce script. C'est parti !!! $C_RESET"
            install_dir=/tmp/reinstall_tmp.d
            if [ -d "$install_dir" ]; then
                rm -rf $install_dir
            fi
            echo "$C_JAUNE>>> Création du dossier d'installation temporaire dans \"/tmp\" $C_RESET"
            mkdir $install_dir && cd $install_dir
            echo "$C_VERT$TAB>>> Le dossier d'installation temporaire a été créé avec succès dans \"/tmp\" $C_RESET"; echo ""
            ;;
        *)
            echo "$C_ROUGE$TAB>>> Pour lire le script, entrez la commande suivante :"
            echo "$TAB>>> cat reinstall.sh"
            echo "$TAB>>> Abandon"
            echo "$C_RESET"
            exit 1
            ;;
    esac
}

check_internet_connection()
{
    $ERR_OR="ERREUR : VOTRE ORDINATEUR N\'EST PAS CONNECTÉ À INTERNET"
	script_header "$C_HEADER_LINE VÉRIFICATION DE LA CONNEXION À INTERNET $C_HEADER_LINE"; echo ""
	if ping -q -c 1 -W 1 google.com >/dev/null; then
		echo "$C_VERT$TAB>>> Votre ordinateur est connecté à internet $C_RESET"
	else
		handle_error $ERR_OR
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté (ÉTAPE IMPORTANTE, NE PAS MODIFIER, SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
dist_upgrade()
{
    ## MISE À JOUR DES PAQUETS
    script_header "$C_HEADER_LINE MISE À JOUR DU SYSTÈME $C_HEADER_LINE"; echo ""
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
	echo "$C_VERT$TAB>>> Mise à jour du système effectuée avec succès $C_RESET"; echo ""
}

# Pour installer des paquets directement depuis les dépôts officiels de la distribution utilisée
install_for_dist()
{
	script_header "$C_HEADER_LINE INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION $C_HEADER_LINE"; echo "$C_RESET"; echo""
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
		cmd_install="$(get_cmd_install)"
	fi
    if test $INSTALL_VAL -eq 1; then
        echo "$C_JAUNE>>> Installation de : " $package_name "(commande :" $cmd_install $package_name ") $C_RESET"
        return
    fi
    $cmd_install $package_name
	handle_error $?
}

script_install()
{
    $cmd_install
	if test $INSTALL_VAL -eq 1; then
		echo "$C_JAUNE>>> Installation de" $1 "(script_install)"
		return
	fi
}

# Pour installer des paquets directement depuis un site web (DE PRÉFÉRENCE UN SITE OFFICIEL, CONNU ET SÉCURISÉ (exemple : Source Forge, etc...))
wget_install()
{
    script_header "$C_HEADER_LINE INSTALLATION DE WGET $C_HEADER_LINE"; echo ""

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
                echo "$C_ROUGE$TAB>>> wget ne sera pas installé $C_RESET"
                ;;
        esac
    else
        echo "$C_VERT>>> Le paquet \"wget\" est déjà installé sur votre ordinateur $C_RESET"
    fi
}

# La liste des paquets à télécharger
package_install()
{
	commandes="neofetch tree sl"
    images="gimp inkscape"
    internet="thunderbird"
    logiciels="snapd k4dirstat"
    modelisation="blender"
    programmation="atom codeblocks emacs libsfml-dev libcsfml-dev python-pip valgrind"
    video="vlc"
    windows="wine mono-complete"
    lamp="apache2 php libapache2-mod-php mariadb-server php-mysql php-curl php-gd php-intl php-json php-mbstring php-xml php-zip"

    paquets=$commandes $images $internet $logiciels $modelisation $programmation $video $windows $lamp
    script_install $paquets # Mettre dans une boucle pour écrire en temps réel les étapes d'installation des paquets

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
        echo "$C_VERT$TAB Le paquet \"youtube-dl\" est déjà installé sur votre ordinateur $C_RESET"
    fi
}

## Suppression des paquets obsolètes avec "deborphan"
autoremove()
{
    script_header "$C_HEADER_LINE AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES $C_HEADER_LINE"; echo ""
    echo "$C_RESET"
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
    echo "$C_VERT$TAB Auto-suppression des paquets obsolètes effectuée avec succès $C_RESET"; echo ""
}

is_installation_done()
{
    echo "$C_VERT>>> Installation terminée. Suppression du dossier d'installation temporaire dans \"/tmp\" $C_RESET"
    rm -rf $install_dir
}

get_dist_package_manager
# handle_error # Supprimer cette ligne quand j'aurai une fonction fonctionnelle à utiliser dans une condition
detect_root
check_internet_connection
dist_upgrade
install_for_dist
script_install
wget_install
autoremove
is_installation_done
