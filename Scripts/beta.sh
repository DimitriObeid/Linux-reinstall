#!/usr/bin/env bash

# Script de réinstallation minimal pour les cours de BTS SIO en version Bêta
# Version Bêta 2.0

# Pour débugguer ce script en cas de besoin, tapez la commande :
# sudo <shell utilisé> -x <nom du fichier>
# Exemple :
# sudo /bin/bash -x reinstall.sh
# Ou encore
# sudo bash -x reinstall.sh

# Ou débugguez le en utilisant l'excellent utilitaire Shell Check :
#	En ligne -> https://www.shellcheck.net/
#	En ligne de commandes -> shellcheck beta.sh
#		--> Commande d'installation de l'utilitaire : sudo $gestionnaire de paquets $option_d'installation shellcheck



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



################### DÉCLARATION DES VARIABLES ET AFFECTATION DE LEURS VALEURS ###################

## ARGUMENTS
# Arguments à placer après la commande d'exécution du script pour qu'il s'exécute
SCRIPT_USERNAME=$1		# Premier argument : Le nom du compte de l'utilisateur


## CHRONOMÈTRE

# Met en pause le script pendant une demi-seconde pour mieux voir l'arrivée d'une nouvelle étape majeure.
# Pour changer une durée de chronométrage, changez la valeur de la commande "sleep" voulue.
# Pour désactiver cette fonctionnalité, mettez la valeur de la commande "sleep" à 0.
# ATTENTION À NE PAS SUPPRIMER LES ANTISLASHS, SINON LA VALEUR DE LA COMMANDE "sleep" NE SERA PAS INTERPRÉTÉE EN TANT QU'ARGUMENT, MAIS COMME UNE NOUVELLE COMMANDE
SCRIPT_SLEEP_0_5=sleep\ .5		# Met le script en pause pendant 0,5 seconde. Exemple d'utilisation : temps d'affichage d'un texte de sous-étape
SCRIPT_SLEEP_1_5=sleep\ 1.5		# Met le script en pause pendant 1,5 seconde. Exemple d'utilisation : temps d'affichage d'un header uniquement, avant l'affichage du reste de l'étape lors d'un changement d'étape
SCRIPT_SLEEP_1=sleep\ 1			# Met le script en pause pendant une seconde. Exemple d'utilisation : temps d'affichage du nom du paquet avant l'affichage du reste de l'étape lors de l'installation d'un nouveau paquet


## COULEURS

# Encodage des couleurs pour mieux lire les étapes de l'exécution du script
SCRIPT_C_BLUE=$(tput setaf 4)		# Bleu foncé	--> Couleurs diverses
SCRIPT_C_CYAN=$(tput setaf 6)		# Bleu cyan		--> Couleur des headers
SCRIPT_C_ERR=$(tput setaf 196)   	# Rouge clair	--> Couleur d'affichage des messages d'erreur de la sous-étape
SCRIPT_C_RESET=$(tput sgr0)        	# Restauration de la couleur originelle d'affichage de texte selon la configuration du profil du terminal
SCRIPT_C_STEP=$(tput setaf 226) 	# Jaune clair	--> Couleur d'affichage des messages de passage à la prochaine sous-étapes
SCRIPT_C_SUCC=$(tput setaf 82)     	# Vert clair	--> Couleur d'affichage des messages de succès la sous-étape


# DATE
# Variable permettant l'écriture de la date et de l'heure actuelle dans le nom d'un fichier
SCRIPT_DATE=$(date +"%Y-%m-%d %Hh-%Mm-%Ss")


## DOSSIERS ET FICHIERS
# Définition du dossier personnel de l'utilisateur
SCRIPT_HOMEDIR="/home/${SCRIPT_USERNAME}"	# Dossier personnel de l'utilisateur

# Définition du dossier temporaire et de son chemin
SCRIPT_TMPDIR="Linux-reinstall.tmp.d"				# Nom du dossier temporaire
SCRIPT_TMPPARENT="/tmp"								# Dossier parent du dossier temporaire
SCRIPT_TMPPATH="$SCRIPT_TMPPARENT/$SCRIPT_TMPDIR"	# Chemin complet du dossier temporaire

# Définition du dossier d'installation de logiciels indisponibles via les gestionnaires de paquets
SOFTWARE_DIR="Logiciels.Linux-reinstall.d"

# Définition du nom et du chemin du fichier de logs
SCRIPT_LOG="Linux-reinstall $SCRIPT_DATE.log"		# Nom du fichier de logs
SCRIPT_LOGPATH="$PWD/$SCRIPT_LOG"					# Chemin du fichier de logs depuis la racine, dans le dossier actuel


## TEXTE
# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret,
# changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes
# (une ligne de chaque caractère).
SCRIPT_HEADER_LINE_CHAR="-"		# Caractère à afficher en boucle pour créer une ligne des headers de changement d'étapes
SCRIPT_COLS=$(tput cols)		# Affichage du nombre de colonnes sur le terminal
SCRIPT_TAB=">>>>"				# Nombre de chevrons à afficher avant les chaînes de caractères jaunes, vertes et rouges

# Affichage de chevrons suivant l'encodage de la couleur d'une chaîne de caractères
SCRIPT_J_TAB="$SCRIPT_C_STEP$SCRIPT_TAB"				# Encodage de la couleur en jaune et affichage de 4 chevrons
SCRIPT_R_TAB="$SCRIPT_C_ERR$SCRIPT_TAB$SCRIPT_TAB"		# Encodage de la couleur en rouge et affichage de 4 * 2 chevrons
SCRIPT_V_TAB="$SCRIPT_C_SUCC$SCRIPT_TAB$SCRIPT_TAB"		# Encodage de la couleur en vert et affichage de 4 * 2 chevrons


## VERSION
# Version actuelle du script
SCRIPT_VERSION="2.0"



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #



############################################# DÉFINITIONS DES FONCTIONS #############################################


#### DÉFINITION DES FONCTIONS INDÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####


## DÉFINITION DES FONCTIONS D'AFFICHAGE DE TEXTE
# Fonction servant à colorer d'une autre colueur une partie du texte de changement de sous-étape (jeu de mots entre "déco(ration)" et "echo")
function DechoN() { d_nws_string=$1; echo "$SCRIPT_C_CYAN$d_nws_string$SCRIPT_C_STEP"; }

# Appel de la fonction "EchoNewstepNoLog" en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoNewstep() { e_nws_string=$1; EchoNewstepNoLog "$e_nws_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP_0_5; }

# Affichage d'un message dont le temps de pause du script peut être choisi en argument
function EchoNewstepCustomTimer() { e_nws_ct_string=$1; e_nws_ct_t=$2; EchoNewstepNoLog "$SCRIPT_J_TAB $e_nws_ct_string $SCRIPT_C_RESET"; sleep "$e_nws_ct_t"; }

# Affichage d'un message de passage à une nouvelle sous-étape en jaune avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function EchoNewstepNoLog() { e_nws_nl_string=$1; echo "$SCRIPT_J_TAB $e_nws_nl_string $SCRIPT_C_RESET"; }


# Fonction servant à colorer d'une autre colueur une partie du message d'échec de sous-étape (jeu de mots entre "déco(ration)" et "echo")
function DechoE() { d_err_string=$1; echo "$SCRIPT_C_CYAN$d_err_string$SCRIPT_C_ERR"; }

# Appel de la fonction "EchoErrorNoLog" en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoError() { e_err_string=$1; EchoErrorNoLog "$e_err_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP_0_5; }

# Affichage d'un message d'échec de sous-étape dont le temps de pause du script peut être choisi en argument
function EchoErrorCustomTimer() { e_err_ct_string=$1; e_err_ct_t=$2; EchoErrorNoLog "$e_err_ct_string"; sleep "$e_err_ct_t"; }

