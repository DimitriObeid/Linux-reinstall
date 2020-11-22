#!/usr/bin/env bash

# Script de réinstallation | Reinstallation script
# Version : 2.0

# To debug this script when needed, type the following command :
# sudo <shell> -x <filename>

# Example :
# sudo bash -x reinstall.sh

# Or debug it by using Shellcheck :
#	Online -> https://www.shellcheck.net/
#	On command line interface -> shellcheck beta.sh
#		--> Shellcheck install command : sudo $package_manager $install_command shellcheck


# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

###################################### INCLUDING DEPENDENCIES #####################################

#### INITIALIZING DEPENDENCIES

## DEFINING MAIN SCRIPT VARIABLES

# Log

MAIN_LOG="initscript.log"

if test ! -f "$MAIN_LOG"; then touch "$MAIN_LOG"; fi

# Paths
MAIN_LANG="lang"
MAIN_L_FNCTS="lib/functions"
MAIN_L_VARS="lib/variables"
MAIN_S_INST="src/installcat"
MAIN_S_LANG="src/lang"
MAIN_S_VARS="src/variables"

# Script Version
MAIN_SCRIPT_VERSION="2.0"    # Script's current version

# -----------------------------------------------

## DEFINING PROJECT'S ROOT DIRECTORY

MAIN_PROJECT_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; cd .. && pwd -P )"
{ echo "$MAIN_PROJECT_ROOT"; echo; } > "$MAIN_LOGs"

