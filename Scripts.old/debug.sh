#!/usr/bin/env bash

# Code
sudo ./beta.sh dimob debug

if test $? -eq 0; then
    echo "Tout s'est bien passé"
    echo ""
else
    echo "Une erreur est survenue"
    echo ""
fi

#read -rp "Souhaitez-vous lire le fichier de logs ? " rep

#case ${rep,,} in
#    "oui" | "o" | "yes" | "y")
#        less -R "Linux-reinstall.log" || echo "Aucun fichier de logs valide trouvé"
#        ;;
#    *)
#        false
#        ;;
#    esac
#exit 0
