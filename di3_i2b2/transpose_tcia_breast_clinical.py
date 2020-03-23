#
# A quick script to create a transposed version the TCIA Breast clinical data public 
# for loading into a database table
#

import openpyxl
import sys
import os.path
import os
import collections
import csv

f  = '/Users/hubert/Dropbox/EssexManagement/DICUBED/data_sources/Breast_Diagnosis/TCIA Breast clinical data public 7_16_11.xlsx'

wb = openpyxl.load_workbook(f,
                            data_only=True)

sn=wb.get_sheet_names()
print sn
sheet = wb.get_sheet_by_name('Sheet1') 
h1 = ''
h2 = ''
csv_list = []
csvfile = open('TCIA_Breast_clincial_data_public.csv', 'wb') 
writer = csv.writer(csvfile, delimiter=',', quotechar = '"', quoting=csv.QUOTE_MINIMAL)
for r in sheet.rows:
    heading1 = r[0].value
    if heading1:
        h1 = heading1
    heading2 = r[1].value
    if heading2:
        h2 = heading2
    else:
        h2 = ''
    heading = h1 + ' ' + h2 
#    print heading
    csv_list.append(heading)
#    print str(r[0].row)
writer.writerow(csv_list)
#print csv_list
csv_list = []
for c in sheet.columns:
    if c[0].column != 'A' and c[0].column != 'B':
        print c[0].value
        for cell in c:
            csv_list.append(cell.value)
#        print csv_list 
        writer.writerow(csv_list)
        csv_list = []


