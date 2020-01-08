/*
** Fichier :
** main.cpp
** Description :
** Fichier contenant la fonction principale du parseur (merci StackOverflow)
*/

#include "parser.h"
using namespace std;

void parseFunction()
{
	string str;
    string delim("()");
	string functionName = str.substr(0, str.find(delim));

	cout << functionName << endl;
}

int main(int argc, char *argv[])
{
	if (argc != 2) {
		cout << "Erreur : Seulement deux arguments sont attendus, ni plus ni moins" << endl;
	}
	
	ifstream stream(argv[1]);
	stream.open(argv[1]);

	char c;

	int counter;
	const int fieldCount(5);

	string field[fieldCount];
	string buffer("");
	string str;

	// Tant que la dernière ligne du fichier n'est pas atteinte (EOF = End Of File)
	while(! stream.eof()) {
		getline(stream, str);
		counter++;
	}
	counter--;

	// 
	stream.clear();
	// Retour au début du fichier
	stream.seekg(ios_base::beg);

	if (stream) {
		for (int i(0); i < counter; i++) {
			for (int j(0); j < fieldCount; j++) {
				stream.ignore();
				while (stream.good() && (c = stream.get()) != '"') {
					buffer += c;
					parseFunction();
				}
				field[j] = buffer;
				cout << buffer << endl;
				buffer = "";
				if (j != fieldCount - 1) {
					stream.ignore();
				}
			}
		}
		
	}
	else {
		cout << "ERREUR FATALE : Le fichier \"" << argv[1] << "\" n'existe pas" << endl;
		return 84;
	}
	
	return 0;
}
