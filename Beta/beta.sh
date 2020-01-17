#!/bin/bash

# Script de réinstallation minimal pour les cours de BTS SIO en version Bêta
# Version Bêta 2.0

# Pour débugguer ce script en cas de besoin, tapez la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

# Ou débugguez le en utilisant Shell Check : https://www.shellcheck.net/


################### DÉCLARATION DES VARIABLES ET AFFECTATION DE LEURS VALEURS ###################

## CHRONOMÈTRE

# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer le timer, changer la valeur de "sleep".
# Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
# NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SCRIPT_SLEEP_HEADER=sleep\ 1.5 	# Temps d'affichage d'un header uniquement, avant d'afficher le reste de l'étape, lors d'un changement d'étape
SCRIPT_SLEEP_INST=sleep\ .5    	# Temps d'affichage du nom du paquet, avant d'afficher le reste de l'étape, lors de l'installation d'un nouveau paquet
SCRIPT_SLEEP_INST_CAT=sleep\ 1 	# Temps d'affichage d'un changement de catégories de paquets lors de l'étape d'installation


## COULEURS

# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
SCRIPT_C_HEADER=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers.
SCRIPT_C_JAUNE=$(tput setaf 226) 		# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes.
SCRIPT_C_PACK_CATS=$(tput setaf 6)		# Bleu cyan		--> Couleur d'affichage des messages de passage à la prochaine catégorie de paquets.
SCRIPT_C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal.
SCRIPT_C_ROUGE=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape.
SCRIPT_C_VERT=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape.

# DOSSIERS ET FICHIERS
SCRIPT_TMPDIR="Linux-reinstall.tmp.d"
SCRIPT_TMPPATH="$HOME/$SCRIPT_TMPDIR"


# RESSOURCES
SCRIPT_REPO="https://github.com/DimitriObeid/Linux-reinstall"

## TEXTE

# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret,
# changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes
# (une ligne de chaque caractère).
SCRIPT_HEADER_LINE_CHAR="-"
# Affichage de colonnes sur le terminal
SCRIPT_COLS=$(tput cols)
# Nombre de dièses (hash) précédant et suivant une chaîne de caractères
SCRIPT_HASH="#####"
# Nombre de chevrons avant les chaînes de caractères jaunes, vertes et rouges
SCRIPT_TAB=">>>>"
# Affichage de chevrons précédant l'encodage de la couleur d'une chaîne de caractères
SCRIPT_J_TAB="$SCRIPT_C_JAUNE$SCRIPT_TAB"
SCRIPT_R_TAB="$SCRIPT_C_ROUGE$SCRIPT_TAB$SCRIPT_TAB"
SCRIPT_V_TAB="$SCRIPT_C_VERT$SCRIPT_TAB$SCRIPT_TAB"
# Saut de ligne
SCRIPT_VOID=""


## VERSION

# Version actuelle du script
SCRIPT_VERSION="2.0"


################### DÉFINITION DES FONCTIONS ###################

## DÉFINITION DES FONCTIONS DE DÉCORATION DU SCRIPT
# Affichage d'un message de changement de catégories de paquets propre à la partie d'installation des paquets (encodé en bleu cyan,
# entouré de dièses et appelant la variable de chronomètre pour chaque passage à une autre catégorie de paquets)
cats_echo() { cats_string=$1; echo "$SCRIPT_C_PACK_CATS$SCRIPT_HASH $cats_string $SCRIPT_HASH $SCRIPT_C_RESET"; $SCRIPT_SLEEP_INST_CAT;}
# Affichage d'un message en jaune avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
j_echo() { j_string=$1; echo "$SCRIPT_J_TAB $j_string $SCRIPT_C_RESET";}
# Affichage d'un message en rouge avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
r_echo() { r_string=$1; echo "$SCRIPT_R_TAB $r_string $SCRIPT_C_RESET";}
# Affichage d'un message en vert avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
v_echo() { v_string=$1; echo "$SCRIPT_V_TAB $v_string $SCRIPT_C_RESET";}

