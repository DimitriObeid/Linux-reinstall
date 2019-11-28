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

echo "$J_TAB Ajout de l'utilisateur actuel à la liste des sudoers $C_RESET"
echo "$J_TAB LISEZ ATTENTIVEMENT CE QUI SUIT !!!!!!!! $C_RESET"
echo "L'éditeur de texte Visudo (éditeur basé sur Vi spécialement créé pour modifier le fichier protégé /etc/sudoers)"
echo "va s'ouvrir pour que vous puissiez ajouter votre compte utilisateur à la liste des sudoers afin de bénéficier"
echo "des privilèges d'administrateur sans avoir à vous connecter en mode super-utilisateur."; echo ""
echo "$J_TAB La ligne à ajouter se trouve dans la section \"#User privilege specification\". Sous la ligne $C_RESET"
echo "root    ALL=(ALL) ALL"; echo ""
echo "$J_TAB Tapez : $C_RESET"
echo "$USER	ALL=(ALL) NOPASSWD:ALL"; echo ""
echo "$J_TAB Si vous avez bien compris la procédure à suivre, tapez EXACTEMENT \"compris\" pour ouvrir Visudo"
echo "$J_TAB ou \"quitter\" si vous souhaitez configurer le fichier \"/etc/visudo\" plus tard $C_RESET"
read_rep_f()
{
	read visudo_rep
	case ${visudo_rep,,} in
		"compris")
			visudo
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
read_rep_f
