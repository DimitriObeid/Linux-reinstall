/*
 *  Nom du fichier :
 *      window.h
 *  Description :
 *      Fichier d'en-tête pour les fonctions de ma fenêtre
*/

/*
 * Tout ce qui se trouve entre le "ifndef" et le "endif" ne sera défini
 * qu'une seule et unique fois. C'est à dire que rien ne sera redéfini
 * qu'à chaque appel de ce fichier header dans tous les fichiers source C++.
*/
#ifndef WindowGUI_H
#define WindowGUI_H

#include <QApplication>
#include <QMessageBox>
#include <QPushButton>
#include <QWidget>

#include <string>

//  * Comme la classe "WindowGUI" hérite de la classe "QWidget", on pense à inclure la définition de cette dernière.
class WindowGUI : public QWidget
{
public:
    WindowGUI();                // Constructeur
    void WindowGUI::buttonBase(string name, std::string font, int fontSize, std::string help, int x, int y);
    void buttonExecute();       // Définition du bouton d'exécution du script de réinstallation
    void buttonQuit();          // Définition du bouton "quitter"
    ~WindowGUI();               // Déconstructeur

public slots:
    void openWindow();

private:
    QPushButton *m_button;
};

#endif // WindowGUI_H
