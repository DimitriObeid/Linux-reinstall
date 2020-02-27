#!/usr/bin/python3

import sys    # Importation du module "sys" pour intéragir avec 
import os     # Importation du module "os" pour intéragir avec les appels systèmes

file_base = "/tmp/paquets_base.xml"
file_suggest = "/tmp/paquets_suggestion.xml"
file_custom = "/tmp/paquets_perso.xml"

# On crée une liste pour y stocker des valeurs, ici les chemins des fichiers XML
list_files = [file_base, file_suggest, file_custom]
# On récupère les chaînes de caractères des noms de fichiers de la liste créée ci-dessus
lf_str = ''.join(list_files)

# "Try" est une clause permettant de tester un code pouvant poser problème. Ces problèmes sont gérés par la clause "except"
try:
    # Ouverture du fichier en mode lecture (r (read))
    # La variable 'i' stocke en l'index de la liste, tandis que la variable "lf_str" stocke la valeur de la variable de l'index
    for i, lf_str in enumerate(list_files):
        if path.isfile(lf_str):
            lf_str = open(lf_str, "r").close

# Clause de gestion d'erreurs. Ici, on gère l'absence d'un ou des fichiers XML
except FileNotFoundError:
    for i, lf_str in enumerate(list_files):
        if not path.isfile(lf_str):
            # En cas d'absence d'au moins un fichier de la liste "list_files"
            print("Le fichier %s n'existe pas" % lf_str)
    print("Abandon")

    # On met fin à l'exécution du programme
    sys.exit()

# "Finally" est une clause 
finally:
    # Fermeture du fichier
    for i, lf_str in enumerate(list_files):
        print("Fermeture du fichier \"%s\"" % lf_str)
        path.isfile(lf_str).close() and print("Le fichier \"%s\" a été fermé avec succès" % lf_str)
    sys.exit()