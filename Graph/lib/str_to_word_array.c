/*
** Nom du fichier :
** str_to_word_array.c
** Description
** Transformer une chaîne de caractères contenant plusieurs mots en un tableau de chaînes de caractères
*/

#include "gui.h"

void free_word_arr(char **arr)
{
    for (int i = 0; arr[i]; i++)
        free(arr[i]);
    free(arr);
}

static char *get_next_word(char const *str, int nb, int len, char delim)
{
    int i = 0;
    char *word = malloc(sizeof(char) * (len + 1));

    if (!word)
        return (NULL);
    for (; str[i] && nb > 0; i++)
        if (str[i] == delim)
            nb--;
    if (i != 0 && str[i - 1] != delim)
        i--;
    for (int j = 0; str[i] && str[i] != '\n' && str[i] != delim; i++, j++)
        word[j] = str[i];
    word[len] = '\0';
    return (word);
}

static int get_word_len(char const *str, char delim, int nb)
{
    int res = 0;
    int i = 0;

    if (!str)
        return (0);
    for (i = 0; str[i] && nb > 0; i++)
        if (str[i] == delim)
            nb--;
    if (i != 0 && str[i - 1] != delim)
        i--;
    for (; str[i] && str[i] != '\n' && str[i] != delim; i++)
        res++;
    return (res);
}

static int get_rows(char const *str, char delim)
{
    int res = 0;
    int i = 0;

    if (!str)
        return (0);
    for (i = 0; str[i]; ++i)
        if (str[i] == delim)
            ++res;
    if (str[i - 2] == delim)
        --res;
    return (res + 1);
}


char **str_to_word_array(char const *str)
{
	// Délimitation
    char delim = ' ';
    int rows = get_rows(str, delim);
    int cols = 0;
    char **arr = NULL;

    if (rows <= 0)
        return (NULL);
    arr = malloc(sizeof(char *) * (rows + 1));
    if (!arr)
        return (NULL);
    for (int i = 0; i < rows; ++i) {
        cols = get_word_len(str, delim, i);
        if (cols <= 0)
            return (NULL);
        arr[i] = get_next_word(str, i, cols, delim);
        if (!arr[i])
            return (NULL);
    }
    arr[rows] = NULL;
    for (int i = 0; arr[i] != NULL ; i++) {
        printf("%s\n", arr[i]);
    }
    printf("%d\n", rows);
    printf("%d\n", cols);
    free_word_arr(arr);
    return (arr);
}
