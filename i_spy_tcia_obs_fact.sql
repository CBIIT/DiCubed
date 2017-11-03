create or replace function ispy_obs_fact_proc()
RETURNS void
LANGUAGE 'plpgsql'
as $BODY$ 
BEGIN

drop table if exists ispy_obs_fact;
create table ispy_obs_fact  as 
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
race as (

select
    cast(subjectid as varchar(200)) as patient_ide,
     'fabricated_for_' || subjectid as encounter_ide,
    cast('NCIt:17049' as varchar(50))  as concept_cd,
  case
    when i.race_id = 1 then 'NCIt:C41261' /* white */
    when i.race_id = 3 then 'NCIt:C16352' /* African american */
    when i.race_id = 4 then 'NCIt:C41260' /* Asian */
    when i.race_id = 5 then 'NCIt:C41219' /* Native Hawaiian Pacific Islander */ 
    when i.race_id = 6 then 'NCIt:C41259' /* American Indian or Alaskan Native */
    when i.race_id = 50 then 'NCIt:C67109' /* Multiracial */
    else 'NCIt:C17998' /* Unknown (generic unknown) */
  end as tval_char,
  to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast('T' as varchar(50)) as valtype_cd,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
  cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
  from
  i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
 )
,
estrogen_receptor as (
select
cast(subjectid as varchar(200)) as patient_ide,
       'fabricated_for_' || subjectid as encounter_ide,
  case
    when i.erpos = 0 then 'NCIt:C15493' /* Negative */
    when i.erpos = 1 then 'NCIt:C15492' /* Positive */
    when i.erpos = 2 then 'NCIt:C15495' /* Unknown */
    else cast(NULL as varchar(50))
  end as concept_cd,
  to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
  cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
  from
  i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
  )
,
progesterone_receptor as (
select
cast(subjectid as varchar(200)) as patient_ide,
       'fabricated_for_' || subjectid as encounter_ide,
  case
    when i.pgrpos = 0 then 'NCIt:C15497' /* Negative */
    when i.pgrpos = 1 then 'NCIt:C15496' /* Positive */
    when i.pgrpos = 2 or i.pgrpos is NULL then 'NCIt:C15498' /* Unknown */
    else cast(NULL as varchar(50))
  end as concept_cd,
  to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
  cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
  from
  i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
  )
  ,
  her2 as (
  select
  cast(subjectid as varchar(200)) as patient_ide,
         'fabricated_for_' || subjectid as encounter_ide,
    case
      when i.her2mostpos = 0 then 'NCIt:C68749' /* Negative */
      when i.her2mostpos = 1 then 'NCIt:C68748' /* Positive */
      else 'NCIt:68750' /*unknown*/
    end as concept_cd,
    to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
    from
    i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
    )
,
  ages as (
  select
  cast(subjectid as varchar(200)) as patient_ide,
         'fabricated_for_' || subjectid as encounter_ide,
      cast('NCIt:C69260' as varchar(50))  as concept_cd,
    to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast('N' as varchar(50)) as valtype_cd,
    cast('E' as varchar(255)) as tval_char,
    cast(i.age as decimal(18,5)) as nval_num,
    cast('Years' as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
    from
    i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
  )
  ,
  survival_status as (
  select
  cast(subjectid as varchar(200)) as patient_ide,
         'fabricated_for_' || subjectid as encounter_ide,
    cast('NCIt:C25717' as varchar(50)) as concept_cd, 
    cast('T' as varchar(50)) as valtype_cd,
    
    case
      when i.sstat = 7 then 'NCIt:C37987' /* Alive  */
      when i.sstat = 8 then 'NCIt:C28554' /* Positive */
      when i.sstat = 9 then 'NCIt:C48227' /* Lost to followup */
      else 'NCIt:17998' /*unknown*/
    end as tval_char,
    to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_ISPY1_Outcome' as varchar(50)) as sourcesystem_cd
    from
    i_spy_tcia_outcomes_subset i where i.subjectid is not null
    )
,
  clinical_course_of_disease  as (
  select
  cast(subjectid as varchar(200)) as patient_ide,
         'fabricated_for_' || subjectid as encounter_ide,
    case
      when i.rfs_ind = 0 then 'NCIt:C40413' /* No evidence of disease */
      when i.rfs_ind = 1 then 'NCIt:C38155' /* Recurrent disease */
    end as concept_cd,
    to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_ISPY1_Outcome' as varchar(50)) as sourcesystem_cd
    from
    i_spy_tcia_outcomes_subset i where i.subjectid is not null
    )
,
  gender  as (
  select
  cast(subjectid as varchar(200)) as patient_ide,
         'fabricated_for_' || subjectid as encounter_ide,
    cast('NCIt:C46110'as varchar(50)) as  concept_cd,   /* implied female */
    to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
    from
    i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
    )
,
  laterality  as (
  select
  cast(subjectid as varchar(200)) as patient_ide,
         'fabricated_for_' || subjectid as encounter_ide,
    case
      when i.laterality = 1 then 'NCIt:C25229' /* Left  */
      when i.laterality = 2 then 'NCIt:C25228' /* Right */
    end as concept_cd,
    to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
    from
    i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
    )
,
  organ  as (
  select
  cast(subjectid as varchar(200)) as patient_ide,
         'fabricated_for_' || subjectid as encounter_ide,
    
    cast('NCIt:C12971'as varchar(50)) as  concept_cd,   /* implied breast */
    to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
    from
    i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
    )
,
  dataset  as (
  select
  cast(subjectid as varchar(200)) as patient_ide,
         'fabricated_for_' || subjectid as encounter_ide,
    
    cast('NCIt:C47824:I-Spy1'as varchar(50)) as  concept_cd,   /* implied breast */
    to_date(i.dataextractdt, 'MM/DD/YY') as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_ISPY1_Clinical' as varchar(50)) as sourcesystem_cd
    from
    i_spy_tcia_patient_clinical_subset i where i.subjectid is not null
    )
,
ispy_clinical as (
ispy_clinical as (
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from race
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from estrogen_receptor
  union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from progesterone_receptor
 union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from ages
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from her2
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from survival_status 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from clinical_course_of_disease  
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from gender  
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from laterality  
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from organ  
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from dataset  
)
select * from ispy_clinical cross join consts;

END;
$BODY$;

