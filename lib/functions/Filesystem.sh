#!/usr/bin/env bash

#### INCLUSION DES VARIABLES
# shellcheck source="../variables/filesystem.sh"
source ../variables/filesystem.sh || echo "../variables/filesystem.sh : not found" && exit 1


#### INCLUSION DES FONCTIONS | INCLUDING FUNCTIONS
# shellcheck source="Echo.sh"
source Echo.sh || echo "Echo.sh : not found" && exit 1

# shellcheck source=Headers.sh
source Headers.sh || echo "Headers.sh : not found" && exit 1


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### DÉFINITION DES FONCTIONS DE TRAITEMENT DE FICHIERS

# Fonction de création de dossiers ET d'attribution récursive des droits de lecture et d'écriture à l'utilisateur.
# LORS DE SON APPEL, LA SORTIE DE CETTE FONCTION DOIT ÊTRE REDIRIGÉE SOIT VERS LE TERMINAL ET LE FICHIER DE LOGS, SOIT VERS LE FICHIER DE LOGS UNIQUEMENT.
function Makedir()
{
	#***** Paramètres *****
	local parent=$1		# Emplacement depuis la racine du dossier parent du dossier à traiter.
	local name=$2		# Nom du dossier à traiter (dans son dossier parent).
	local sleep_blk=$3	# Temps de pause du script avant et après la création d'une ligne d'un bloc d'informations sur le traitement du dossier.
	local sleep_txt=$4	# Temps d'affichage des messages de passage à une nouvelle sous-étape, d'échec ou de succès lors du traitement du dossier.

	#***** Autres variables *****
	local path="$parent/$name"	# Chemin du dossier à traiter.
	local block_char='"'		# Caractère composant la ligne (c'est un double quote (")).

	#***** Code *****
	# On commence par dessiner la première ligne du bloc.
	sleep "$sleep_blk"
	DrawLine "$COL_RESET" "$block_char"

	EchoNewstepTimer "$MSG_MKDIR_PROCESSING_BEGIN." "$sleep_txt"
	echo   # On ne redirige aucun saut de ligne vers le fichier de logs, pour éviter de les afficher en double, étant donné que la fonction est appelée avec une redirection (directement dans le fichier de logs ou dans ce dernier PLUS sur le terminal).

    # Si le dossier à créer existe déjà dans son dossier parent ET que ce dossier contient AU MOINS un fichier ou dossier.
	if test -d "$path" && test "$(ls -A "$path")"; then
		EchoNewstepTimer "$MSG_MKDIR_NONEMPTY_1." "$sleep_txt"
		EchoNewstepTimer "$MSG_MKDIR_NONEMPTY_2." "$sleep_txt"
		echo

		# ATTENTION À NE PAS MODIFIER LA COMMANDE SUIVANTE", À MOINS DE SAVOIR EXACTEMENT CE QUE VOUS FAITES !!!
		# Pour plus d'informations sur cette commande complète --> https://github.com/koalaman/shellcheck/wiki/SC2115
		rm -rfv "${path/:?}/"*

		if test "$?" -eq "0"; then
			echo

			EchoSuccessTimer "$MSG_MKDIR_NONEMPTY_SUCC." "$sleep_txt"
			echo

			EchoSuccessTimer "$MSG_MKDIR_PROCESSING_END_SUCC." "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo

		else
            echo

            EchoErrorTimer "$MSG_MKDIR_NONEMPTY_FAIL_1." "$sleep_txt";
			EchoErrorTimer "$MSG_MKDIR_NONEMPTY_FAIL_2" "$sleep_txt"
			echo

			EchoErrorTimer "$MSG_MKDIR_PROCESSING_END_FAIL." "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo

			return
		fi

		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent ET que ce dossier est vide.
	elif test -d "$path" && test ! "$(ls -A "$path")"; then
		EchoSuccessTimer "$MSG_MKDIR_EXISTS." "$sleep_txt"
		echo

		EchoSuccessTimer "$MSG_MKDIR_PROCESSING_END_SUCC." "$sleep_txt"
		DrawLine "$COL_RESET" "$block_char"
		sleep "$sleep_blk"
		echo

		return

	# Sinon, si le dossier à traiter n'existe pas, alors le script le crée.
	elif test ! -d "$path"; then
		EchoNewstepTimer "$MSG_MKDIR_CREATE_MSG." "$sleep_txt"
		echo

		# On crée une variable nommée "lineno". Elle enregistre la valeur de la variable globale "$LINENO", qui enregistre le numéro de la ligne dans laquelle est est appelée dans un script.
		local lineno=$LINENO; mkdir -v "$path"

        # On vérifie si le dossier a bien été créé en vérifiant le code de retour de la commande "mkdir" via la fonction "HandleErrors"
		HandleErrors "$?" "$MSG_MKDIR_CREATE_FAIL." "$MSG_MKDIR_CREATE_FAIL_ADV" "$lineno"
        echo

        EchoSuccessTimer "$MSG_MKDIR_CREATE_SUCC." "$sleep_txt"
        echo

		# On change les droits du dossier nouvellement créé par le script
		# Comme ce dernier est exécuté en mode super-utilisateur, tout dossier ou fichier créé appartient à l'utilisateur root.
		# Pour attribuer récursivement la propriété du dossier à l'utilisateur normal, on appelle la commande chown avec pour arguments :
		#		- Le nom de l'utilisateur à qui donner les droits
		#		- Le chemin du dossier cible

		EchoNewstepTimer "$MSG_MKDIR_CHMOD." "$sleep_txt"
		echo

		chown -Rv "${ARG_USERNAME}" "$path"

        # On vérifie que les droits du dossier nouvellement créé ont bien été changés, en vérifiant le code de retour de la commande "chown".
		if test "$?" -eq "0"; then
			echo

			EchoSuccessTimer "$MSG_MKDIR_CHMOD_SUCC." "$sleep_txt"
			echo

			EchoSuccessTimer "$MSG_MKDIR_PROCESSING_END_SUCC." "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo

			return
		else
            echo

			EchoErrorTimer "$MSG_MKDIR_CHMOD_FAIL_1." "$sleep_txt"
			EchoErrorTimer "$MSG_MKDIR_CHMOD_FAIL_2 :" "$sleep_txt"
			echo "	chown -R ${ARG_USERNAME} $path"
			echo

			EchoErrorTimer "$MSG_MKDIR_PROCESSING_END_FAIL." "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"		# On dessine la deuxième et dernière ligne du bloc.
			sleep "$sleep_blk"
			echo

			return
        fi
    fi
}

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### DÉFINITION DES FONCTIONS DE TRAITEMENT DE FICHIERS
# Fonction de création de fichiers ET d'attribution des droits de lecture et d'écriture à l'utilisateur.
# LORS DE SON APPEL, LA SORTIE DE CETTE FONCTION DOIT ÊTRE REDIRIGÉE SOIT VERS LE TERMINAL ET LE FICHIER DE LOGS, SOIT VERS LE FICHIER DE LOGS UNIQUEMENT.
function Makefile()
{
	#***** Paramètres *****
	local parent=$1		# Emplacement depuis la racine du dossier parent du fichier à traiter.
	local name=$2		# Nom du fichier à traiter (dans son dossier parent).
	local sleep_blk=$3	# Temps de pause du script avant et après la création d'un bloc d'informations sur le traitement du fichier.
	local sleep_txt=$4	# Temps d'affichage des messages de passage à une nouvelle sous-étape, d'échec ou de succès.

	#***** Autres variables *****
	local path="$parent/$name"	# Chemin du fichier à traiter.
	local block_char="'"		# Caractère composant la ligne.

	#***** Code *****
	# On commence par dessiner la première ligne du bloc.
	sleep "$sleep_blk"
	DrawLine "$COL_RESET" "$block_char"

	EchoNewstepTimer "$MSG_MKFILE_PROCESSING_BEGIN." "$sleep_txt"
	echo

    # Si le fichier à créer existe déjà ET qu'il n'est pas vide.
	if test -f "$path" && test -s "$path"; then
		EchoNewstepTimer "$MSG_MKFILE_NONEMPTY_1." "$sleep_txt"
		EchoNewstepTimer "$MSG_MKFILE_NONEMPTY_2." "$sleep_txt"
		echo

		true > "$path"

		# On vérifie que le contenu du fichier cible a bien été supprimé en testant le code de retour de la commande "true".
		if test "$?" -eq "0"; then
			EchoSuccessTimer "$MSG_MKFILE_NONEMPTY_SUCC." "$sleep_txt"
			echo

			EchoSuccessTimer "$MSG_MKFILE_PROCESSING_END_SUCC." "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo
        else
            EchoErrorTimer "$MSG_MKFILE_NONEMPTY_FAIL." "$sleep_txt"
			echo

			EchoErrorTimer "$MSG_MKFILE_PROCESSING_END_FAIL." "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo
		fi

		return

	# Sinon, si le fichier à créer existe déjà ET qu'il est vide.
	elif test -f "$path" && test ! -s "$path"; then
		EchoSuccessTimer "Le fichier $(DechoS "$name") existe déjà dans le dossier $(DechoS "$parent/")." "$sleep_txt"
		echo

		EchoSuccessTimer "$MSG_MKFILE_PROCESSING_END_SUCC." "$sleep_txt"
		DrawLine "$COL_RESET" "$block_char"

		return

	# Sinon, si le fichier à traiter n'existe pas, on le crée avec l'aide de la commande "touch".
	elif test ! -f "$path"; then
        EchoNewstepTimer "Création du fichier $(DechoN "$name") dans le dossier $(DechoN "$parent/")." "$sleep_txt"
		echo

		local lineno=$LINENO; touch "$path"

		# On vérifie que le fichier a bien été créé en vérifiant le code de retour de la commande "touch" via la fonction "HandleErrors".
        HandleErrors "$?" "LE FICHIER $(DechoE "$name") N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER $(DechoE "$parent/")" "Essayez de le créer manuellement." "$lineno"
        EchoSuccessTimer "Le fichier $(DechoS "$name") a été créé avec succès dans le dossier $(DechoS "$parent/")." "$sleep_txt"
        echo

		# On change les droits du fichier créé par le script.
		# Comme il est exécuté en mode super-utilisateur, tout dossier ou fichier créé appartient à l'utilisateur root.
		# Pour attribuer les droits de lecture, d'écriture et d'exécution (rwx) à l'utilisateur normal, on appelle
		# la commande chown avec pour arguments :
		#		- Le nom de l'utilisateur à qui donner les droits.
		#		- Le chemin du dossier cible.

		EchoNewstepTimer "Changement des droits du nouveau fichier $(DechoN "$path") de $(DechoN "$USER") en $(DechoN "$ARG_USERNAME")." "$sleep_txt"
		echo

		chown -v "${ARG_USERNAME}" "$path"

		# On vérifie que les droits du fichier nouvellement créé ont bien été changés, en vérifiant le code de retour de la commande "chown".
		if test "$?" -eq "0"; then
			echo

			EchoSuccessTimer "Les droits du fichier $(DechoS "$parent") ont été changés avec succès." "$sleep_txt"
			echo

			EchoSuccessTimer "$MSG_MKFILE_PROCESSING_END_SUCC." "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo

			return
		else
			echo

			EchoErrorTimer "Impossible de changer les droits du fichier $(DechoE "$path")." "$sleep_txt"
			EchoErrorTimer "Pour changer les droits du fichier $(DechoE "$path")," "$sleep_txt"
			EchoErrorTimer "utilisez la commande :" "$sleep_txt"
			echo "	chown ${ARG_USERNAME} $path"

			EchoErrorTimer "$MSG_MKFILE_PROCESSING_END_FAIL." "$sleep_txt"
			DrawLine "$COL_RESET" "$block_char"
			sleep "$sleep_blk"
			echo

			return
		fi
	fi
}

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### FONCTIONS DE TRAITEMENT D'ARCHIVES
# Décompression des archives des logiciels selon la méthode de compression utilisée (voir la fonction "SoftwareInstall").
function UncompressArchive()
{
    #***** Paramètres *****
    cmd=$1     # Commande de décompression propre à une méthode de compression.
    option=$2  # Option de la commande de décompression (dans le cas où l'appel d'une option n'est pas obligatoire, laisser une chaîne de caractères vide lors de l'appel de la fonction).
    path=$3    # Chemin vers l'archive à décompresser.
    name=$4    # Nom de l'archive.

    #***** Code *****
    # On exécute la commande de décompression en passant en arguments ses options et le chemin vers l'archive.
    "$cmd $option $path"

    HandleErrors "$?" "LA DÉCOMPRESSION DE L'ARCHIVE $(DechoE "$name") A ÉCHOUÉE"
    
    EchoSuccessTee "La décompression de l'archive $(DechoS "$name") s'est effectuée avec brio."
    Newline
}
