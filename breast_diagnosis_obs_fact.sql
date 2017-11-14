create or replace function breast_diagnosis_obs_fact_proc()
RETURNS void
LANGUAGE 'plpgsql'
as $BODY$
BEGIN

drop table if exists breast_diagnosis_obs_fact;
create table breast_diagnosis_obs_fact  as
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
  cast(i.breast_dx_case as varchar(200)) as patient_ide,
         'fabricated_for_' || i.breast_dx_case as encounter_ide,

    cast('NCIt:C47824|Breast Diagnosis' as varchar(50)) as  concept_cd,   /* Extract the name of the dataset as a fact */
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
    from
    tcia_breast_clinical_data  i where i.breast_dx_case is not null
    )
,
organ  as (
  select
  cast(i.breast_dx_case as varchar(200)) as patient_ide,
         'fabricated_for_' || i.breast_dx_case as encounter_ide,

    cast('NCIt:C12971'as varchar(50)) as  concept_cd,   /* implied breast */
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
    from
    tcia_breast_clinical_data i where i.breast_dx_case is not null
    )
,
  laterality  as (
  select
  cast(i.breast_dx_case as varchar(200)) as patient_ide,
         'fabricated_for_' || i.breast_dx_case as encounter_ide,
    case
      when i.path_which_breast = 'L' then 'NCIt:C25229' /* Left  */
      when i.path_which_breast = 'R' then 'NCIt:C25228' /* Right */
    end as concept_cd,
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
    from
    tcia_breast_clinical_data i where i.breast_dx_case is not null and i.path_which_breast in ('L', 'R')
    )
,
estrogen_receptor as (
select
cast(breast_dx_case as varchar(200)) as patient_ide,
       'fabricated_for_' || breast_dx_case as encounter_ide,
  case
    when i.path_er like '%neg%' then 'NCIt:C15493' /* Negative */
    when i.path_er like '%pos%'  then 'NCIt:C15492' /* Positive */
    else 'NCIt:C15495' /* Unknown */
  end as concept_cd,
  current_timestamp as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
  from
  tcia_breast_clinical_data i where i.breast_dx_case is not null
  )
,
progesterone_receptor as (
select
cast(breast_dx_case as varchar(200)) as patient_ide,
       'fabricated_for_' || breast_dx_case as encounter_ide,
  case
    when i.path_pr like '%neg%' then 'NCIt:C15497' /* Negative */
    when i.path_pr like '%pos%'  then 'NCIt:C15496' /* Positive */
    else 'NCIt:C15498' /* Unknown */
  end as concept_cd,
  current_timestamp as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
  from
  tcia_breast_clinical_data i where i.breast_dx_case is not null
  )
,
her2 as (
select
cast(breast_dx_case as varchar(200)) as patient_ide,
       'fabricated_for_' || breast_dx_case as encounter_ide,
  case
    when i.path_her2 like '%neg%' then 'NCIt:C68749' /* Negative */
    when i.path_her2 like '%pos%' or i.path_her2 like '%mod%'  then 'NCIt:C68748' /* Positive */
    else 'NCIt:C68750' /* Unknown */
  end as concept_cd,
  current_timestamp as download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as varchar(255)) as tval_char,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
  from
  tcia_breast_clinical_data i where i.breast_dx_case is not null
  )
,
  primary_diagnosis as (
  select
  cast(breast_dx_case as varchar(200)) as patient_ide,
         'fabricated_for_' || breast_dx_case as encounter_ide,
    case
      when i.path_dx = 'benign'  then 'NCIt:C14172' /* Benign */
      when i.path_dx = 'benign fibroadenoma' then 'NCIt:C3744l' /* Breast Fibroadenoma */
      when i.path_dx in ('benign fibrocyst','benign firbosis') then 'NCIt:C3039' /*  Breast Fibrocystic Change */
      when lower(i.path_dx) like 'ducta%ca%' then 'NCIt:C2924' /* Ductal Breast Carcinoma In Situ  */
      when i.path_dx = 'infiltrating ductal CA' or lower(i.path_dx) like 'invasive ductal%' or lower(i.path_dx) like 'invasive intraduct%'
                      then 'NCIt:C4194' /* Invasive Ductal Carcinoma, Not Otherwise Specified */
      when lower(i.path_dx) like 'invasive lobular%' then 'NCIt:C7950' /* Invasive Lobular Breast Carcinoma */
      when lower(i.path_dx) like 'specimen: invasive carcinoma%' then 'NCIt:C7950'
      when lower(i.path_dx) like 'stromal hyperplasia%' then 'NCIt:C35857' /* Stromal Hyperplasia */
      else 'NCIt:C15220+NCIt:C17998' /* unknown */
    end as concept_cd,
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
    from
    tcia_breast_clinical_data i where i.breast_dx_case is not null
    )
,
gender  as (
  select
  cast(breast_dx_case as varchar(200)) as patient_ide,
         'fabricated_for_' || breast_dx_case as encounter_ide,
    cast('NCIt:C16576'as varchar(50)) as  concept_cd,   /* implied female */
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
    from
    tcia_breast_clinical_data i where i.breast_dx_case is not null
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
from primary_diagnosis 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from gender 
)

select * from breast_diagnosis_facts cross join consts;

END;
$BODY$;