shopt -s extglob                # enable +(...) glob syntax
MAIN_PROJECT_RESULT=${MAIN_PROJECT_ROOT%%+(/)}   # Trimming however many trailing slashes exist
MAIN_PROJECT_RESULT=${MAIN_PROJECT_ROOT##*/}     # Removing everything before the last / that still remains to get only the project root folder's name
{ echo "$MAIN_PROJECT_RESULT"; echo; } >> "$MAIN_LOG"

# Failsafe : verifying if the result matches with the project root folder's name.
if test "$MAIN_PROJECT_RESULT" != "Linux-reinstall"; then
    echo "Unable to find the project's root directory path"; exit 1
fi

# -----------------------------------------------

## CHECKING IF THE SUB-FOLDERS EXISTS

# Function checking if the project's subfolders paths passed as argument exist
function CheckSubFolder()   
{
    #***** Parameters *****
    local path=$1;

    #***** Code *****
    if test -d "$MAIN_PROJECT_ROOT/$path"; then
        echo "Included file : $path" >> "$MAIN_LOG"
    else
        echo "Cannot include $path, abort"

        exit 1
    fi
}

# Calling the above function and passing targeted directories paths as argument
CheckSubFolder "$MAIN_LANG"
CheckSubFolder "$MAIN_L_FNCTS"
CheckSubFolder "$MAIN_L_VARS"
CheckSubFolder "$MAIN_S_INST"
CheckSubFolder "$MAIN_S_LANG"
CheckSubFolder "$MAIN_S_VARS"
echo >> "$MAIN_LOG"


# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #


#### INCLUDING FILES

## TRANSLATION FILES

# shellcheck source="$MAIN_PROJECT_ROOT/$MAIN_S_LANG/SetMainLang.sh"
source "$MAIN_PROJECT_ROOT/$MAIN_S_LANG/SetMainLang.sh" \
    || echo "$MAIN_PROJECT_ROOT/$MAIN_S_LANG/SetMainLang.sh : Unable to find the main file's variables translation file" && exit 1

# shellcheck source="$MAIN_PROJECT_ROOT/$MAIN_LANG/SetLibLang.sh"
source "$MAIN_PROJECT_ROOT/$MAIN_LANG/SetLibLang.sh" \
    || echo "$MAIN_PROJECT_ROOT/$MAIN_LANG/SetLibLang.sh : Unable to find the library variables translation file" && exit 1
echo "Included file : $MAIN_PROJECT_ROOT/$MAIN_S_LANG/DetectLocale.sh" >> 

# -----------------------------------------------

## VARIABLES FILES

# shellcheck source=$MAIN_PROJECT_ROOT/$MAIN_S_RES/main.var
source "$MAIN_PROJECT_ROOT/$MAIN_S_RES/main.var" || echo "$MAIN_S_RES/main.var : not found" && exit 1
echo "Included variable file : $MAIN_S_VARS/main.var"

# shellcheck source=lib/variables/colors.var
source "$MAIN_PROJECT_ROOT/$MAIN_L_VARS/colors.var" || echo "$MAIN_L_VARS/colors.var : not found" && exit 1
echo "Included variable file : $MAIN_L_VARS/colors.var"

# shellcheck source=../variables/filesystem.var
source "$MAIN_PROJECT_ROOT/$MAIN_L_VARS/files.sh" || echo "$MAIN_L_VARS/filesystem.var : not found" && exit 1
echo "Included variable file : $MAIN_L_VARS/files.sh"

# shellcheck source=../variables/colors.var
source "$MAIN_PROJECT_ROOT/$MAIN_L_VARS/text.var" || echo "$MAIN_L_VARS/text.var : not found" && exit 1
echo "Included variable file : $MAIN_L_VARS/text.var"

# -----------------------------------------------

## FUNCTION FILES

# shellcheck source="/home/dimob/Projets/Linux-reinstall/lib/functions/Echo.lib"
source "$MAIN_PROJECT_ROOT/$MAIN_L_FNCTS/Echo.lib" || echo "$MAIN_L_FNCTS/Echo.lib : not found" && exit 1
echo "Included function file : $MAIN_L_FNCTS/Echo.lib"

# shellcheck source="/home/dimob/Projets/Linux-reinstall/lib/functions/Filesystem.lib"
source "$MAIN_PROJECT_ROOT/$MAIN_L_FNCTS/Filesystem.lib" || echo "$MAIN_L_FNCTS/Filesystem.lib : not found" && exit 1
echo "Included function file : $MAIN_L_FNCTS/"

# shellcheck source="/home/dimob/Projets/Linux-reinstall/lib/functions/Headers.lib"
source "$MAIN_PROJECT_ROOT/$MAIN_L_FNCTS/Headers.sh" || echo "$MAIN_L_FNCTS/Headers.lib : not found" && exit 1
echo "Included function file : $MAIN_L_FNCTS/Headers.lib"

# shellcheck source="/home/dimob/Projets/sLinux-reinstall/lib/functions/Install.lib"
source "$MAIN_PROJECT_ROOT/$MAIN_L_FNCTS/Install.lib" || echo "$MAIN_L_FNCTS/Install.lib : not found" && exit 1
echo "Included function file : $MAIN_L_FNCTS/Install.lib"



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

################################ DEFINING THE MAIN SCRIPT VARIABLES ###############################

# TODO : Mettre ça dans les fichiers de traduction du script principal
declare -A MSG_LANG_YES
declare -A MSG_LANG_NO

MSG_LANG_YES=("oui" "yes")
MSG_LANG_NO=("non" "no")



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

####################################### INITIALIZING SCRIPT #######################################

#### DÉFINITION DES FONCTIONS DÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####

## DÉFINITION DES FONCTIONS D'INITIALISATION
# Détection du passage des arguments au script
function CheckArgs()
{    
	# If the script is not run as super-user (root)
	if test "$EUID" -ne 0; then
		EchoErrorLog "$MSG_INIT_ROOT_ZERO."
		EchoErrorLog "$MSG_INIT_ROOT_ZERO_EXEC :"

		# La variable "$0" ci-dessous est le nom du fichier shell en question avec le "./" placé devant (argument 0).
		# Si ce fichier est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
		echo "$MSG_INIT_ARGS_SUDO"
		echo

		EchoErrorLog "$MSG_INIT_ROOT_ZERO_OR_1,"
		EchoErrorLog "$MSG_INIT_ROOT_ZERO_OR_2 :"
		echo "$MSG_INIT_ARGS"
		echo

		EchoErrorLog "$MSG_INIT_ROOT_FAIL !"
		EchoErrorLog "$MSG_INIT_ROOT_ADVICE."
		echo

		exit 1
    fi
		
	# If no value is passed as username argument.
	if test -z "$ARG_USERNAME"; then
		EchoErrorLog "$MSG_INIT_USERNAME_ZERO :"
		echo "$MSG_INIT_ARGS_SUDO"
		echo

		EchoErrorLog "$MSG_INIT_USERNAME_FAIL !"
		EchoErrorLog "$MSG_INIT_USERNAME_ADVICE."
		echo

		exit 1

	# Else, if the username argument doesn't match to any existing user account.
	elif ! id -u "$ARG_USERNAME" > /dev/null; then
        echo

		EchoErrorLog "$MSG_INIT_USERNAME_INCORRECT !"
		EchoErrorLog "$MSG_INIT_USERNAME_INCORRECT_ADVICE."
		echo

		exit 1
	fi

	# If the second mandatory argument is not passed.
	if test -z "$ARG_INSTALL"; then
        echo

        EchoErrorLog "$MSG_INIT_INSTALL_ZERO !"
        EchoErrorLog "$MSG_INIT_INSTALL_ZERO_ADVICE."
        echo
        
        EchoErrorLog "$MSG_INIT_INSTALL_AWAITED."
        echo
        
        exit 1
	    
    # Else, if the second argument is passed, the script checks if the value is equal to only one of the awaited values ("custom" or "sio"). They are not case sensitive.
   	else
        case ${ARG_INSTALL,,} in
            "custom")
                VER_INSTALL="$ARG_INSTALL"
                ;;
            "sio")
                VER_INSTALL="$ARG_INSTALL"
                ;;
            *)
                echo
        
                EchoErrorLog "$MSG_INIT_INSTALL_DIFFERENT !"
                EchoErrorLog "$MSG_INIT_INSTALL_AWAITED."
                echo
            
                exit 1
                ;;
        esac
    fi


	# I use this function to test features on my script without waiting for it to reach their step. Its content is likely to change a lot.
	# Checking if the user passed a string named "debug" as last argument. 
	if test "$ARG_DEBUG_VAL" = "${ARG_DEBUG}"; then
		# The name of the log file is redefined, THEN we redefine the path, EVEN if the initial value of the variable "$FILE_LOG_PATH" is the same as the new value.
		# In this case, if the value of the variable "$FILE_LOG_PATH" is not redefined, the old value is called.
		FILE_LOG_NAME="Linux-reinstall $DATE_TIME.test"
		FILE_LOG_PATH="$PWD/$FILE_LOG_NAME"

		## APPEL DES FONCTIONS D'INITIALISATION
		CreateLogFile			# On appelle la fonction de création du fichier de logs. À partir de maintenant, chaque sortie peut être redirigée vers un fichier de logs existant.
		Mktmpdir				# Puis la fonction de création du dossier temporaire.
		GetMainPackageManager	# Puis la fonction de détection du gestionnaire de paquets principal de la distribution de l'utilisateur.
		WriteInstallScript		# Puis la fonction de création de scripts d'installation.

		# APPEL DES FONCTIONS À TESTER
		EchoNewstepTee "Test de la fonction d'installation"

		HeaderStep "TEST D'INSTALLATION DE PAQUETS"
		PackInstall "apt" "nano"
		PackInstall "apt" "emacs"

		exit 0

	# Si un deuxième argument est passé ET si la valeur attendue ("debug") ne correspond pas à la valeur du dernier argument.
	elif test ! -z "${ARG_DEBUG}" && test "$ARG_DEBUG_VAL" != "${ARG_DEBUG}" ; then
		EchoError "$MSG_INIT_DEBUG_FAIL : $(DechoE "debug")"
		EchoError "$MSG_INIT_DEBUG_ADVICE"
		echo

		exit 1
	fi
}

