#!/usr/bin/env python3

# *** Importing modules
from os import path
import csv

# *** Variables
TRANSLF = 'Translations.csv'     # Translation file

# *** Code
# def GetRow(target, word):


def GetCSVCol(target, col):
    if col > 2:
        print("Error : Invalid column index")
        exit(84)
    with open(target, 'r', newline='') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')

        for lines in csv_reader:
            print(lines[col])


if path.exists(TRANSLF):
    GetCSVCol(TRANSLF, 3)
else:
    print("Error : The file", TRANSLF, "doesn't exists")
    exit(84)
