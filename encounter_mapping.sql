

CREATE OR REPLACE FUNCTION i_spy_encounter_mapping ()
 RETURNS VOID AS $body$
BEGIN

insert into di3crcdata.encounter_mapping(encounter_ide, encounter_ide_source, project_id, encounter_num, patient_ide, patient_ide_source, encounter_ide_status, upload_date, download_date, import_date, sourcesystem_cd, upload_id)
   select 'fabricated_for_' || d.subjectid as encounter_ide, 'i_spy_tcia_patient_clinical_subset' as encounter_ide_source, 'Dicubed' as project_id, nextval('di3sources.encounter_num_seq') as encounter_num, cast(d.subjectid as varchar) as patient_ide, 
        'i_spy_tcia_patient_clinical_subset' as patient_ide_source, 'Active' as encounter_ide_status,  current_timestamp as upload_date, current_timestamp as download_date, current_timestamp as update_date,
         'TCIA_ISPY1_Clinical' as sourcesystem_cd, 10 as upload_id 
from di3sources.i_spy_tcia_patient_clinical_subset d where d.subjectid is not null;   
 
END;
$body$
LANGUAGE PLPGSQL;

