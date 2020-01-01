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
#ifndef FENETREGUI_H
#define FENETREGUI_H

#include <QApplication>
#include <QMessageBox>
#include <QPushButton>
#include <QWidget>

//  * Comme la classe "FenetreGUI" hérite de la classe "QWidget", on pense à inclure la définition de cette dernière.
class FenetreGUI : public QWidget
{
public:
    FenetreGUI();               // Constructeur
    void FenetreGUI::boutonBase(string nom, string police, int taillePolice, string aide, int x, int y);
    void boutonExecuter();      // Définition du bouton d'exécution du script de réinstallation
    void boutonQuitter();       // Définition du bouton "quitter"
    ~FenetreGUI();              // Déconstructeur

public slots:
    void ouvrirFenetre();

private:
    QPushButton *m_bouton;
};

#endif // FENETREGUI_H
