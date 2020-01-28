# Linux Reinstall : Le programme qui va vous simplifier la réinstallation de vos programmes sur votre distribution Linux

**Version Bêta actuelle :** 2.0  
**Version stable actuelle :** 1.4.2  

## 1) Description du projet

Vous en avez plus qu'assez de repasser encore et encore par toutes les étapes de réinstallation de vos logiciels à la main ? Ou bien souhaitez-vous vous simplifier la vie lors de l'installation des programmes que vous souhaitez la première fois que vous installez une distribution Linux ?

Ne vous embêtez plus. Désormais, vous n'avez qu'à télécharger un des deux scripts du dossier **"Stable"** (recommandé) et à l'exécuter après chaque (ré)installation d'une distribution Linux sur votre ordinateur. Il vous téléchargera tous les programmes dont vous avez besoin et les installera à votre place.

Lisez le fichier **"Mode d'emploi.odt"** pour :  
<ul>
    <li> Voir quelle est la différence entre les deux scripts,  </li>
    <li> Voir comment exécuter un des scripts,  </li>
    <li> Savoir à quels moments le script aura besoin de votre permission pour apporter des modifications,  </li>  
    <li> Savoir quoi faire en cas d'erreur,  </li>
    <li> Savoir quels programmes sont ajoutés par le script de réinstallation choisi.  </li>  
</ul>

La lecture de la documentation du script que vous souhaitez installer est vivement conseillée si vous avez besoin d'ajouter ou de supprimer des programmes. Vous saurez ainsi quelle partie du script changer pour l'adapter à vos besoins.

## 2) Gestionnaires de paquets supportés :
- **APT** (Debian, Ubuntu, Mint, Kali)  
- **DNF** (RHEL, Fedora, CentOS)  
- **Emerge** (Gentoo)  
- **Pacman** (Arch Linux, Manjaro)  
- **Zypper** (OpenSUSE)  

## 3) Fichiers à télécharger :

- Les fichiers qui vous intéresseront le plus pour vos cours de BTS SIO ou pour une utilisation personnelle ou plus avancée se trouvent dans le dossier **Stable** (*__Documentation Stable.odt__* _(si vous souhaitez modifier le script)_, plus *__sio.sh__* ou *__personnel.sh__*).  
- Les fichiers qui vous intéresseront le plus si vous êtes développeur et que vous souhaitez participer à l'élaboration du projet se trouvent dans le sous-dossier **"Beta"** (si vous voulez donner un petit coup de main).  

## 4) Arborescence et description des fichiers du projet

Ce dépôt Github s'organise en un dossier de fichiers contenant 5 fichiers et 5 sous-dossiers :  

* *__4.1) Dossier actuel :__*
    - **.gitignore :** Fichier servant à ne pas inclure, dans les commits Git, les fichiers listés dedans (fichiers binaires, etc...).  
    - **Bug tracking.md :** Liste tous les bugs connus jusqu'à leur correction.  
    - **Changelogs.md :** Contient la liste des changements ayant eu lieu entre deux versions.  
    - **Mode d'emploi.odt :** Mode d'emploi d'exécution de chaque script, avec de nombreuses informations supplémentaires.  
    - **README.md :** Le fichier que vous lisez actuellement sur Github (ou dans tout autre lecteur de fichiers Markdown).  

* *__4.2) Beta :__*
    - **beta.sh :** Le fichier exécutable de la version Beta du script de réinstallation SIO.  
    - **Documentation Beta.odt :** La documentation officielle de la version Bêta.  

* *__4.3) GUI :__*
    - **.gitignore :** Fichier servant à ne pas inclure, dans les commits Git, les fichiers listés dedans (fichiers binaires, temporaires, etc...).  
    - **fenetreGUI.cpp :** Fichier source C++ contenant la définition des méthodes de la classe **"fenetreGUI"**.  
    - **fenetreGUI.h :** Fichier d'en-tête contenant la classe gérant l'affichage de la fenêtre principale.  
    - **main.cpp :** Fichier source C++ contenant la fonction principale du programme **(main)**, fonction de début et de fin de **TOUT** programme écrit en C ou en C++.  

* *__4.4) Parser :__*
    - **main.cpp :** Fichier source C++ contenant la fonction principale du programme de parsing du script shell.  
    - **Makefile :** Fichier Makefile permettant de compiler tous les fichiers d'un projet avec des paramètres prédéfinis, le tout en une seule commande.  
    - **parser.cpp :** Fichier source C++ contenant les définitions des méthodes de la classe **"Parser"**.  
    - **parser.h :** Fichier d'en-tête (header) contenant la classe **"Parser"**, ses attributs et déclarations de méthodes et l'inclusion des en-têtes des librairies standard C++ (iostream, string, fstream, etc...).  

* *__4.5) Ressources :__*
    - **paquets.xml :** Fichier de structuration de données contenant les noms des paquets.  
    - **sudoers :** Fichier de configuration se trouvant dans le dossier **"/etc/"**, consignant la gestion des droits du super-utilisateur accordés aux utilisateurs de l'ordinateur.  

* *__4.6) Stable :__*
    - **Documentation Stable.odt :** La documentation officielle des deux scripts de réinstallation en version stable.  
    - **personnel.sh :** Le fichier exécutable de la dernière version stable du script de réinstallation personnalisé.  
    - **sio.sh :** Le fichier exécutable de la dernière version stable du script de réinstallation SIO.  


## 5) Ajouts futurs (version 2.0 et au-delà)

- Proposition d'une interface graphique  
- Téléchargement de VMware.  
- Ajout de dépôts PPA pour télécharger des paquets supplémentaires (**exemple** : Steam).  
- Ajout de sudo et configuration pour y accéder en tant qu'utilisateur normal pour Debian.  
- Proposition d'installation d'un environnement graphique si aucun environnement graphique n'est détecté.  
- Ajout d'une possibilité d'appel d'arguments lors de l'appel du fichier exécutable.  
- Création d'une manpage pour y lister ces arguments et y écrire le mode d'emploi.  
- Parmi ces options, une qui servira à supprimer les paquets installés par le script  
    - Pour cela, je pense mettre le nom des paquets installés par le script (s'ils n'étaient pas déjà installés) dans un fichier, et si l'option est appelée, récupérer ces paquets et appeler la commande de suppression adaptée à la distribution de l'utilisateur.  