# Affichage d'un message en rouge avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function EchoErrorNoLog() { e_err_nl_string=$1; echo "$SCRIPT_R_TAB $e_err_nl_string $SCRIPT_C_RESET"; }


# Fonction servant à colorer d'une autre colueur une partie du texte de réussite de sous-étape (jeu de mots entre "déco(ration)" et "echo")
function DechoS() { d_succ_string=$1; echo "$SCRIPT_C_CYAN$d_succ_string$SCRIPT_C_SUCC"; }

# Appel de la fonction "EchoSuccessNoLog" en redirigeant les sorties standard et les sorties d'erreur vers le fichier de logs
function EchoSuccess() { e_succ_string=$1; EchoSuccessNoLog "$e_succ_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"; $SCRIPT_SLEEP_0_5; }

# Affichage d'un message de succès de sous-étape dont le temps de pause du script peut être choisi en argument
function EchoSuccessCustomTimer() { e_succ_ct_string=$1; e_succ_ct_t=$2; EchoSuccessNoLog "$SCRIPT_V_TAB $e_succ_ct_string $SCRIPT_C_RESET"; sleep "$e_succ_ct_t"; }

# Affichage d'un message en vert avec des chevrons, sans avoir à encoder la couleur au début et la fin de la chaîne de caractères
function EchoSuccessNoLog() { e_succ_nl_string=$1; echo "$SCRIPT_V_TAB $e_succ_nl_string $SCRIPT_C_RESET"; }


# Fonction de saut de ligne pour la zone de texte du terminal et pour le fichier de logs
function Newline() { echo "" | tee -a "$SCRIPT_LOGPATH"; }

# Fonction de saut de ligne pour le fichier de logs uniquement (utiliser la fonction "Newline" en redirigeant sa sortie vers le fichier de logs provoque un saut de deux lignes au lieu d'une)
function NewlineLog() { echo "" >> "$SCRIPT_LOGPATH"; }

# Fonction de saut de ligne pour la zone de texte du terminal uniquement (aucune sortie n'est redirigée vers le fichier de logs)
function NewlineNoLog() { echo ""; }


## DÉFINITION DES FONCTIONS DE CRÉATION DES HEADERS
# Fonction de création et d'affichage des lignes des headers
function DrawHeaderLine()
{
	line_color=$1	# Deuxième paramètre servant à définir la couleur souhaitée du caractère lors de l'appel de la fonction
	line_char=$2	# Premier paramètre servant à définir le caractère souhaité lors de l'appel de la fonction

	# Définition de la couleur du caractère souhaité sur toute la ligne avant l'affichage du tout premier caractère
	# Si la chaîne de caractère de la variable $line_color (qui contient l'encodage de la couleur du texte) est vide,
	# alors on écrit l'encodage de la couleur dans le terminal, qui affiche la couleur, et non son encodage en texte.
	# L'encodage de la couleur peut être écrit via la commande "tput cols $encodage_de_la_couleur"
	if test "$line_color" != ""; then
		echo -ne "$line_color"
	fi

	# Affichage du caractère souhaité sur toute la ligne. Pour cela, en utilisant une boucle "for", on commence à la lire à partir
	# de la première colonne (1), puis, on parcourt toute la ligne jusqu'à la fin de la zone de texte du terminal. À chaque appel
	# de la commande "echo", un caractère est affiché et coloré selon l'encodage défini et écrit ci-dessus.
	for i in $(eval echo "{1..$SCRIPT_COLS}"); do
		echo -n "$line_char"
	done

	# Définition (ici, réintialisation) de la couleur des caractères suivant le dernier caractère de la ligne du header
	# en utilisant le même bout de code que la première condition, pour écrire l'encodage de la couleur de base du terminal
	# (il est recommandé d'appeller la commande "tput cols sgr0" pour réinitialiser la couleur selon les options du profil
	# du terminal). Comme tout encodage de couleur, le texte brut ne sera pas affiché sur le terminal.
	# En pratique, La couleur des caractères suivants est déjà encodée quand ils sont appelés via une des fonctions d'affichage.
	# Cette réinitialisation de la couleur du texte n'est qu'une mini-sécurité permettant d'éviter d'avoir la couleur de l'invite de
	# commandes encodée avec la couleur des headers si l'exécution du script est interrompue de force avec la combinaison "CTRL + C"
	# ou mise en pause avec la combinaison "CTRL + Z", par exemple.
	if test "$line_color" != ""; then
        echo -ne "$SCRIPT_C_RESET"
	fi

	return
}

# Fonction de création de base d'un header (Couleur et caractère de ligne, couleur et chaîne de caractères)
function HeaderBase()
{
	# Couleur de ligne
	header_base_line_color=$1

	# Définition de la couleur de la ligne du caractère souhaité.
	# Ce code produit le même résultat que la première condition de la fonction "DrawHeaderLine", mais il a été
	# réécrit ici car aucune partie d'une fonction ne peut être utilisée individuellement depuis une autre fonction
	if test "$header_base_line_color" == ""; then
        # Définition de la couleur de la ligne.
        # Ne pas ajouter de '$' avant le nom de la variable "header_color", sinon la couleur souhaitée ne s'affiche pas
		echo -ne "$header_base_line_color"
	fi

	# Ligne
	header_base_line_char=$2		# Caractère composant chaque colonne d'une ligne d'un header

	# Chaîne de caractères
	header_base_string_color=$3		# Définition de la couleur de la chaîne de caractères
	header_base_string=$4			# Chaîne de caractères affichée dans chaque header

	# Décommenter la ligne ci dessous pour activer un chronomètre avant l'affichage du header
	# $SCRIPT_SLEEP_1_5
	DrawHeaderLine "$header_base_line_color" "$header_base_line_char"
	# Affichage une autre couleur pour le texte
	echo "$header_base_string_color""##>" "$header_base_string" "$SCRIPT_C_RESET"
	DrawHeaderLine "$header_base_line_color" "$header_base_line_char"
	# Double saut de ligne, car l'option '-n' de la commande "echo" empêche un saut de ligne (un affichage via la commande "echo" (sans l'option '-n')
	# affiche toujours un saut de ligne à la fin)

	# Ne pas appeler la fonction "Newline" ici, car cette dernière est automatiquement réappelée lors de la redirection de la fonction "HeaderBase"
	# vers le terminal et le fichier de logs, puis une troisième fois dans les fonctions "ScriptHeader" et "HeaderInstall" (dans le cas où on appelle
	# la fonction "Newline" ici, puis une seule et unique fois dans une des deux fonctions suivantes)

	return
}

# Fonction d'affichage des headers lors d'un changement d'étape
function ScriptHeader()
{
	Newline

	script_header_string=$1	# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	HeaderBase "$SCRIPT_C_CYAN" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_CYAN" "$script_header_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"

	Newline
	Newline

	$SCRIPT_SLEEP_1_5

	return
}

# Fonction d'affichage de headers lors du passage à une nouvelle catégorie de paquets lors de l'installation de ces derniers
function HeaderInstall()
{
	Newline
	Newline

	header_install_string=$1	# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	HeaderBase "$SCRIPT_C_STEP" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_SUCC" "$header_install_string"  2>&1 | tee -a "$SCRIPT_LOGPATH"
	Newline
	Newline

	$SCRIPT_SLEEP_1_5

	return
}

# Fonction de gestion d'erreurs fatales (impossibles à corriger)
function HandleErrors()
{
	error_string=$1		# Chaîne de caractères à passer en argument lors de l'appel de la fonction

	HeaderBase "$SCRIPT_C_ERR" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_ERR" "ERREUR FATALE : $error_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	Newline

	$SCRIPT_SLEEP_1_5

	EchoErrorNoLog "Une erreur fatale s'est produite :" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	EchoErrorNoLog "$error_string" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	Newline

	EchoErrorNoLog "Arrêt de l'installation" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	Newline

	# Si le fichier de logs se trouve toujours dans le dossier actuel (si le script a été exécuté depuis un autre dossier)
	if test ! -f "$SCRIPT_HOMEDIR/$SCRIPT_LOG"; then
		mv -v "$SCRIPT_LOG" "$SCRIPT_HOMEDIR" >> "$SCRIPT_LOGPATH"
	fi

	EchoError "En cas de bug, veuillez m'envoyer le fichier de logs situé à l'adresse suivante : $(DechoE "$SCRIPT_LOG")"
	Newline

	exit 1
}


