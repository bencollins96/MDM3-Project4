#formatter.py

import os
import re
import csv

for file in os.listdir('Data/'):



    new_rows = [] # a holder for our modified rows when we make them
    changes = {   # a dictionary of changes to make, find 'key' substitue with 'value'
        ' ' : '', # I assume both 'key' and 'value' are strings
            }

    with open('Data/' + file, 'rb') as f:
        reader = csv.reader(f) # pass the file to our csv reader
        for row in reader:     # iterate over the rows in the file
            new_row = row      # at first, just copy the row
            for key, value in changes.items(): # iterate over 'changes' dictionary
                new_row = [ x.replace(key, value) for x in new_row ] # make the substitutions
            new_rows.append(new_row) # add the modified rows

    with open('Data/' + file, 'wb') as f:
        # Overwrite the old file with the modified rows
        writer = csv.writer(f)
        writer.writerows(new_rows)

