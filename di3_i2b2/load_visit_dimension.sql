CREATE OR REPLACE FUNCTION load_visit_dimension()
 
RETURNS text  
AS $body$
DECLARE ret_stuff text;
BEGIN

delete from di3crcdata.visit_dimension;

insert into di3crcdata.visit_dimension (encounter_num, 
                                        patient_num,
                                        active_status_cd,
                                        start_date,
                                        end_date, 
                                        import_date, 
                                        sourcesystem_cd )  

select distinct em.encounter_num,  pm.patient_num,
'UA' as active_status_cd, cast('1960-01-01' as timestamp) as start_date, cast(NULL as timestamp) as end_date, 
current_timestamp as import_date,
em.sourcesystem_cd 
from di3crcdata.encounter_mapping em 
join di3crcdata.patient_mapping pm on em.patient_ide = pm.patient_ide
where em.encounter_ide like 'fabricated_for%'
union
select distinct em.encounter_num,  pm.patient_num, 
'U ' as active_status_cd, usm.study_date as start_date, cast(NULL as timestamp) as end_date, 
current_timestamp as import_date,
em.sourcesystem_cd 
from di3crcdata.encounter_mapping em 
join di3crcdata.patient_mapping pm on em.patient_ide = pm.patient_ide
join di3sources.ucsf_measures_view usm on em.encounter_ide = usm.studyid
where em.encounter_ide_source = 'TCIA' and em.patient_ide_source = 'shared_clinical_and_rfs'
union 
select distinct em.encounter_num,  pm.patient_num, 
'U ' as active_status_cd, ism.study_date as start_date, cast(NULL as timestamp) as end_date, 
current_timestamp as import_date,
em.sourcesystem_cd 
from di3crcdata.encounter_mapping em 
join di3crcdata.patient_mapping pm on em.patient_ide = pm.patient_ide
join di3sources.ispy_measures_view ism on em.encounter_ide = ism.studyid
where em.encounter_ide_source = 'TCIA' and em.patient_ide_source = 'i_spy_tcia_patient_clinical_subset'

;
return ret_stuff;
END;
$body$
LANGUAGE 'plpgsql' ;
