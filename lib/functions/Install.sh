#!/usr/bin/env bash

# shellcheck source="Echo.sh"
source Echo.sh || echo "Echo.sh : not found" && exit 1

# shellcheck source="Filesystem.sh"
source Filesystem.sh || echo "Filesystem.sh : not found" && exit 1

#### DÉFINITION DES FONCTIONS D'INSTALLATION
# Optimisation de la partie d'installation du script.
function OptimizeInstallation()
{
	#***** Parameters *****
	local parent=$1            # Dossier parent du fichier script à exécuter.
	local file=$2              # Nom du fichier script à exécuter.
	local cmd=$3               # Commande du gestionnaire de paquets à exécuter.
	local package_manager=$4   # Nom du gestionnaire de paquets utilisé.
	local package=$5           # Nom du paquet.
	local type=$6              # Type de commande envoyée (recherche sur le disque dur, dans la base de données ou installation de paquets).

	#***** Autres variables *****
	local parent="$DIR_INSTALL_PATH"
	local block_char="="

	#**** Code *****
	# On vérifie si tous les arguments sont bien appelés (IMPORTANT POUR UNE INSTALLATION SANS PROBLÈMES)
	if test "$#" -ne 6; then
		HandleErrors "1" "UN OU PLUSIEURS ARGUMENTS MANQUENT À LA FONCTION $(DechoE "OptimizeInstallation")" \
			"Vérifiez quels arguments manquent à la fonction." "$LINENO_INST"
	fi

	# On vérifie si la valeur de l'argument correspond à un des trois types attendus.
	case "$type" in
		"HD")
			EchoNewstepTee "Vérification de la présence du paquet $(DechoN "$package") sur votre système."
			Newline
			;;
		"DB")
			EchoNewstepTee "Vérification de la présence du paquet $(DechoN "$package") dans la base de données du gestionnaire $(DechoN "$package_manager")."
			Newline
			;;
		"INST")
			EchoNewstepTee "Installation du paquet $(DechoN "$package")."
			Newline
			;;
		*)
			HandleErrors "1" "LA VALEUR DE LA CHAÎNE DE CARACTÈRES PASSÉE EN CINQUIÈME ARGUMENT $(DechoE "$type") NE CORRESPOND À AUCUNE DES TROIS CHAÎNES ATTENDUES" \
				"Les trois chaînes de caractères attendues sont :
				 $(DechoE "HD") pour la recherche de paquets sur le système,
				 $(DechoE "DB") pour la recherche de paquets dans la base de données du gestionnaire de paquets,
				 $(DechoE "INST") pour l'installation de paquets.
				 " \
                "$LINENO_INST"

	esac

	# Exécution du script.
	local lineno=$LINENO; (cd "$parent" && ./"$file" "$FILE_LOG_PATH" "$cmd" && cat <<-EOF > "$GETVAL_PATH"
	"$?"
EOF
)

	GETVAL=$(cat "$GETVAL_PATH")

	case "$GETVAL" in
		"1")
			case "$type" in
				"HD")
					EchoNewstepTee "Le paquet $(DechoN "$package") n'est pas installé sur votre système."
					Newline

					EchoNewstepTee "Préparation de l'installation du paquet $(DechoN "$package")."
					Newline
					sleep 1
					;;
				"DB")
					EchoErrorTee "Le paquet $(DechoE "$package") n'a pas été trouvé dans la base de données du gestionnaire $(DechoE "$package_manager")."
					EchoErrorTee "Écriture du nom du paquet $(DechoE "$package") dans le fichier $(DechoE "$DIR_PACKAGES_PATH")."
					Newline

					# S'il n'existe pas, on crée le fichier contenant les noms des paquets introuvables dans la base de données.
					if test ! -f "$FILE_PACKAGES_DB_PATH"; then
						Makefile "$DIR_PACKAGES_PATH" "$FILE_PACKAGES_DB_NAME" "0" "0" >> "$FILE_LOG_PATH"
						echo "Gestionnaire de paquets : $package_manager" > "$FILE_PACKAGES_DB_PATH"
						echo "" >> "$FILE_PACKAGES_DB_PATH"
					fi

					echo "$package" >> "$FILE_PACKAGES_DB_PATH"

					EchoErrorTee "Abandon de l'installation du paquet $(DechoE "$package")."
					Newline

					Drawline "$COL_RESET" "$block_char" 2>&1 | tee -a "$FILE_LOG_PATH"
					Newline
					;;
				"INST")
					EchoErrorTee "Impossible d'installer le paquet $(DechoE "$package")."
					Newline

					# S'il n'existe pas, on crée le fichier contenant les noms des paquets dont l'installation a échouée
					if test ! -f "$FILE_PACKAGES_INST_PATH"; then
						Makefile "$DIR_PACKAGES_PATH" "$FILE_PACKAGES_INST_NAME" "0" "0" >> "$FILE_LOG_PATH"

						echo "Gestionnaire de paquets : $package_manager" > "$FILE_PACKAGES_INST_PATH"
						echo "" >> "$FILE_PACKAGES_INST_PATH"
					fi

					echo "$package" >> "$FILE_PACKAGES_INST_PATH"

					EchoErrorTee "Abandon de l'installation du paquet $(DechoE "$package")"
					Newline

					Drawline "$COL_RESET" "$block_char" 2>&1 | tee -a "$FILE_LOG_PATH"
					Newline
					;;
			esac
			;;
		"2")
			HandleErrors "2" "AUCUNE COMMANDE N'EST PASSÉE EN ARGUMENT LORS DE L'APPEL DE LA FONCTION $(DechoE "OptimizeInstallation")" \
				"Veuillez passer le chemin vers le fichier de logs en premier argument, PUIS la commande souhaitée (recherche (système ou base de données) ou installation) en deuxième argument." "$lineno"
			;;
		"3")
			HandleErrors "3" "AUCUNE COMMANDE N'EST PASSÉE EN DEUXIÈME ARGUMENT LORS DE L'APPEL DE LA FONCTION $(DechoE "OptimizeInstallation")" \
				"Veuillez passer le nom de la commande souhaitée (recherche (système ou base de données) ou installation) en deuxième argument." \
				"$lineno"
			;;
        "4")
            HandleErrors "4" "TROP D'ARGUMENTS ONT ÉTÉ PASSÉS LORS DE L'APPEL DU SCRIPT" \
                "Pour rappel, le script ne prend que deux arguments : le chemin du fichier de logs et la commande à exécuter." \
                "$lineno"
            ;;
		"5")
			HandleErrors "5" "UNE ERREUR INCONNUE S'EST PRODUITE PENDANT L'EXÉCUTION DU SCRIPT" \
				"" \
				"$lineno"
			;;
		"0")
			case "$type" in
				"HD")
					EchoSuccessTee "Le paquet $(DechoS "$package") est déjà installé sur votre système."
					Newline

					Drawline "$COL_RESET" "$block_char" 2>&1 | tee -a "$FILE_LOG_PATH"
					Newline
					;;
				"DB")
					EchoSuccessTee "Le paquet $(DechoS "$package") a été trouvé dans la base de données du gestionnaire $(DechoS "$package_manager")."
					;;
				"INST")
					EchoSuccessTee "Le paquet $(DechoS "$package") a bien été installé."
					;;
			esac
			;;
