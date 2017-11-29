CREATE OR REPLACE FUNCTION dicubed_encounter_mapping ()
 RETURNS VOID AS $body$
 DECLARE upload_id_v int;
BEGIN

select nextval('di3crcdata.upload_status_upload_id_seq') into upload_id_v;

alter sequence encounter_num_seq restart with 1;

delete from di3crcdata.encounter_mapping;

insert into di3crcdata.encounter_mapping(encounter_ide, encounter_ide_source, project_id, encounter_num, 
                                         patient_ide, patient_ide_source, encounter_ide_status, upload_date, download_date, import_date, sourcesystem_cd, upload_id)
        select 'fabricated_for_' || d.subjectid as encounter_ide, 
        'i_spy_tcia_patient_clinical_subset' as encounter_ide_source, 
        'Dicubed' as project_id,  
         nextval('encounter_num_seq') as encounter_num, 
         cast(d.subjectid as varchar) as patient_ide, 
        'i_spy_tcia_patient_clinical_subset' as patient_ide_source, 
         'Active' as encounter_ide_status,  current_timestamp as upload_date, current_timestamp as download_date, current_timestamp as update_date,
         'TCIA_ISPY1_Clinical' as sourcesystem_cd, upload_id_v as upload_id 
from di3sources.i_spy_tcia_patient_clinical_subset d where d.subjectid is not null;   
 
select nextval('di3crcdata.upload_status_upload_id_seq') into upload_id_v;

insert into di3crcdata.encounter_mapping(encounter_ide, encounter_ide_source, project_id, encounter_num, 
                                         patient_ide, patient_ide_source, encounter_ide_status, upload_date, download_date, import_date, sourcesystem_cd, upload_id)
        select 'fabricated_for_' || d.breast_dx_case as encounter_ide, 
        'tcia_breast_clinical_data' as encounter_ide_source, 
        'Dicubed' as project_id,  
         nextval('encounter_num_seq') as encounter_num, 
         cast(d.breast_dx_case as varchar) as patient_ide, 
        'tcia_breast_clinical_data' as patient_ide_source, 
         'Active' as encounter_ide_status,  current_timestamp as upload_date, current_timestamp as download_date, current_timestamp as update_date,
         'TCIA_Breast-Diagnosis_Sheet1' as sourcesystem_cd, upload_id_v as upload_id 
from di3sources.tcia_breast_clinical_data d where d.breast_dx_case is not null;   

select nextval('di3crcdata.upload_status_upload_id_seq') into upload_id_v;

insert into di3crcdata.encounter_mapping(encounter_ide, encounter_ide_source, project_id, encounter_num, 
                                         patient_ide, patient_ide_source, encounter_ide_status, upload_date, download_date, import_date, sourcesystem_cd, upload_id)
        select 'fabricated_for_' || d.patient_id as encounter_ide, 
        'shared_clinical_and_rfs' as encounter_ide_source, 
        'Dicubed' as project_id,  
         nextval('encounter_num_seq') as encounter_num, 
         cast(d.patient_id as varchar) as patient_ide, 
        'shared_clinical_and_rfs' as patient_ide_source, 
         'Active' as encounter_ide_status,  current_timestamp as upload_date, current_timestamp as download_date, current_timestamp as update_date,
         'TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as sourcesystem_cd, upload_id_v as upload_id 
from di3sources.shared_clinical_and_rfs d where d.patient_id is not null;   

select nextval('di3crcdata.upload_status_upload_id_seq') into upload_id_v;

insert into di3crcdata.encounter_mapping(encounter_ide, encounter_ide_source, project_id, encounter_num, 
                                         patient_ide, patient_ide_source, encounter_ide_status, upload_date, download_date, import_date, sourcesystem_cd, upload_id)
        select 'fabricated_for_' || d.bcr_patient_barcode as encounter_ide, 
        'nwc_org_clinical_patient_brca' as encounter_ide_source, 
        'Dicubed' as project_id,  
         nextval('encounter_num_seq') as encounter_num, 
         cast(d.bcr_patient_barcode as varchar) as patient_ide, 
        'nwc_org_clinical_patient_brca' as patient_ide_source, 
         'Active' as encounter_ide_status,  current_timestamp as upload_date, d.form_completion_date as download_date, current_timestamp as update_date,
         'TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as sourcesystem_cd, upload_id_v as upload_id 
from di3sources.nwc_org_clinical_patient_brca   d where d.bcr_patient_barcode is not null;   

select nextval('di3crcdata.upload_status_upload_id_seq') into upload_id_v;

insert into di3crcdata.encounter_mapping(encounter_ide, encounter_ide_source, project_id, encounter_num, 
                                         patient_ide, patient_ide_source, encounter_ide_status, upload_date, download_date, import_date, sourcesystem_cd, upload_id)
        select d.bcr_followup_barcode as encounter_ide, 
        'nwc_org_clinical_follow_up_v4_0_brca' as encounter_ide_source, 
        'Dicubed' as project_id,  
         nextval('encounter_num_seq') as encounter_num, 
         cast(d.bcr_patient_barcode as varchar) as patient_ide, 
        'nwc_org_clinical_follow_up_v4_0_brca' as patient_ide_source, 
         'Active' as encounter_ide_status,  current_timestamp as upload_date, d.form_completion_date as download_date, current_timestamp as update_date,
         'TCIA_TCGA-BRCA-follow_up_v4_0_BRCA' as sourcesystem_cd, upload_id_v as upload_id 
from di3sources.nwc_org_clinical_follow_up_v4_0_brca   d where d.bcr_patient_barcode is not null;   

select nextval('di3crcdata.upload_status_upload_id_seq') into upload_id_v;

insert into di3crcdata.encounter_mapping(encounter_ide, encounter_ide_source, project_id, encounter_num, 
                                         patient_ide, patient_ide_source, encounter_ide_status, upload_date, download_date, import_date, sourcesystem_cd, upload_id)
with ivy_gap_pats as  (select distinct patient_id from ivy_report)
        select 'fabricated_for_' || d.patient_id as encounter_ide, 
        'ivy_report' as encounter_ide_source, 
        'Dicubed' as project_id,  
         nextval('encounter_num_seq') as encounter_num, 
         cast(d.patient_id as varchar) as patient_ide, 
        'ivy_report' as patient_ide_source, 
         'Active' as encounter_ide_status,  current_timestamp as upload_date, current_timestamp as download_date, current_timestamp as update_date,
         'IVY_GAP_ivy_report' as sourcesystem_cd, upload_id_v as upload_id 
from ivy_gap_pats   d where d.patient_id is not null;   

END;
$body$
LANGUAGE PLPGSQL;