## DÉFINITION DES FONCTIONS DE CRÉATION DE FICHIERS ET DE DOSSIERS
# Fonction de création de dossiers ET d'attribution récursive des droits de lecture et d'écriture à l'utilisateur
function Makedir()
{
	parentdir=$1					# Emplacement de création du dossier depuis la racine (dossier parent)
	dirname=$2						# Nom du dossier à créer dans son dossier parent
	makedir_sleep=$3				# Temps d'affichage des messages

	dirpath="$parentdir/$dirname"	# Chemin complet du dossier


	if test ! -d "$dirpath"; then
		EchoNewstepCustomTimer "Création du dossier $(DechoN "$dirname") dans le dossier $(DechoN "$parentdir")" "$makedir_sleep"
		mkdir -v "$dirpath" >> "$SCRIPT_LOGPATH" \
			|| HandleErrors "LE DOSSIER $(DechoE "$dirname") N'A PAS PU ÊTRE CRÉÉ DANS LE DOSSIER PARENT $(DechoE "$parentdir")" \
			&& EchoSuccessCustomTimer "Le dossier $(DechoS "$dirname") a été créé avec succès dans le dossier $(DechoS "$parentdir")" "$makedir_sleep"
		NewlineNoLog	# On ne redirige pas les sauts de ligne vers le fichier de logs, pour éviter de les afficher en double en cas d'appel de la fonction avec redirections

		# On change les droits du dossier créé par le script
		# Comme il est exécuté en mode super-utilisateur, le dossier créé appartient totalement au super-utilisateur.
		# Pour attribuer les droits de lecture, d'écriture et d'exécution (rwx) à l'utilisateur normal, on appelle
		# la commande chown avec pour arguments :
		#		- Le nom de l'utilisateur à qui donner les droits
		#		- Le chemin du dossier cible
		#		- Ici, la variable contenant la redirection
		chown -Rv "$SCRIPT_USERNAME" "$dirpath" >> "$SCRIPT_LOGPATH" \
			|| {
				EchoErrorCustomTimer "Impossible de changer les droits du dossier $(DechoE "$dirpath")" "$makedir_sleep"
				EchoErrorCustomTimer "Pour changer les droits du dossier $(DechoE "$dirpath") de manière récursive," "$makedir_sleep"
				EchoErrorCustomTimer "utilisez la commande :" "$makedir_sleep"
				echo "	chown -R $SCRIPT_USERNAME $dirpath"

				return
			} \
			&& EchoSuccessCustomTimer "Les droits du dossier $(DechoS "$dirname") ont été changés avec succès" "$makedir_sleep"
			NewlineNoLog

		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent ET que ce dossier contient AU MOINS un fichier ou dossier
	elif test -d "$dirpath" && test "$(ls -A "$dirpath")"; then
		EchoNewstepCustomTimer "Un dossier non-vide portant exactement le même nom se trouve déjà dans le dossier cible $(DechoN "$parentdir")" "$makedir_sleep"
		EchoNewstepCustomTimer "Suppression du contenu du dossier $(DechoN "$dirpath")" "$makedir_sleep"

		# ATTENTION À NE PAS MODIFIER LA COMMANDE SUIVANTE", À MOINS DE SAVOIR EXACTEMENT CE QUE VOUS FAITES !!!
		# Pour plus d'informations sur cette commande complète --> https://github.com/koalaman/shellcheck/wiki/SC2115
		rm -rfv "${dirpath/:?}/"* \
			||
			{
				EchoErrorCustomTimer "Impossible de supprimer le contenu du dossier $(DechoE "$dirpath")" "$makedir_sleep";
				EchoErrorCustomTimer "Le contenu de tout fichier du dossier $(DechoE "$dirpath") portant le même nom qu'un des fichiers téléchargés sera écrasé" "$makedir_sleep"
				NewlineNoLog

				return
			} \
			&&
			{
				EchoSuccessCustomTimer "Suppression du contenu du dossier $(DechoS "$dirpath") effectuée avec succès" "$makedir_sleep"
				NewlineNoLog
			}

		return

	# Sinon, si le dossier à créer existe déjà dans son dossier parent ET que ce dossier est vide
	elif test -d "$dirpath"; then
		EchoSuccessCustomTimer "Le dossier $(DechoS "$dirpath") existe déjà" "$makedir_sleep"

		return
	fi
}

# Fonction de création de fichiers ET d'attribution des droits de lecture et d'écriture à l'utilisateur
function Makefile()
{
	file_parentdir=$1	# Dossier parent du fichier à créer
	filename=$2			# Nom du fichier à créer
	makefile_sleep=$3	# Temps d'affichage des messages

	filepath="$file_parentdir/$filename"

	# Si le fichier à créer n'existe pas
	if test ! -s "$filepath"; then
		touch "$file_parentdir/$filename" >> "$SCRIPT_LOGPATH" \
			|| HandleErrors "LE FICHIER $(DechoE "$filename") n'a pas pu être créé dans le dossier $(DechoE "$file_parentdir")" \
			&& EchoSuccessCustomTimer "Le fichier $(DechoS "$filename") a été créé avec succès dans le dossier $(DechoS "$file_parentdir")" "$makefile_sleep"
		NewlineNoLog

		chown -v "$SCRIPT_USERNAME" "$filepath" >> "$SCRIPT_LOGPATH" \
			|| {
				EchoErrorCustomTimer "Impossible de changer les droits du fichier $(DechoE "$filepath")" "$makefile_sleep"
				EchoErrorCustomTimer "Pour changer les droits du fichier $(DechoE "$filepath")," "$makefile_sleep"
				EchoErrorCustomTimer "utilisez la commande :" "$makefile_sleep"
				echo "	chown $SCRIPT_USERNAME $filepath"

				return
			} \
			&& EchoSuccessCustomTimer "Les droits du fichier $(DechoS "$file_parentdir") ont été changés avec succès" "$makefile_sleep"
			NewlineNoLog

		return

	# Sinon, si le fichier à créer existe déjà ET qu'il est vide
	elif test -f "$filepath" && test -s "$filepath"; then
		EchoSuccessCustomTimer "Le fichier $(DechoS "$filename") existe déjà dans le dossier $(DechoS "$file_parentdir")" "$makefile_sleep"

		return

	# Sinon, si le fichier à créer existe déjà ET qu'il n'est pas vide
	elif test -f "$filepath" && test ! -s "$filepath"; then
		true > "$filepath" \
			|| EchoErrorCustomTimer "Le contenu du fichier $(DechoE "$filepath") n'a pas été écrasé" "$makefile_sleep" \
			&& EchoSuccessCustomTimer "Le contenu du fichier $(DechoS "$filepath") a été écrasé avec succès" "$makefile_sleep"
		Newline

		return
	fi
}


