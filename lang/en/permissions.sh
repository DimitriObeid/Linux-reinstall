#!/usr/bin/env bash

    MSG_PERM_CHOWN_DIR="Recursive change of the rights of the new folder $(DechoN "$path/") from $(DechoN "$USER") to $(DechoN "$ARG_USERNAME")"
    MSG_PERM_CHOWN_DIR_SUCCESS="The rights of the $(DechoS "$name") folder have been successfully changed from $(DechoS "$USER") to $(DechoS "$ARG_USERNAME")"
    MSG_PERM_CHOWN_DIR_FAIL_1="Unable to change the rights of the $(DechoE "$path/") folder"
    MSG_PERM_CHOWN_DIR_FAIL_2="To change recursively its rights, use the following command"
