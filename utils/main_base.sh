#!/usr/bin/env bash

# This script is a template for your own main script file. It contains whatever you need to make your script working

# For more informations, please check its documentation in the "docs/<your language>/utils/MainBase.pdf" file.

# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #

###################################### INCLUDING DEPENDENCIES #####################################

#### INITIALIZING DEPENDENCIES

## DEFINING MAIN SCRIPT VARIABLES

# Log

MAIN_LOG="initscript.log"

# Paths
MAIN_LANG="lang"
MAIN_L_FNCTS="lib/functions"
MAIN_L_VARS="lib/variables"
MAIN_S_INST="src/install"
MAIN_S_LANG="src/lang"
MAIN_S_RES="src/res"

## DEFINING PROJECT'S ROOT DIRECTORY

MAIN_PROJECT_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; cd .. && pwd -P )"
{ echo "$MAIN_PROJECT_ROOT"; echo; } > "$MAIN_LOGs"

shopt -s extglob                # enable +(...) glob syntax
MAIN_PROJECT_RESULT=${MAIN_PROJECT_ROOT%%+(/)}   # Trimming however many trailing slashes exist
MAIN_PROJECT_RESULT=${MAIN_PROJECT_ROOT##*/}     # Removing everything before the last / that still remains to get only the project root folder's name
{ echo "$MAIN_PROJECT_RESULT"; echo; } >> "$MAIN_LOG"

# Failsafe : verifying if the result matches with the project root folder's name.
if test "$MAIN_PROJECT_RESULT" != "Linux-reinstall"; then
    echo "Unable to find the project's root directory path"; exit 1
fi

# -----------------------------------------------

## CHECKING IF THE SUB-FOLDERS EXISTS

# Function checking if the project's subfolders paths passed as argument exist
function CheckSubFolder()   
{
    #***** Parameters *****
    local path=$1;

    #***** Code *****
    if test -d "$MAIN_PROJECT_ROOT/$path"; then
        echo "Included file : $path" >> "$MAIN_LOG"
    else
        echo "Cannot include $path, abort"

        exit 1
    fi
}

# Calling the above function and passing targeted directories paths as argument
CheckSubFolder "$MAIN_LANG"
CheckSubFolder "$MAIN_L_FNCTS"
CheckSubFolder "$MAIN_L_VARS"
CheckSubFolder "$MAIN_S_INST"
CheckSubFolder "$MAIN_S_LANG"
CheckSubFolder "$MAIN_S_RES"
echo >> "$MAIN_LOG"


# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #


#### INCLUDING FILES
