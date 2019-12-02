# Ancienne version : Bêta 0.1

* Changelogs :
    - Headers fonctionnels.
    - Détection du mode super-administrateur.
    - Détection de la connexion à Internet.
    - Mises à jour effectuées avec succès.
    - Installation des paquets depuis les dépôts officiels à résoudre.
    - Commande exacte de nettoyage des paquets obsolètes à trouver pour OpenSUSE.
    - Header de fin d'installation.


# Ancienne version : Bêta 0.2

* Changelogs :
    - Ajout des paquets à installer (les travaux sur la fonction d'installation des paquets sont toujours en cours).
    - Changement du mode d'affichage des erreurs de détection du gestionnaire de paquets et de l'exécution en tant qu'utilisateur normal : **$ERROR_OUTPUT_1 ---> Erreur s'étant produite $ERROR_OUTPUT_2**.
    - Léger changement pour le header de bienvenue : **BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES LINUX !!!!!** ---> **BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX !!!!!**


# Ancienne version : Bêta 0.2.1

* Changelogs :
    - Amélioration visuelle de la partie d'installation des logiciels.
    - **autoremove()** : Correction du bug d'affichage de la chaîne de caractères de mauvaise réponse avant que la question ne soit posée pour la première fois.


# Ancienne version : 1.0

* Changelogs :
    - Mise en fonctionnement de la fonction d'installation des paquets venant des dépôts officiels.
    - Ajout de la fonction **"snap_install()"** pour télécharger des paquets depuis les dépôts de Snap.
    - Suppression de Zypper de la fonction **"autoremove()"**. Se référer à la documentation pour supprimer les paquets obsolètes sur OpenSUSE.
    - Légères modifications appliquées sur les commentaires.


# Ancienne version : 1.1

* Changelogs :
    - Placement des conditions **"case"** d'attente de réponse de l'utilisateur dans des sous-fonctions.
    - Correction de fautes d'orthographe mineures.
    - Optimisation de la fonction **"script_header"**. Désormais, il n'y a plus besoin de remettre la couleur de base du texte du terminal juste après le texte du header, ni de rajouer un **echo ""** juste après, car le saut de ligne est automatique.


# Version actuelle : 1.2

* Changelogs :
    - **get_dist_package_manager()** et **pack_install()** : Remplacement des commandes *__which__* par *__command -v__*, commande recommandée pour vérifier qu'un paquet est déjà installé.
    - Correction d'un bug affichant l'étape d'autoremove sans interaction possible.
    - Toujours dans l'étape d'autoremove : La fonction **"read_autoremove"** se répète désormais en cas de réponse inattendue.
    - Léger changement de la chaîne de caractères à afficher en cas de réponse inattendue dans les fonctions **"read_launch_script()"** et **"read_autoremove()"**. Passage de *__"Veuillez rentrer une valeur valide (oui/non)"__* à *__"Veuillez répondre EXACTEMENT par "oui" ou par "non" "__*
    - **detect_root()** : Changement de la demande d'autorisation de lancement de l'installation. Passage de *__"Assurez-vous d'avoir lu le script et sa documentation avant de l'exécuter."__* à *__"Assurez-vous d'avoir lu au moins le mode d'emploi avant de lancer l'installation."__*.


# Prochaine version : 1.3

* Changelogs :
    - Utilisation d'un file descriptor pour vérifier qu'un paquet est déjà installé.

# Future version : 2.0

* Changelogs :
    - Ajout de la fonction **"set_sudo()"** pour télécharger sudo et ajouter l'utilisateur actuel à la liste des sudoers (**sudo** n'est pas installé de base sur Debian).
    - Téléchargement des paquets de la logithèque de la distribution depuis les PPA.
