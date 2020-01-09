#!/bin/bash

# FICHIERS
TMPDIR="$HOME/Linux_script_output.d"	# Dossier contenant les fichiers temporaires
TMPPACK="tmppack"						# Fichier temporaire contenant les sorties de la commande "command -v $package_name"


pack_install()
{
	# Si vous souhaitez mettre tous les paquets en tant que multiples arguments (tableau d'arguments), remplacez le "$1"
	# ci-dessous par "$@" et enlevez les doubles guillemets "" entourant chaque variable "$package_name" suivant la commande
	# d'installation de votre distribution.
	package_name=$1

	# Pour éviter de retaper ce qui ne fait pas partie de la commande d'installation pour chaque gestionnaire de paquets
	pack_install_complete()
	{
        # $@ --> Tableau dynamique d'arguments permettant d'appeller la commande d'installation complète du gestionnaire de paquets et ses options
		sleep 1; "$@"
	}

	# On cherche à savoir si le paquet souhaité est déjà installé sur le disque en utilisant des redirections.
	# Si c'est le cas, le script affiche que le paquet est déjà installé et ne perd pas de temps à le réinstaller.
	# Sinon, le script installe le paquet manquant.

	# Rediriger les sorties de "command -v" vers un fichier temporaire et lire le fichier pour trouver la commande
	command -v "$package_name" 1> $TMPPACK
    
    while IFS= read -r tmpline; do
        if test line != ""; then
            echo "Texte lu : $tmpline"
            echo "$VOID Le paquet \"$package_name\" est déjà installé"
        elif test $tmpline == ""; then
            echo "La ligne est vide"
            echo "$VOID"
		    echo "Installation de $package_name"
    		pack_install_complete sudo apt -y install "$package_name"
    		echo "Le paquet \"$package_name\" a été correctement installé"
        fi
    done < "$TMPPACK"
	echo "" > $TMPPACK
}

echo "INSTALLATION"

pack_install vlc