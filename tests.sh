#!/bin/bash

# COOLDOWN_3=sleep 1 && echo "3" && sleep 1 && echo "2" && sleep 1 && echo "1" && sleep 1 && echo ""

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

# Installer sudo sur Debian et ajouter l'utilisateur actuel à la liste des sudoers
set_sudo()
{
    echo "$J_TAB Détection de sudo $C_RESET"
    if ! which sudo > /dev/null ; then
        pack_install sudo
    else
        echo "$V_TAB \"sudo\" est déjà installé sur votre système d'exploitation $C_RESET"; echo ""
    fi
	# Si l'utilisateur ne bénéficie pas des privilèges root

	# Astuce : Essayer de parser le fichier sudoers et de récupérer la ligne : "root    ALL=(ALL) ALL", puis le contenu de la ligne du dessous. Si elle est vide, alors on ouvre Visudo et on laisse l'utilisateur rentrer la ligne "user root    ALL=(ALL) NOPASSWORD"
    if [  ]; then
		echo "$J_TAB AJOUT DE L'UTILISATEUR ACTUEL À LA LISTE DES SUDOERS $C_RESET"
		echo "$J_TAB LISEZ ATTENTIVEMENT CE QUI SUIT !!!!!!!! $C_RESET"
		echo "L'éditeur de texte Visudo (éditeur basé sur Vi spécialement créé pour modifier le fichier protégé /etc/sudoers)"
		echo "va s'ouvrir pour que vous puissiez ajouter votre compte utilisateur à la liste des sudoers afin de bénéficier"
		echo "des privilèges d'administrateur avec la commande sudo sans avoir à vous connecter en mode super-utilisateur."; echo ""
		echo "$J_TAB La ligne à ajouter se trouve dans la section \"#User privilege specification\". Sous la ligne $C_RESET"
		echo "root    ALL=(ALL) ALL"; echo ""
		echo "$J_TAB Tapez : $C_RESET"
		echo "$USER	ALL=(ALL) NOPASSWD:ALL"; echo ""
		echo "$J_TAB Si vous avez bien compris la procédure à suivre, tapez EXACTEMENT \"compris\" pour ouvrir Visudo"
		echo "$J_TAB ou \"quitter\" si vous souhaitez configurer le fichier \"/etc/visudo\" plus tard $C_RESET"

		# Fonction d'entrée de réponse sécurisée et optimisée
		read_visudo()
		{
			read visudo_rep
			case ${visudo_rep,,} in
				"compris")
					visudo
					usermod -aG sudo $USER
					# SI USERMOD = MODIFIÉ; ALORS
					#	AFFICHER "sudoers modifié"
					# SINON
					#	AFFICHER "sudoers non modifié"
					;;
				"quitter")
					return
					;;
				*)
					echo ""
					echo "$R_TAB Veuillez taper EXACTEMENT \"compris\" pour ouvrir Visudo,"
					echo "$R_TAB ou \"quitter\" pour configurer le fichier \"/etc/sudoers\" plus tard $C_RESET"
					read_rep_f
					;;
			esac
		}
		read_visudo
    else
        echo "$V_TAB Vous avez déjà les permissions du mode sudo $C_RESET"
    fi
}

set_sudo