## DÉFINITION DES FONCTIONS D'INSTALLATION
# Vérification de l'existence du paquet dans la base de données du gestionnaire de paquets.
#     Mettre ce commentaire dans la doc, puis le supprimer du script --> S'il n'existe pas, le nom est envoyé dans un fichier texte pour indiquer à l'utilisateur quels sont les paquets à télécharger sur Internet pour récupérer et compiler leur code source s'il le souhaite
function PackManagerCheck()
{
	search_command=$*

	EchoNewstep "Vérification de la présence du paquet $(DechoN "$package_name") dans la base de données du gestionnaire $(DechoN "$SCRIPT_MAIN_PACK_MANAGER")"
	if test "$($search_command "$package_name")"; then
		EchoSuccess "Le paquet $(DechoS "$package_name") a été trouvé dans la base de données du gestionnaire $(DechoS "$SCRIPT_MAIN_PACK_MANAGER")"
		Newline

		return
	else
		EchoError "Le paquet $(DechoE "$package_name") n'a pas été trouvé dans la base de données du gestionnaire $(DechoE "$SCRIPT_MAIN_PACK_MANAGER")"
		Newline

		if test ! -d "$package_not_found_dir"; then
			mkdir -v "$package_not_found_dir" >> "$SCRIPT_TMPPATH"
		fi

		touch "$package_not_found_dir/$package_name not found"

		return
	fi
}

# Adaptation de la commande de vérification de présence de paquets selon le gestionnaire de paquets
function PackManagerList()
{
	list_command="$*"

	# Cette ligne sert à m'assurer que le code fonctionne
	EchoNewstep "Vérification de la présence du paquet $(DechoN "$package_name")" # >> "$SCRIPT_LOGPATH"
	"$($list_command)" "$package_name" 2>&1 | grep -o "$package_name" >> "$SCRIPT_LOGPATH" \
		|| {
				is_installed=0
				PackManagerInstall "$*"
			} \
		&& {
			is_installed=1
			EchoSuccess "Le paquet $(DechoS "$package_name") est déjà installé"
			Newline

			Newline
		}

	return
}

# Adaptation de la commande d'installation selon le gestionnaire de paquets
function PackManagerInstall()
{
	install_command=$*

	if test "$is_installed" == "0"; then
		EchoNewstep "Installation du paquet $(DechoN "$package_name")"
		$SCRIPT_SLEEP_1

		# On appelle la commande d'installation du gestionnaire de paquets,
		# puis on assigne la valeur de la variable "is_installed" à 1 si l'opération est un succès (&&)
		"$($install_command)" "$package_name" 2>&1 | tee -a "$SCRIPT_LOGPATH" \
			|| {
					EchoError "Le paquet $(DechoE "$package_name") est introuvable dans les dépôts de votre gestionnaire de paquets"
					Newline

					Newline

					return
				} \
			&& is_installed=1
		Newline

		$SCRIPT_SLEEP_1

		# On vérifie que le paquet à installer a été correctement installé
		EchoNewstep "Vérification de l'installation du paquet $(DechoN "$package_name")" # >> "$SCRIPT_LOGPATH"
		if test "$is_installed" = 1; then
			EchoSuccess "Le paquet $(DechoS "$package_name") a été installé avec succès"
			is_installed=0
			Newline

			Newline

		else
			EchoError "L'installation du paquet $(DechoE "$package_name") a échoué"
			Newline

			Newline
		fi
	fi

	return
}

# Téléchargement des paquets directement depuis les dépôts officiels de la distribution utilisée selon la commande d'installation de paquets, puis installation des paquets
function PackInstall()
{
	# Si vous souhaitez mettre tous les paquets en tant que multiples arguments (tableau d'arguments), remplacez le "$1"
	# ci-dessous par "$@" et enlevez les doubles guillemets "" entourant chaque variable "$package_name" de la fonction
	package_name=$1		# Argument de la fonction "PackInstall" contenant le nom du paquet à installer
	package_not_found_dir="$SCRIPT_TMPPATH/Packages not found"
	is_installed=0		# Variable servant à enregistrer la présence d'un paquet

	# Installation du paquet souhaité selon la commande d'installation du gestionnaire de paquets de la distribution de l'utilisateur
	# Pour chaque gestionnaire de paquets, on appelle la fonction "PackManagerCheck" pour vérifier la présence du paquet dans la base de données du gestionnaire,
	# puis on appelle la fonction "PackManagerList" pour vérifier si le paquet désiré est déjà installé sur le disque dur de l'utilisateur.
	# Enfin, on appelle la fonction "PackManagerInstall" pour installer le paquet tout en forçant le choix de l'utilisateur
	case $SCRIPT_MAIN_PACK_MANAGER in
		"APT")
			PackManagerCheck apt-cache show
			if test -f "$package_not_found_dir/$package_name not found"; then
				EchoError "Passage à un autre paquet"
				return
			fi
			PackManagerList apt list --installed
			# PackManagerInstall apt -y install
			;;
		"DNF")
			PackManagerCheck
			if test -f "$package_not_found_dir/$package_name not found"; then
				EchoError "Passage à un autre paquet"
				return
			fi
			PackManagerList
			PackManagerInstall dnf -y install
			;;
		"Emerge")
			PackManagerCheck
			if test -f "$package_not_found_dir/$package_name not found"; then
				EchoError "Passage à un autre paquet"
				return
			fi
			PackManagerList
			PackManagerInstall emerge
			;;
		"Pacman")
			PackManagerCheck
			if test -f "$package_not_found_dir/$package_name not found"; then
				EchoError "Passage à un autre paquet"
				return
			fi
	    	PackManagerList pacman -Q
			# PackManagerInstall pacman --noconfirm -S
			;;
		"Zypper")
			PackManagerCheck
			if test -f "$package_not_found_dir/$package_name not found"; then
				EchoError "Passage à un autre paquet"
				return
			fi
			PackManagerList
			PackManagerInstall zypper -y install
			;;
	esac

	return
}

# Installation de paquets via le gestionnaire de paquets Snap
function SnapInstall()
{
    PackManagerCheck
	if test -f "$package_not_found_dir/$package_name not found"; then
		EchoError "Passage à un autre paquet"
		return
	fi
	PackManagerList
	PackManagerInstall snap install "$@"	# Ce tableau d'arguments sert à utiliser les options de téléchargement passées en argument

	return
}

