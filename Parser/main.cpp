/*
** Fichier :
** main.cpp
** Description :
** Fichier contenant la fonction principale du parseur
*/

#include "parser.h"
using namespace std;

int main(int argc, char *argv[])
{
	ifstream stream(argv[1], ios::in);

	Parser parseString;

	if (argc != 2)
	{
		cout << "Erreur : Seulement deux arguments sont attendus, ni plus ni moins" << endl;
	}

	if (stream) {
		parseString.parseFunction();
	}
	else {
		cout << "ERREUR FATALE : Le fichier \"" << argv[1] << "\" n'existe pas" << endl;
		return 84;
	}
	return 0;
}
