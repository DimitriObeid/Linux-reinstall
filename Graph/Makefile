# J'ai créé ce Makefile pour compiler les fichiers avec toutes les options de compilation
# nécessaires à la création d'une fenêtre créée à partir du framework GTK+3

# Chemin vers le dossier du projet
PATH_TO_PROJ	=	$(HOME)/Bureau/Linux-reinstall/

# Fichiers source
SRC		=	main.c

# Fichier exécutable à créer
EXE		=	gui.elf

# Commande de compilation
CC		=	gcc

# Commande de copie de fichiers
CP		=	cp

# Commande de suppression de fichiers
RM		=	rm -f

CFLAGS	=	-Wextra -Wall -I. -L./lib/-lib

all:
	$(MAKE) -C lib/
	$(CC) `pkg-config --cflags gtk+-3.0` $(SRC) -o $(EXE) `pkg-config --libs gtk+-3.0`
	$(CP) $(EXE) $(PATH_TO_PROJ)/Bêta

debug:
	$(MAKE) -C lib/ debug
	$(CC) $(EXEC) $(CFLAGS) $(SRC)

clean:
	$(MAKE) -C lib/ clean
	$(RM) *.o

fclean: clean
	$(MAKE) -C lib/ fclean
	$(RM) $(EXE)
	$(RM) ../Bêta/$(EXE)

re: fclean all

.PHONY: all clean fclean re