## CRÉATION DES HEADERS
# Afficher les lignes des headers pour la bienvenue et le passage à une autre étape du script
draw_header_line()
{
	line_char=$1	# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction
	line_color=$2	# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction

	# Pour définir la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	if test "$line_color" != ""; then
		echo -n -e "$line_color"
	fi

	# Pour afficher le caractère souhaité sur toute la ligne
	for i in $(eval echo "{1..$SCRIPT_COLS}"); do
		echo -n "$line_char"
	done

	# Pour définir (ici, réintialiser) la couleur des caractères suivant le dernier caractère de la ligne du header.
	# En pratique, La couleur des caractères suivants est déjà encodée quand ils sont appelés. Cette réinitialisation
	# de la couleur du texte n'est qu'une mini sécurité permettant d'éviter d'avoir la couleur du prompt encodée avec
	# la couleur des headers si l'exécution du script est interrompue de force avec un "CTRL + C" ou un "CTRL + Z", par
	# exemple.
	if test "$line_color" != ""; then
        echo -n -e "$SCRIPT_C_RESET"
	fi
}

# Affichage du texte des headers
script_header()
{
	header_string=$1

	# Pour définir la couleur de la ligne du caractère souhaité
	if test "$header_color" = ""; then
        # Définition de la couleur de la ligne.
        # Ne pas ajouter de '$' avant le nom de la variable "header_color", sinon la couleur souhaitée ne s'affiche pas
		header_color=$SCRIPT_C_HEADER
	fi

	echo "$SCRIPT_VOID"

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SCRIPT_SLEEP_HEADER
	draw_header_line "$SCRIPT_HEADER_LINE_CHAR" "$header_color"
	# Pour afficher une autre couleur pour le texte, remplacez l'appel de variable "$header_color" ci-dessous par la couleur que vous souhaitez
	echo "$header_color" "##>" "$header_string"
	draw_header_line "$SCRIPT_HEADER_LINE_CHAR" "$header_color"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	echo "$SCRIPT_VOID"

	echo "$SCRIPT_VOID"

	$SCRIPT_SLEEP_HEADER
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger)
handle_errors()
{
	error_result=$1

	if test "$error_color" = ""; then
		error_color=$SCRIPT_C_ROUGE
	fi

	echo "$SCRIPT_VOID" "$SCRIPT_VOID"

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SCRIPT_SLEEP_HEADER
	draw_header_line "$SCRIPT_HEADER_LINE_CHAR" "$error_color"
	# Pour afficher une autre couleur pour le texte, remplacez l'appel de variable "$error_color" ci-dessous par la couleur que vous souhaitez
	echo "$error_color" "##> ERREUR FATALE : $error_result"
	draw_header_line "$SCRIPT_HEADER_LINE_CHAR" "$error_color"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	echo "$SCRIPT_VOID"

	echo "$SCRIPT_VOID"

	$SCRIPT_SLEEP_HEADER
	r_echo "Une erreur fatale s'est produite : $error_result"
	r_echo "Arrêt de l'installation"
	echo "$SCRIPT_VOID"

	exit 1
}


## DÉFINITION DES FONCTIONS D'EXÉCUTION
# Détection de l'exécution du script en mode super-administrateur (root)
detect_root()
{
	if test "$EUID" -ne 0; then
    	r_echo "Ce script doit être exécuté en tant que super-administrateur (root)."
    	r_echo "Exécutez ce script en plaçant$C_RESET sudo$C_ROUGE devant votre commande :"
    	# Le paramètre "$0" ci-dessous est le nom du fichier shell en question avec le "./" placé devant (argument 0).
    	# Si ce fichier est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
    	r_echo "$C_RESET	sudo $0"
		r_echo "Ou connectez vous directement en tant que super-administrateur"
		r_echo "Et tapez cette commande :"
		r_echo "$C_RESET	$0"
		handle_errors "ERREUR : SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"
    fi
}

# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager()
{
	script_header "DÉTECTION DE VOTRE GESTIONNAIRE DE PAQUETS"

	# On cherche la commande du gestionnaire de paquets de la distribution de l'utilisateur dans les chemins de la variable d'environnement "$PATH" en l'exécutant.
	# On redirige chaque sortie ("stdout (sortie standard) si la commande est trouvée" et "stderr(sortie d'erreurs) si la commande n'est pas trouvée")
	# de la commande vers /dev/null (vers rien) pour ne pas exécuter la commande.

	# Pour en savoir plus sur les redirections en Shell UNIX, consultez ce lien -> https://www.tldp.org/LDP/abs/html/io-redirection.html
    command -v zypper &> /dev/null && OS_FAMILY="opensuse"
    command -v pacman &> /dev/null && OS_FAMILY="archlinux"
    command -v dnf &> /dev/null && OS_FAMILY="fedora"
    command -v apt &> /dev/null && OS_FAMILY="debian"
    command -v emerge &> /dev/null && OS_FAMILY="gentoo"

	# Si, après la recherche de la commande, la chaîne de caractères contenue dans la variable $OS_FAMILY est toujours nulle (aucune commande trouvée)
	if test "$OS_FAMILY" = ""; then
		handle_errors "LE GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION N'EST PAS SUPPORTÉ"
	else
		v_echo "Le gestionnaire de paquets de votre distribution est supporté ($OS_FAMILY)"
	fi
}

# Demande à l'utilisateur s'il souhaite vraiment lancer le script, puis connecte l'utilisateur en mode super-utilisateur
launch_script()
{
	script_header "LANCEMENT DU SCRIPT"

	j_echo "Assurez-vous d'avoir lu au moins le mode d'emploi (Mode d'emploi.odt) avant de lancer l'installation."
    j_echo "Êtes-vous sûr de savoir ce que vous faites ? (oui/non)"
	echo "$SCRIPT_VOID"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	read_launch_script()
	{
        # Demande à l'utilisateur d'entrer une réponse
		read -r -p "Entrez votre réponse : " rep_launch

		# Les deux virgules suivant directement le "launch" signifient que les mêmes réponses avec des majuscules sont permises
		case ${rep_launch,,} in
	        "oui")
				echo "$SCRIPT_VOID"

				v_echo "Vous avez confirmé vouloir exécuter ce script."
				v_echo "C'est parti !!!"
	            ;;
	        "non")
				echo "$SCRIPT_VOID"

				r_echo "Le script ne sera pas exécuté"
	            r_echo "Abandon"
				echo "$SCRIPT_VOID"

				exit 1
	            ;;
            # Si une réponse différente de "oui" ou de "non" est rentrée
			*)
				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
				# On rappelle la fonction "read_launch_script" en boucle tant qu"une réponse différente de "oui" ou de "non" est entrée
				read_launch_script
				;;
	    esac
	}
	# Appel de la fonction "read_launch_script", car même si la fonction est définie dans la fonction "launch_script", elle n'est pas lue automatiquement
	read_launch_script
}

