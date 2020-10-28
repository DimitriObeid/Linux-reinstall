#!/usr/bin/env python3

# *** Importing modules
from os import path
import csv

# *** Variables
TRANSLF = 'Translations.csv'     # Translation file

# * Language
default_lang = 'fr'
current_lang = default_lang

'''
# * CSV file translations
# Adding package window
Add packages window = GetTranslateCSVInfos()
addPackGUI_BtnAddPack = GetTranslateCSVInfos()
addPackGUI_BtnAddPackMsg = GetTranslateCSVInfos()
addPackGUI_BtnAddPPA = GetTranslateCSVInfos()
addPackGUI_BtnAddPPAMsg = GetTranslateCSVInfos()
addPackGUI_Cancel = GetTranslateCSVInfos()
addPackGUI_CancelMsg = GetTranslateCSVInfos()

# Main menu window
welcomeGUI_BntAdd = GetTranslateCSVInfos()
welcomeGUI_BtnAddMsg = GetTranslateCSVInfos()
welcomeGUI_BtnQuit = GetTranslateCSVInfos()
welcomeGUI_BtnQuitMsg = GetTranslateCSVInfos()
welcomeGUI_BtnVal = GetTranslateCSVInfos()
welcomeGUI_BtnValMsg = GetTranslateCSVInfos()
welcomeGUI_WinMsg1 = GetTranslateCSVInfos()
welcomeGUI_WinMsg2 = GetTranslateCSVInfos()
welcomeGUI_WinName = GetTranslateCSVInfos()
'''

# *** Code


# This function search the matching column and row
def GetTranslateCSVInfos(col, row):
    if path.exists(TRANSLF):
        with open(TRANSLF, 'r') as csv_file:
            # Columns
            csv_col_reader = csv.DictReader(csv_file, delimiter=',')
            verif_col = ['fr', 'en']

            # Rows
            csv_row_reader = csv.DictReader(csv_file, delimiter='\n')
            verif_row = row

            # Getting columns first
            if col in verif_col:
                for lines_c in csv_col_reader:
                    print(lines_c[col])

                    # Getting row last
                    if row in verif_row:
                        for lines_r in csv_row_reader:
                            print(lines_r[row])
                    else:
                        print("One of the CSV file's row name doesn't match to an expected value")
                        csv_file.close()
                        exit(84)
                csv_file.close()

            else:
                print("One of the CSV file's column name doesn't match to an expected value")
                csv_file.close()
                exit(84)
    else:
        print("Error : The file", TRANSLF, "doesn't exists")
        exit(84)


GetTranslateCSVInfos('fr', 'welcomeGUI_WinMsg1')
