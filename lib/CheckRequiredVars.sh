#!/usr/bin/env bash

# This file contains functions that check if, for example, the argument variables, contain a value
# It must be called BEFORE including the files from "" in the main script.

# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### ARGUMENTS AND EXECUTION

## CHECK FOR CURRENT UID

# Checking if the current UID is equal to 0 (root account)
function CheckRoot()
{
    if test "$EUID" -ne 0; then
        HandleFatalErrors "" "" "" "" ""
    fi
}

# -----------------------------------------------

## CHECK ARGUMENT PASSAGE

# Check if an username is passed as argument
function CheckArgUsername()
{
    if test -z "$ARG_USERNAME"; then
        EchoError "No username passed as argument"; echo; exit 1
    fi
}

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### FILES

## LOG FILE

# Checking the recording of a value in the variable "$FILE_LOG_PATH".
function CheckLog()
{
    if test -z "$FILE_LOG_PATH"; then
        EchoError "No path provided for the log file."; echo; exit 1
    fi
}

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #
