create or replace function tcia_tcga_obs_fact_proc()
RETURNS void
LANGUAGE 'plpgsql'
as $BODY$
BEGIN

drop table if exists tcia_tcga_obs_fact;
create table tcia_tcga_obs_fact  as
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
  cast(i.bcr_patient_barcode as varchar(200)) as patient_ide,
         'fabricated_for_' || i.bcr_patient_barcode as encounter_ide,

    cast('NCIt:C47824|TCGA-BRCA' as varchar(50)) as  concept_cd,   /* Extract the name of the dataset as a fact */
    i.form_completion_date as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    i.form_completion_date as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd,
    i.form_completion_date as start_date
    from
    nwc_org_clinical_patient_brca  i where i.bcr_patient_barcode is not null
    )
,
organ  as (
  select
  cast(i.bcr_patient_barcode as varchar(200)) as patient_ide,
         'fabricated_for_' || i.bcr_patient_barcode as encounter_ide,

    cast('NCIt:C12971'as varchar(50)) as  concept_cd,   /* implied breast */
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    i.form_completion_date as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd
    from
    nwc_org_clinical_patient_brca  i where i.bcr_patient_barcode is not null
    )
,
gender  as (
  select
  cast(i.bcr_patient_barcode as varchar(200)) as patient_ide,
         'fabricated_for_' || bcr_patient_barcode as encounter_ide,
    cast('NCIt:C16576'as varchar(50)) as  concept_cd,   /* implied female */
    i.form_completion_date download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd
    from
    nwc_org_clinical_patient_brca i where i.bcr_patient_barcode is not null
    )
,
race as (
select
  cast(i.bcr_patient_barcode as varchar(200)) as patient_ide,
         'fabricated_for_' || bcr_patient_barcode as encounter_ide,
  case
    when i.race = 'WHITE' then 'NCIt:C41261' /* white */
    when i.race = 'BLACK OR AFRICAN AMERICAN' then 'NCIt:C16352' /* African american */ 
    when i.race = 'ASIAN' then 'NCIt:C41260' /* Asian */ 
    else 'NCIt:17049+NCIt:C17998' /* Unknown (generic unknown) */
  end as concept_cd,
  cast(NULL as varchar(255)) as tval_char,
  i.form_completion_date download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd,
  i.form_completion_date + i.birth_days_to as start_date
  from
    nwc_org_clinical_patient_brca i where i.bcr_patient_barcode is not null
  )
,

vital_status_alive_dead as (
select  
  cast(i.bcr_patient_barcode as varchar(200)) as patient_ide,
         coalesce(v4.bcr_followup_barcode, 'fabricated_for_' || i.bcr_patient_barcode) as encounter_ide,
  case
  when coalesce(v4.vital_status, i.vital_status) = 'Alive' then 'NCIt:C37987'
  when coalesce(v4.vital_status, i.vital_status) = 'Dead' then 'NCIt:C28554'
    else 'NCIt:C25717+NCIt:C17998' /* Unknown (generic unknown) */
  end as concept_cd,
  cast(NULL as varchar(255)) as tval_char,
  i.form_completion_date download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd,
  coalesce(v4.form_completion_date, i.form_completion_date) as start_date
  from
    nwc_org_clinical_patient_brca i left outer join nwc_org_clinical_follow_up_v4_0_brca v4 on i.bcr_patient_barcode = v4.bcr_patient_barcode
   
   where i.bcr_patient_barcode is not null
  )
,

/* Note there is no value as NO for lost to followup */

lost_to_followup as (
select  
  cast(v4.bcr_patient_barcode as varchar(200)) as patient_ide,
          v4.bcr_followup_barcode as encounter_ide,
  case
  when v4.followup_lost_to = 'YES' then 'NCIt:C48227'
    else 'NCIt:C25717+NCIt:C17998' /* Unknown (generic unknown) */
  end as concept_cd,
  cast(NULL as varchar(255)) as tval_char,
  v4.form_completion_date download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_TCGA-BRCA-follow_up_BRCA' as varchar(50)) as sourcesystem_cd,
  v4.form_completion_date as start_date
  from
    nwc_org_clinical_follow_up_v4_0_brca v4
   
   where v4.bcr_patient_barcode is not null and v4.followup_lost_to <> 'NO'  
  )
