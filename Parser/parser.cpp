/*
** Fichier :
** parser.cpp
** Description
** Fichier servant à parser le fichier script souhaité
*/

#include "parser.h"
using namespace std;

Parser::Parser() : m_function(), m_scriptString(), m_var()
{

}

void Parser::parseFunction()
{
	string str;
    string delim("()");
	string functionName = str.substr(0, str.find(delim));

	cout << functionName << endl;
}

Parser::~Parser()
{

}