# Création du fichier de logs pour répertorier chaque sortie de commande (sortie standard (STDOUT) ou sortie d'erreurs (STDERR)).
function CreateLogFile()
{
	# Récupération des informations sur le système d'exploitation de l'utilisateur, me permettant de corriger tout bug pouvant survenir sur une distribution Linux précise.

	# Le script crée d'abord le fichier de logs dans le dossier actuel (pour cela, on passe la valeur de la variable d'environnement $PWD en premier argument de la fonction "Makefile").
	lineno=$LINENO; Makefile "$PWD" "$FILE_LOG_NAME" "0" "0" > /dev/null
	
	# On vérifie si le fichier de logs a bien été créé.
	if test -f "$FILE_LOG_PATH"; then
		EchoSuccessLog "$MSG_CRLOGFILE_SUCCESS"

		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" "RÉCUPÉRATION DES INFORMATIONS SUR LE SYSTÈME DE L'UTILISATEUR" "0" >> "$FILE_LOG_PATH"	# Au moment de la création du fichier de logs, la variable "$FILE_LOG_PATH" correspond au dossier actuel de l'utilisateur.

		# Récupération des informations sur le système d'exploitation de l'utilisateur contenues dans le fichier "/etc/os-release".
		EchoNewstepLog "$MSG_CRLOGFILE_GETOSINFOS :"
		cat "/etc/os-release" >> "$FILE_LOG_PATH"
		EchoLog

		EchoSuccessLog "$MSG_CRLOGFILE_GOTOSINFOS."
    else
        # Étant donné que le fichier de logs n'existe pas dans ce cas, il est impossible d'appeler la fonction "HandleErrors" sans que le moindre bug ne se produise (cependant, il ne s'agit pas de bugs importants).
        EchoError "$MSG_CRLOGFILE_FAIL"
        EchoError "$MSG_CRLOGFILE_ADVICE"
        echo
        
        EchoError "$MSG_LINENO $lineno."
        echo
        
        exit 1
    fi
}

# Création du dossier temporaire où sont stockés les fichiers et dossiers temporaires.
function Mktmpdir()
{
    #***** Code *****
    # Tout ce qui se trouve entre les accolades suivantes est envoyé dans le fichier de logs.
	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" \
			"CRÉATION DU DOSSIER TEMPORAIRE $COL_JAUNE\"$DIR_TMP_NAME$COL_BLUE\" DANS LE DOSSIER $COL_JAUNE\"$DIR_TMP_PARENT\"$COL_RESET" "0"

		Makedir "$DIR_TMP_PARENT" "$DIR_TMP_NAME" "0" "0"     # Dossier principal
		Makedir "$DIR_TMP_PATH" "$DIR_LOG_NAME" "0" "0"       # Dossier d'enregistrement des fichiers de logs
	} >> "$FILE_LOG_PATH"

	# Avant de déplacer le fichier de logs, on vérifie si l'utilisateur n'a pas passé la valeur "debug" en tant que dernier argument (vérification importante, étant donné que le chemin et le nom du fichier sont redéfinis dans ce cas).
    EchoNewstepLog "Déplacement du fichier de logs dans le dossier $(DechoN "$DIR_LOG_PATH")" >> "$FILE_LOG_PATH"
	
	# Dans le cas où l'utilisateur ne le passe pas, une fois le dossier temporaire créé, on y déplace le fichier de logs tout en vérifiant s'il ne s'y trouve pas déjà, puis on redéfinit le chemin du fichier de logs de la variable "$FILE_LOG_PATH". Sinon, le fichier de logs n'est déplacé nulle part ailleurs dans l'arborescence.
	if test -z "${ARGV[2]}"; then
		FILE_LOG_PATH="$DIR_LOG_PATH/$FILE_LOG_NAME"
		
		# On vérifie que le fichier de logs a bien été déplacé vers le dossier temporaire en vérifiant le code de retour de la commande "mv".
		local lineno=$LINENO; mv "$PWD/$FILE_LOG_NAME" "$FILE_LOG_PATH"

        # Étant donné que la fonction "Mktmpdir" est appelée après la fonction de création du fichier de logs (CreateLogFile) dans les fonctions "CheckArgs" (dans le cas où l'argument de débug est passé) et "CreateLogFile" dans la fonction "ScriptInit, il est possible d'appeler la fonction "HandleErrors" sans que le moindre bug ne se produise.
        HandleErrors "$?" "IMPOSSIBLE DE DÉPLACER LE FICHIER DE LOGS VERS LE DOSSIER $(DechoE "$DIR_LOG_PATH")" "" "$lineno"
        EchoLog

        EchoSuccessLog "Le fichier de logs a été déplacé avec succès dans le dossier $(DechoS "$DIR_LOG_PATH")." >> "$FILE_LOG_PATH"
    else
        # Rappel : Dans cette situation où l'argument de débug est passé, les valeurs des variables "FILE_LOG_NAME" et "$DIR_LOG_PATH" ont été redéfinies dans la fonction "CheckArgs".
        EchoSuccessLog "Le fichier $(DechoS "$FILE_LOG_NAME") reste dans le dossier $(DechoS "$PWD")." >> "$FILE_LOG_PATH"
	fi
}

