# Reinstall Linux : Le programme qui va vous simplifier la réinstallation sur Linux

## 1) Description du projet

Vous en avez plus qu'assez de vous retaper toutes les étapes de réinstallation de vos logiciels à la main ?

Ne vous embêtez plus. Désormais, vous n'avez qu'à télécharger un des trois scripts du dossier **"V1.3"** et à l'exécuter après chaque (ré)installation d'une distribution Linux sur votre ordinateur.

Il vous téléchargera tous les programmes dont vous avez besoin et les installera à votre place, et bien plus.

Lisez le fichier **"Mode d'emploi.odt"** pour :  
    * Voir comment exécuter un des scripts,  
    * Savoir à quels moments le script aura besoin de votre permission pour modifier des fichiers,  
    * Savoir quoi faire en cas d'erreur,  
    * Quels programmes sont ajoutés par le script de réinstallation choisi.  

La lecture de la documentation du script que vous souhaitez installer est vivement conseillée si vous avez besoin d'ajouter ou de supprimer des programmes. Vous saurez ainsi quelle partie du script changer pour l'adapter à vos besoins.

## 2) Mode d'emploi

Lisez le fichier **"Mode d'emploi.odt"** pour voir comment exécuter un des scripts, que faire en cas d'erreurs et la liste des programmes installés par chaque script.

## 3) Description des fichiers du projet

Deux sous-dossiers se trouvent dans ce dépôt Github :  

* *__Alpha :__*
    - Contient le fichier de réinstallation en version Alpha 2.0, ainsi que sa documentation. Le contenu de ce sous-dossier est régulièrement mis à jour.

* *__V 1.3 :__*
    - Contient le script de réinstallation minimal en version Bêta.
    - Contient le script de réinstallation minimal dont vous avez besoin pour vos cours de BTS SIO.  
    - Contient également le script de réinstallation personnelle. Vous pouvez le télécharger si vous souhaitez installer les mêmes programmes que moi ou plus que le strict minimum pour le BTS SIO.  
    - Contient la documentation pour chaque script en version stable, ainsi que celle du script de la version Bêta.

## 4) Contenu du dossier actuel et des sous-dossiers

* ### 4.a) Dossier _"Alpha"_ :  
    - *__Documentation Alpha.odt :__* La documentation de la version Alpha du projet. Elle est mise à jour dès que possible.  
    - *__alpha.sh :__* Le fichier exécutable de la version Alpha. Il est régulièrement mis à jour.  

* ### 4.b) Dossier _"V 1.3"_ :
    - *__Documentation Bêta :__* La documentation officielle de la version Bêta 1.4.  
    - *__Documentation Stable :__* La documentation officielle de la version 1.3 des scripts SIO et personnel.  
    - *__beta.sh :__* Le fichier exécutable de la version Bêta 1.4 du script de réinstallation SIO.
    - *__personnel.sh :__* Le fichier exécutable de la version stable 1.3 du script de réinstallation personnalisé.  
    - *__sio.sh :__* Le fichier exécutable de la version stable 1.3 du script de réinstallation SIO.  


* ### 4.c) Dossier actuel :
    - *__Bug tracking.md :__* Liste tous les bugs connus jusqu'à leur correction.  
    - *__Changelogs.md :__* Contient les changements ayant eu lieu entre deux versions.  
    - *__Mode d'emploi.odt :__* Mode d'emploi d'exécution de chaque script.
    - *__README.md :__* Le fichier que vous lisez actuellement sur Github (ou dans tout autre lecteur de fichiers Markdown).  

## 5) Fichiers à télécharger :

- Les fichiers qui vous intéresseront le plus pour vos cours de BTS SIO ou pour une utilisation personnelle ou plus avancée sont au moins deux des trois fichiers de la version 1.3 (*__Documentation Stable.odt__* _(si vous souhaitez modifier le script)_, plus *__sio.sh__* ou *__personnel.sh__*) se trouvant dans le dossier **"V 1.3"**.  
- Les fichiers qui vous intéresseront le plus si vous êtes développeur et que vous souhaitez participer à l'élaboration du projet se trouvent dans le dossier **"Alpha"** (si vous êtes déterminé), ou les deux fichiers de la version 1.4 (*__Documentation Bêta.odt__* plus *__beta.sh__*) se trouvant dans le dossier **V 1.3**.  

## 6) Ajouts futurs

- Téléchargement de VMware.  
- Ajout de PPA pour télécharger des paquets supplémentaires (**exemple** : Steam).  
- Ajout de sudo et configuration pour y accéder en tant qu'utilisateur normal pour Debian.  
- Proposition d'installation d'un environnement graphique si aucun environnement graphique n'est détecté.  
