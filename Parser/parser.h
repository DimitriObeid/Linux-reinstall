/*
 *  Nom du fichier :
 *      script.h
 *  Description :
 *      Fichier d'en-tête contenant les méthodes d'intéractions avec le script
*/

#ifndef SCRIPT_H
#define SCRIPT_H

#include <fstream>
#include <iostream>
#include <string>
#include <vector>

class Parser
{
public:
    Parser();
    void parseFunction();
    ~Parser();

private:
    std::string m_function;         // Attribut de récupération de nom de fonction
    std::string m_scriptString;     // Attribut de récupération de chaînes de caractères
    std::string m_var;              // Attribut de récupération de nom de variable
};

#endif // SCRIPT_H
