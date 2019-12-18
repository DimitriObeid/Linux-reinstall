/*
** Nom du fichier :
** "gui.h"
** Description :
** Fichier d'en-tête permettant d'utiliser des fonctions de plusieurs fichiers différents dans un fichier
*/

/* Pour ne définir le contenu du fichier header (tout ce qui est situé entre le "ifndef" (if not defined) et le "endif")
qu'une seule et unique fois et éviter de le redéfinir dans tous les fichiers source C (optimisation et gain de temps) */
#ifndef GUI_H_
#define GUI_H_

#include <gtk/gtk.h>
#include <unistd.h>

// Nombre de catégories
#define NB_CATS 2


#endif // GUI_H_
