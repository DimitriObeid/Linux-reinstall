#!/bin/bash

# FICHIERS
TMPPACK="tmppack"		# Fichier temporaire contenant les sorties de la commande "command -v $package_name"


pack_install()
{
	if [ ! -f "$TMPPACK" ]; then
		touch "$TMPPACK"
	fi
	
	package_name=$1
	
	pack_install_complete()
	{
		sleep 1; "$@"
	}

	command -v "$package_name" > $TMPPACK
    
    while IFS= read -r tmpline; do
    	if [ $tmpline != "" ]; then
            echo "Texte lu : $tmpline"
            echo "$VOID Le paquet \"$package_name\" est déjà installé"
			echo ""
			echo "" > $TMPPACK
        else
            echo "La ligne est vide"
            echo "$VOID"
		    echo "Installation de $package_name"
    		pack_install_complete sudo apt -y install "$package_name"
    		echo "Le paquet \"$package_name\" a été correctement installé"
        fi
    done < "$TMPPACK"
}


pack_install vlc
pack_install ls
pack_install tree
pack_install sl
pack_install neofetch