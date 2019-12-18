#include "fenetreGUI.h"
using namespace std;

FenetreGUI::FenetreGUI() : QWidget()
{
    setFixedSize(300, 150);
}

FenetreGUI::quitter()
{
    // Construction du bouton
    m_bouton = new QPushButton("Quitter", this);

    m_bouton->setFont(QFont("Ubuntu Condensed", 12));   // Ajout d'une police d'écriture au texte du bouton, avec sa taille
    m_bouton->setToolTip("Cliquez sur ce bouton");         // Affichage d'un texte d'aide si le curseur est placé sur le bouton
    m_bouton->setCursor(Qt::PointingHandCursor);        // Afficher le curseur pointant son index, pour bien montrer que le bouton est cliquable
    m_bouton->move(60, 50);

    // Connexion du clic du bouton à la fermeture de l'application
    QObject::connect(m_bouton, SIGNAL(clicked(bool)), qApp, SLOT(quit()));
}

FenetreGUI::~FenetreGUI()
{

}