# Détection du gestionnaire de paquets principal utilisée par la distribution de l'utilisateur.
function GetMainPackageManager()
{
	HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" "DÉTECTION DU GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION" "0" >> "$FILE_LOG_PATH"

	# On cherche la commande du gestionnaire de paquets de la distribution de l'utilisateur dans les chemins de la variable d'environnement "$PATH" en l'exécutant.
	# On redirige chaque sortie ("STDOUT (sortie standard) si la commande est trouvée" et "STDERR (sortie d'erreurs) si la commande n'est pas trouvée")
	# de la commande vers /dev/null (vers rien) pour ne pas exécuter la commande.

	# Pour en savoir plus sur les redirections en Shell UNIX, consultez ce lien -> https://www.tldp.org/LDP/abs/html/io-redirection.html
	command -v apt-get &> /dev/null && command -v apt &> /dev/null && command -v apt-cache &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="apt"
	command -v dnf &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="dnf"
	command -v pacman &> /dev/null && PACK_MAIN_PACKAGE_MANAGER="pacman"

	# Si, après la recherche de la commande, la chaîne de caractères contenue dans la variable $PACK_MAIN_PACKAGE_MANAGER est toujours nulle (aucune commande trouvée).
	if test -z "$PACK_MAIN_PACKAGE_MANAGER"; then
        # Étant donné que la fonction "Mktmpdir" est appelée après la fonction de création du fichier de logs (CreateLogFile) dans les fonctions "CheckArgs" (dans le cas où le deuxième argument de débug est passé) et "CreateLogFile" dans la fonction "ScriptInit, il est possible d'appeler la fonction "HandleErrors" sans que le moindre bug ne se produise.
		HandleErrors "1" "AUCUN GESTIONNAIRE DE PAQUETS PRINCIPAL SUPPORTÉ TROUVÉ" "Les gestionnaires de paquets supportés sont : $(DechoE "APT"), $(DechoE "DNF") et $(DechoE "Pacman")." "$LINENO"
	else
		EchoSuccessLog "Gestionnaire de paquets principal trouvé : $(DechoS "$PACK_MAIN_PACKAGE_MANAGER")" >> "$FILE_LOG_PATH"
	fi
}

# Création du script de traitement de paquets à installer.
function WriteInstallScript()
{
	# Création du dossier contenant le script de traitement de paquets et les fichiers contenant les commandes de recherche et d'installation de paquets.
	# Creating the folder containing the packages treatment script and the files containing the packages search and installation commands.
	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_BLUE" "ÉCRITURE DU SCRIPT DE TRAITEMENT DE PAQUETS" "0"

		Makedir "$DIR_TMP_PATH" "$DIR_INSTALL_NAME" "0" "0"						# On crée le dossier contenant les fichiers temporaires contenant les commandes de recherche et d'installation des paquets.
		Makefile "$DIR_TMP_PATH/$DIR_INSTALL_NAME" "$FILE_SCRIPT_NAME" "0" "0"	# On crée le fichier de script.
	} >> "$FILE_LOG_PATH"

	# Writing the script's content into the script file by using a here document.
	cat <<-'INSTALL_SCRIPT' > "$FILE_SCRIPT_PATH"
	#!/usr/bin/env bash

	LOG=$1
	CMD=$2

	if test "$#" -eq 0; then
		exit 2
	elif test -z "${CMD}"; then
		exit 3
	elif test -s "${LOG}" && test -s "${CMD}"; then
		"$CMD" || exit 1
		exit 0
    elif test "$#" -gt 2; then
        exit 4
    else
        exit 5
    fi
	INSTALL_SCRIPT

	# Making the script executable via the "chmod" command.
	EchoNewstepLog "Attribution des droits d'exécution sur le fichier script $(DechoN "$FILE_SCRIPT_PATH")."
	EchoLog

	local lineno=$LINENO; chmod +x -v "$FILE_SCRIPT_PATH" >> "$FILE_LOG_PATH" 2>&1

    HandleErrors "$?" "IMPOSSIBLE DE CHANGER LES DROITS D'EXÉCUTION DU FICHIER SCRIPT DE TRAITEMENT DE PAQUETS" "Vérifiez ce qui cause ce problème" "$lineno"
    echo

    EchoSuccessLog "Les droits d'exécution ont été attribués avec succès sur le fichier script de traitement de paquets."
}

# Script's initialization.
function ScriptInit()
{
	CheckArgs				# On appelle la fonction de vérification des arguments passés au script,
	CreateLogFile			# Puis la fonction de création du fichier de logs. À partir de maintenant, chaque sortie peut être redirigée vers un fichier de logs existant,
	Mktmpdir 				# Puis la fonction de création du dossier temporaire,
	GetMainPackageManager	# Puis la fonction de détection du gestionnaire de paquets principal de la distribution de l'utilisateur,
	WriteInstallScript		# Puis la fonction de création de scripts d'installation.

	# On écrit dans le fichier de logs que l'on passe à la première étape "visible dans le terminal", à savoir l'étape d'initialisation du script.
	{
		HeaderBase "$COL_BLUE" "$TXT_HEADER_LINE_CHAR" "$COL_CYAN" \
			"VÉRIFICATION DES INFORMATIONS PASSÉES EN ARGUMENT" "0" >> "$FILE_LOG_PATH"
	} >> "$FILE_LOG_PATH"

	# On demande à l'utilisateur de bien confirmer son nom d'utilisateur, au cas où son compte utilisateur cohabite avec d'autres comptes et qu'il n'a pas passé le bon compte en argument.
	EchoNewstepTee "Nom d'utilisateur entré :$COL_RESET ${ARG_USERNAME}"
	EchoNewstepTee "Est-ce correct ? (oui/non)"
	Newline

	# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
	# Les deux virgules suivant directement le "rep_script_init" entre les accolades signifient que les mêmes réponses avec des
	# majuscules sont permises, peu importe où elles se situent dans la chaîne de caractères (pas de sensibilité à la casse).
	function ReadScriptInit()
	{
		read -rp "Entrez votre réponse : " rep_script_init
		echo "$rep_script_init" >> "$FILE_LOG_PATH"
		Newline

		case ${rep_script_init,,} in
			"oui" | "yes")
				return
				;;
			"non" | "no")
				EchoErrorTee "Abandon"
				Newline

				exit 0
				;;
			*)
				EchoErrorTee "Réponses attendues : $(DechoE "oui") ou $(DechoE "non") (pas de sensibilité à la casse)."
				Newline

				ReadScriptInit
				;;
		esac
	}

	ReadScriptInit

	return
}

