#!/usr/bin/env bash

# Arguments
MSG_INIT_ARGS=" $0 langue nom_d'utilisateur installation"
MSG_INIT_ARGS_SUDO="    sudo $MSG_INIT_ARGS"

# Vérification du lancement en mode super-utilisateur
MSG_INIT_ROOT_1="Ce script doit être exécuté en tant que super-utilisateur (root)"
MSG_INIT_ROOT_2="Exécutez ce script en plaçant la commande $(DechoE "sudo") devant votre commande :"
MSG_INIT_ROOT_3="Ou connectez vous directement en tant que super-utilisateur"
MSG_INIT_ROOT_4="et tapez cette commande"
    
MSG_INIT_ROOT_FAIL="SCRIPT LANCÉ EN TANT QU'UTILISATEUR NORMAL"
MSG_INIT_ROOT_ADVICE="Relancez le script avec les droits de super-utilisateur (avec la commande $(DechoE "sudo")) ou en vous connectant en mode root"

# Argument de nom d'utilisateur
MSG_INIT_USERNAME_ZERO="Veuillez lancer le script en plaçant votre nom d'utilisateur après la commande d'exécution du script"

MSG_INIT_USERNAME_FAIL="VOUS N'AVEZ PAS PASSÉ VOTRE NOM D'UTILISATEUR EN ARGUMENT"
MSG_INIT_USERNAME_ADVICE="Veuillez entrer votre nom d'utilisateur juste après le nom du script"

MSG_INIT_USERNAME_INCORRECT="NOM D'UTILISATEUR INCORRECT"
MSG_INIT_USERNAME_INCORRECT_ADVICE="Veuillez entrer correctement votre nom d'utilisateur"


# Argument de type d'installation
MSG_INIT_INSTALL_ZERO="VOUS N'AVEZ PAS PASSÉ LE TYPE D'INSTALLATION EN DEUXIÈME ARGUMENT"
MSG_INIT_INSTALL_ZERO_ADV="Veuillez entrez une seule valeur après votre nom d'utilisateur"

MSG_INIT_INSTALL_DIFFERENT="LA VALEUR DU DEUXIÈME ARGUMENT NE CORRESPOND PAS À L'UNE DES VALEURS ATTENDUES"

MSG_INIT_INSTALL_AWAITED="Les valeurs attendues sont : $(DechoE "perso") ou $(DechoE "sio")"
