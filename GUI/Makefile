##
## Fichier
## Makefile
## Description:
## Fichier de type Makefile, permettant de compiler tout un projet avec toutes les options souhaitées, le tout en une commande
##

SRC		=	main.c

OBJ		=	$(SRC:.c=.o)

NAME	=	gui.exe

MV		=	mv

CC		=	gcc

RM		=	rm -rf

CFLAGS	+=	-Wextra -Wall -I./include

all: $(OBJ)
	$(CC) $(CFLAGS) -std=c99 $(pkg-config --libs --cflags gtk+-3.0) $(SRC) -o $(NAME)
	mkdir obj/
	$(MV) $(OBJ) obj/

clean:
	$(RM) obj/*.o

debug:
	$(CC) $(NAME) $(CFLAGS) $(SRC)

fclean:
	$(RM) obj/

re: fclean all

.PHONY: all clean fclean re
