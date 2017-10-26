

CREATE OR REPLACE FUNCTION i_spy_patient_mapping ()
 RETURNS VOID AS $body$
BEGIN

insert into di3crcdata.patient_mapping(patient_ide, patient_ide_source, patient_num, patient_ide_status, project_id, upload_date, update_date, download_date, sourcesystem_cd, upload_id)
select cast(d.subjectid as varchar) as patient_ide, 'i_spy_tcia_patient_clinical_subset' as patient_ide_source, nextval('di3crcdata.patient_num_seq') as patient_num, 'Active' as patient_ide_status, 'Dicubed' as project_id, 
       current_timestamp as upload_date, current_timestamp as download_date, current_timestamp as update_date, 'TCIA_ISPY1_Clinical' as sourcesystem_cd, nextval('di3crcdata.upload_status_upload_id_seq') as upload_id
   from di3sources.i_spy_tcia_patient_clinical_subset d where d.subjectid is not null;
 
END;
$body$
LANGUAGE PLPGSQL;

