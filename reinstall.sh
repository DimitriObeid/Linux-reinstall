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
LINE_CHAR="-"		# Si vous souhaitez mettre d'autres caractères à la place d'une ligne

## CHRONOMÈTRE
# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape. Pour changer le timer, changer la valeur de "sleep". Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
SLEEP=sleep\ 1.5 # NE PAS SUPPRIMER L'ANTISLASH, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE

# File buffer
INSTALL_VAL=0

## COULEURS
# Couleurs pour mieux lire les étapes de l'exécution du script
C_ROUGE=$(tput setaf 196)   # Rouge clair
C_VERT=$(tput setaf 82)     # Vert clair
C_JAUNE=$(tput setaf 226)   # Jaune clair
C_RESET=$(tput sgr0)        # Restaurer la couleur originale du texte affiché selon la configuration du profil du terminal
C_HEADER_LINE=$(tput setaf 6)      # Bleu cyan. Définition de l'encodage de la couleur du texte du header. /!\ Ne modifier l'encodage de couleurs du header qu'ici ET SEULEMENT ici /!\

# Nombre de chevrons avant les chaînes de caractères vertes et rouges
TAB=">>>>"
J_TAB="$C_JAUNE$TAB"
$R_TAB="$ROUGE$TAB>>>>"
$V_TAB="$VERT$TAB>>>>"

## GESTION D'ERREURS
# Codes de sortie d'erreur
EXIT_ERR_NON_ROOT=67
# Cas d'erreurs possibles
ERROR_OUTPUT_1="$R_TAB>>> Une erreur s'est produite lors de l'installation :"
ERROR_OUTPUT_2="$C_ROUGE Arrêt de l'installation$C_RESET"

## DÉBUT DE L'INSTALLATION
# Afficher les lignes des headers pour la bienvenue et le passage à une autre étape du script
draw_line()
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
	draw_line $LINE_CHAR
    # Commenter la ligne du dessous pour que le prompt "##>" soit de la même couleur que la ligne du dessus
#    echo -ne $C_RESET
	echo "##> "$1
	draw_line $LINE_CHAR
	echo -ne $color
	$SLEEP
}

# Gestion de cas d'erreur lors de l'installation du script
#handle_error()
#{
#    result=$1
#    error_output="$J_TAB$ERR_OR."
#    if test $result -eq 0; then
#        return
#    if ! test $result -eq 0; then
#        trap "echo $error_output"
#        read stop_script
#        case ${stop_script,,} in
#            "n" | "non" | "no")
#				return
#                ;;
#            *)
#                echo "$R_TAB>>> Vous avez arrêté l'exécution du script"
#                echo "$TAB>>> Abandon $C_RESET"
#				exit 1
#                ;;
#        esac
#    fi
#}

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
    	echo "$R_TAB Ce script doit être exécuté en tant qu'administrateur (root)."
    	echo "$R_TAB Placez sudo devant votre commande :"
    	echo "$R_TAB sudo $0"  # $0 est le nom du fichier shell en question avec le "./" placé devant (argument 0)
    	echo "$R_TAB Abandon"
    	echo "$C_RESET"
    	exit 1          # Quitter le programme en cas d'erreur
    fi

    # Sinon, si le script est exécuté en root
    script_header "$C_HEADER_LINE BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES LINUX !!!!! $C_HEADER_LINE"
    echo "$J_TAB Détection de votre gestionnaire de paquet :$C_RESET"
    get_dist_package_manager
    if [ "$OS_FAMILY" = "void" ]; then  # Si, après l'appel de la fonction, la string contenue dans la variable $OS_FAMILY est toujours à "void"
        echo "$R_TAB ERREUR FATALE : LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ !!!"
        echo "$R_TAB Abandon"
        echo "$C_RESET"
        exit 1
    else
        echo "$V_TAB Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY) $C_RESET"; echo ""
    fi
    echo "$J_TAB Assurez-vous d'avoir lu la documentation du script avant de l'exécuter."
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
        *)
            echo "$R_TAB Pour lire le script, entrez la commande suivante :"
            echo "$R_TAB cat reinstall.sh"
            echo "$R_TAB Abandon"
            echo "$C_RESET"
            exit 1
            ;;
    esac
}

