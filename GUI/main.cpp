#include "fenetreGUI.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    FenetreGUI gui;
    gui.show();

    return app.exec();
}
