import openpyxl
import csv
import os

excel = openpyxl.load_workbook("carmen_sightings_20220629061307.xlsx")
  
# select the active sheet
for sheet in excel.sheetnames:
  
  # writer object is created
  with open(f"{os.getcwd()+'/seeds'}/{sheet}.csv", 'w', newline="", encoding='utf-8') as output_file:
    csv_writer = csv.writer(output_file)
    
    rows = excel[sheet].rows
    for r in rows:
        csv_writer.writerow([cell.value for cell in r])
      