check_internet_connection()
{
	script_header "$C_HEADER_LINE VÉRIFICATION DE LA CONNEXION À INTERNET $C_HEADER_LINE"; echo "$C_RESET";
	if ping -q -c 1 -W 1 google.com >/dev/null; then
		echo "$V_TAB Votre ordinateur est connecté à internet $C_RESET"
		echo ""
	else
		echo "$ERROR_OUTPUT_1 ERREUR DE CONNEXION À INTERNET !!.$ERROR_OUTPUT_2"
		echo "$R_TAB Abandon $C_RESET"
		exit 1
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
	echo "$V_TAB Mise à jour du système effectuée avec succès $C_RESET"; echo ""
}

# Pour installer des paquets directement depuis les dépôts officiels de la distribution utilisée
install_for_dist_cmd()
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

#    # Si la longueur de la chaîne de caractères est égale à 0
#    if test -z "$cmd_install"; then
#		cmd_install="$(get_cmd_install)"
#	fi
#    if test $INSTALL_VAL -eq 1; then
#        echo "$J_TAB>>> Installation de : " $package_name "(commande :" $cmd_install $package_name ") $C_RESET"
#        return
#    fi
#    $cmd_install $package_name
#	handle_error $?
}

script_install_cmd()
{
	$handle_error $cmd_install
    $cmd_install
	if test $INSTALL_VAL -eq 1; then
		echo "$J_TAB Installation de" $1 "($script_install_cmd)"
		return
	fi
}

# Pour installer des paquets directement depuis un site web (DE PRÉFÉRENCE UN SITE OFFICIEL, CONNU ET SÉCURISÉ (exemple : Source Forge, etc...))
wget_install()
{
    echo ""; script_header "$C_HEADER_LINE INSTALLATION DE WGET $C_HEADER_LINE"; echo ""

    # Installation de wget si le binaire n'est pas installé
    if [ ! /usr/bin/wget ]; then
        echo "$J_TAB La commande \"wget\" manque à l'appel, souhaitez vous l'installer ? $C_RESET"
        read wget_rep
        case $wget_rep in
            "o" | "oui" | "y" | "yes")
                echo "$V_TAB Installation de wget $C_RESET"
                $pack_inst wget
                echo "$V_TAB wget a été installé avec succès $C_RESET"
				echo ""
                ;;
            *)
                echo "$R_TAB wget ne sera pas installé $C_RESET"
				echo ""
                ;;
        esac
    else
        echo "$V_TAB Le paquet \"wget\" est déjà installé sur votre ordinateur $C_RESET"
		echo ""
    fi
}

# Pour installer des logiciels disponibles dans la logithèque de la distribution (Steam), indisponibles dans les gestionnaires de paquets et la logithèque (VMware) ou mis à jour plus rapidement ou uniquement sur le site officiel du paquet (youtube-dl).
software_install_cmd()
{
    # Installation de Steam
    steam_exe=/usr/games/steam
    if [ ! -f $steam_exe ]; then
        echo "$V_TAB Téléchargement de Steam $C_RESET"
        wget media.steampowered.com/client/installer/steam.deb
        echo "$V_TAB Décompression de Steam $C_RESET"
        # dpkg -i
    else
        echo "$V_TAB Steam est déjà installé sur votre ordinateur $C_RESET"
    fi

    # Installation de youtube-dl (pour télécharger des vidéos YouTube plus facilement)
    youtube_dl_exe="/usr/local/bin/youtube-dl"
    if [ ! -f $youtube_dl_exe ]; then
        wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin
        chmod a+rx $youtube_dl_exe
        # youtube-dl -U # Pour mettre à jour youtube-dl
    else
        echo "$V_TAB Le paquet \"youtube-dl\" est déjà installé sur votre ordinateur $C_RESET"
    fi
}