# Demande à l'utilisateur s'il souhaite vraiment lancer le script, puis connecte l'utilisateur en mode super-utilisateur.
function LaunchScript()
{
    # Affichage du header de bienvenue
    HeaderStep "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX : VERSION $MAIN_SCRIPT_VERSION"
    EchoNewstepTee "Début de l'installation."
	Newline

	EchoNewstepTee "Assurez-vous d'avoir lu au moins le mode d'emploi $(DechoN "(Mode d'emploi.odt)") avant de lancer l'installation."
    EchoNewstepTee "Êtes-vous sûr de bien vouloir lancer l'installation ? (oui/non)."
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script.
	function ReadLaunchScript()
	{
        # On demande à l'utilisateur d'entrer une réponse.
		read -rp "Entrez votre réponse : " rep_launch_script
		echo "$rep_launch_script" >> "$FILE_LOG_PATH"
		Newline

		# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
		case ${rep_launch_script,,} in
	        "oui")
				EchoSuccessTee "Vous avez confirmé vouloir exécuter ce script."
				EchoSuccessTee "C'est parti !!!"

				return
	            ;;
	        "non")
				EchoErrorTee "Le script ne sera pas exécuté."
	            EchoErrorTee "Abandon"
				Newline

				exit 0
	            ;;
            # Si une réponse différente de "oui" ou de "non" est rentrée.
			*)
				Newline

				EchoNewstepTee "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")."
				Newline

				# On rappelle la fonction "ReadLaunchScript" en boucle tant qu"une réponse différente de "oui" ou de "non" est entrée.
				ReadLaunchScript
				;;
	    esac
	}

	# Appel de la fonction "ReadLaunchScript", car même si la fonction est définie dans la fonction "LaunchScript", ses instructions ne sont pas lues automatiquement.
	ReadLaunchScript
}

# -----------------------------------------------

## DÉFINITION DES FONCTIONS DE CONNEXION À INTERNET ET DE MISES À JOUR
# Vérification de la connexion à Internet.
function CheckInternetConnection()
{
	HeaderStep "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# On vérifie si l'ordinateur est connecté à Internet (pour le savoir, on ping le serveur DNS d'OpenDNS avec la commande ping 1.1.1.1).
	local lineno=$LINENO; ping -q -c 1 -W 1 opendns.com 2>&1 | tee -a "$FILE_LOG_PATH"
    
    HandleErrors "$?" "AUCUNE CONNEXION À INTERNET" "Vérifiez que vous êtes bien connecté à Internet, puis relancez le script." "$lineno"
    EchoSuccessTee "Votre ordinateur est connecté à Internet."

    return
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets principal supporté (utilisé par la distribution).
# C'EST UNE ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE MODIFIEZ PAS CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS PRINCIPAL (PAS DE SNAP OU DE FLATPAK) !!!.
function DistUpgrade()
{
	#***** Variables *****
	# Noms du dossier et des fichiers temporaires contenant les commandes de mise à jour selon le gestionnaire de paquets principal de l'utilisateur.
	local update_d_name="Update"		# Dossier contenant les fichiers.
	local pack_upg_f_name="pack.tmp"	# Fichier contenant la commande de mise à jour des paquets.

	# Chemins du dossier et des fichiers temporaires contenant les commandes de mise à jour selon le gestionnaire de paquets principal de l'utilisateur.
	local update_d_path="$DIR_TMP_PATH/$update_d_name"			# Chemin du dossier.
	local pack_upg_f_path="$update_d_path/$pack_upg_f_name"		# Chemin du fichier contenant la commande de mise à jour des paquets.

	# Vérification du succès des mises à jour.
	local packs_updated="0"

	#***** Code *****
	HeaderStep "MISE À JOUR DU SYSTÈME"

	# On crée le dossier contenant les commandes de mise à jour.
	if test ! -d "$update_d_path"; then
		Makedir "$DIR_TMP_PATH" "$update_d_name" "0" "0" >> "$FILE_LOG_PATH"
	fi

	# On récupère la commande de mise à jour du gestionnaire de paquets principal enregistée dans la variable "$PACK_MAIN_PACKAGE_MANAGER".
	case "$PACK_MAIN_PACKAGE_MANAGER" in
		"apt")
			echo apt-get -y upgrade > "$pack_upg_f_path"
			;;
		"dnf")
			echo dnf -y update > "$pack_upg_f_path"
			;;
		"pacman")
			echo pacman --noconfirm -Syu > "$pack_upg_f_path"
			;;
	esac

	# On met à jour les paquets
	EchoNewstepTee "Mise à jour des paquets"
	Newline

	bash "$pack_upg_f_path" # | tee -a "$FILE_LOG_PATH"

	if test "$?" -eq 0; then
		packs_updated="1"
		EchoSuccessTee "Tous les paquets ont été mis à jour."
		Newline
	else
		EchoErrorTee "Une ou plusieurs erreurs ont eu lieu lors de la mise à jour des paquets."
		Newline
	fi

	# On vérifie maintenant si les paquets ont bien été mis à jour.
	if test $packs_updated = "1"; then
		EchoSuccessTee "Les paquets ont été mis à jour avec succès."
	else
		EchoErrorTee "La mise à jour des paquets a échouée."
	fi

	return
}


