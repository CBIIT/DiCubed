create or replace function ivy_report_obs_fact_proc()
RETURNS void
LANGUAGE 'plpgsql'
as $BODY$
BEGIN

drop table if exists ivy_report_obs_fact;
create table ivy_report_obs_fact  as
with consts as (
select
       cast('1960-01-01' as timestamp) as start_date,
       cast(NULL as timestamp) as end_date,
       cast('@' as varchar(10)) as provider_id,
       1 as instance_num,
       cast(NULL as decimal(18,5)) as quantity_num,
       cast(NULL as varchar(50)) as location_cd,
       cast(NULL as decimal(18,5)) as confidence_num,
       cast(NULL as varchar(50)) as valueflag_cd,
       1 as upload_id,
       current_timestamp as update_date
       ),
ivy_gap_pat_info as (
select distinct patient_id,age,gender,cause_of_death from ivy_report
)
,
ages as (
  select
  cast(patient_id as varchar(200)) as patient_ide,
         'fabricated_for_' || patient_id as encounter_ide,
      cast('NCIt:C69260' as varchar(50))  as concept_cd,
    current_timestamp as download_date,
    cast('N' as varchar(50)) as valtype_cd,
    cast('E' as varchar(255)) as tval_char,
    cast(i.age as decimal(18,5)) as nval_num,
    cast('Years' as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('IVY_GAP-ivy_report' as varchar(50)) as sourcesystem_cd
    from
    ivy_gap_pat_info i where i.patient_id is not null
  )
,
gender  as (
  select
  cast(patient_id as varchar(200)) as patient_ide,
         'fabricated_for_' || patient_id as encounter_ide,
    case 
      when i.gender = 'Male' then 'NCIt:C20197'
      when i.gender = 'Female' then 'NCIt:C16576'
    end as concept_cd,
    current_timestamp  as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('IVY_GAP-ivy_report' as varchar(50)) as sourcesystem_cd
    from
    ivy_gap_pat_info i where i.patient_id is not null
    )
,
dataset  as (
  select
  cast(patient_id as varchar(200)) as patient_ide,
         'fabricated_for_' || patient_id as encounter_ide,
    cast('NCIt:C47824|Ivy-Gap' as varchar(50))  as concept_cd,
    current_timestamp  as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('IVY_GAP-ivy_report' as varchar(50)) as sourcesystem_cd
    from
    ivy_gap_pat_info i where i.patient_id is not null
    )
,
ivy_report_data as (
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from ages
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from gender 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from dataset 
)
select * from ivy_report_data cross join consts;

END;
$BODY$;

