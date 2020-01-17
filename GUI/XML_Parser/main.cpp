#include "xml_gui.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    WindowGUI gui;
    gui.show();

    return app.exec();
}
