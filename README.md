# Linux Reinstall : Le programme qui va vous simplifier la réinstallation sur votre distribution Linux

## 1) Description du projet

Vous en avez plus qu'assez de repasser encore et encore par toutes les étapes de réinstallation de vos logiciels à la main ? Ou bien souhaitez-vous vous simplifier la vie lors de l'installation des programmes que vous souhaitez ?

Ne vous embêtez plus. Désormais, vous n'avez qu'à télécharger un des deux scripts du dossier **"Stable"** et à l'exécuter après chaque (ré)installation d'une distribution Linux sur votre ordinateur (familles Debian, Arch Linux, Fedora, Gentoo et SUSE).

Il vous téléchargera tous les programmes dont vous avez besoin et les installera à votre place, et bien plus.

Lisez le fichier **"Mode d'emploi.odt"** pour :  
<ul>
    <li> Voir quelle est la différence entre les deux scripts,  </li>
    <li> Voir comment exécuter un des scripts,  </li>
    <li> Savoir à quels moments le script aura besoin de votre permission pour modifier des fichiers,  </li>  
    <li> Savoir quoi faire en cas d'erreur,  </li>
    <li> Savoir quels programmes sont ajoutés par le script de réinstallation choisi.  </li>  
</ul>

La lecture de la documentation du script que vous souhaitez installer est vivement conseillée si vous avez besoin d'ajouter ou de supprimer des programmes. Vous saurez ainsi quelle partie du script est à changer pour l'adapter à vos besoins.

## 2) Fichiers à télécharger :

- Les fichiers qui vous intéresseront le plus pour vos cours de BTS SIO ou pour une utilisation personnelle ou plus avancée sont au moins deux des trois fichiers de la version 1.4 (*__Documentation Stable.odt__* _(si vous souhaitez modifier le script)_, plus *__sio.sh__* ou *__personnel.sh__*) se trouvant dans le dossier **"Stable"**.  
- Les fichiers qui vous intéresseront le plus si vous êtes développeur et que vous souhaitez participer à l'élaboration du projet se trouvent dans le sous-dossier **"Alpha"** (si vous êtes déterminé) ou dans le sous-dossier **"Bêta"** (si vous voulez donner un petit coup de main).  

## 3) Description des fichiers du projet

Ce dépôt Github s'organise en un dossier de fichiers contenant 4 fichiers et 3 sous-dossiers :  

* *__2.1) Dossier actuel :__*
    * **Bug tracking.md :** Liste tous les bugs connus jusqu'à leur correction.    
    * **Changelogs.md :** Contient les changements ayant eu lieu entre deux versions.    
    * **Mode d'emploi.odt :** Mode d'emploi d'exécution de chaque script.  
    * **README.md :** Le fichier que vous lisez actuellement sur Github (ou dans tout autre lecteur de fichiers Markdown).  

* *__2.2) Alpha :__*
    - **alpha.sh :** Le fichier exécutable de la version Alpha. Il est régulièrement mis à jour.  
    - **Documentation Alpha.odt :** La documentation de la version Alpha du projet. Elle est mise à jour dès que possible.  

* *__2.3) Bêta :__*
    - **beta.sh :** Le fichier exécutable de la version Bêta du script de réinstallation SIO.
    - **Documentation Bêta.odt :** La documentation officielle de la version Bêta.

* *__2.4) Stable :__*
    - **Documentation Stable.odt :** La documentation officielle des deux scripts de réinstallation en version stable.
    - **personnel.sh :** Le fichier exécutable de la dernière version stable du script de réinstallation personnalisé.  
    - **sio.sh :** Le fichier exécutable de la dernière version stable du script de réinstallation SIO.


## 4) Ajouts futurs (version 2.0 et au-delà)

- Téléchargement de VMware.  
- Ajout de PPA pour télécharger des paquets supplémentaires (**exemple** : Steam).  
- Ajout de sudo et configuration pour y accéder en tant qu'utilisateur normal pour Debian.  
- Proposition d'installation d'un environnement graphique si aucun environnement graphique n'est détecté.  
