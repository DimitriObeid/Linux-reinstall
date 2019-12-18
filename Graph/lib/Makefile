# J'ai créé ce Makefile pour compiler les fichiers de librairies pour y créer une archive

SRC		=	str_to_word_array.c

OBJ		=	$(SRC:.c=.o)

ARCHIVE	=	lib.a

RM		=	rm -f

CFLAGS	+=	-Wextra -Wall -I../

all: $(OBJ)
	ar -rc $(ARCHIVE) $(OBJ)

$(ARCHIVE): $(OBJ)

clean:
	$(RM) $(OBJ)

fclean: clean
	$(RM) $(ARCHIVE)

re: fclean all

.PHONY: all clean fclean re