,
er_status as (
select
  cast(i.bcr_patient_barcode  as varchar(200)) as patient_ide,
         'fabricated_for_' || bcr_patient_barcode as encounter_ide,
  case
    when i.er_status_by_ihc = 'Negative' then 'NCIt:C15493' /* Negative */
    when i.er_status_by_ihc = 'Positive' then 'NCIt:C15492' /* positive */
    else 'NCIt:C15495' /* Unknown */
  end as concept_cd,
  cast(NULL as varchar(255)) as tval_char,
  i.form_completion_date download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd,
  i.form_completion_date as start_date
  from
    nwc_org_clinical_patient_brca i where i.bcr_patient_barcode is not null
  )
,
pr_status as (
select
  cast(i.bcr_patient_barcode  as varchar(200)) as patient_ide,
         'fabricated_for_' || bcr_patient_barcode as encounter_ide,
  case
    when i.pr_status_by_ihc = 'Negative' then 'NCIt:C15497' /* Negative */
    when i.pr_status_by_ihc = 'Positive' then 'NCIt:C15496' /* positive */
    else 'NCIt:C15498' /* Unknown */
  end as concept_cd,
  cast(NULL as varchar(255)) as tval_char,
  i.form_completion_date download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd,
  i.form_completion_date as start_date
  from
    nwc_org_clinical_patient_brca i where i.bcr_patient_barcode is not null
  )
,
her2_status as (
select
  cast(i.bcr_patient_barcode  as varchar(200)) as patient_ide,
         'fabricated_for_' || bcr_patient_barcode as encounter_ide,
  case
    when i.her2_status_by_ihc = 'Negative' then 'NCIt:C68749' /* Negative */
    when i.her2_status_by_ihc = 'Positive' then 'NCIt:C68748' /* positive */
    else 'NCIt:C68750' /* Unknown */
  end as concept_cd,
  cast(NULL as varchar(255)) as tval_char,
  i.form_completion_date download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd,
  i.form_completion_date as start_date
  from
    nwc_org_clinical_patient_brca i where i.bcr_patient_barcode is not null
  )
,
primary_dx as (
select
  cast(i.bcr_patient_barcode  as varchar(200)) as patient_ide,
         'fabricated_for_' || bcr_patient_barcode as encounter_ide,
  case
    when i.histological_type  = 'Infiltrating Ductal Carcinoma' then 'NCIt:C4194' 
    when i.histological_type = 'Infiltrating Lobular Carcinoma' then 'NCIt:C7950'
    when i.histological_type = 'Mixed Histology (please specify)' then 'NCIt:C6930'
    else 'NCIt:C15220+NCIt:C17998' /* Unknown */
  end as concept_cd,
  cast(NULL as varchar(255)) as tval_char,
  i.form_completion_date download_date,
  cast(NULL as varchar(50)) as valtype_cd,
  cast(NULL as decimal(18,5)) as nval_num,
  cast(NULL as varchar(50)) as units_cd,
  current_timestamp as import_date,
    cast('TCIA_TCGA-BRCA-Clinical_Patient_BRCA' as varchar(50)) as sourcesystem_cd,
  i.form_completion_date as start_date
  from
    nwc_org_clinical_patient_brca i where i.bcr_patient_barcode is not null
  )
,
breast_diagnosis_facts as (
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from organ 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd
from gender 
)
,
facts_with_start_dates as (
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date 
from race 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date 
from dataset 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date 
from vital_status_alive_dead 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date 
from lost_to_followup 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date 
from er_status 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date 
from pr_status 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date 
from her2_status 
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date 
from primary_dx 
)

select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, start_date,
       end_date, provider_id, instance_num , quantity_num, location_cd, confidence_num, valueflag_cd,upload_id,update_date
 from breast_diagnosis_facts cross join consts
union
select patient_ide, encounter_ide, concept_cd, download_date, valtype_cd, tval_char, nval_num, units_cd, import_date,sourcesystem_cd, coalesce(f.start_date,c.start_date),
       end_date, provider_id, instance_num , quantity_num, location_cd, confidence_num, valueflag_cd,upload_id,update_date
 from facts_with_start_dates f cross join consts c
;


END;
$BODY$;

