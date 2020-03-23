import requests
import datetime
import psycopg2
import json
import pprint
from urllib.parse import urlencode
import string
import sys

def tcia_format(s):
    if s.startswith('UCSF'):
        r=s.replace('_','-')
        return r
    elif s.startswith('BreastDX'):
        r=s.replace('BreastDX', 'BreastDx')
        return r
    return s


conn = psycopg2.connect(dbname='i2b2', user='di3sources', password='', host='ncidb-d115.nci.nih.gov', port=5492)
cur = conn.cursor()

client_id = ""
client_secret = ""
token_url = "https://public-dev.cancerimagingarchive.net/nbia-api/oauth/token"
simple_search_url = "https://public-dev.cancerimagingarchive.net/nbia-api/services/getSimpleSearch"
series_url = "https://public-dev.cancerimagingarchive.net/nbia-api/services/getStudyDrillDown"
username=""
password=""

r = requests.post(token_url, {'username':username, 'client_id':client_id, 'client_secret':client_secret, 'grant_type':'password', 'password':""})
print(r.text)
token_data = r.json()
pprint.pprint(token_data)
my_token = token_data['access_token']


header = {'Authorization':'Bearer '+my_token}
print(header)
#payload = {'criteriaType0':'PatientCriteria', 'value0':'W20'}
#r = requests.post(simple_search_url, headers=header, data=payload)
#ret_data = r.json()
#pprint.pprint(ret_data) 


sql = '''select patient_num, tcia_subject_id from di3crcdata.patient_dimension'''
cur.execute(sql) 
patients = cur.fetchall()
conn.commit()
print(patients)
insert_sql = '''insert into di3crcdata.dcm_study_dimension(patient_num, 
                          study_date,
                          id,
                          description,
                          studyId)
                          values(%s,%s,%s,%s,%s)'''

insert_series_sql = ''' insert into di3crcdata.dcm_series_dimension (
  patient_num,
  annotations_flag,
  annotations_size,
  data_provenance_site_name,
  description,
  exact_size,
  manufacturer,
  manufacturer_model_name,
  max_frame_count,
  modality,
  number_images,
  patient_id,
  patient_pk_id,
  project,
  series_id,
  series_number,
  series_pk_id,
  series_uid,
  software_version,
  study_date,
  study_desc,
  studyid,
  study_pk_id,
  study_id,
  total_size_for_all_images )
  values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) '''

for p in patients:
    print("-----------------------------------")
    print(p)
    payload = {'criteriaType0':'PatientCriteria', 'value0':tcia_format(p[1])}
    r = requests.post(simple_search_url, headers=header, data=payload)
    ret_data = r.json()
    pprint.pprint(ret_data) 
    if len(ret_data) > 0:
        pprint.pprint(ret_data[0]['totalNumberOfSeries'])
        pprint.pprint(ret_data[0]['totalNumberOfStudies'])
        studies = ret_data[0]['studyIdentifiers']
        for s in studies:
            pprint.pprint(s)
            studyIdentifier = s['studyIdentifier']
            print(studyIdentifier)
            series_info = requests.post(series_url, headers=header, data={"list":s['seriesIdentifiers']} ).json()[0]
            pprint.pprint(series_info)
            study_date = datetime.datetime.fromtimestamp(series_info['date']/1000)
            cur.execute(insert_sql, [p[0], study_date, series_info['id'], series_info['description'], series_info['studyId']])
            conn.commit()
            series_list = series_info['seriesList']
            print("series list ")
            pprint.pprint(series_list)
            for series in series_list:
               print("series")
               pprint.pprint(series)
               cur.execute(insert_series_sql, [p[0], series['annotationsFlag'], series['annotationsSize'],
                                    series['dataProvenanceSiteName'],
                                    series['description'],
                                    series['exactSize'],
                                    series['manufacturer'],
                                    series['manufacturerModelName'],
                                    series['maxFrameCount'],
                                    series['modality'],
                                    series['numberImages'],
                                    series['patientId'],
                                    series['patientPkId'],
                                    series['project'],
                                    series['seriesId'],
                                    series['seriesNumber'],
                                    series['seriesPkId'],
                                    series['seriesUID'],
                                    series['softwareVersion'],
                                    datetime.datetime.fromtimestamp(series['studyDate']/1000) if series['studyDate'] else None,
                                    series['studyDesc'],
                                    series['studyId'],
                                    series['studyPkId'],
                                    series['study_id'],
                                    series['totalSizeForAllImagesInSeries'] ] )
               conn.commit()
    

cur.close()
conn.close()