# Installation de logiciels absents de la base de données de tous les gestionnaires de paquets
function SoftwareInstall()
{
	# Paramètres
	software_web_link=$1		# Adresse de téléchargement du logiciel (téléchargement via la commande "wget"), SANS LE NOM DE L'ARCHIVE
	software_archive=$2			# Nom de l'archive contenant les fichiers du logiciel
	software_name=$3			# Nom du logiciel
	software_comment=$4			# Affichage d'un commentaire descriptif du logiciel lorsque l'utilisateur passe le curseur de sa souris pas dessus le fichier ".desktop"
	software_exec=$5			# Adresse du fichier exécutable du logiciel
	software_icon=$6			# Emplacement du fichier image de l'icône du logiciel
	software_type=$7			# Détermine si le fichier ".desktop" pointe vers une application, un lien ou un dossier
	software_category=$8		# Catégorie(s) du logiciel (jeu, développement, bureautique, etc...)

	# Dossiers
	software_inst_dir="$SOFTWARE_DIR/$software_name"						# Dossier d'installation du logiciel
	software_shortcut_dir="$SCRIPT_HOMEDIR/Bureau/Linux-reinstall.links"	# Dossier de stockage des raccourcis vers les fichiers exécutables des logiciels téléchargés

	# Téléchargement
	software_dl_link="$software_web_link/$software_archive"

	EchoNewstep "Téléchargement de $SCRIPT_C_CYAN$software_name"

	# On crée un dossier dédié au logiciel dans le dossier d'installation de logiciels
	Makedir "$SOFTWARE_DIR" "$software_name" "1" 2>&1 | tee -a "$SCRIPT_LOGPATH"
	wget -v "$software_dl_link" -O "$software_inst_dir" >> "$SCRIPT_LOGPATH" \
		|| EchoError "Échec du téléchargement du logiciel $software_name" \
		&& EchoSuccess "Le logiciel $software_name a été téléchargé avec succès"
	Newline

	# On décompresse l'archive téléchargée selon le format de comporession
	EchoNewstep "Décompression de l'archive $(DechoN "$software_archive")"
	{
		case "$software_archive" in
			"*.zip")
				unzip "$SOFTWARE_DIR/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.7z")
				7z e "$SOFTWARE_DIR/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.rar")
				unrar e "$SOFTWARE_DIR/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.tar.gz")
				tar -zxvf "$SOFTWARE_DIR/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
			"*.tar.bz2")
				tar -jxvf "$SOFTWARE_DIR/$software_name/$software_archive" || { EchoError "La décompression de l'archive $(DechoE "$software_archive") a échouée"; return; } && EchoSuccess "La décompression de l'archive $(DechoS "$software_archive") s'est faite avec brio"
				;;
		esac
	} 2>&1 | tee -a "$SCRIPT_LOGPATH"

	# On vérifie que le dossier contenant les fichiers desktop (servant de raccourci) existe, pour ne pas encombrer le bureau de l'utilisateur
	if test ! -d "$SCRIPT_USERNAME/Bureau/Linux-reinstall.links"; then
		EchoNewstep "Création d'un dossier contenant les raccourcis vers les logiciels téléchargés via la commande wget (pour ne pas encombrer votre bureau)"
		Newline

		Makedir "$SCRIPT_USERNAME/Bureau/" "Linux-reinstall.link" "1" 2>&1 | tee -a "$SCRIPT_LOGPATH"
		EchoSuccess "Vous pourrez déplacer les raccourcis sur votre bureau sans avoir à les modifier"
	fi

	EchoNewstep "Création d'un lien symbolique pointant vers le fichier exécutable du logiciel $(DechoN "$software_name")"
	ln -s "$software_exec" "$software_name" \
		|| EchoError "Impossible de créer un lien symbolique pointant vers $(DechoE "$software_exec")" \
		&& EchoSuccess "Le lien symbolique a été créé avec succès"
	Newline

	EchoNewstep "Création du raccourci vers le fichier exécutable du logiciel $(DechoN "$software_name")"
	echo"[Desktop Entry]
		Name=$software_name
		Comment=$software_comment
		Exec=$software_inst_dir/$software_exec
		Icon=$software_icon
		Type=$software_type
		Categories=$software_category;" > "$software_shortcut_dir/$software_name.desktop"
	EchoSuccess "Le fichier $(DechoS "$software_name.desktop") a été créé avec succès dans le dossier $(DechoS "$software_shortcut_dir")"
	Newline

	EchoNewstep "Suppression de l'archive $(DechoN "$software_archive")"
	rm -f "$software_inst_dir/$software_archive" \
		|| EchoError "La suppression de l'archive $(DechoE "$software_archive") a échouée" \
		&& EchoSuccess "L'archive $(DechoS "$software_archive") a été correctement supprimée"
	Newline
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

#### DÉFINITION DES FONCTIONS DÉPENDANTES DE L'AVANCEMENT DU SCRIPT ####



## DÉFINITION DES FONCTIONS D'INITIALISATION
# Création du fichier de logs pour répertorier chaque sortie de commande (sortie standard STDOUT ou sortie d'erreurs STDERR)
function CreateLogFile()
{
	# Si le fichier de logs n'existe pas, le script le crée via la fonction "Makefile"
	Makefile "$PWD" "$SCRIPT_LOG" "0" > /dev/null
	NewlineLog	# On appelle la fonction "NewlineLog" pour rediriger le saut de ligne vers le fichier de logs, car les sauts de ligne de la fonction Makefile ne sont pas redirigés vers le fichier de logs

	# On évite d'appeler les fonctions d'affichage propre "EchoSuccess" ou "EchoError" (sans le "NoLog") pour éviter
	# d'écrire deux fois le même texte, vu que ces fonctions appellent chacune une commande écrivant dans le fichier de logs
	EchoSuccessNoLog "Fichier de logs créé avec succès" >> "$SCRIPT_LOGPATH"
	NewlineLog

	# Tout ce qui se trouve entre ces accolades est envoyé dans le fichier de logs
	{
		HeaderBase "$SCRIPT_C_BLUE" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_BLUE" "RÉCUPÉRATION DES INFORMATIONS SUR LE SYSTÈME DE L'UTILISATEUR"

		Newline

		# Récupération des informations sur le système d'exploitation de l'utilisateur contenues dans le fichier "/etc/os-release"
		EchoNewstepNoLog "Informations sur le système d'exploitation de l'utilisateur $(DechoN "$SCRIPT_USERNAME") :"
		cat "/etc/os-release"
		NewlineLog

		EchoSuccessNoLog "Fin de la récupération d'informations sur le système d'exploitation"
	} >> "$SCRIPT_LOGPATH"

	# Au moment de la création du fichier de logs, la variable "$SCRIPT_LOGPATH" correspond au dossier actuel de l'utilisateur

	return
}

# Création du dossier temporaire où sont stockés les fichiers et dossiers temporaires
function Mktmpdir()
{
	NewlineLog
	{
		HeaderBase "$SCRIPT_C_BLUE" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_BLUE" \
			"CRÉATION DU DOSSIER TEMPORAIRE $SCRIPT_C_JAUNE\"$SCRIPT_TMPDIR$SCRIPT_C_BLUE\" DANS LE DOSSIER $SCRIPT_C_JAUNE\"$SCRIPT_TMPPARENT\"$SCRIPT_C_RESET"

		Newline

		Makedir "$SCRIPT_TMPPARENT" "$SCRIPT_TMPDIR" "0"		# Dossier principal
		Makedir "$SCRIPT_TMPPATH" "Logs" "0"					# Dossier d'enregistrement des fichiers de logs
	} >> "$SCRIPT_LOGPATH"
}

