#!/usr/bin/env bash

## INSTALLATION DES PAQUETS DEPUIS LES DÉPÔTS DES GESTIONNAIRES DE PAQUETS PRINCIPAUX ET SECONDAIRES
# Installation des paquets de base.
function SIOInstall()
{
    HeaderStep "INSTALLATION DES PAQUETS DE BASE DEPUIS LES DÉPÔTS DES GESTIONNAIRES DE PAQUETS PRINCIPAUX ET SECONDAIRES"

    # Commandes
    HeaderInstall "INSTALLATION DES COMMANDES PRATIQUES"
    PackInstall "$main" htop
    PackInstall "$main" neofetch
    PackInstall "$main" tree

    # Développement
    HeaderInstall "INSTALLATION DES OUTILS DE DÉVELOPPEMENT"
    PackInstall "snap" atom --classic --stable		# Éditeur de code Atom.
    PackInstall "snap" code --classic	--stable	# Éditeur de code Visual Studio Code.
    PackInstall "$main" emacs
    PackInstall "$main" g++
    PackInstall "$main" gcc
    PackInstall "$main" git

    PackInstall "$main" make
    PackInstall "$main" umlet
    PackInstall "$main" valgrind

    # Logiciels de nettoyage de disque
    HeaderInstall "INSTALLATION DES LOGICIELS DE NETTOYAGE DE DISQUE"
    PackInstall "$main" k4dirstat

    # Internet
    HeaderInstall "INSTALLATION DES CLIENTS INTERNET"
    PackInstall "snap" discord --stable
    PackInstall "snap" skype --stable
    PackInstall "$main" thunderbird

    # LAMP
    HeaderInstall "INSTALLATION DES PAQUETS NÉCESSAIRES AU BON FONCTIONNEMENT DE LAMP"
    PackInstall "$main" apache2             # Installe le serveur HTTP Apache 2 (il dépend du paquet "libapache2-mod-php", installé plus loin).
    PackInstall "$main" php                 # Installe l'interpréteur PHP.
    PackInstall "$main" libapache2-mod-php  # Installe un module d'Apache nécessaire à son bon fonctionnement.
    PackInstall "$main" mariadb-server		# Installe le serveur de base de données MariaDB (Si vous souhaitez un seveur MySQL, remplacez "mariadb-server" par "mysql-server").
    PackInstall "$main" php-mysql           # Module PHP permettant d'utiliser MySQL ou MariaDB avec PHP.
    PackInstall "$main" php-curl            # Module PHP permettant le support de la commande "curl" pour se connecter et communiquer avec d'autres serveurs grâce à différents protocoles de communication (HTTP(S), FTP, LDAP, etc...).
    PackInstall "$main" php-gd              # Module PHP permettant à PHP de créer et de manipuler différents formats d'images (PNG, JPEG, GIF, etc...).
    PackInstall "$main" php-intl            # Module PHP installant les fonctions d'internationalisation (paramètres régionaux, conversion d'encodages, opérations de calendrier, etc...).
    PackInstall "$main" php-json            # Module PHP implémentant le support de l'analyse de fichiers au format d'échange de données JSON.
    PackInstall "$main" php-mbstring        # Module PHP fournissant des fonctions de traitement de jeux de caractères très grands pour certaines langues.
    PackInstall "$main" php-xml             # Module PHP implémentant le support de l'analyse de fichiers au format d'échange de données XML.
    PackInstall "$main" php-zip             # Module PHP permettant à l'interpréteur PHP de lire et écrire des archives compressées au format ZIP, ainsi que d'accéder aux fichiers et aux dossiers s'y trouvant.

    # Librairies
    HeaderInstall "INSTALLATION DES LIBRAIRIES"
    PackInstall "$main" python3.8

    # Réseau
    HeaderInstall "INSTALLATION DES LOGICIELS RÉSEAU"
    PackInstall "$main" wireshark

    # Vidéo
    HeaderInstall "INSTALLATION DES LOGICIELS VIDÉO"
    PackInstall "$main" vlc

    # Wine
    HeaderInstall "INSTALLATION DE WINE"
    PackInstall "$main" wine-stable

    EchoSuccessTee "TOUS LES PAQUETS ONT ÉTÉ INSTALLÉS AVEC SUCCÈS DEPUIS LES GESTIONNAIRES DE PAQUETS !"
}