# Création d'un dossier temporaire pour y stocker des fichiers temporaires
mktmpdir()
{
	script_header "CRÉATION DU DOSSIER TEMPORAIRE $SCRIPT_TMPDIR DANS $SCRIPT_TMPPATH"

	# Si le dossier "Linux-reinstall.tmp.d" n'existe pas dans le dossier personnel de l'utilisateur
	if test ! -d "$SCRIPT_TMPPATH"; then
		j_echo "Création du dossier temporaire"

		# Création du dossier
		mkdir "$SCRIPT_TMPPATH"
		echo "$SCRIPT_VOID"
		
		v_echo "Le dossier $SCRIPT_TMPDIR a été créé avec succès"
	# Sinon, si le dossier "Linux-reinstall.tmp.d" existe déjà dans le dossier personnel de l'utilisateur
	else
		j_echo "Un dossier portant exactement le même nom se trouve déjà dans votre dossier temporaire."
		j_echo "Souhaitez vous écraser son contenu ? (oui/non)"
		echo "$SCRIPT_VOID"

		# Lectre de la réponse de l'utilisateur
		read_mktmpdir()
		{
			read -r -p "Entrez votre réponse : " rep_tmpdir

			# Dans le cas où l'utilisateur répond par ...
			case ${rep_tmpdir,,} in
				"oui")
					j_echo "Déplacement vers le dossier $SCRIPT_TMPPATH et "
					cd "$SCRIPT_TMPPATH" || handle_errors "LE DOSSIER $SCRIPT_TMPDIR N'EXISTE PAS"

					# MESURE DE SÉCURITÉ !!! NE PAS ENLEVER LA CONDITION SUIVANTE !!!
					# On vérifie que l'on se trouve bien dans le dossier "Linux-reinstall.tmp.d"
					# AVANT de supprimer tout le contenu récursivement 
					if test "$(pwd)" == "$SCRIPT_TMPPATH"; then
						j_echo "Suppression du contenu du dossier $SCRIPT_TMPDIR"
						rm -rf --*

						# On vérifie que le contenu du dossier a bien été intégralement supprimé
						if test ! "$(ls -A $SCRIPT_TMPDIR)"; then
							v_echo "Le contenu du dosssier $SCRIPT_TMPDIR a été effacé avec succès"
						fi
					fi
					echo "$SCRIPT_VOID"

					return
					;;
				"non")
					echo "$SCRIPT_VOID"

					j_echo "Le contenu du dossier $SCRIPT_TMPDIR ne sera pas supprimé."
					j_echo "En revanche, les fichiers temporaires créés écraseront les fichiers homonymes"
					echo "$SCRIPT_VOID"

					v_echo "Changement de dossier : Déplacement vers le dossier $SCRIPT_TMPPATH"
					# On se déplace vers le dossier temporaire fraîchement créé
					cd "$SCRIPT_TMPPATH" || handle_errors "LE DOSSIER $SCRIPT_TMPPATH N'EXISTE PAS"
					v_echo "Déplacement vers le dossier $SCRIPT_TMPPATH effectué avec succès"
					
					return
					;;
				*)
					j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
					read_mktmpdir
					;;
			esac  
		}
		read_mktmpdir
	fi

	echo "$SCRIPT_VOID"
}

## CONNEXION À INTERNET ET MISES À JOUR
# Vérification de la connexion à Internet
check_internet_connection()
{
	script_header "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à internet
	if ping -q -c 1 -W 1 google.com > /dev/null; then
		v_echo "Votre ordinateur est connecté à Internet"
	else
		handle_errors "AUCUNE CONNEXION À INTERNET"
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets supporté
# (ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE PAS MODIFIER CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS !!!)
dist_upgrade()
{
	script_header "MISE À JOUR DU SYSTÈME"

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

	echo "$SCRIPT_VOID"

	v_echo "Mise à jour du système effectuée avec succès"
}

## DÉFINITION DES FONCTIONS D'INSTALLATION
# Téléchargement des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets, puis installation des paquets
pack_install()
{
	# Si vous souhaitez mettre tous les paquets en tant que multiples arguments (tableau d'arguments), remplacez le "$1"
	# ci-dessous par "$@" et enlevez les doubles guillemets "" entourant chaque variable "$package_name" suivant la commande
	# d'installation de votre distribution.
	package_name=$1

	# Pour éviter de retaper ce qui ne fait pas partie de la commande d'installation pour chaque gestionnaire de paquets
	pack_manager_install()
	{
		$SCRIPT_SLEEP_INST

		# $@ --> Tableau dynamique d'arguments permettant d'appeller la commande d'installation complète du gestionnaire de paquets et ses options
		# ATTENTION
		"$@" "$package_name"
		v_echo "Le paquet \"$package_name\" a été correctement installé"
		echo "$SCRIPT_VOID"

		$SCRIPT_SLEEP_INST
	}

	# On cherche à savoir si le paquet souhaité est déjà installé sur le disque en utilisant des redirections.
	# Si c'est le cas, le script affiche que le paquet est déjà installé et ne perd pas de temps à le réinstaller.
	# Sinon, le script installe le paquet manquant.

	j_echo "Installation de $package_name"

	# Installation du paquet souhaité selon la commande d'installation du gestionnaire de paquets de la distribution de l'utilisateur
	case $OS_FAMILY in
		opensuse)
			pack_manager_install zypper -y install
			;;
		archlinux)
			pack_manager_install pacman --noconfirm -S
			;;
		fedora)
			pack_manager_install dnf -y install
			;;
		debian)
			pack_manager_install apt -y install
			;;
		gentoo)
			pack_manager_install emerge
			;;
	esac
}