# Détection de l'exécution du script en mode super-utilisateur (root)
function ScriptInit()
{
	# On appelle la fonction de création du fichier de logs
	CreateLogFile

	# Puis la fonction de création du dossier temporaire
	Mktmpdir

	Makefile "/home/dimob/Bureau" "Linux-reinstall.test" "0" 2>&1 | tee -a "$SCRIPT_LOGPATH"

	# On déplace le fichier de logs vers le dossier temporaire tout en vérifiant s'il ne s'y trouve pas déjà
	if test ! -f "$SCRIPT_LOG"; then
		mv -v "$SCRIPT_LOG" "$SCRIPT_TMPPATH/Logs" >> "$SCRIPT_TMPPATH/Logs/$SCRIPT_LOG" \
			|| HandleErrors "IMPOSSIBLE DE DÉPLACER LE FICHIER DE LOGS VERS LE DOSSIER $(DechoE "$SCRIPT_HOMEDIR")" \
			&& SCRIPT_LOGPATH="$SCRIPT_TMPPATH/Logs/$SCRIPT_LOG"	# Une fois que le fichier de logs est déplacé dans le dossier temporaire, on redéfinit le chemin du fichier de logs de la variable "$SCRIPT_LOGPATH"
	fi

	# On écrit dans le fichier de logs que l'on passe à la première étape "visible dans le terminal", à savoir l'étape d'initialisation du script
	{
		HeaderBase "$SCRIPT_C_BLUE" "$SCRIPT_HEADER_LINE_CHAR" "$SCRIPT_C_BLUE" \
			"VÉRIFICATION DES INFORMATIONS PASSÉES EN ARGUMENT" >> "$SCRIPT_LOGPATH"

		Newline
	} >> "$SCRIPT_LOGPATH"

	# Si le script n'est pas lancé en mode super-utilisateur
	if test "$EUID" -ne 0; then
    	EchoError "Ce script doit être exécuté en tant que super-utilisateur (root)"
    	EchoError "Exécutez ce script en plaçant la commande $(DechoE "sudo") devant votre commande :"
		Newline

    	# Le paramètre "$0" ci-dessous est le nom du fichier shell en question avec le "./" placé devant (argument 0).
    	# Si ce fichier est exécuté en dehors de son dossier, le chemin vers le script depuis le dossier actuel sera affiché.
    	echo "	sudo $0 votre_nom_d'utilisateur"
		Newline

		EchoError "Ou connectez vous directement en tant que super-utilisateur"
		EchoError "Et tapez cette commande :"
		echo "	$0 votre_nom_d'utilisateur"

		HandleErrors "SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"

	# Sinon, si le script est lancé en mode super-utilisateur, on vérifie que la commande d'exécution du script soit accompagnée d'un argument
	else
		# Si aucun argument n'est entré
		if test -z "${SCRIPT_USERNAME}"; then
			EchoError "Veuillez lancer le script en plaçant votre nom d'utilisateur après la commande d'exécution du script :"
			echo "	sudo $0 votre_nom_d'utilisateur"

			HandleErrors "VOUS N'AVEZ PAS PASSÉ VOTRE NOM D'UTILISATEUR EN ARGUMENT"

		# Sinon, si l'argument attendu est entré
		else
            # Si la valeur de l'argument ne correspond pas au nom de l'utilisateur
			if test "$(pwd | cut -d '/' -f-3 | cut -d '/' -f3-)" != "${SCRIPT_USERNAME}"; then
				EchoError "Veuillez entrer correctement votre nom d'utilisateur"
				Newline

				EchoError "Si vous avez exécuté le script en dehors de votre dossier personnel ou d'un de ses sous-dossiers,"
				EchoError "retournez-y pour réexécuter le script sans problèmes."

				HandleErrors "LA CHAÎNE DE CARACTÈRES PASSÉE EN PREMIER ARGUMENT NE CORRESPOND PAS À VOTRE NOM D'UTILISATEUR"

			# Sinon, si la valeur de l'argument correspond au nom de l'utilisateur
			else
				# On demande à l'utilisateur de bien confirmer son nom, au cas où son compte utilisateur cohabite avec d'autres comptes
				EchoNewstep "Nom d'utilisateur entré :$SCRIPT_C_RESET $SCRIPT_USERNAME"
				EchoNewstep "Est-ce correct ? (oui/non)"
				Newline

				# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
				# Les deux virgules suivant directement le "rep_ScriptInit" entre les accolades signifient que les mêmes réponses avec des
				# majuscules sont permises, peu importe où elles se situent dans la chaîne de caractères (pas de sensibilité à la casse).
				function ReadScriptInit()
				{
					read -r -p "Entrez votre réponse : " rep_script_init
					echo "$rep_script_init" >> "$SCRIPT_LOGPATH"
					Newline

					case ${rep_script_init,,} in
						"oui")
							EchoSuccess "Lancement du script"

							return
							;;
						"non")
							EchoError "Abandon"
							Newline

							exit 1
							;;
						*)
							EchoError "Réponses attendues : \"oui\" ou \"non\" (pas de sensibilité à la casse)"
							EchoError "Abandon"
							Newline

							exit 1
							;;
					esac
				}

				ReadScriptInit

				return
			fi
		fi
	fi
}

# Détection du gestionnaire de paquets de la distribution utilisée
function GetMainPackageManager()
{
	ScriptHeader "DÉTECTION DU GESTIONNAIRE DE PAQUETS DE VOTRE DISTRIBUTION"

	# On cherche la commande du gestionnaire de paquets de la distribution de l'utilisateur dans les chemins de la variable d'environnement "$PATH" en l'exécutant.
	# On redirige chaque sortie ("STDOUT (sortie standard) si la commande est trouvée" et "STDERR (sortie d'erreurs) si la commande n'est pas trouvée")
	# de la commande vers /dev/null (vers rien) pour ne pas exécuter la commande.

	# Pour en savoir plus sur les redirections en Shell UNIX, consultez ce lien -> https://www.tldp.org/LDP/abs/html/io-redirection.html
    command -v zypper &> /dev/null && SCRIPT_MAIN_PACK_MANAGER="Zypper"
    command -v pacman &> /dev/null && SCRIPT_MAIN_PACK_MANAGER="Pacman"
    command -v dnf &> /dev/null && SCRIPT_MAIN_PACK_MANAGER="DNF"
    command -v apt &> /dev/null && SCRIPT_MAIN_PACK_MANAGER="APT"
    command -v emerge &> /dev/null && SCRIPT_MAIN_PACK_MANAGER="Emerge"

	# Si, après la recherche de la commande, la chaîne de caractères contenue dans la variable $SCRIPT_MAIN_PACK_MANAGER est toujours nulle (aucune commande trouvée)
	if test "$SCRIPT_MAIN_PACK_MANAGER" = ""; then
		HandleErrors "AUCUN GESTIONNAIRE DE PAQUETS PRINCIPAL SUPPORTÉ TROUVÉ"
	else
		EchoSuccess "Gestionnaire de paquets principal trouvé : $(DechoS "$SCRIPT_MAIN_PACK_MANAGER")"
	fi
}

# Demande à l'utilisateur s'il souhaite vraiment lancer le script, puis connecte l'utilisateur en mode super-utilisateur
function LaunchScript()
{
	ScriptHeader "LANCEMENT DU SCRIPT"

	EchoNewstep "Assurez-vous d'avoir lu au moins le mode d'emploi $(DechoN "(Mode d'emploi.odt)") avant de lancer l'installation."
    EchoNewstep "Êtes-vous sûr de bien vouloir lancer l'installation ? (oui/non)"
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il est sûr de lancer le script
	function ReadLaunchScript()
	{
        # On demande à l'utilisateur d'entrer une réponse
		read -r -p "Entrez votre réponse : " rep_launch_script
		echo "$rep_launch_script" >> "$SCRIPT_LOGPATH"
		Newline

		# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
		case ${rep_launch_script,,} in
	        "oui")
				EchoSuccess "Vous avez confirmé vouloir exécuter ce script."
				EchoSuccess "C'est parti !!!"

				return
	            ;;
	        "non")
				EchoError "Le script ne sera pas exécuté"
	            EchoError "Abandon"
				Newline

				exit 1
	            ;;
            # Si une réponse différente de "oui" ou de "non" est rentrée
			*)
				Newline

				EchoNewstep "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")"
				Newline

				# On rappelle la fonction "ReadLaunchScript" en boucle tant qu"une réponse différente de "oui" ou de "non" est entrée
				ReadLaunchScript
				;;
	    esac
	}
	# Appel de la fonction "ReadLaunchScript", car même si la fonction est définie dans la fonction "LaunchScript", ses instructions ne sont pas lues automatiquement
	ReadLaunchScript
}


## DÉFINITION DES FONCTIONS DE CONNEXION À INTERNET ET DE MISES À JOUR
# Vérification de la connexion à Internet
function CheckInternetConnection()
{
	ScriptHeader "VÉRIFICATION DE LA CONNEXION À INTERNET"

	# Si l'ordinateur est connecté à Internet (pour le savoir, on ping le serveur DNS d'OpenDNS avec la commande ping 1.1.1.1)
	if ping -q -c 1 -W 1 opendns.com >> /dev/null; then
		EchoSuccess "Votre ordinateur est connecté à Internet"

		return
	# Sinon, si l'ordinateur n'est pas connecté à Internet
	else
		HandleErrors "AUCUNE CONNEXION À INTERNET"
	fi
}

