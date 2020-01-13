#!/bin/bash


## CHRONOMÈTRE

# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer le timer, changer la valeur de "sleep".
# Pour désactiver cette fonctionnalité, mettre la valeur de "sleep" à 0
# NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE "sleep" NE SERA PAS PRISE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SLEEP_HEADER=sleep\ 1.5   	# Temps d'affichage d'un header uniquement, avant d'afficher le reste de l'étape, lors d'un changement d'étape
SLEEP_INST_CAT=sleep\ 1 	# Temps d'affichage d'un changement de catégories de paquets lors de l'étape d'installation


## COULEURS

# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
C_HEADER=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers.
C_JAUNE=$(tput setaf 226) 		# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes.
C_PACK_CATS=$(tput setaf 6)		# Bleu cyan		--> Couleur d'affichage des messages de passage à la prochaine catégorie de paquets.
C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal.
C_ROUGE=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape.
C_VERT=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape.

## TEXTE

# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret,
# changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes
# (une ligne de chaque caractère).
HEADER_LINE_CHAR="-"
# Affichage de colonnes sur le terminal
COLS=$(tput cols)
# Nombre de dièses (hash) précédant et suivant une chaîne de caractères
HASH="#####"
# Nombre de chevrons avant les chaînes de caractères jaunes, vertes et rouges
TAB=">>>>"
# Affichage de chevrons précédant l'encodage de la couleur d'une chaîne de caractères
J_TAB="$C_JAUNE$TAB"
R_TAB="$C_ROUGE$TAB$TAB"
V_TAB="$C_VERT$TAB$TAB"
# Saut de ligne
VOID=""

################### DÉFINITION DES FONCTIONS ###################

## DÉFINITION DES FONCTIONS DE DÉCORATION DU SCRIPT
# Affichage d'un message de changement de catégories de paquets propre à la partie d'installation des paquets (encodé en bleu cyan,
# entouré de dièses et appelant la variable de chronomètre pour chaque passage à une autre catégorie de paquets)
cats_echo() { cats_string=$1; echo "$C_PACK_CATS$HASH $cats_string $HASH $C_RESET"; $SLEEP_INST_CAT;}
# Affichage d'un message en jaune avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
j_echo() { j_string=$1; echo "$J_TAB $j_string $C_RESET";}
# Affichage d'un message en rouge avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
r_echo() { r_string=$1; echo "$R_TAB $r_string $C_RESET";}
# Affichage d'un message en vert avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
v_echo() { v_string=$1; echo "$V_TAB $v_string $C_RESET";}

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
	for i in $(eval echo "{1..$COLS}"); do
		echo -n "$line_char"
	done

	# Pour définir (ici, réintialiser) la couleur des caractères suivant le dernier caractère de la ligne du header.
	# En pratique, La couleur des caractères suivants est déjà encodée quand ils sont appelés. Cette réinitialisation
	# de la couleur du texte n'est qu'une mini sécurité permettant d'éviter d'avoir la couleur du prompt encodée avec
	# la couleur des headers si l'exécution du script est interrompue de force avec un "CTRL + C" ou un "CTRL + Z", par
	# exemple.
	if test "$line_color" != ""; then
        echo -n -e "$C_RESET"
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
		header_color=$C_HEADER
	fi

	echo "$VOID"

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SLEEP_HEADER
	draw_header_line "$HEADER_LINE_CHAR" "$header_color"
	# Pour afficher une autre couleur pour le texte, remplacez l'appel de variable "$header_color" ci-dessous par la couleur que vous souhaitez
	echo "$header_color" "##>" "$header_string"
	draw_header_line "$HEADER_LINE_CHAR" "$header_color"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)
	echo "$VOID"

	echo "$VOID"

	$SLEEP_HEADER
}

# Installer sudo sur Debian et ajouter l'utilisateur actuel à la liste des sudoers
set_sudo()
{
    script_header "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"

    echo "$J_TAB Détection de sudo $C_RESET"
    if test command -v sudo > /dev/null 2>&1; then
        j_echo "sudo n'est pas installé sur votre système"
        j_echo "installation"
        pack_install sudo
        v_echo "sudo a été correctement istallé sur votre système"
    else
        echo "$V_TAB \"sudo\" est déjà installé sur votre système d'exploitation $C_RESET"; echo "$VOID"
    fi
	# Si l'utilisateur ne bénéficie pas des privilèges root

	# Astuce : Essayer de parser le fichier sudoers et de récupérer la ligne : "root    ALL=(ALL) ALL", puis le contenu de la ligne du dessous. Si elle est vide, alors on ouvre Visudo et on laisse l'utilisateur rentrer la ligne "user root    ALL=(ALL) NOPASSWORD"
    find /etc/ -type f -print | xargs -0 grep -1 "sudoers"
	
	while read -r line; do
		if [ ! $line="%sudo	ALL=(ALL:ALL) ALL" || ! $line="$SUDO_USER    ALL=(ALL:ALL) ALL" ]; then
			j_echo "AJOUT DE L'UTILISATEUR ACTUEL À LA LISTE DES SUDOERS $C_RESET"
			j_echo "LISEZ ATTENTIVEMENT CE QUI SUIT !!!!!!!! $C_RESET"
			echo "L'éditeur de texte Visudo (éditeur basé sur Vi spécialement créé pour modifier le fichier protégé /etc/sudoers)"
			echo "va s'ouvrir pour que vous puissiez ajouter votre compte utilisateur à la liste des sudoers afin de bénéficier"
			echo "des privilèges d'administrateur avec la commande sudo sans avoir à vous connecter en mode super-utilisateur."
			echo "$VOID"

			j_echo "La ligne à ajouter se trouve dans la section \"#User privilege specification\". Sous la ligne"
			echo "root    ALL=(ALL) ALL"
			
			j_echo "Tapez (écrivez également le commentaire de la ligne ci-dessous pour vous rappeler ce que fait cette ligne) :"
			echo "# Permettre l'accès aux membres du groupe d'utilisateurs \"sudo\" (dont vous) aux prvilèges de super-utilisateur "
			echo "%sudo	ALL=(ALL:ALL) ALL"
			echo "$VOID"
			
			echo "$J_TAB Si vous avez bien compris (ou mieux, noté) la procédure à suivre, tapez EXACTEMENT \"compris\" pour ouvrir Visudo"
			echo "$J_TAB Ou tapez EXACTEMENT \"quitter\" si vous souhaitez configurer le fichier \"/etc/visudo\" plus tard $C_RESET"

			# Fonction d'entrée de réponse sécurisée et optimisée
			read_visudo()
			{
				read -r visudo_rep
				case ${visudo_rep,,} in
					"compris")
						visudo
						usermod -aG sudo "$USER"
						# SI USERMOD = MODIFIÉ; ALORS
						#	AFFICHER "sudoers modifié"
						# SINON
						#	AFFICHER "sudoers non modifié"
						;;
					"quitter")
						return
						;;
					*)
					#	echo "$VOID"
					#	echo "$R_TAB Veuillez taper EXACTEMENT \"compris\" pour ouvrir Visudo,"
					#	echo "$R_TAB ou \"quitter\" pour configurer le fichier \"/etc/sudoers\" plus tard $C_RESET"
						read_visudo
						;;
				esac
			}
			read_visudo
		else
			v_echo "Vous bénéficiez déjà des privilèges du super-administrateur"
		fi
	done
}

set_sudo