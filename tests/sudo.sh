#!/bin/bash

C_JAUNE=$(tput setaf 226) 		# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes.
C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal.
C_ROUGE=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape.
C_VERT=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape.

# Nombre de chevrons avant les chaînes de caractères jaunes, vertes et rouges
TAB=">>>>"
# Affichage de chevrons précédant l'encodage de la couleur d'une chaîne de caractères
J_TAB="$C_JAUNE$TAB"
R_TAB="$C_ROUGE$TAB$TAB"
V_TAB="$C_VERT$TAB$TAB"
# Saut de ligne
VOID=""

j_echo() { j_string=$1; echo "$J_TAB $j_string $C_RESET";}
r_echo() { r_string=$1; echo "$R_TAB $r_string $C_RESET";}
v_echo() { v_string=$1; echo "$V_TAB $v_string $C_RESET";}

# Installer sudo sur Debian et ajouter l'utilisateur actuel à la liste des sudoers
set_sudo()
{
    j_echo "Détection de sudo"
    if [ ! -f /usr/bin/sudo ]; then
        j_echo "sudo n'est pas installé sur votre système"
        j_echo "installation"
        apt install sudo
        v_echo "sudo a été correctement istallé sur votre système"
    else
        v_echo "$V_TAB \"sudo\" est déjà installé sur votre système d'exploitation"
    fi

	# Ajout de l'utilisateur 
	adduser $LOGNAME sudo

}

set_sudo