# Mise à jour des paquets actuels selon le gestionnaire de paquets principal supporté
# (ÉTAPE IMPORTANTE SUR UNE INSTALLATION FRAÎCHE, NE PAS MODIFIER CE QUI SE TROUVE DANS LA CONDITION "CASE",
# SAUF EN CAS D'AJOUT D'UN NOUVEAU GESTIONNAIRE DE PAQUETS PRINCIPAL (PAS DE SNAP OU DE FLATPAK) !!!)
function DistUpgrade()
{
	ScriptHeader "MISE À JOUR DU SYSTÈME"

	EchoSuccess "Mise à jour du système en cours"
	Newline

	# On récupère la commande de mise à jour du gestionnaire de paquets principal enregistée dans la variable "$SCRIPT_MAIN_PACK_MANAGER",
	case "$SCRIPT_MAIN_PACK_MANAGER" in
		"APT")
			# APT renvoie souvent un message d'avertissement en cas d'utilisation de ce dernier dans un script :
			# 	--> "Warning : apt does not have a stable CLI interface. Use with caution in scripts."

			# Ce n'est pas un message problématique, mais il est assez ennuyeux, car il arrive à chaque appel de la commande
			# Pour y remédier, je renvoie ses sorties d'erreur vers un fichier temporaire, avant de renvoyer ces messages dans le fichier de logs
			# (il est impossible de rediriger directement une sortie d'erreur vers un fichier ET de rediriger tout de suite après la sortie standard
			# vers ce même fichier ET vers le terminal (apt-get -y update 2>> "$SCRIPT_LOGPATH" | tee -a "$SCRIPT_LOGPATH") <-- Code problématique)

			tmpapt="$SCRIPT_TMPPATH/Logs/aptEchoErrors.log"

			Makefile "$SCRIPT_TMPPATH/Logs" "aptEchoErrors.log" "1" 2>&1 | tee -a "$SCRIPT_LOGPATH"
			Newline

			apt -y update 2>> "$tmpapt" 1>> "$SCRIPT_LOGPATH" /dev/tty && apt -y upgrade 2>> "$tmpapt" 1>> "$SCRIPT_LOGPATH" /dev/tty
			;;
		"DNF")
			dnf -y update | tee -a "$SCRIPT_LOGPATH"
			;;
		"Emerge")
			emerge -u world 2>&1 | tee -a "$SCRIPT_LOGPATH"
			;;
		"Pacman")
			pacman --noconfirm -Syu | tee -a "$SCRIPT_LOGPATH"
			;;
		"Zypper")
			zypper -y update | tee -a "$SCRIPT_LOGPATH"
			;;
	esac

	Newline

	EchoSuccess "Mise à jour du système effectuée avec succès"

	return
}


## DÉFINITION DES FONCTIONS DE PARAMÉTRAGE
# Détection et installation de Sudo
function SetSudo()
{
	ScriptHeader "DÉTECTION DE SUDO ET AJOUT DE L'UTILISATEUR À LA LISTE DES SUDOERS"

	sudoers_old="/etc/sudoers - $SCRIPT_DATE.old"

    EchoNewstep "Détection de sudo $SCRIPT_C_RESET"

	# On effectue un test pour savoir si la commande "sudo" est installée sur le système de l'utilisateur
	command -v sudo > /dev/null 2>&1 \
		|| {
				EchoNewstep "La commande $(DechoN "sudo") n'est pas installé sur votre système"
				PackInstall sudo
			} \
		&& EchoSuccess "La commande $(DechoS "sudo") est déjà installée sur votre système";
	Newline

	EchoNewstep "Le script va tenter de télécharger un fichier $(DechoN "sudoers") déjà configuré"
	EchoNewstep "depuis le dossier des fichiers ressources de mon dépôt Git : "
	echo ">>>> https://github.com/DimitriObeid/Linux-reinstall/tree/Beta/Ressources"
	Newline

	EchoNewstep "Souhaitez vous le télécharger PUIS l'installer maintenant dans le dossier $(DechoN "/etc/") ? (oui/non)"
	Newline

	echo ">>>> REMARQUE : Si vous disposez déjà des droits de super-utilisateur, ce n'est pas la peine de le faire !"
	echo ">>>> Si vous avez déjà un fichier sudoers modifié, une sauvegarde du fichier actuel sera effectuée dans le même dossier,"
	echo "	tout en arborant sa date de sauvegarde dans son nom (par exemple :$SCRIPT_C_CYAN sudoers - $SCRIPT_DATE.old $SCRIPT_C_RESET)"
	Newline

	function ReadSetSudo()
	{
		read -r -p "Entrez votre réponse : " rep_set_sudo
		echo "$rep_set_sudo" >> "$SCRIPT_LOGPATH"

		# Cette condition case permer de tester les cas où l'utilisateur répond par "oui", "non" ou autre chose que "oui" ou "non".
		case ${rep_set_sudo,,} in
			"oui")
				Newline

				# Sauvegarde du fichier "/etc/sudoers" existant en "sudoers.old"
				EchoNewstep "Création d'une sauvegarde de votre fichier $(DechoN "sudoers") existant nommée $(DechoN "sudoers $SCRIPT_DATE.old")"
				cat "/etc/sudoers" > "$sudoers_old" \
					|| { EchoError "Impossible de créer une sauvegarde du fichier $(DechoE "sudoers")"; return; } \
					&& EchoSuccess "Le fichier de sauvegarde $(DechoS "$sudoers_old") a été créé avec succès"
				Newline

				# Téléchargement du fichier sudoers configuré
				EchoNewstep "Téléchargement du fichier sudoers depuis le dépôt Git $SCRIPT_REPO"
				sleep 1
				Newline

				wget https://raw.githubusercontent.com/DimitriObeid/Linux-reinstall/Beta/Ressources/sudoers -O "$SCRIPT_TMPPATH/sudoers" \
					|| { EchoError "Impossible de télécharger le nouveau fichier $(DechoE "sudoers")"; return; } \
					&& EchoSuccess "Le nouveau fichier $(DechoS "sudoers") téléchargé avec succès"
				Newline

				# Déplacement du fichier vers le dossier "/etc/"
				EchoNewstep "Déplacement du fichier \"sudoers\" vers \"/etc/\""
				mv "$SCRIPT_TMPPATH/sudoers" /etc/sudoers \
					|| { EchoError "Impossible de déplacer le fichier $(DechoE "sudoers") vers le dossier $(DechoE "/etc/")"; return; } \
					&& { EchoSuccess "Fichier $(DechoS "sudoers") déplacé avec succès vers le dossier $(DechoS "/etc/")"; }
				Newline

				# Ajout de l'utilisateur au groupe "sudo"
				EchoNewstep "Ajout de l'utilisateur $(DechoN "$SCRIPT_USERNAME") au groupe sudo"
				usermod -aG root "${SCRIPT_USERNAME}" 2>&1 | tee -a "$SCRIPT_LOGPATH" \
					|| { EchoError "Impossible d'ajouter l'utilisateur $(DechoE "$SCRIPT_USERNAME") à la liste des sudoers"; return; } \
					&& { EchoSuccess "L'utilisateur $(DechoS "$SCRIPT_USERNAME") a été ajouté au groupe sudo avec succès"; }

				return
				;;
			"non")
				Newline

				EchoSuccess "Le fichier $(DechoS "/etc/sudoers") ne sera pas modifié"

				return
				;;
			*)
				Newline

				EchoNewstep "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")"
				ReadSetSudo
				;;
		esac
	}
	ReadSetSudo

	return
}


