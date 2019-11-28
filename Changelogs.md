# Version ancienne : Bêta 0.1

* Changelogs :
    - Headers fonctionnels.
    - Détection du mode super-administrateur.
    - Détection de la connexion à Internet.
    - Mises à jour effectuées avec succès.
    - Installation des paquets depuis les dépôts officiels à résoudre.
    - Commande exacte de nettoyage des paquets obsolètes à trouver pour OpenSUSE.
    - Header de fin d'installation.


# Version ancienne : Bêta 0.2

* Changelogs :
    - Ajout des paquets à installer (les travaux sur la fonction d'installation des paquets sont toujours en cours).
    - Changement du mode d'affichage des erreurs de détection du gestionnaire de paquets et de l'exécution en tant qu'utilisateur normal : **$ERROR_OUTPUT_1 ---> Erreur s'étant produite $ERROR_OUTPUT_2**.
    - Léger changement pour le header de bienvenue : **BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES LINUX !!!!!** ---> **BIENVENUE DANS L'INSTALLATEUR DE PROGRAMMES POUR LINUX !!!!!**


# Version ancienne : Bêta 0.2.1

* Changelogs :
    - Amélioration visuelle de la partie d'installation des logiciels.
    - autoremove() : Correction du bug d'affichage de la chaîne de caractères de mauvaise réponse avant que la question ne soit posée pour la première fois.


# Version ancienne : 1.0

* Changelogs :
    - Mise en fonctionnement de la fonction d'installation des paquets venant des dépôts officiels.
    - Ajout de la fonction **"snap_install()"** pour télécharger des paquets depuis les dépôts de Snap.
    - Suppression de Zypper de la fonction **"autoremove()"**. Se référer à la documentation pour supprimer les paquets obsolètes sur OpenSUSE.
    - Légères modifications appliquées sur les commentaires.


# Version actuelle : 1.1

* Changelogs :
    - Placement des conditions **"case"** d'attente de réponse de l'utilisateur dans des sous-fonctions.
    - Correction de fautes d'orthographe mineures.
    - Optimisation de la fonction **"script_header"**. Désormais, il n'y a plus besoin de remettre la couleur de base du texte du terminal juste après le texte du header, ni de rajouer un **echo ""** juste après, car le saut de ligne est automatique.


# Prochaine version : 1.2

* Changelogs :
    - ...

# Version future : 2.0

* Changelogs :
    - Ajout de la fonction **"set_sudo()"** pour télécharger sudo et ajouter l'utilisateur actuel à la liste des sudoers (**sudo** n'est pas installé de base sur Debian).
    - Téléchargement des paquets de la logithèque de la distribution depuis les PPA
    
