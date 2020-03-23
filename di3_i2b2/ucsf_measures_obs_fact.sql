create or replace function ucsf_measures_obs_fact_proc()
RETURNS void
LANGUAGE 'plpgsql'
as $BODY$
BEGIN

drop table if exists ucsf_measures_obs_fact;
create table ucsf_measures_obs_fact  as
  select
  cast(patient_id as varchar(200)) as patient_ide,
         studyid  as encounter_ide,
         study_date as start_date,
      cast('NCIt:C96684' as varchar(50))  as concept_cd,
    current_timestamp as download_date,
    cast('N' as varchar(50)) as valtype_cd,
    cast('E' as varchar(255)) as tval_char,
    cast(ld as decimal(18,5)) as nval_num,
    ld_units as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd,
       cast(NULL as timestamp) as end_date,
       cast('@' as varchar(10)) as provider_id,
       1 as instance_num,
       cast(NULL as decimal(18,5)) as quantity_num,
       cast(NULL as varchar(50)) as location_cd,
       cast(NULL as decimal(18,5)) as confidence_num,
       cast(NULL as varchar(50)) as valueflag_cd,
       1 as upload_id,
       current_timestamp as update_date
    from
    di3sources.ucsf_measures_view i where i.patient_id is not null
 union
 select
  cast(patient_id as varchar(200)) as patient_ide,
         studyid  as encounter_ide,
         study_date as start_date,
      cast('NCIt:C25335' as varchar(50))  as concept_cd,
    current_timestamp as download_date,
    cast('N' as varchar(50)) as valtype_cd,
    cast('E' as varchar(255)) as tval_char,
    cast(volume as decimal(18,5)) as nval_num,
    volume_units as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd,
       cast(NULL as timestamp) as end_date,
       cast('@' as varchar(10)) as provider_id,
       1 as instance_num,
       cast(NULL as decimal(18,5)) as quantity_num,
       cast(NULL as varchar(50)) as location_cd,
       cast(NULL as decimal(18,5)) as confidence_num,
       cast(NULL as varchar(50)) as valueflag_cd,
       1 as upload_id,
       current_timestamp as update_date
    from
    di3sources.ucsf_measures_view i where i.patient_id is not null 
;

END;
$BODY$;