# DÉFINITION DES FONCTIONS DE FIN D'INSTALLATION
# Suppression des paquets obsolètes
function Autoremove()
{
	ScriptHeader "AUTO-SUPPRESSION DES PAQUETS OBSOLÈTES"

	EchoNewstep "Souhaitez vous supprimer les paquets obsolètes ? (oui/non)"
	Newline

	# Fonction d'entrée de réponse sécurisée et optimisée demandant à l'utilisateur s'il souhaite supprimer les paquets obsolètes
	function ReadAutoremove()
	{
		read -rp "Entrez votre réponse : " rep_autoremove
		echo "$rep_autoremove" >> "$SCRIPT_LOGPATH"

		case ${rep_autoremove,,} in
			"oui")
				Newline

				EchoNewstep "Suppression des paquets"
				Newline

	    		case "$SCRIPT_MAIN_PACK_MANAGER" in
					"APT")
	            		apt -y autoremove
	            		;;
					"DNF")
		           		dnf -y autoremove
		           		;;
		       		"Emerge")
		           		emerge -uDN @world      # D'abord, vérifier qu'aucune tâche d'installation est active
		           		emerge --depclean -a    # Suppression des paquets obsolètes. Demande à l'utilisateur s'il souhaite supprimer ces paquets
		            	eix-test-obsolete       # Tester s'il reste des paquets obsolètes
		            	;;
	        		"Pacman")
	            		pacman --noconfirm -Qdt
	            		;;
					"Zypper")
		           		EchoNewstep "Le gestionnaire de paquets Zypper n'a pas de commande de suppression automatique de tous les paquets obsolètes"
						EchoNewstep "Référez vous à la documentation du script ou à celle de Zypper pour supprimer les paquets obsolètes"
		           		;;
				esac

				Newline

				EchoSuccess "Auto-suppression des paquets obsolètes effectuée avec succès"

				return
				;;
			"non")
				Newline

				EchoSuccess "Les paquets obsolètes ne seront pas supprimés"
				EchoSuccess "Si vous voulez supprimer les paquets obsolète plus tard, tapez la commande de suppression de paquets obsolètes adaptée à votre getionnaire de paquets"

				return
				;;
			*)
				Newline

				EchoNewstep "Veuillez répondre EXACTEMENT par $(DechoN "oui") ou par $(DechoN "non")"
				ReadAutoremove
				;;
		esac
	}
	ReadAutoremove

	return
}

# Fin de l'installation
function IsInstallationDone()
{
	ScriptHeader "INSTALLATION TERMINÉE"

	EchoNewstep "Souhaitez-vous supprimer le dossier temporaire $(DechoN "$SCRIPT_TMPPATH") ?"
	Newline

	read -rp "Entrez votre réponse : " rep_erase_tmp
	echo "$rep_erase_tmp" >> "$SCRIPT_LOGPATH"

	case ${rep_erase_tmp,,} in
		"oui")
			EchoNewstep "Suppression du dossier temporaire $SCRIPT_TMPPATH"
			rm -rfv "$SCRIPT_TMPPATH" >> "$SCRIPT_LOGPATH" \
				|| EchoError "Suppression du dossier temporaire impossible. Essayez de le supprimer à la main" \
				&& EchoSuccess "Le dossier temporaire \"$SCRIPT_TMPPATH\" a été supprimé avec succès"
				Newline
			;;
		*)
			EchoSuccess "Le dossier temporaire $(DechoS "$SCRIPT_TMPPATH") ne sera pas supprimé"
			;;
	esac

    EchoSuccess "Installation terminée. Votre distribution Linux est prête à l'emploi"
	Newline

	echo "$SCRIPT_C_CYAN"
	echo "Note :$SCRIPT_C_RESET Si vous avez constaté un bug ou tout autre problème lors de l'exécution du script,"
	echo "vous pouvez m'envoyer le fichier de logs situé dans votre dossier personnel."
	echo "Il porte le nom de $SCRIPT_C_CYAN$SCRIPT_LOG$SCRIPT_C_RESET"
	Newline

    # On tue le processus de connexion en mode super-utilisateur
	sudo -k

	return
}



# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #


################### DÉBUT DE L'EXÉCUTION DU SCRIPT ###################



## APPEL DES FONCTIONS D'INITIALISATION ET DE PRÉ-INSTALLATION
# Détection du mode super-administrateur (root) et de la présence de l'argument contenant le nom d'utilisateur
ScriptInit

# Affichage du header de bienvenue
ScriptHeader "BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX : VERSION $SCRIPT_VERSION !!!!!"
EchoSuccess "Début de l'installation"

# Détection du gestionnaire de paquets de la distribution utilisée
GetMainPackageManager

# Assurance que l'utilisateur soit sûr de lancer le script
LaunchScript

# Détection de la connexion à Internet
CheckInternetConnection

# Mise à jour des paquets actuels
DistUpgrade


## INSTALLATIONS PRIORITAIRES ET CONFIGURATIONS DE PRÉ-INSTALLATION
ScriptHeader "INSTALLATION DES COMMANDES IMPORTANTES POUR LES TÉLÉCHARGEMENTS"
PackInstall curl
PackInstall snapd
PackInstall wget

command -v curl snap wget >> "$SCRIPT_LOGPATH" \
	|| HandleErrors "AU MOINS UNE DES COMMANDES D'INSTALLATION MANQUE À L'APPEL" \
	&& EchoSuccess "Les commandes importantes d'installation ont été installées avec succès"

# Installation de sudo (pour les distributions livrées sans la commande) et configuration du fichier "sudoers" ("/etc/sudoers")
SetSudo


## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS DES GESTIONNAIRES DE PAQUETS
ScriptHeader "INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS OFFICIELS DE VOTRE DISTRIBUTION"

EchoSuccess "Vous pouvez désormais quitter votre ordinateur pour chercher un café"
EchoSuccess "La partie d'installation de vos programmes commence véritablement"
sleep 1

Newline
Newline

sleep 3

# Commandes
HeaderInstall "INSTALLATION DES COMMANDES PRATIQUES"
PackInstall htop
PackInstall neofetch
PackInstall tree

# Développement
HeaderInstall "INSTALLATION DES OUTILS DE DÉVELOPPEMENT"
SnapInstall atom --classic --stable		# Éditeur de code Atom
SnapInstall code --classic	--stable	# Éditeur de code Visual Studio Code
PackInstall emacs
PackInstall g++
PackInstall gcc
PackInstall git

PackInstall make
PackInstall umlet
PackInstall valgrind

# Logiciels de nettoyage de disque
HeaderInstall "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"
PackInstall k4dirstat

# Internet
HeaderInstall "INSTALLATION DES CLIENTS INTERNET"
SnapInstall discord --stable
PackInstall thunderbird

# LAMP
HeaderInstall "INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP"
PackInstall apache2
PackInstall php
PackInstall libapache2-mod-php
PackInstall mariadb-server		# Pour installer un serveur MariaDB (Si vous souhaitez un seveur MySQL, remplacez "mariadb-server" par "mysql-server"
PackInstall php-mysql
PackInstall php-curl
PackInstall php-gd
PackInstall php-intl
PackInstall php-json
PackInstall php-mbstring
PackInstall php-xml
PackInstall php-zip

# Librairies
HeaderInstall "INSTALLATION DES LIBRAIRIES"
PackInstall python3.7

# Réseau
HeaderInstall "INSTALLATION DES LOGICIELS RÉSEAU"
PackInstall wireshark

# Vidéo
HeaderInstall "INSTALLATION DES LOGICIELS VIDÉO"
PackInstall vlc

# Wine
HeaderInstall "INSTALLATION DE WINE"
PackInstall wine-stable

EchoSuccess "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS DEPUIS LES  GESTIONNAIRES DE PAQUETS !"


## INSTALLATION DES LOGICIELS ABSENTS DES GESTIONNAIRES DE PAQUETS
ScriptHeader "INSTALLATION DES LOGICIELS INDISPONIBLES DANS LES BASES DE DONNÉES DES GESTIONNAIRES DE PAQUETS"

EchoNewstep "Les logiciels téléchargés via la commande $(DechoN "wget") sont déplacés vers le nouveau dossier $(DechoN "$SOFTWARE_DIR"), localisé dans votre dossier personnel"
sleep 1
Newline

# Création du dossier "Logiciels.Linux-reinstall.d" dans le dossier personnel de l'utilisateur
EchoNewstep "Création du dossier d'installation des logiciels"
Makedir "$SCRIPT_HOMEDIR" "$SOFTWARE_DIR" "1"
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


## INSTALLATIONS SUPPLÉMENTAIRES
# Installation de paquets

## FIN D'INSTALLATION
# Suppression des paquets obsolètes
Autoremove

# Fin de l'installation
IsInstallationDone
