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
	string const shellFile(argv[1]);
	ifstream stream(shellFile.c_str());

	Parser parseString;

	if (stream) {
		parseString.parseFunction();
	}
	else {
		cout << "ERREUR FATALE : Le fichier \"" << argv[1] << "\" n'existe pas" << endl;
		return 84;
	}
	return 0;
}