# Pour installer des paquets via le gestionnaire de paquets Snap
snap_install()
{
    snap install "$@"    # Utilisation d'un tableau dynamique d'arguments pour ajouter des options
	echo "$SCRIPT_VOID"
}

## DÉFINITION DES FONCTIONS DE PARAMÉTRAGE
# Détection et installation de Sudo
set_sudo()
{
	script_header "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"

    j_echo "$SCRIPT_J_TAB Détection de sudo $SCRIPT_C_RESET"

	if test ! type "sudo" > /dev/null; then
		j_echo "Sudo n'est pas installé sur votre système."
		pack_install sudo
	fi

	j_echo "Le script va tenter de télécharger un fichier \"sudoers\" déjà configuré depuis mon dépôt Git : "
	j_echo "$SCRIPT_REPO (dans le dossier \"Ressources\")"
	echo "$SCRIPT_VOID"

	j_echo "Souhaitez vous le télécharger PUIS l'installer maintenant dans le dossier \"/etc/\" ? (oui/non)"
	echo "REMARQUE : Si vous disposez déjà des droits de super-utilisateur, ce n'est pas la peine de le faire !"
	echo "$SCRIPT_VOID"

	read_sudo()
	{
		read -r -p "Entrez votre réponse : " rep_sudo

		case ${rep_sudo,,} in
			"oui")
				echo "$SCRIPT_VOID"

				j_echo "Entrez votre nom d'utilisateur, le script s'en servira pour vous garantir les droits de super-utilisateur"
				echo "$SCRIPT_VOID"

				read -r -p "Votre nom ? : " rep_sudo_name

				j_echo "Téléchargement du fichier sudoers depuis le dépôt Git $SCRIPT_REPO"
				wget https://raw.githubusercontent.com/DimitriObeid/Linux-reinstall/master/Ressources/sudoers

				if ! test -f "sudoers"; then
					handle_errors "FICHIER SUDOERS MANQUANT"
				else
					j_echo "Fichier \"sudoers\"téléchargé avec succès"
					j_echo "Déplacement du fichier \"sudoers\" vers \"/etc/\""
					mv "sudoers" /etc/
					echo "$SCRIPT_VOID"

					j_echo "Ajout de l'utilisateur $rep_sudo_name au groupe sudo"
					usermod -aG root "$rep_sudo_name"
					echo "$SCRIPT_VOID"

					v_echo "L'utilisateur $rep_sudo_name a été ajouté au groupe sudo avec succès"
				fi

				return
				;;
			"non")
				j_echo "Le fichier \"/etc/sudoers\" ne sera pas modifié"
				j_echo "Vous pourrez toujours le configurer plus tard"

				return
				;;
			*)
				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
				read_sudo
				;;
		esac
	}
	read_sudo
}

# Suppression des paquets obsolètes
autoremove()
{
	script_header "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"

	j_echo "Souhaitez vous supprimer les paquets obsolètes ? (oui/non)"

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il souhaite supprimer les paquets obsolètes
	read_autoremove()
	{
		read -r rep_autoremove

		case ${rep_autoremove,,} in
			"oui")
				echo "$SCRIPT_VOID"

				j_echo "Suppression des paquets"
				echo "$SCRIPT_VOID"

	    		case "$OS_FAMILY" in
	        		opensuse)
	            		j_echo "Le gestionnaire de paquets Zypper n'a pas de commande de suppression automatique de tous les paquets obsolètes"
						j_echo "Référez vous à la documentation du script ou à celle de Zypper pour supprimer les paquets obsolètes"
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

				echo "$SCRIPT_VOID"

				v_echo "Auto-suppression des paquets obsolètes effectuée avec succès"
				return
				;;
			"non")
				echo "$SCRIPT_VOID"

				v_echo "Les paquets obsolètes ne seront pas supprimés"
				v_echo "Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets"
				return
				;;
			*)
				j_echo "Veuillez répondre EXACTEMENT par \"oui\" ou par \"non\""
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

	v_echo "Retour vers le dossier $OLDPWD et suppression du dossier temporaire $SCRIPT_TMPDIR"
	cd - > /dev/null && rm -rf "$TMPDIR"
	echo "$SCRIPT_VOID"

    v_echo "Installation terminée. Votre distribution Linux est prête à l'emploi"
	sudo -k

	echo "$SCRIPT_VOID"
}

