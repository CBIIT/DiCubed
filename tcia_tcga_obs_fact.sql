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
    current_timestamp as download_date,
    cast(NULL as varchar(50)) as valtype_cd,
    cast(NULL as varchar(255)) as tval_char,
    cast(NULL as decimal(18,5)) as nval_num,
    cast(NULL as varchar(50)) as units_cd,
    current_timestamp as import_date,
    cast('TCIA_Breast-Diagnosis_Sheet1' as varchar(50)) as sourcesystem_cd
    from
    nwc_org_clinical_patient_brca i where i.bcr_patient_barcode is not null
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
from gender 
)

select * from breast_diagnosis_facts cross join consts;

END;
$BODY$;

