# Ancienne version : Bêta 0.1 (mercredi 18 novembre 2019)

* Changelogs :
    - Headers fonctionnels.
    - Détection du mode super-administrateur.
    - Détection de la connexion à Internet.
    - Mises à jour effectuées avec succès.
    - Installation des paquets depuis les dépôts officiels à résoudre.
    - Commande exacte de nettoyage des paquets obsolètes à trouver pour OpenSUSE.
    - Header de fin d'installation.


# Ancienne version : Bêta 0.2 (mercredi 18 novembre 2019)

* Changelogs :
    - Ajout des paquets à installer (les travaux sur la fonction d'installation des paquets sont toujours en cours).
    - Changement du mode d'affichage des erreurs de détection du gestionnaire de paquets et de l'exécution en tant qu'utilisateur normal : **$ERROR_OUTPUT_1 ---> Erreur s'étant produite $ERROR_OUTPUT_2**. Abandon de la fonction **handle_errors()**, restaurée à partir de la version 1.2.
    - Léger changement pour le header de bienvenue : **BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES LINUX !!!!!** ---> **BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX !!!!!**


# Ancienne version : Bêta 0.2.1 (mercredi 18 novembre 2019)

* Changelogs :
    - Amélioration visuelle de la partie d'installation des logiciels.
    - **autoremove()** : Correction du bug d'affichage de la chaîne de caractères de mauvaise réponse avant que la question ne soit posée pour la première fois.


# Ancienne version : 1.0 (vendredi 20 novembre 2019)

* Changelogs :
    - Mise en fonctionnement de la fonction d'installation des paquets venant des dépôts officiels.
    - Ajout de la fonction **snap_install()** pour télécharger des paquets depuis les dépôts de Snap.
    - Suppression de Zypper de la fonction **autoremove()**. Se référer à la documentation pour supprimer les paquets obsolètes sur OpenSUSE.
    - Légères modifications appliquées sur les commentaires.


# Ancienne version : 1.1 (jeudi 28 novembre 2019)

* Changelogs :
    - Placement des conditions **"case"** d'attente de réponse de l'utilisateur dans des sous-fonctions.
    - Correction de fautes d'orthographe mineures.
    - Optimisation de la fonction **script_header()**. Désormais, il n'y a plus besoin de remettre la couleur de base du texte du terminal juste après le texte du header, ni de rajouer un **echo ""** juste après, car le saut de ligne est automatique.


# Ancienne version : 1.2 (lundi 2 décembre 2019)

* Changelogs :
    - **get_dist_package_manager()** et **pack_install()** : Remplacement des commandes *__which__* par *__command -v__*, commande mieux recommandée que *__which__* pour vérifier qu'un paquet est déjà installé.
    - Correction d'un bug affichant l'étape d'autoremove sans interaction possible.
    - Toujours dans l'étape d'autoremove : La fonction **read_autoremove()** se répète désormais en cas de réponse inattendue.
    - Léger changement de la chaîne de caractères à afficher en cas de réponse inattendue dans les fonctions **read_launch_script()** et **read_autoremove()**. Passage de *__"Veuillez rentrer une valeur valide (oui/non)"__* à *__"Veuillez répondre EXACTEMENT par "oui" ou par "non" "__*
    - **detect_root()** : Changement de la demande d'autorisation de lancement de l'installation. Passage de *__"Assurez-vous d'avoir lu le script et sa documentation avant de l'exécuter."__* à *__"Assurez-vous d'avoir lu au moins le mode d'emploi avant de lancer l'installation."__*, le mode d'emploi étant de plus en plus complet pour les personnes qui ne souhaitent pas s'embêter à lire la description des fonctions et variables pour savoir ce qu'elles exécutent.


# Ancienne version : 1.3 (mardi 3 décembre 2019, ~14h)

* Changelogs :
    - Ajout d'une variable **$VOID** pour rendre le script un peu plus clair. Au lieu de taper *__echo ""__* à chaque fois que l'on souhaite sauter une ligne, on tape *__echo $VOID__*.
    - Débogage et renforcement de l'intégrité du script grâce au débogueur en ligne Shell Check --> https://www.shellcheck.net/.  Ajout de double guillemets aux appels de variables contenant des chaînes de caractères pour éviter la séparation des mots des chaînes de caractères et le globbing.
        - Fonctionnalité des systèmes UNIX permettant l'utilisation d'un wildcard **(ou joker, ou encore métacaractère)** pour rechercher plus rapidement un ou des fichiers selon ce que l'on cherche.  
        Par exemple, sous Windows, pour rechercher une partie d'un nom de fichier, on écrit **%fichier%**, tandis que sous tout système UNIX, on écrit **\*fichier***.  

    - **detect_root()** : Changement du nom de la variable **"rep"** par **"rep_launch"**.


# Ancienne version : 1.4 (mardi 3 décembre 2019, ~16h)

* Changelogs :
    - Remise en place de la fonction **handle_errors()**, une fonction de sortie d'erreurs abandonnée à la sortie de la version Bêta 0.2, à l'époque où je ne savais pas très bien comment manipuler les arguments en Shell. Plus besoin de préciser la couleur du texte de sortie d'erreurs et d'appeler deux chaînes de caractères avant et après le message d'erreur.
    - Modification des noms des variables déclarées dans chaque fonction pour éviter la confusion avec les noms de d'autres variables situées dans d'autres fonctions.
    - Précision plus importante sur l'argument **$0** de la fonction **detect_root()** en commentaire.
    - Pas d'oubli de rajouter les changements stables du ficher **beta.sh** dans les fichiers shell **sio.sh** et **personnel.sh**. Avec le développement rapide et facile des ajouts de cette version, c'est une des raisons pour lesquelles cette version est sortie près de deux heures après la version 1.3.


# Version actuelle : 1.4.1 (mardi 3 décembre 2019, ~22h)

* Changelogs :  
    - Correction d'un bug d'affichage des couleurs des headers apporté par la version 1.3. La couleur par défaut du terminal était utilisé à la place de la couleur souhaitée à cause d'un **$** placé où il ne fallait pas, ajouté accidentellement lors de l'ajout des double guillemets afin de renforcer l'intégrité du script **(ajout conseillé par le débogueur de Shell Check)**.


# Prochaine version : 1.5

* Changelogs :
    - Ajout du paquet **git** pour tous les scripts, surtout pour la version SIO, étant donné qu'il s'agit d'un des meilleurs amis d'un programmeur --> https://fr.wikipedia.org/wiki/Git <-- Mettre à jour la liste des programmes dans le mode d'emploi
    - Séparation des options multiples pour éviter la confusion chez un débutant qui lit le script et veut le modifier.
    - Séparation des éléments de la fonction **detect_root()**. Dans cette fonction ne reste que la partie effectuant la gestion d'erreur de lancement du script en mode utilisateur normal, la partie de demande de permission pour le lancement ayant été déplacée dans une nouvelle fonction appelée **launch_script()**.
    - Création de trois nouvelles petites fonctions d'affichage de texte plus propre, sans avoir à définir les couleurs au début et à la fin du texte :
        - **j_echo()** : Affiche un texte en jaune avec 4 chevrons avant de remettre la couleur par défaut au texte suivant.
        - **r_echo()** : Affiche un texte en rouge avec 8 chevrons avant de remettre la couleur par défaut au texte suivant.
        - **v_echo()** : Affiche un texte en vert avec 8 chevrons avant de remettre la couleur par défaut au texte suivant.
    - **pack_install()** : Changement du tableau d'arguments (**$@**) en premier argument (**$1**).
    - **Installation des paquets de LAMP** : Avec la modification ci-dessus de la fonction **pack_install()**, les paquets ne sont plus installés grâce à un tableau d'arguments, mais en liste, comme tous les autres paquets.
    - **handle_errors()** : Correction du bug d'affichage des headers d'erreur ne s'affichant pas en rouge, mais selon la couleur de texte par défaut du terminal (variable utilisée : **$C_RED** au lieu de **$C_ROUGE**).
    - Optimisation de la fonction **pack_install()**. Placement des appels de commandes répétitifs dans une nouvelle sous-fonction nommée **cmd_args_f()** et passage des commandes d'installation complètes dans un tableau d'arguments.
    - Déclaration de la variable **$OS_FAMILY** avec les autres variables, au lieu d'être déclarée et directement définie dans la fonction **get_dist_package_manager()**.*
    - Simplification de la liste de définition des variables.
    - Ajout d'une variable nommée **$COLS**, destinée à afficher des colonnes quand on en a besoin ailleurs que dans la fonction **draw_header_line()** (suppression de la variable **$line_cols** au profit de la nouvelle variable).
    - Légère refonte de la partie de création des headers. La personnalisation de la couleur pour chaque partie est désormais plus facile et compréhensible.
    - Changement du nom de la variable **$SLEEP_TAB** par **$SLEEP_HEADER**.


# Prochaine version : 1.6

* Changelogs :
    - Utilisation d'un file descriptor pour vérifier qu'un paquet est déjà installé.


# Future version : Alpha 2.0

* Changelogs :
    - Ajout de la fonction **"set_sudo()"** pour télécharger sudo et ajouter l'utilisateur actuel à la liste des sudoers (**sudo** n'est pas installé de base sur Debian), avec obtention du nom de l'utilisateur normal au moment de lancer le script via un appel système **"read"**.
    - Pour l'instant : Demander à l'utilisateur d'écrire son nom via read
    - Téléchargement des paquets de la logithèque de la distribution depuis les PPA.
