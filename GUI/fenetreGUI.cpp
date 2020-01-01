#include "fenetreGUI.h"
using namespace std;

FenetreGUI::FenetreGUI() : QWidget()
{
    setFixedSize(750, 600);
    boutonExecuter();
    boutonQuitter();
}

// Création d'un bouton basique. Les informations concernant le bouton sont à placer en argument lors de l'appel de la méthode
void FenetreGUI::boutonBase(string nom, string police, int taillePolice, string aide, int x, int y)
{
    m_bouton = new QPushButton(nom, this);              // Construction du bouton
    m_bouton->setFont(QFont(police, taillePolice));     // Ajout d'une police d'écriture au texte du bouton, avec sa taille
    m_bouton->setToolTip(aide);                         // Affichage d'un texte d'aide si le curseur est placé sur le bouton
    m_bouton->setCursor(Qt::PointingHandCursor);        // Afficher le curseur pointant son index, pour bien montrer que le bouton est cliquable
    m_bouton->move(x, y);
}

// Création du bouton d'exécution du script
void FenetreGUI::boutonExecuter()
{
    // Appel de la méthode de création basique d'un bouton
    boutonBase("Exécuter", "Ubuntu Condensed", 12,
               "Cliquez sur ce bouton pour exécuter le script",
               550, 550);

    QObject::connect(m_bouton, SIGNAL(clicked(bool)), qApp, SLOT(quit()));
}

// Création du bouton "Quitter" pour quitter le script
void FenetreGUI::boutonQuitter()
{
    // Construction du bouton
    boutonBase("Quitter", "Ubuntu Condensed", 12,
               "Cliquez sur ce bouton pour quitter le programme",
               650, 550);

    // Connexion du clic du bouton à la fermeture de l'application
    QObject::connect(m_bouton, SIGNAL(clicked(bool)), qApp, SLOT(quit()));
}

FenetreGUI::~FenetreGUI()
{

}