# 		*)
# 			HandleErrors "1" "UNE ERREUR S'EST PRODUITE LORS DE LA LECTURE DE LA SORTIE DE LA COMMANDE $(DechoE "$cmd")" \
# 				"Vérifiez ce qui a causé cette erreur en commentant la condition contenant le message d'erreur suivant : $(DechoE "UNE ERREUR S'EST PRODUITE LORS DE LA LECTURE DE LA SORTIE DE LA COMMANDE \$(DechoE \"\$cmd\")"), à la ligne $(DechoE "$LINENO")." \
# 				"$lineno"
# 			;;
	esac
}

# Installation d'un paquet selon le gestionnaire de paquets, ainsi que sa commande de recherche de paquets dans le système de l'utilisateur,
# sa commande de recherche de paquets dans sa base de données, ainsi que sa commande d'installation de paquets.
function PackInstall()
{
	#***** Paramètres | Parameters *****
	local package_manager=$1	# Nom du gestionnaire de paquets.
	local package=$2			# Nom du paquet à installer.

	#***** Autres | Other variables *****
	local block_char="="	# Caractère composant la ligne.
	LINENO_INST=$LINENO

	#***** Code *****
	DrawLine "$COL_RESET" "$block_char" 2>&1 | tee -a "$FILE_LOG_PATH"
	sleep 1
	Newline

	EchoNewstepTee "Traitement du paquet $(DechoN "$package")."
	Newline

	# On définit les commandes de recherche et d'installation de paquets selon le nom du gestionnaire de paquets passé en premier argument.
	case ${package_manager} in
		"$PACK_MAIN_PACKAGE_MANAGER")
			case ${PACK_MAIN_PACKAGE_MANAGER} in
				"apt")
                    # Pour enregistrer la commande souhaitée dans un fichier, il faut utiliser un here document. Le tiret après les chevrons "<<" sert à effacer tous les espaces avant le premier caractère d'une ligne du fichier, étant donné qu'il y a plusieurs tabulations servant à indenter le script. Il ne faut pas mettre de guillemets uniques (') avant et après le nom du délimiteur (EOF) pour prendre en compte la valeur de la variable "$package", enregistrant le nom du paquet à installer.
					cat <<-EOF > "$FILE_INSTALL_HD_PATH"
					apt-cache policy "$package" | grep "$package"
					EOF

					cat <<-EOF > "$FILE_INSTALL_DB_PATH"
					apt-cache show "$package" | grep "$package"
					EOF

					cat <<-EOF > "$FILE_INSTALL_INST_PATH"
					apt-get -y install "$package"
					EOF
					;;
			#	"dnf")
			#		search_pack_hdrive_command=""

			#		search_pack_db_command=""

			#		cat <<-EOF > "$FILE_INSTALL_INST_PATH"
            #       dnf -y install "$package"
            #       EOF
			#		;;
			#	"pacman")
			#		cat <<-EOF > "$FILE_INSTALL_HD_PATH"
			#       pacman -Q "$package"
			#       EOF

			#		search_pack_db_command=""
			#		cat <<-EOF > "$FILE_INSTALL_INST_PATH"
			#       pacman --noconfirm -S "$package"
            #       EOF
			esac
			;;
		"snap")
			cat <<-EOF > "$FILE_INSTALL_HD_PATH" snap list "$package"
			EOF
			# search_pack_db_command=""
			cat <<-EOF > "$FILE_INSTALL_INST_PATH" snap install "$*"
			EOF
			;;
		"")
			HandleErrors "1" "AUCUN NOM DE GESTIONNAIRE DE PAQUETS N'A ÉTÉ PASSÉ EN ARGUMENT" \
				"Passez un gestionnaire de paquets supporté en argument (pour rappel, les gestionnaires de paquets supportés sont $(DechoE "APT"), $(DechoE "DNF") et $(DechoE "Pacman"). Si vous avez rajouté un gestionnaire de paquets, n'oubliez pas d'inclure ses commandes de recherche et d'installation de paquets)." \
				"$LINENO, avec le paquet $(DechoE "$package")"
				;;
			*)
			EchoErrorTee "Le nom du gestionnaire de paquets passé en premier argument $(DechoE "$package_manager") ne correspond à aucun gestionnaire de paquets présent sur votre système."
			EchoErrorTee "Vérifiez que le nom du gestionnaire de paquets passé en arguments ne contienne pas de majuscules et corresponde EXACTEMENT au nom de la commande."
			Newline

			HandleErrors "1" "LE NOM DU GESTIONNAIRE DE PAQUETS PASSÉ EN PREMIER ARGUMENT ($(DechoE "$package_manager")) NE CORRESPOND À AUCUN GESTIONNAIRE DE PAQUETS PRÉSENT SUR VOTRE SYSTÈME" \
				"Désolé, ce gestionnaire de paquets n'est pas supporté ¯\_(ツ)_/¯" \
				"$LINENO, avec le paquet $(DechoE "$package")"
			;;
	esac

	## RECHERCHE DU PAQUET SUR LE SYSTÈME DE L'UTILISATEUR
	var_file_content=$(cat "$FILE_INSTALL_HD_PATH")	# On récupère la commande stockée dans le fichier contenant la commande de recherche sur le système, puis on assigne son contenu en tant que valeur d'une variable à passer en argument lors de l'appel de la fonction "OptimizeInstallation".
	var_type="HD"	# On enregistre la valeur du troisième paramètre de la fonction "OptimizeInstallation" pour mieux le récupérer lors du test.

	# On appelle en premier lieu la commande de recherche de paquets installés sur le système de l'utilisateur, puis on quitte la fonction "PackInstall" si le paquet recherché est déjà installé sur le disque dur de l'utilisateur.
	OptimizeInstallation "$DIR_INSTALL_PATH" "$FILE_SCRIPT_NAME" "$var_file_content" "$package_manager" "$package" "$var_type"

	if test "$var_type" = "HD" && test "$GETVAL" -eq "1"; then
		return
	fi

	## RECHERCHE DU PAQUET DANS LA BASE DE DONNÉES DU GESTIONNAIRE DE PAQUETS DE L'UTILISATEUR
	var_file_content=$(cat "$FILE_INSTALL_DB_PATH")	# On récupère la commande stockée dans le fichier contenant la commande de recherche dans la base de données, puis on assigne son contenu en tant que valeur d'une variable à passer en argument lors de l'appel de la fonction "OptimizeInstallation".
	var_type="DB"

	# On appelle en deuxième lieu la commande de recherche de paquets dans la base de données du gestionnaire de paquets de l'utilisateur, puis on quitte la fonction "PackInstall" si le paquet recherché est absent de la base de données.
	OptimizeInstallation "$DIR_INSTALL_PATH" "$FILE_SCRIPT_NAME" "$var_file_content" "$package_manager" "$package" "$var_type"

	if test "$var_type" = "DB" && test "$GETVAL" -eq "1"; then
		return
	fi

	## INSTALLATION DU PAQUET SUR LE SYSTÈME DE L'UTILISATEUR
	var_file_content=$(cat "$FILE_INSTALL_INST_PATH")	# On récupère la commande stockée dans le fichier contenant la commande d'installation de paquets, puis on assigne son contenu en tant que valeur d'une variable à passer en argument lors de l'appel de la fonction "OptimizeInstallation".
	var_type="INST"

	# On appelle en troisième et dernier lieu la commande d'installation de paquets, puis on quitte la fonction "PackInstall" si le paquet n'a pas pu être installé.
	OptimizeInstallation "$DIR_INSTALL_PATH" "$FILE_SCRIPT_NAME" "$var_file_content" "$package_manager" "$package" "$var_type"

	if test "$var_type" = "INST" && test "$GETVAL" -eq "1"; then
		return
	fi

	return
}

