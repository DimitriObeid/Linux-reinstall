#!/bin/bash

draw_header_line()
{
	cols=$(tput cols)
	char=$1
	color=$2
	if test "$color" != ""; then
		echo -ne $color
	fi
	for i in $(eval echo "{1..$cols}"); do
		echo -n $char
	done
	if test "$color" != ""; then
		echo -ne $C_RESET
	fi
}

# Affichage du texte des headers
script_header()
{
	color=$2
	if test "$color" = ""; then
        # Définition de la couleur des lignes
		color=$C_HEADER_LINE
	fi

	# Décommenter la ligne ci dessous pour activer le chronomètre avant l'affichage du header
#    $SLEEP
	echo -ne $color    # Afficher la ligne du haut selon la couleur de la variable $color
	draw_header_line $LINE_CHAR
    # Commenter la ligne du dessous pour que le prompt "##>" soit de la même couleur que la ligne du dessus
#    echo -ne $C_RESET
	echo "##> "$1
	draw_header_line $LINE_CHAR
	echo -ne $color
	$SLEEP_TAB
}

LINE_CHAR="-"
C_ROUGE=$(tput setaf 196)
C_VERT=$(tput setaf 82)
C_JAUNE=$(tput setaf 226)
C_RESET=$(tput sgr0)
C_HEADER_LINE=$(tput setaf 6)

draw_header_line_test()
{
    cols=$(tput cols)
	char=$1
	color=$2
	if test "$color" != ""; then
		echo -ne $color
	fi
	for i in $(eval echo "{1..$cols}"); do
		echo -n $char
	done
	if test "$color" != ""; then
		echo -ne $C_RESET
	fi
}

script_header_test()
{
#	end_color="$C_HEADER_LINE"
#	$end_color=$3
    color=$2
	if test "$color" = ""; then
        # Définition de la couleur des lignes
		color=$C_HEADER_LINE
	fi

	echo ""
	# Décommenter la ligne ci dessous pour activer le chronomètre avant l'affichage du header
#    $SLEEP
	echo -ne $color    # Afficher la ligne du haut selon la couleur de la variable $color
	draw_header_line_test $LINE_CHAR
    # Commenter la ligne du dessous pour que le prompt "##>" soit de la même couleur que la ligne du dessus
#    echo -ne $C_RESET
	echo "##> "$1 $color
	draw_header_line_test $LINE_CHAR
	echo -ne $C_RESET
	echo ""
	$SLEEP_TAB
}

script_header_test "TEST"
echo "test"
