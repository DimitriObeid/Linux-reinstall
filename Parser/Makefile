##
## Fichier
## Makefile
## Description:
## Fichier de type Makefile, permettant de compiler tout un projet avec toutes les options souhaitées, le tout en une commande
##

SRC		=	main.cpp	\
			parser.cpp

OBJ		=	$(SRC:.cpp=.o)

NAME	=	parser

MV		=	mv

CC		=	g++

RM		=	rm -f

CFLAGS	+=	-Wextra -Wall -I./include

all: $(OBJ)
	$(CC) -o $(NAME) $(OBJ) $(CFLAGS)
	$(MV) $(OBJ) obj/

clean:
	$(RM) obj/*.o

debug:
	$(CC) $(NAME) $(CFLAGS) $(SRC)

fclean:
	$(RM) obj/*.o

re: fclean all

.PHONY: all clean fclean re
