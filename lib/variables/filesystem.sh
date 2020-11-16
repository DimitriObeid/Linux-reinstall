#!/usr/bin/env bash

# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### DOSSIERS | FOLDERS
## DOSSIER PERSONNEL DE L'UTILISATEUR | USER'S HOME FOLDER.
DIR_HOMEDIR="/home/${ARG_USERNAME}"     # Chemin | Path

# -----------------------------------------------

## INFORMATIONS DU DOSSIER TEMPORAIRE | TEMPORARY FOLDER'S INFORMATIONS.
DIR_TMP_NAME="Linux-reinstall.tmp.d"			# Nom | Name
DIR_TMP_PARENT="/tmp"							# Dossier parent | Parent folder
DIR_TMP_PATH="$DIR_TMP_PARENT/$DIR_TMP_NAME"	# Chemin complet | Full path

# -----------------------------------------------

## SOUS-DOSSIERS DU DOSSIER TEMPORAIRE | TEMPORARY FOLDER'S SUD-FOLDERS
# Dossier contenant les fichiers et le script d'installation | Folder containing the installation files and the installation script
DIR_INSTALL_NAME="Install"                              # Nom | Name
DIR_INSTALL_PATH="$DIR_TMP_PATH/$DIR_INSTALL_NAME"      # Chemin | Path

# Dossier contenant le fichier de logs | Folder containing the logs file.
DIR_LOG_NAME="Logs"
DIR_LOG_PATH="$DIR_TMP_PATH/$DIR_LOG_NAME"

# Dossier contenant les fichiers enregistrant les paquets non-trouvés dans la base de données du gestionnaire de paquets ou dont l'installation a échoué |
# Folder containing the files that registers registering packages not found in the package manager's database or whose installation failed
DIR_PACKAGES_NAME="Packages"
DIR_PACKAGES_PATH="$DIR_TMP_PATH/$DIR_PACKAGES_NAME"

# Dossier d'installation de logiciels indisponibles via les gestionnaires de paquets | Unavailable softwares on package manager's installation folder
DIR_SOFTWARE_NAME="Logiciels.Linux-reinstall.d"
DIR_SOFTWARE_PATH="$DIR_HOMEDIR/$DIR_SOFTWARE_NAME"

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### FICHIERS | FILES
## FICHIER DE LOGS
# Définition du nom et du chemin du fichier de logs.
FILE_LOG_NAME="Linux-reinstall $DATE_TIME.log"		# Nom | Name
FILE_LOG_PATH="$PWD/$FILE_LOG_NAME"					# Chemin du fichier de logs depuis la racine, dans le dossier actuel (il est mis à jour pendant l'initialisation du script).

# -----------------------------------------------

## FICHIERS DE SCRIPT | SCRIPT FILES
# Définition du nom et du chemin du fichier de script de traitement des paquets à installer.
FILE_SCRIPT_NAME="Packs.sh"
FILE_SCRIPT_PATH="$DIR_INSTALL_PATH/$FILE_SCRIPT_NAME"

# -----------------------------------------------

## FICHIERS D'ÉCHEC DE TÉLÉCHARGEMENT | DOWNLOAD FAILURE FILES
# Définition des noms et des chemins des fichiers listant les paquets absents de la base de données du gestionnaire de paquets ou dont l'installation a échouée.
FILE_PACKAGES_DB_NAME="Packages not found.txt"
FILE_PACKAGES_DB_PATH="$DIR_PACKAGES_PATH/$FILE_PACKAGES_DB_NAME"

FILE_PACKAGES_INST_NAME="Packages not installed.txt"
FILE_PACKAGES_INST_PATH="$DIR_PACKAGES_PATH/$FILE_PACKAGES_INST_NAME"

# -----------------------------------------------

## FICHIERS D'INSTALLATION | INSTALLATION FILES
# Définition des noms et des chemins des fichiers contenant les commandes de recherche et d'installation de paquets selon le gestionnaire de paquets de l'utilisateur.
FILE_INSTALL_HD_NAME="hd_search.tmp"
FILE_INSTALL_HD_PATH="$DIR_INSTALL_PATH/$FILE_INSTALL_HD_NAME"

FILE_INSTALL_DB_NAME="db_search.tmp"
FILE_INSTALL_DB_PATH="$DIR_INSTALL_PATH/$FILE_INSTALL_DB_NAME"

FILE_INSTALL_INST_NAME="inst.tmp"
FILE_INSTALL_INST_PATH="$DIR_INSTALL_PATH/$FILE_INSTALL_INST_NAME"

# Définition du nom et du chemin du fichier contenant le code de retour de la commande de recherche ou d'installation de paquets.
GETVAL_NAME="getval.tmp"
GETVAL_PATH="$DIR_INSTALL_PATH/$GETVAL_NAME"

# -----------------------------------------------
