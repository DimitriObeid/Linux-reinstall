#!/usr/bin/env bash

# TODO : Mettre chaque traduction dans un fichier dédié et mettre la condition case dans un des fichiers du script, puis appeler le fichier selon la langue en utilisant la commande "source".

#case ${ARG_LANG,,} in
#    "EN")
# "HandleErrors" function messages
    MSG_HNDERR_FATAL="FATAL ERROR"

    MSG_HNDERR_FATAL_HAP="A fatal error has occurred"

    MSG_HNDERR_FATAL_LINE="The error in question occurred in the line"

    MSG_HNDERR_FATAL_STOP="Stopping the installation"

    MSG_HNDERR_MV_FAIL="Unable to move the log file to the $DIR_HOMEDIR folder"

    MSG_HNDERR_IFBUG="In case of bug, please send me the log file located in the $(DechoE "$DIR_LOG_PATH") folder"

    MSG_HNDERR_SEND="You can send me the log file if you need help to debug the script and / or decipher the returned errors"

    MSG_HNDERR_SEND_PATH="It is located in the $(DechoE "$DIR_LOG_PATH") folder"
        

# "Makedir" function messages
    MSG_MKDIR_PROCESSING_BEGIN="Processing the $(DechoN "$name") folder in the parent folder $(DechoN "$parent")"

    MSG_MKDIR_PROCESSING_END_FAIL="End of processing the $(DechoE "$path/") folder"

    MSG_MKDIR_PROCESSING_END_SUCC="End of processing the $(DechoS "$path/") folder"

    MSG_MKDIR_NONEMPTY_1="A non-empty folder with exactly the same name ($(DechoN "$name")) is already in the target folder $(DechoN "$parent/")"

    MSG_MKDIR_NONEMPTY_2="Deleting the contents of the $(DechoN "$path/") folder"

    MSG_MKDIR_NONEMPTY_SUCC="Deletion of the contents of the folder $(DechoS "$path/") performed successfully"

    MSG_MKDIR_NONEMPTY_FAIL_1="Unable to delete the contents of the $(DechoE "$path/") folder."

    MSG_MKDIR_NONEMPTY_FAIL_2="The contents of any file in the $(DechoE "$path/") folder with the same name as one of the created or downloaded files will be overwritten"
    
    MSG_MKDIR_EXISTS="The $(DechoS "$path/") folder already exists in the $(DechoS "$parent/") folder and is empty"
    
    MSG_MKDIR_CREATE_MSG="Creating the $(DechoN "$name") folder in the parent folder $(DechoN "$parent/")"
    
    MSG_MKDIR_CREATE_FAIL="THE $(DechoE "$name") FOLDER CANNOT BE CREATED IN THE PARENT FILE $(DechoE "$parent/")"
    
    MSG_MKDIR_CREATE_FAIL_ADV="Check if the $(DechoE "mkdir") command exists."
    
    MSG_MKDIR_CREATE_SUCC="The $(DechoS "$name") was successfully created in the $(DechoS "$parent") folder"
    
    MSG_MKDIR_CHMOD="Recursive change of the rights of the new folder $(DechoN "$path/") from $(DechoN "$USER") to $(DechoN "$ARG_USERNAME")"
    
    MSG_MKDIR_CHMOD_SUCC="The rights of the $(DechoS "$name") folder have been successfully changed from $(DechoS "$USER") to $(DechoS "$ARG_USERNAME")"
    
    MSG_MKDIR_CHMOD_FAIL_1="Unable to change the rights of the $(DechoE "$path/") folder"
    
    MSG_MKDIR_CHMOD_FAIL_2="To change recursively its rights, use the following command"
    
## "Makefile" function messages
    MSG_MKFILE_PROCESSING_BEGIN="Processing the $(DechoN "$name") file"
        
    MSG_MKFILE_PROCESSING_END_FAIL="End of processing the $(DechoE "$name") file"
    
    MSG_MKFILE_PROCESSING_END_SUCC="End of processing the $(DechoS "$name") file"
    
    MSG_MKFILE_NONEMPTY_1="The file $(DechoN "$path") already exists and is not empty."
    
    MSG_MKFILE_NONEMPTY_2="Overwriting data from file $(DechoN "$path")"
    
    MSG_MKFILE_NONEMPTY_SUCC="The content of the file $(DechoS "$path") has been successfully overwritten"
    
    MSG_MKFILE_NONEMPTY_FAIL_1="The content of the $(DechoE "$path") file has not been overwritten"
