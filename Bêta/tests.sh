#!/bin/bash

set_sudo()
{
	command -v sudo 1&> /dev/null && echo "Le paquet \"sudo\" est déjà installé" || echo "sudo n'est pas installé"
}

set_sudo
