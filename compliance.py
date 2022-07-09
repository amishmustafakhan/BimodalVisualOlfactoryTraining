#!/usr/bin/env python
# coding: utf-8
#! python3

# VOLT.py - Monitor individial participants' trial compliance by viewing timestamps associated with web application usage.

import json, requests, sys, os, csv
from styleframe import StyleFrame
import pandas as pd

#Set working directory
os.chdir('/') 

#Load JSON data into a Python variable
with open('/volt-data-store-export.json', encoding = 'utf-8') as f:
    voltPy = json.load(f)

#Iterate through data dictionary to pull identifier + enrollment date + session dates
for key, value in voltPy.items():
    x = []
    x.append(key)
    for e in value:
        if 'notes' in e:
            for i in value['notes'].values():
                if 'content' in i:
                    x.append(i['content'])
            with open('qualitative.csv', 'a') as myfile:
                wr = csv.writer(myfile)
                wr.writerow(x)

import pandas as pd
import openpyxl

#Tidy new dataframe which now contains compliance as timestamps corresponding to web application usage
compliance = pd.read_csv('qualitative.csv', header = None, sep = 'delimiter')
compliance = compliance[0].str.split(',', expand=True)

x = len(compliance.columns) - 1
y = ['firebasekey']
z = list(range(0 , x))
w = y + z
compliance.columns = w

#Read dataframe containing keys that link study participants' web application profiles to Firebase cloud server
firebaseDeidentify = pd.read_csv('firebaseDeidentify.csv')

#Left join
complianceLogin = pd.merge(firebaseDeidentify, compliance, how = 'left', on = 'firebasekey')

#Read datafram containing keys that link study participants' REDCap data to web application profiles
volt_xlsx = pd.read_excel('VOLT_keeper.xlsx', 'Enrolled', index_col=None, engine = 'openpyxl')

#Left join
complianceIdentify = pd.merge(complianceLogin, volt_xlsx, how = 'left', on = 'login')
complianceIdentify = complianceIdentify.iloc[:,0:x+4]

#Auto-adjust the cells so all data are visible, and write to XLSX file
excel_writer = StyleFrame.ExcelWriter('complianceIdentify.xlsx')
sf = StyleFrame(complianceIdentify)
sf.to_excel(excel_writer=excel_writer, row_to_add_filters=0,
            columns_and_rows_to_freeze='B2')
excel_writer.save()
