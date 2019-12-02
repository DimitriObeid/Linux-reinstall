# Reinstall Linux : Le programme qui va vous simplifier la réinstallation sur Linux

## 1) Description du projet

Vous en avez plus qu'assez de vous retaper toutes les étapes de réinstallation de vos logiciels à la main ?

Ne vous embêtez plus. Désormais, vous n'avez qu'à télécharger un des deux scripts du dossier **"V1.1"** et  
à l'exécuter après chaque (ré)installation d'une distribution Linux sur votre ordinateur.

Il vous téléchargera tous les programmes dont vous avez besoin et les installera à votre place, et bien plus.

Lisez le fichier **"Mode d'emploi.odt"** pour :  
    * Voir comment exécuter un des scripts,  
    * Savoir à quels moments le script aura besoin de votre permission pour modifier des fichiers,  
    * Savoir quoi faire en cas d'erreur,  
    * Quels programmes sont ajoutés par le script de réinstallation choisi.  


La lecture de la documentation du script que vous souhaitez installer est vivement conseillée si vous  
avez besoin d'ajouter ou de supprimer des programmes. Vous saurez ainsi quelle partie du script  
changer pour l'adapter à vos besoins.

## 2) Mode d'emploi

Lisez le fichier **"Mode d'emploi.odt"** pour voir comment exécuter un des scripts.

## 3) Description des fichiers du projet

Deux sous-dossiers se trouvent dans ce dépôt Github :  

* *__Bêta :__*
    - Contient le fichier de réinstallation en version Bêta, ainsi que sa documentation. Le contenu est régulièrement  
    mis à jour.

* *__V 1.1 :__*
    - Contient le script minimal dont vous avez besoin pour vos cours de BTS SIO, ainsi que sa documentation.  
    - Contient également mon script de réinstallation personnelle. Vous pouvez le télécharger si vous souhaitez  
    installer les mêmes programmes que moi ou plus que le strict minimum pour le BTS SIO.  
    - Entre les deux scripts, les seuls changements se situent au niveau des logiciels à installer.  
    Le script personnalisé ajoute les mêmes programmes que le script minimal, plus de nombreux  
    programmes supplémentaires.

## 4) Contenu du dossier actuel et des sous-dossiers

* ### 4.a) Dossier _"Bêta"_ :  
    - *__Documentation Bêta.odt :__* La documentation de la version Bêta du projet. Elle est régulièrement mise à jour.  
    - *__beta.sh :__* Le fichier de réinstallation en version Bêta. Il est régulièrement mis à jour.


* ### 4.b) Dossier _"V 1.1"_ :
    - *__Documentation script personnalisé 1.1 :__* La documentation officielle de la version de réinstallation personnalisée.  
    - *__Documentation SIO 1.1 :__* La documentation officielle de la version 1.1 du script.  
    - *__sio.sh :__* Le fichier de la version 1.1 du script de réinstallation minimal.  
    - *__personnel.sh :__* Le fichier de la version 1.1 du script de réinstallation personnalisé.  


* ### 4.c) Dossier actuel :
    - *__Bug tracking.md :__* Liste tous les bugs connus jusqu'à leur correction.  
    - *__Changelogs.md :__* Contient les changements ayant eu lieu entre deux versions.  
    - *__Mode d'emploi.odt :__* Mode d'emploi d'exécution de chaque script.
    - *__README.md :__* Le fichier que vous lisez actuellement sur Github (ou dans tout autre lecteur de fichiers Markdown).  

## 5) Fichiers à télécharger :

- Les fichiers qui vous intéresseront le plus pour vos cours de BTS SIO ou pour une utilisation personnelle  
ou ou plus avancée sont les quatre fichiers se trouvant dans le dossier **"V 1.1"**.  
- Les fichiers qui vous intéresseront le plus si vous êtes développeur et que vous souhaitez participer à  
l'élaboration du projet se trouvent dans le dossier **"Bêta"**.  

## 6) Ajouts futurs

- Téléchargement de VMware.  
- Ajout de PPA pour télécharger des paquets supplémentaires (**exemple** : Steam).  
- Ajout de sudo et configuration pour y accéder en tant qu'utilisateur normal pour Debian.  
- Proposition d'installation d'un environnement graphique si aucun environnement graphique n'est détecté.  
