#!/usr/bin/env python3

# *** Importing Tkinter modules
from tkinter import *
import tkinter as tk
# from tkinter import ttk


# *** Importing variables /
# from Translate import welcomeGUI*

# *** Code
# * Window creation
app = tk.Tk()

# * Defining window geometry
# Window dimensions must be written as a string, as a single argument.
# The multiplier isn't the star character '*', but the latin alphabet character 'x'
app.geometry('300x300')
app['bg'] = 'black'


# * Creating frames to place the widgets esthetically
# For the action buttons
frame_btns = Frame(app, bd=1, relief=SUNKEN)
frame_btns.pack(padx=5, pady=5)

# For the language choice button
frame_lang = Frame(app, bd=1, relief=SUNKEN)
frame_lang.pack(padx=5, pady=5)

# For the welcoming text
frame_txt = Frame(app, bd=1, relief=SUNKEN)
frame_txt.pack(padx=5, pady=5)


# * Creating buttons
# Adding packages
btn_add = Button(frame_btns, text='Ajouter')
btn_add.pack(side=tk.BOTTOM)

# Language
btn_lang = Button(frame_lang, text='Langu(ag)e')
btn_lang.pack(side=tk.TOP)

# Quit
btn_quit = Button(frame_btns, text='Quitter', command=app.destroy)
btn_quit.pack(side=tk.LEFT)

# Validate
btn_valid = Button(frame_btns, text='Valider')
btn_valid.pack(side=tk.LEFT)


# * Program's main loop
app.mainloop()

exit(0)
