create or replace function shared_clinical_obs_fact_proc()
RETURNS void
LANGUAGE 'plpgsql'
as $BODY$
BEGIN

drop table if exists shared_clinical_obs_fact;
create table shared_clinical_obs_fact  as
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
dataset  as (
  select
  cast(i.patient_id as varchar(200)) as patient_ide,
         'fabricated_for_' || i.patient_id as encounter_ide,

    cast('NCIt:C47824|Breast-MRI-NACT-Pilot' as varchar(50)) as  concept_cd,   /* Extract the name of the dataset as a fact */
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs  i where i.patient_id is not null
    )
,
organ  as (
  select
  cast(i.patient_id as varchar(200)) as patient_ide,
         'fabricated_for_' || i.patient_id as encounter_ide,

    cast('NCIt:C12971'as varchar(50)) as  concept_cd,   /* implied breast */
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
    )
,
  laterality  as (
  select
  cast(i.patient_id as varchar(200)) as patient_ide,
         'fabricated_for_' || i.patient_id as encounter_ide,
    case
      when i.breast_laterality = 'left' then 'NCIt:C25229' /* Left  */
      when i.breast_laterality = 'right' then 'NCIt:C25228' /* Right */
    end as concept_cd,
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
    )
,
estrogen_receptor as (
select
cast(i.patient_id as varchar(200)) as patient_ide,
       'fabricated_for_' || i.patient_id as encounter_ide,
  case
    when i.er_positive = 0 then 'NCIt:C15493' /* Negative */
    when i.er_positive = 1 then 'NCIt:C15492' /* Positive */
    else 'NCIt:C15495' /* Unknown */
  end as concept_cd,
  current_timestamp as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
  )
,
progesterone_receptor as (
select
cast(i.patient_id as varchar(200)) as patient_ide,
       'fabricated_for_' || i.patient_id as encounter_ide,
  case
    when i.pr_positive = 0 then 'NCIt:C15497' /* Negative */
    when i.pr_positive = 1 then 'NCIt:C15496' /* Positive */
    else 'NCIt:C15498' /* Unknown */
  end as concept_cd,
  current_timestamp as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
  )
,
her2 as (
select
cast(i.patient_id as varchar(200)) as patient_ide,
       'fabricated_for_' || i.patient_id as encounter_ide,
  case
    when i.her2_positive = 0  then 'NCIt:C68749' /* Negative */
    when i.her2_positive = 1  then 'NCIt:C68748' /* Positive */
    else 'NCIt:C68750' /* Unknown */
  end as concept_cd,
  current_timestamp as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
  )
,
gender  as (
  select
  cast(i.patient_id as varchar(200)) as patient_ide,
         'fabricated_for_' || i.patient_id as encounter_ide,
    cast('NCIt:C16576'as varchar(50)) as  concept_cd,   /* implied female */
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
    )
,

censor as (
select
cast(i.patient_id as varchar(200)) as patient_ide,
       'fabricated_for_' || i.patient_id as encounter_ide,
  case
    when i.censor = 0  then 'NCIt:C38155' /* Recurrent disease */
    when i.censor = 1  then 'NCIt:C40413' /* no recurrence */
  end as concept_cd,
  current_timestamp as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
  )
,
race as (
select
cast(i.patient_id as varchar(200)) as patient_ide,
       'fabricated_for_' || i.patient_id as encounter_ide,
  case
    when i.race = 'caucasian'  then 'NCIt:C41261' 
    when i.race = 'african-amer'  then 'NCIt:C16352' 
    when i.race = 'asian'  then 'NCIt:C41260' 
    when i.race in ('not given', 'other', 'hispanic') then 'NCIt:17049+NCIt:C17998' /* unknowns */
    else 'NCIt:17049+NCIt:C17998'
  end as concept_cd,
  current_timestamp as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
  )
,
ages as (
  select
cast(i.patient_id as varchar(200)) as patient_ide,
       'fabricated_for_' || i.patient_id as encounter_ide,
      cast('NCIt:C69260' as varchar(50))  as concept_cd,
  current_timestamp as download_date,
    cast('N' as varchar(50)) as valtype_cd,
    cast('E' as varchar(255)) as tval_char,
    cast(i.age_at_mr1 as decimal(18,5)) as nval_num,
    cast('Years' as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-MRI-NACT-Pilot_Clinical_and_RFS' as varchar(50)) as sourcesystem_cd
    from
    shared_clinical_and_rfs i where i.patient_id is not null
  )
  ,

breast_diagnosis_facts as (

select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from dataset 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from organ 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from laterality  
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from estrogen_receptor 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from progesterone_receptor 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from her2 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from gender 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from censor 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from race 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from ages 
)

select * from breast_diagnosis_facts cross join consts;

END;
$BODY$;