## DÉFINITION DES FONCTIONS DE PARAMÉTRAGE
# Détection et installation de Sudo.
function SetSudo()
{
	HeaderStep "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"

	# On crée une backup du fichier de configuration "sudoers" au cas où l'utilisateur souhaite revenir à son ancienne configuration.
	local sudoers_old="/etc/sudoers - $DATE_TIME.old"

    EchoNewstepTee "Détection de la commande sudo $COL_RESET."
    Newline

	# On vérifie si la commande "sudo" est installée sur le système de l'utilisateur.
	command -v sudo 2>&1 | tee -a "$FILE_LOG_PATH"

	if test "$?" -eq 0; then
        Newline

        EchoSuccessTee "La commande $(DechoS "sudo") est déjà installée sur votre système."
		Newline
	else
		Newline
		EchoNewstepTee "La commande $(DechoN "sudo") n'est pas installé sur votre système."
		Newline

		PackInstall "$PACK_MAIN_PACKAGE_MANAGER" "sudo"
	fi

	EchoNewstepTee "Le script va tenter de télécharger un fichier $(DechoN "sudoers") déjà configuré"
	EchoNewstepTee "depuis le dossier des fichiers ressources de mon dépôt Git :"
	echo ">>>> https://github.com/DimitriObeid/Linux-reinstall/tree/Beta/Ressources"
	Newline

	EchoNewstepTee "Souhaitez vous le télécharger PUIS l'installer maintenant dans le dossier $(DechoN "/etc/") ? (oui/non)"
	Newline

	echo ">>>> REMARQUE : Si vous disposez déjà des droits de super-utilisateur, ce n'est pas la peine de le faire !"
	echo ">>>> Si vous avez déjà un fichier sudoers modifié, une sauvegarde du fichier actuel sera effectuée dans le même dossier,"
	echo "	tout en arborant sa date de sauvegarde dans son nom (par exemple :$COL_CYAN sudoers - $DATE_TIME.old $COL_RESET)."
	Newline

	function ReadSetSudo()
	{
		read -rp "Entrez votre réponse : " rep_set_sudo
		echo "$rep_set_sudo" >> "$FILE_LOG_PATH"
		Newline

		# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
		case ${rep_set_sudo,,} in
			"oui" | "yes")
				# Sauvegarde du fichier "/etc/sudoers" existant en "/etc/sudoers $date_et_heure.old"
				EchoNewstepTee "Création d'une sauvegarde de votre fichier $(DechoN "sudoers") existant nommée $(DechoN "sudoers $DATE_TIME.old")."
				Newline

				cat "/etc/sudoers" > "$sudoers_old"

				if test "$?" -eq 0; then
					EchoSuccessTee "Le fichier de sauvegarde $(DechoS "$sudoers_old") a été créé avec succès."
					Newline
				else
                    EchoErrorTee "Impossible de créer une sauvegarde du fichier $(DechoE "sudoers")."
					Newline

					return
				fi

				# Téléchargement du fichier sudoers configuré.
				EchoNewstepTee "Téléchargement du fichier sudoers depuis le dépôt Git $SCRIPT_REPO."
				Newline

				sleep 1

				wget https://raw.githubusercontent.com/DimitriObeid/Linux-reinstall/Beta/Ressources/sudoers -O "$DIR_TMP_PATH/sudoers"

				if test "$?" -eq "0"; then
                    EchoSuccessTee "Le nouveau fichier $(DechoS "sudoers") a été téléchargé avec succès."
					Newline
				else
                    EchoErrorTee "Impossible de télécharger le nouveau fichier $(DechoE "sudoers")."

					return
				fi

				# Déplacement du fichier "sudoers" fraîchement téléchargé vers le dossier "/etc/".
				EchoNewstepTee "Déplacement du fichier $(DechoN "sudoers") vers le dossier $(DechoN "/etc")."
				Newline

				mv "$DIR_TMP_PATH/sudoers" /etc/sudoers

				if test "$?" -eq 0; then
					EchoSuccessTee "Fichier $(DechoS "sudoers") déplacé avec succès vers le dossier $(DechoS "/etc/")."
					Newline
				else
                    EchoErrorTee "Impossible de déplacer le fichier $(DechoE "sudoers") vers le dossier $(DechoE "/etc/")."
					Newline

					return
				fi

				# Ajout de l'utilisateur au groupe "sudo".
				EchoNewstepTee "Ajout de l'utilisateur $(DechoN "${ARG_USERNAME}") au groupe sudo."
				Newline

				usermod -aG root "${ARG_USERNAME}" 2>&1 | tee -a "$FILE_LOG_PATH"

				if test "$?" == "0"; then
                    EchoSuccessTee "L'utilisateur $(DechoS "${ARG_USERNAME}") a été ajouté au groupe sudo avec succès."
                    Newline

					return
				else
					EchoErrorTee "Impossible d'ajouter l'utilisateur $(DechoE "${ARG_USERNAME}") à la liste des sudoers."
                    Newline

					return

				fi
				;;
			"non" | "no")
				EchoSuccessTee "Le fichier $(DechoS "/etc/sudoers") ne sera pas modifié."

				return
				;;
			*)
				EchoNewstepTee "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")."
				ReadSetSudo
				;;
		esac
	}
	ReadSetSudo

	return
}

