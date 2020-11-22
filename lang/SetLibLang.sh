#!/usr/bin/env bash

# Detecting user's language with the "$LANG" environment variable.

# There's no need for extra check with "*)", as this case of failure is already tested in the "src/lang/SetMainLang.sh" file, which is the first file sourced, at the beginning of the main file.
case "$LANG" in
    # English
    "en_*")
        for f in "$MAIN_PROJECT_ROOT/$MAIN_SRC_LANG/en/*.en"; do
            source $f || echo "At least one of the translation files cannot be included" && exit 1
        done
        ;;
    # French
    "fr_*")
        for f in "$MAIN_PROJECT_ROOT/$MAIN_SRC_LANG/fr/*.fr"; do
            source $f || echo "Au moins un des fichiers de traduction n'a pas pu être inclus" && exit 1
        done
        ;;
    # Unsupported language
    *)
        echo "Sorry, your language is not (yet) supported."
        
        exit 1
        ;;
esac