main_install()
{
	script_header "$C_HEADER_LINE INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION $C_HEADER_LINE"; echo "$C_RESET"; echo""

	####################################################
	# ICI COMMENCE LA LISTE DES PROGRAMMES À INSTALLER #
	####################################################
	## PAQUETS À INSTALLER DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION SELON LEUR CATÉGORIE

	# Des commandes pratiques... ou bien juste pour le fun
	commandes="neofetch tree sl "

	# Manipulation d'images
	images="gimp "

	# Messageries, clients internet, ect...
	internet="thunderbird "

	# Des logiciels pratiques pour votre ordinateur... ou pour en installer d'autres
	logiciels="snapd k4dirstat "

	# Pour faire de la modélisation 3D
	modelisation="blender "

	# Pour bien programmer. Après tout, chaque distribution Linux est le meilleur système d'exploitation pour programmer
	programmation="atom codeblocks emacs gcc g++ libsfml-dev libcsfml-dev python-pip valgrind "

	# Visionneuse ou éditeur de vidéos
	video="vlc "

	# Pour utiliser des logiciels conçus uniquement pour Windaube en convertissant leurs appels systèmes en appels systèmes POSIX
	windows="wine mono-complete "

	# Pour travailler avec LAMP (Linux Apache, MySQL, PHP)
	lamp="apache2 php libapache2-mod-php mariadb-server php-mysql php-curl php-gd php-intl php-json php-mbstring php-xml php-zip "

	# Ainsi, si vous voulez ajouter ou supprimer un paquet, vous n'avez qu'à l'ajouter ou le supprimer à un seul endroit dans la liste ci-dessus
	paquets_a_installer="$commandes $images $internet $logiciels $modelisation $programmation $video $windows $lamp"

	script_install_cmd "$paquets_a_installer"

	####################################################
	#    FIN DE LA LISTE DES PROGRAMMES À INSTALLER    #
	####################################################
}

## Suppression des paquets obsolètes avec "deborphan"
autoremove()
{
    script_header "$C_HEADER_LINE AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES $C_HEADER_LINE"; echo ""
    echo "$C_RESET"
	echo "$J_TAB Souhaitez vous supprimer les paquets obsolètes ? (oui/non) $C_RESET"
	read $autoremove_rep
	case {$autoremove_rep,,} in
		"o" | "oui" | "y" | "yes")
			echo "$V_TAB>>> Suppresiion des paquets $C_RESET"; echo ""
    		case "$OS_FAMILY" in
        		opensuse)
            		echo "zypper"
            		;;
        		archlinux)
            		echo "pacman -Qdt"
            		;;
        		fedora)
            		echo "dnf autoremove"
            		;;
        		debian)
            		echo "apt-get autoremove"
            		;;
        		gentoo)
            		echo "emerge -uDN @world"      # D'abord, vérifier qu'aucune tâche d'installation est active
            		echo "emerge --depclean -a"    # Suppression des paquets obsolètes. Demande à l'utilisateur s'il souhaite supprimer ces paquets
            		echo "eix-test-obsolete"       # Tester s'il reste des paquets obsolètes
            		;;
			esac
			echo "$V_TAB Auto-suppression des paquets obsolètes effectuée avec succès $C_RESET"; echo ""
			;;
		*)
			echo "$V_TAB Les paquets obsolètes ne seront pas supprimés $C_RESET"; echo ""
			return
			;;
	esac
}

is_installation_done()
{
	script_header "$C_HEADER_LINE FIN DE L'INSTALLATION $C_HEADER_LINE"; echo ""
    echo "$V_TAB Installation terminée. Suppression du dossier d'installation temporaire dans \"/tmp\" $C_RESET"
    rm -rf $install_dir
}

get_dist_package_manager
# handle_error # Supprimer cette ligne quand j'aurai une fonction fonctionnelle à utiliser dans une condition
detect_root
check_internet_connection
dist_upgrade
install_for_dist_cmd
script_install_cmd
wget_install
main_install
autoremove
is_installation_done
