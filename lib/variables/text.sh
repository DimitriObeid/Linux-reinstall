#!/usr/bin/env bash

# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### COLONNES | COLUMNS
## OBTENTION | RETRIEVAL
# Récupération du nombre de colonnes selon la longueur de la fenêtre du terminal | Get the columns number on the terminal according to its window's lenght
TXT_COLS=$(tput cols)

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### CARACTÈRES | CHARACTERS
## CARACTÈRE DE LIGNES DU HEADER | HEADER'S LINES CHARACTER
# Caractère utilisé pour dessiner les lignes des headers. Si vous souhaitez mettre un autre caractère à la place d'un tiret, changez le caractère entre les double guillemets.
# Ne mettez pas plus d'un caractère si vous ne souhaitez pas voir le texte de chaque header apparaître entre plusieurs lignes (une ligne de chaque caractère).
TXT_HEADER_LINE_CHAR="-"		# Caractère à afficher en boucle pour créer une ligne des headers de changement d'étapes.

# -----------------------------------------------


# /////////////////////////////////////////////////////////////////////////////////////////////// #

#### ÉCRITURE
## ÉCRITURE DE CHEVRONS | CHEVRONS WRITING
# Affichage de chevrons avant une chaîne de caractères (par exemple).
TXT_TAB=">>>>"

# -----------------------------------------------

## ÉCRITURE DE TEXT | TEXT WRITING
# Affichage de chevrons suivant l'encodage de la couleur d'une chaîne de caractères.
TXT_G_TAB="$COL_GREEN$TXT_TAB$TXT_TAB"		# Encodage de la couleur en vert et affichage de 4 * 2 chevrons.
TXT_R_TAB="$COL_RED$TXT_TAB$TXT_TAB"		# Encodage de la couleur en rouge et affichage de 4 * 2 chevrons.
TXT_Y_TAB="$COL_YELLOW$TXT_TAB"				# Encodage de la couleur en jaune et affichage de 4 chevrons.

# -----------------------------------------------
