## FICHIER MAKEFILE PERMETTANT DE CONSTRUIRE LE SCRIPT FINAL

TARGET_FILE = "install.sh"		# Fichier final 	| Final file
SRC="${PWD}/src/main.sh"		# Fichier principal	| Main file
LIB = $(shell ls -d ${PWD}/lib/*) 	# Fichiers du dossier ./lib | Files of the ./lib folder

export LIB

SHELL := /usr/bin/env bash
all: define_main add_dependencies invoke_main

define_main:
	echo -e "#!$(SHELL)\n" > ${TARGET_FILE}
	echo -e "function main() {\n" >> ${TARGET_FILE}
	cat "${PRJ_SRC}" | sed -e 's/^/  /g' >> ${TARGET_FILE}
	echo -e "\n}\n" >> ${TARGET_FILE}

invoke_main:
	echo "main \$$@" >> ${TARGET_FILE}

add_dependencies:
	for filename in $${PRJ_LIB[*]}; do cat $${filename} >> ${TARGET_FILE}; echo >> ${TARGET_FILE}; done

