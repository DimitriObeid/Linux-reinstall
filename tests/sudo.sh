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
	# Si l'utilisateur ne bénéficie pas des privilèges root

	# Astuce : Essayer de parser le fichier sudoers et de récupérer la ligne : "root    ALL=(ALL) ALL", puis le contenu de la ligne du dessous. Si elle est vide, alors on ouvre Visudo et on laisse l'utilisateur rentrer la ligne "user root    ALL=(ALL) NOPASSWORD"
 	sudoers="/etc/sudoers"
	
	while IFS= read -r line; do
		echo "$line"
	done < $sudoers

	if [ "$(grep -Fq)" == "%sudo	ALL=(ALL:ALL) ALL" ] || [ "$(grep -Fq)" == "SUDO_USER	ALL=(ALL:ALL) ALL" ]; then
			v_echo "Vous bénéficiez déjà des privilèges du super-administrateur"
		else
			echo "$VOID"
			j_echo "AJOUT DE L'UTILISATEUR ACTUEL À LA LISTE DES SUDOERS"
			j_echo "LISEZ ATTENTIVEMENT CE QUI SUIT !!!!!!!!"
			echo "L'éditeur de texte Visudo (éditeur basé sur Vi spécialement créé pour modifier le fichier protégé /etc/sudoers)"
			echo "va s'ouvrir pour que vous puissiez ajouter votre compte utilisateur à la liste des sudoers afin de bénéficier"
			echo "des privilèges d'administrateur avec la commande sudo sans avoir à vous connecter en mode super-utilisateur."
			echo "$VOID"

			j_echo "La ligne à ajouter se trouve dans la section \"#User privilege specification\". Sous la ligne"
			echo "root    ALL=(ALL) ALL"
			echo "$VOID"
			
			j_echo "Tapez (écrivez également le commentaire de la ligne ci-dessous pour vous rappeler ce que fait cette ligne) :"
			echo "# Permettre l'accès aux membres du groupe d'utilisateurs \"sudo\" (dont vous) aux prvilèges de super-utilisateur "
			echo "%sudo	ALL=(ALL:ALL) ALL"
			echo "$VOID"
			
			j_echo "Si vous avez bien compris (ou mieux, noté) la procédure à suivre, tapez EXACTEMENT \"compris\" pour ouvrir Visudo"
			j_echo "Ou tapez EXACTEMENT \"quitter\" si vous souhaitez configurer le fichier \"/etc/visudo\" plus tard"

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
						echo "$VOID"
						
						r_echo "Veuillez taper EXACTEMENT \"compris\" pour ouvrir Visudo,"
						r_echo "$R_TAB ou \"quitter\" pour configurer le fichier \"/etc/sudoers\" plus tard"
						read_visudo
						;;
				esac
			}
			read_visudo
		fi
}

set_sudo