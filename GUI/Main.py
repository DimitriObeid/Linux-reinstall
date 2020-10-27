#!/usr/bin/env python3

# *** Importing Tkinter modules
from tkinter import *
# from tkinter import ttk


# *** Importing variables /
# from Translate import welcomeGUI*

# *** Code
def main():
    app = Tk()  # Window creation

    # Defining window geometry
    # Window dimensions must be written as a string, as a single argument.
    # The multiplier isn't the star character '*', but the latin alphabet character 'x'
    app.geometry('300x300')
    app['bg'] = 'black'

    # Program's main loop
    app.mainloop()

    exit(0)


main()