################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################

## APPEL DES FONCTIONS DE CONSTRUCTION
# Détection du mode super-administrateur (root)
detect_root
# Affichage du header de bienvenue
script_header "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX VERSION $SCRIPT_VERSION !!!!!"
v_echo "Début de l'installation"
# Détection du gestionnaire de paquets de la distribution utilisée
get_dist_package_manager
# Assurance que l'utilisateur soit sûr de lancer le script
launch_script
# Création du dossier temporaire où sont stockés les fichiers temporaires
mktmpdir
# Détection de la connexion à Internet
check_internet_connection
# Mise à jour des paquets actuels
dist_upgrade

## INSTALLATIONS PRIORITAIRES
script_header "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
pack_install curl
pack_install python-pip
pack_install snapd
pack_install wget

# Installation de sudo et configuration
set_sudo

## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION
script_header "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION"

v_echo "Vous pouvez désormais quitter votre ordinateur pour chercher un café"
v_echo "La partie d'installation de vos programmes commence véritablement"
echo "$SCRIPT_VOID"

sleep 3


# Commandes
cats_echo "INSTALLATION DES COMMANDES PRATIQUES"
pack_install neofetch
pack_install tree
echo "$SCRIPT_VOID"

# Logiciels de cryptage et de sécurité
#cats_echo "INSTALLATION DES LOGICIELS DE CRYPTAGE ET DE SÉCURITÉ"
#pack_install veracrypt

# Développement
cats_echo "INSTALLATION DES OUTILS DE DÉVELOPPEMENT"
snap_install atom --classic		# Éditeur de code Atom
snap_install code --classic		# Éditeur de code Visual Studio Code
pack_install emacs
pack_install g++
pack_install gcc
pack_install git
pack_install make
pack_install umlet
pack_install valgrind
echo "$SCRIPT_VOID"

# Logiciels de nettoyage de disque
cats_echo "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"
pack_install k4dirstat
echo "$SCRIPT_VOID"

# Internet
cats_echo "INSTALLATION DES CLIENTS INTERNET"
snap_install discord --stable
pack_install thunderbird
echo "$SCRIPT_VOID"

# LAMP
cats_echo "INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP"
pack_install apache2			# Apache
pack_install php				# PHP
pack_install libapache2-mod-php
pack_install mariadb-server		# Pour installer un serveur MariaDB (Si vous souhaitez un seveur MySQL, remplacez "mariadb-server" par "mysql-server"
pack_install php-mysql
pack_install php-curl
pack_install php-gd
pack_install php-intl
pack_install php-json
pack_install php-mbstring
pack_install php-xml
pack_install php-zip
echo "$SCRIPT_VOID"

# Librairies
cats_echo "INSTALLATION DES LIBRAIRIES"
pack_install python3.7
echo "$SCRIPT_VOID"

# Réseau
cats_echo "INSTALLATION DES LOGICIELS RÉSEAU"
pack_install wireshark
echo "$SCRIPT_VOID"

# Vidéo
cats_echo "INSTALLATION DES LOGICIELS VIDÉO"
pack_install vlc
echo "$SCRIPT_VOID"

cats_echo "INSTALLATION DE WINE"
pack_install wine-stable
echo "$SCRIPT_VOID"

v_echo "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS ! FIN DE L'INSTALLATION"


# Suppression des paquets obsolètes
autoremove
# Fin de l'installation
is_installation_done