#!/usr/bin/env bash

# Detecting user's language with the "$LANG" environment variable.
case "$LANG" in
# English
    en_*)
        for f in "$MAIN_PROJECT_ROOT/$MAIN_S_LANG/en/*.en"; do
            source $f || echo "At least one of the translation files cannot be included" && exit 1
        done
        ;;
    # French
    fr_*)
        for f in "$MAIN_PROJECT_ROOT/$MAIN_S_LANG/fr/*.fr"; do
            source $f || echo "Au moins un des fichiers de traduction n'a pas pu être inclus" && exit 1
        done
        ;;
    # Unsupported language
    *)
        echo "Sorry, your language is not (yet) supported."
        
        exit 1
        ;;
esac