# Installation du framework PHP Laravel.
function LaravelInstall()
{
    #***** Variables *****
#    phpver=
    local envpath="$DIR_HOMEDIR/.config/composer/vendor/bin:"
    local php_ini_path="/etc/php/7.4/apache2/php.ini"

    #***** Code *****
    HeaderInstall "INSTALLATION DU FRAMEWORK LARAVEL"
    
    CommandLogs systemctl start apache2     # Démarrage du serveur Apache.
    CommandLogs systemctl enable apache2    # Démarrage du serveur Apache lors de la procédure de boot du système d'exploitation.
    
    # Ajout des services HTTP, HTTPS et SSH au firewall UFW.
    for svc in http https ssh; do
        ufw allow $svc
    done
    
    # Démarrage du firewall UFW
    uwf enable
    
    # Installation des paquets et modules PHP importants pour le bon fonctionnement de Laravel et des outils associés
    PackInstall "$main" libapache2-mod-php
    # PackInstall "$main" php                   # Le paquet étant déja installé avec Apache 2, il reste là comme rappel, au cas où vous souhaitez récupérer la fonction "LaravelInstall" pour l'implémenter dans un script personnel
    PackInstall "$main" php-bcmath
    PackInstall "$main" php-common
    # PackInstall "$main" php-json              # Le paquet étant déja installé avec Apache 2, il reste là comme rappel, au cas où vous souhaitez récupérer la fonction "LaravelInstall" pour l'implémenter dans un script personnel
    # PackInstall "$main" php-mbstring          # Le paquet étant déja installé avec Apache 2, il reste là comme rappel, au cas où vous souhaitez récupérer la fonction "LaravelInstall" pour l'implémenter dans un script personnel
    PackInstall "$main" php-opcache
    PackInstall "$main" php-tokenizer
    # PackInstall "$main" php-xml               # Le paquet étant déja installé avec Apache 2, il reste là comme rappel, au cas où vous souhaitez récupérer la fonction "LaravelInstall" pour l'implémenter dans un script personnel
    # PackInstall "$main" php-zip               # Le paquet étant déja installé avec Apache 2, il reste là comme rappel, au cas où vous souhaitez récupérer la fonction "LaravelInstall" pour l'implémenter dans un script personnel
    PackInstall "$main" unzip
    
    # Modification de la valeur de la variable "cgi.fix_pathinfo" (booléen) en la mettant à 0
    local lineno=$LINENO; sed -ie 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' "$php_ini_path"
    HandleErrors "$?" "IMPOSSIBLE DE TROUVER LE FICHIER $(DechoE "$php_ini_path")" \
        "Vérifiez que le dossier $(DechE "/etc/php/7.4") existe." ""
    
    # Redémarrage du serveur Apache après avoir modifié le fichier "php.ini"
    systemctl restart apache2
    
    # Installation de Composer pour gérer les paquets PHP
    curl -sS https://getcomposer.org/installer | php
    mv -v composer.phar /usr/local/bin/composer
    HandleFatalErrors "$?" "" "" ""
    composer --version
    HandleFatalErrors "$?" "" "" ""
    
    # Installation de Laravel
    composer global require laravel/installer
    
    # Ajout du dossier ~/.config/composer/vendor/bin dans la variable d'environnement "$PATH"
    local lineno=$LINENO; cat <<-EOF >> "$DIR_HOMEDIR/.bashrc"
    export PATH="$envpath$PATH"
EOF

    # Mise à jour du fichier de configuration "~/.bashrc" et vérification de l'application de la modification de la variable d'environnement
    # shellcheck source="$DIR_HOMEDIR/.bashrc"
    source "$DIR_HOMEDIR/.bashrc"
    echo "$PATH" | grep "$envpath"
    
    HandleErrors "$?" "LA VARIABLE D'ENVIRONNEMENT $(DechoE "\$PATH") N'A PAS ÉTÉ MODIFÉE" \
        "Échec de l'installation de Laravel." "$lineno"
    EchoSuccessTee "La variable d'environnement $(DechoS "\$PATH") a été modifiée avec succès."
    Newline
    
    EchoSuccessTee "Le framework Laravel a été installé avec succès sur votre système"
}


# Fonction regroupant les fonctions d'installation et de configuration (telles que "LaravelInstall", etc...) pour éviter de retaper leur nom à différents endroits si elles deviennent nombreuses
function InstallAndConfig()
{
    HeaderStep "INSTALLATIONS ET CONFIGURATIONS"
    
    EchoNewstepTee "Installation des programmes et configurations"
    Newline
 
    # Installation de sudo (pour les distributions livrées sans la commande) et configuration du fichier "sudoers" ("/etc/sudoers").
    SetSudo
 
    case ${VER_PACKS,,} in
    "sio")
        # shellcheck source=../src/install/sio.sh
        local lineno=$LINENO; source src/install/sio.sh \
            || HandleErrors "1" "LE FICHIER $(DechoE "install/sio.sh") N'EXISTE PAS" "Vérifiez s'il existe" "$lineno"
        SIOInstall
        ;;
    "custom")
        # shellcheck source=../src/install/custom.sh
        local lineno=$LINENO; source src/install/custom.sh \
            || HandleErrors "1" "LE FICHIER $(DechoE "install/custom.sh") N'EXISTE PAS" "Vérifiez s'il existe" "$lineno"
        SIOInstall
        CustomInstall
        ;;
    esac

    LaravelInstall
}


# DÉFINITION DES FONCTIONS DE FIN D'INSTALLATION
# Suppression des paquets obsolètes.
function Autoremove()
{
	HeaderStep "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"

	EchoNewstepTee "Souhaitez vous supprimer les paquets obsolètes ? (oui/non)"
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il souhaite supprimer les paquets obsolètes.
	function ReadAutoremove()
	{
		read -rp "Entrez votre réponse : " rep_autoremove
		echo "$rep_autoremove" >> "$FILE_LOG_PATH"
		Newline

		case ${rep_autoremove,,} in
			"oui" | "yes")
				EchoNewstepTee "Suppression des paquets."
				Newline

	    		case "$PACK_MAIN_PACKAGE_MANAGER" in
					"apt")
	            		apt-get -y autoremove
	            		;;
					"dnf")
		           		dnf -y autoremove
		           		;;
	        		"pacman")
	            		pacman --noconfirm -Qdt
	            		;;
				esac

				Newline

				EchoSuccessTee "Auto-suppression des paquets obsolètes effectuée avec succès."

				return
				;;
			"non" | "no")
				EchoSuccessTee "Les paquets obsolètes ne seront pas supprimés."
				EchoSuccessTee "Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets."

				return
				;;
			*)
				EchoNewstepTee "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")."
				ReadAutoremove
				;;
		esac
	}
	ReadAutoremove

	return
}