# Redirection des sorties des commandes (pas d'installation) vers le fichier de logs
function CommandLogs()
{
    #***** Variables *****
    local cmd="$*"

    #***** Code *****
    $cmd 2>&1 | tee -a "$FILE_LOG_PATH"
}


# Installation de logiciels absents de la base de données de tous les gestionnaires de paquets.
function SoftwareInstall()
{
	#***** Paramètres *****
	local web_link=$1		# Adresse de téléchargement du logiciel (téléchargement via la commande "wget"), SANS LE NOM DE L'ARCHIVE.
	local archive=$2		# Nom de l'archive contenant les fichiers du logiciel.
	local name=$3			# Nom du logiciel.
	local comment=$4		# Affichage d'un commentaire descriptif du logiciel lorsque l'utilisateur passe le curseur de sa souris pas dessus le fichier ".desktop".
	local exe=$5			# Adresse du fichier exécutable du logiciel.
	local icon=$6			# Emplacement du fichier image de l'icône du logiciel.
	local type=$7			# Détermine si le fichier ".desktop" pointe vers une application, un lien ou un dossier.
	local category=$8		# Catégorie(s) du logiciel (jeu, développement, bureautique, etc...).

	#***** Autres variables *****
	# Dossiers
 	local inst_path="$DIR_SOFTWARE_PATH/$name"	   # Dossier d'installation du logiciel.
	local shortcut_dir="$DIR_HOMEDIR/Bureau/Linux-reinstall.links"	   # Dossier de stockage des raccourcis vers les fichiers exécutables des logiciels téléchargés.

	# Fichiers
	local software_dl_link="$web_link/$archive"		# Lien de téléchargement de l'archive.

	#***** Code *****
	EchoNewstepTee "Téléchargement du logiciel $(DechoN "$name")."

	# S'il n'existe pas, on crée le dossier dédié aux logiciels dans le dossier d'installation de logiciels.
	if test ! -d "$inst_path"; then
        Makedir "$DIR_SOFTWARE_NAME" "$name" "2" "1" 2>&1 | tee -a "$FILE_LOG_PATH"
    fi

	if test wget -v "$software_dl_link" -O "$inst_path" >> "$FILE_LOG_PATH"; then
		EchoSuccessTee "L'archive du logiciel $(DechoS "$name") a été téléchargé avec succès."
		Newline

	else
		EchoErrorTee "Échec du téléchargement de l'archive du logiciel $(DechoE "$name")."
		Newline

		return
	fi

	# On décompresse l'archive téléchargée selon le format de compression tout en redirigeant toutes les sorties vers le terminal et le fichier de logs.
	EchoNewstepTee "Décompression de l'archive $(DechoN "$archive")."
	{
		case "$archive" in
			"*.zip")
				UncompressArchive "unzip" "" "$inst_path/$archive" "$archive"
				;;
			"*.7z")
				UncompressArchive "7z" "e" "$inst_path/$archive" "$archive"
				;;
			"*.rar")
				UncompressArchive "unrar" "e" "$inst_path/$archive" "$archive"
				;;
			"*.tar.gz")
				UncompressArchive "tar" "-zxvf" "$inst_path/$archive" "$archive"
				;;
			"*.tar.bz2")
				UncompressArchive "tar" "-jxvf" "$inst_path/$archive" "$archive"
				;;
			*)
				EchoErrorTee "Le format de fichier de l'archive $(DechoE "$archive") n'est pas supporté."
				Newline

				return
				;;
		esac
	} 2>&1 | tee -a "$FILE_LOG_PATH"

	# On vérifie que le dossier contenant les fichiers desktop (servant de raccourci) existe, pour ne pas encombrer le bureau de l'utilisateur.
	# S'il n'existe pas, alors le script le crée
	if test ! -d "$shortcut_dir"; then
		EchoNewstepTee "Création d'un dossier contenant les raccourcis vers les logiciels téléchargés via la commande wget (pour ne pas encombrer votre bureau)."
		Newline

		Makedir "$DIR_HOMEDIR/Bureau/" "Linux-reinstall.link" "2" "1" 2>&1 | tee -a "$FILE_LOG_PATH"

		EchoSuccessTee "Le dossier  vous pourrez déplacer les raccourcis sur votre bureau sans avoir à les modifier."
	fi

	EchoNewstepTee "Création d'un lien symbolique pointant vers le fichier exécutable du logiciel $(DechoN "$name")."
	ln -s "$exe" "$name"

	if test "$?" == "0"; then
		EchoSuccessTee "Le lien symbolique a été créé avec succès."
		Newline
	else
        EchoErrorTee "Impossible de créer un lien symbolique pointant vers $(DechoE "$exe")."
        Newline
	fi

	EchoNewstepTee "Création du raccourci vers le fichier exécutable du logiciel $(DechoN "$name")."
	Newline

	cat <<-EOF > "$shortcut_dir/$name.desktop"
	[Desktop Entry]
	Name="$name"
	Comment="$comment"
	Exec="$inst_path/$exe"
	Icon="$icon"
	Type="$type"
	Categories="$category";
	EOF

	EchoSuccessTee "Le fichier $(DechoS "$name.desktop") a été créé avec succès dans le dossier $(DechoS "$shortcut_dir")."
	Newline

	EchoNewstepTee "Suppression de l'archive $(DechoN "$archive")."
	Newline

	# On vérifie que l'archive a bien été supprimée.
	if test rm -f "$inst_path/$archive"; then
        EchoSuccessTee "L'archive $(DechoS "$archive") a été correctement supprimée."
		Newline
    else
		EchoErrorTee "La suppression de l'archive $(DechoE "$archive") a échouée."
		Newline
	fi
}
