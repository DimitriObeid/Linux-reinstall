#!/usr/bin/env bash

# Installation des paquets secondaires
function CustomInstall()
{
    HeaderStep "INSTALLATION DES PAQUETS DE BASE DEPUIS LES DÉPÔTS DES GESTIONNAIRES DE PAQUETS PRINCIPAUX ET SECONDAIRES"

    # Commandes
    HeaderInstall "INSTALLATION DE COMMANDES"
    PackInstall "$main" sl              # Commande
    
    # Images
    HeaderInstall "INSTALLATION DES LOGICIELS DE TRAITEMENT D'IMAGES"
    PackInstall "$main" gimp            # Logiciel de traitement d'image libre et open-source
    
    # Jeux
    HeaderInstall "INSTALLATION DE JEUX VIDÉO"
    PackInstall "$main" bsdgames        # Comprend les jeux "Snake",
    PackInstall "$main" desmumes        # Émulateur Nintendo DS
    PackInstall "$main" mgba            # Émulateur Nintendo GBA
    PackInstall "$main" pacman          # Pacman
    PackInstall "$main" supertux        # Clone de Super Mario Bros
    PackInstall "$main" supertuxkart    # Clone de Mario Kart
    PackInstall "$main" wesnoth         # 
    
    # Librairies
    HeaderInstall "INSTALLATION DES LIBRAIRIES"
    PackInstall "$main" libcsfml-dev
    PackInstall "$main" libsfml-dev
    
    # Modélisation 3D
    HeaderInstall "INSTALLATION DES LOGICIELS DE MODÉLISATION 3D"
    PackInstall "$main" blender
}