# Fin de l'installation.
function IsInstallationDone()
{
	HeaderStep "INSTALLATION TERMINÉE"

	EchoNewstepTee "Souhaitez-vous supprimer le dossier temporaire $(DechoN "$DIR_TMP_PATH") ? (oui/non)"
	Newline

	read -rp "Entrez votre réponse : " rep_erase_tmp
	echo "$rep_erase_tmp" >> "$FILE_LOG_PATH"
    Newline

	case ${rep_erase_tmp,,} in
		"oui")
			EchoNewstepTee "Déplacement du fichier de logs dans votre dossier personnel."
			Newline

			mv -v "$FILE_LOG_PATH" "$DIR_HOMEDIR" 2>&1 | tee -a "$DIR_HOMEDIR/$FILE_LOG_NAME" && FILE_LOG_PATH=$"$DIR_HOMEDIR" \
				&& EchoSuccessTee "Le fichier de logs a bien été deplacé dans votre dossier personnel."

			EchoNewstepTee "Suppression du dossier temporaire $DIR_TMP_PATH."
			Newline

			if test rm -rfv "$DIR_TMP_PATH" >> "$FILE_LOG_PATH"; then
				EchoSuccessTee "Le dossier temporaire $(DechoS "$DIR_TMP_PATH") a été supprimé avec succès."
				Newline
			else
				EchoErrorTee "Suppression du dossier temporaire impossible. Essayez de le supprimer manuellement."
                Newline
			fi
			;;
		*)
			EchoSuccessTee "Le dossier temporaire $(DechoS "$DIR_TMP_PATH") ne sera pas supprimé."
            Newline
			;;
	esac

    EchoSuccessTee "Installation terminée. Votre distribution Linux est prête à l'emploi."
	Newline

	echo "$(Decho "Note :") Si vous avez constaté un bug ou tout autre problème lors de l'exécution du script,"
	echo "vous pouvez m'envoyer le fichier de logs situé dans votre dossier personnel."
	echo "Il porte le nom de $(Decho "$FILE_LOG_NAME")."
	Newline

    # On tue le processus de connexion en mode super-utilisateur.
	sudo -k

	exit 0
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################



## APPEL DES FONCTIONS D'INITIALISATION ET DE PRÉ-INSTALLATION
# Détection du mode super-administrateur (root) et de la présence de l'argument contenant le nom d'utilisateur.
ScriptInit              # Initialisation du script.
LaunchScript			# Assurance que l'utilisateur soit sûr de lancer le script.
CheckInternetConnection	# Détection de la connexion à Internet.
DistUpgrade				# Mise à jour des paquets actuels.


## INSTALLATIONS PRIORITAIRES ET CONFIGURATIONS DE PRÉ-INSTALLATION
# On déclare une variable "main" et on lui assigne en valeur le nom du gestionnaire de paquet principal stocké dans la variable. "$PACK_MAIN_PACKAGE_MANAGER" pour éviter de retaper le nom de cette variable.
main="$PACK_MAIN_PACKAGE_MANAGER"

HeaderStep "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
PackInstall "$main" curl
PackInstall "$main" snapd
PackInstall "$main" wget

EchoNewstepTee "Vérification de l'installation des commandes $(DechoN "curl"), $(DechoN "snapd") et $(DechoN "wget")."
Newline

lineno=$LINENO; command -v curl snap wget | tee -a "$FILE_LOG_PATH"
HandleErrors "$?" "AU MOINS UNE DES COMMANDES D'INSTALLATION MANQUE À L'APPEL" "Essayez de  télécharger manuellement ces paquets : $(DechoE "curl"), $(DechoE "snapd") et $(DechoE "wget")." "$lineno"
EchoSuccessTee "Les commandes importantes d'installation ont été installées avec succès."
Newline

# DÉBUT DE LA PARTIE D'INSTALLATION
DrawLine ";" "$COL_GREEN"
Newline

EchoSuccessTee "Vous pouvez désormais quitter votre ordinateur pour chercher un café,"
EchoSuccessTee "La partie d'installation de vos programmes commence véritablement."
sleep 1

Newline
Newline

sleep 3


## INSTALLATION DES LOGICIELS ABSENTS DES GESTIONNAIRES DE PAQUETS
HeaderStep "INSTALLATION DES LOGICIELS INDISPONIBLES DANS LES BASES DE DONNÉES DES GESTIONNAIRES DE PAQUETS"

EchoNewstepTee "Les logiciels téléchargés via la commande $(DechoN "wget") sont déplacés vers le nouveau dossier $(DechoN "$DIR_SOFTWARE_NAME"), localisé dans votre dossier personnel"
Newline

sleep 1

# Création du dossier contenant les fichiers de logiciels téléchargés via la commande "wget" dans le dossier personnel de l'utilisateur.
EchoNewstepTee "Création du dossier d'installation des logiciels."
Newline

Makedir "$DIR_HOMEDIR" "$DIR_SOFTWARE_NAME" "2" "1" 2>&1 | tee -a "$FILE_LOG_PATH"
Newline

# Installation de JMerise
SoftwareInstall "http://www.jfreesoft.com" \
				"JMeriseEtudiant.zip" \
				"JMerise" \
				"JMerise est un logiciel dédié à la modélisation des modèles conceptuels de donnée pour Merise" \
				"JMerise.jar" \
				"" \
				"Application" \
				"Développement"


## FIN D'INSTALLATION
# Suppression des paquets obsolètes.
Autoremove

# Fin de l'installation.
IsInstallationDone
