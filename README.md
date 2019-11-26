# Reinstall Linux : Le programme qui va vous simplifier la réinstallation sur Linux

## 1) Description du projet

Vous en avez plus qu'assez de vous retaper toutes les étapes de réinstallation de vos logiciels à la main ?

Ne vous embêtez plus. Désormais, vous n'avez qu'à télécharger ce script et à l'exécuter.

Il vous téléchargera tous les programmes dont vous avez besoin et les installera à votre place.

La lecture de la documentation est vivement conseillée, surtout si vous avez besoin d'ajouter ou de supprimer des programmes. Vous saurez ainsi quelle partie du script changer pour l'adapter à vos besoins.


## 2) Description des fichiers du projet

Deux sous-dossiers se trouvent dans ce repository :  
  
*__Réinstallation personnelle :__* Contient mon script de réinstallation personnelle. Vous pouvez le télécharger si vous souhaitez installer les mêmes programmes que moi ou plus que le strict minimum pour le BTS SIO.  
*__V 1.0 :__* Ne contient que le strict minimum dont vous avez besoin pour vos cours de BTS SIO.  

### 2.a) Dossier _"Bêta"_ :
*__Documentation Bêta.odt :__* La documentation de la version Bêta du projet. Elle est régulièrement mise à jour.  
*__beta.sh :__* Le fichier de réinstallation en version Bêta. Constamment mis à jour.

### 2.b) Dossier _"Réinstallation personnelle"_ :
*__Documentation personnalisée.odt :__* La documentation officielle de ma version de réinstallation personnalisée  
*__personnel.sh :__* Mon fichier de réinstallation personnelle. Mis à jour lorsqu'une version stable du fichier de réinstallation bêta sort  

### 2.c) Dossier _"V 1.0"_ :
*__Documentation version 1.0.odt :__* La documentation officielle de la version 1.0 du script.  
*__Linux Reinstall 1.0.sh :__* LE fichier de la version 1.0 du script que vous souhaitez exécuter pour réinstaller vos programmes.  


### Dossier actuel :
*__Bug tracking.md :__* Liste tous les bugs connus jusqu'à leur correction.  
*__Changelogs.md :__* Contient les changements ayant eu lieu entre deux versions.  
*__README.md :__* Le fichier que vous lisez actuellement sur Github (ou dans tout autre lecteur de fichiers Markdown).  

## 3) Fichiers à télécharger :

Parmi ces fichiers, ceux qui vous intéresseront le plus sont les deux fichiers se trouvant dans le dossier **"V 1.0"**  

## 4) Mode d'emploi

Ouvrez un terminal, puis naviguez jusqu'au dossier contenant le script. Une fois dans le bon dossier, tapez exactement la commande suivante :

_sudo ./Linux\ Reinstall\ 1.0.sh_  

__IMPORTANT LES ANTISLASHS !!! Sinon "Linux", "Reinstall" et "1.0.sh" seront considérés comme plusieurs fichiers.__

*__Astuce :__* Pour vous simplifier la tâche, vous pouvez taper les premiers caractères du nom du script après le **"./"**, puis appuyer sur la touche de tabulation.

# 5) Ajouts futurs

Téléchargement de VMware  
Ajout de sudo et configuration pour y accéder en tant qu'utilisateur normal pour Debian
