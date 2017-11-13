

CREATE OR REPLACE FUNCTION dicubed_patient_mapping ()
 RETURNS VOID AS $body$
 DECLARE upload_id_v int;
BEGIN

delete from di3crcdata.patient_mapping; 

alter sequence patient_num_seq restart with 1;

select nextval('di3crcdata.upload_status_upload_id_seq') into upload_id_v;

insert into di3crcdata.patient_mapping(patient_ide, patient_ide_source, patient_num, patient_ide_status, project_id, upload_date, update_date, download_date, sourcesystem_cd, upload_id)
select cast(d.subjectid as varchar) as patient_ide, 
       'i_spy_tcia_patient_clinical_subset' as patient_ide_source, 
        nextval('patient_num_seq') as patient_num, 
        'Active' as patient_ide_status, 
        'Dicubed' as project_id, 
       current_timestamp as upload_date, current_timestamp as download_date, current_timestamp as update_date, 
       'TCIA_ISPY1_Clinical' as sourcesystem_cd, 
       upload_id_v  as upload_id
   from di3sources.i_spy_tcia_patient_clinical_subset d where d.subjectid is not null;
  
select nextval('di3crcdata.upload_status_upload_id_seq') into upload_id_v;

insert into di3crcdata.patient_mapping(patient_ide, patient_ide_source, patient_num, patient_ide_status, project_id, upload_date, update_date, download_date, sourcesystem_cd, upload_id)
select cast(d.breast_dx_case as varchar) as patient_ide, 
       'tcia_breast_clinical_data' as patient_ide_source, 
        nextval('patient_num_seq') as patient_num, 
        'Active' as patient_ide_status, 
        'Dicubed' as project_id, 
       current_timestamp as upload_date, current_timestamp as download_date, current_timestamp as update_date, 
       'TCIA_Breast-Diagnosis_Sheet1' as sourcesystem_cd, 
       upload_id_v  as upload_id
   from di3sources.tcia_breast_clinical_data d where d.breast_dx_case is not null;
END;
$body$
LANGUAGE PLPGSQL;

