#include "WindowGUI.h"
using namespace std;

WindowGUI::WindowGUI() : QWidget()
{
    setFixedSize(750, 600);
    buttonExecute();
    buttonQuit();
}

// Création d'un bouton basique. Les informations concernant le bouton sont à placer en argument lors de l'appel de la méthode
void WindowGUI::buttonBase(string name, string font, int fontSize, string help, int x, int y)
{
    m_button = new QPushButton(name, this);             // Construction du bouton
    m_button->setFont(QFont(font, fontSize));           // Ajout d'une police d'écriture au texte du bouton, avec sa taille
    m_button->setToolTip(help);                         // Affichage d'un texte d'aide si le curseur est placé sur le bouton
    m_button->setCursor(Qt::PointingHandCursor);        // Afficher le curseur pointant son index, pour bien montrer que le bouton est cliquable
    m_button->move(x, y);
}

// Création du bouton d'exécution du script
void WindowGUI::buttonExecute()
{
    // Appel de la méthode de création basique d'un bouton
    buttonBase("Exécuter", "Ubuntu Condensed", 12,
               "Cliquez sur ce bouton pour exécuter le script",
               550, 550);

    QObject::connect(m_button, SIGNAL(clicked(bool)), qApp, SLOT(quit()));  // Pour l'instant, ce bouton ne fait que quitter la fenêtre
}

// Création du bouton "Quitter" pour quitter le script
void WindowGUI::buttonQuit()
{
    // Construction du bouton
    buttonBase("Quitter", "Ubuntu Condensed", 12,
               "Cliquez sur ce bouton pour quitter le programme",
               650, 550);

    // Connexion du clic du bouton à la fermeture de l'application
    QObject::connect(m_button, SIGNAL(clicked(bool)), qApp, SLOT(quit()));
}

WindowGUI::~WindowGUI()
{

}
