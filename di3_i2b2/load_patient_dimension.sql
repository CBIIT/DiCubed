/* Note that patient_dimension has added columns: */
/* tcia_subject_id  varchar(200) */
/* collection varchar(200) */
/* alter table patient_dimension add tcia_subject_id varchar(200); */

CREATE OR REPLACE FUNCTION load_patient_dimension()
 
RETURNS text  
AS $body$
DECLARE ret_stuff text;
BEGIN

insert into di3crcdata.patient_dimension(patient_num, sex_cd, age_in_years_num,vital_status_cd,race_cd)
with sex as 
(select patient_num, 'Female' as sex_cd from di3crcdata.observation_fact where concept_cd = 'NCIt:C16576'
union 
select patient_num, 'Male' as sex_cd from di3crcdata.observation_fact where concept_cd = 'NCIt:C20197')
,
age as 
(select patient_num, nval_num as age_in_years_num from di3crcdata.observation_fact where concept_cd = 'NCIt:C69260')
,
survival_status as (
select f.patient_num, md.c_name as vital_status_cd 
from di3crcdata.observation_fact f join di3metadata.di3 md on f.concept_cd = md.c_basecode 
and f.concept_cd in ('NCIt:C48227', 'NCIt:C25717+NCIt:C17998', 'NCIt:C37987', 'NCIt:C28554')
)
,
race as (
select f.patient_num, md.c_name as race_cd 
from di3crcdata.observation_fact f join di3metadata.di3 md on f.concept_cd = md.c_basecode 
and f.concept_cd in ('NCIt:C41260', 'NCIt:C41261', 'NCIt:C16352', 'NCIt:C41259', 'NCIt:17049+NCIt:C17998', 'NCIt:C41219')
)
,
pats as
(select distinct patient_num from di3crcdata.patient_mapping
)

select p.patient_num, s.sex_cd, a.age_in_years_num , v.vital_status_cd, r.race_cd
from pats p 
left outer join sex s on p.patient_num = s.patient_num 
left outer join age a on p.patient_num = a.patient_num
left outer join survival_status v on p.patient_num = v.patient_num
left outer join race r on p.patient_num = r.patient_num;

/* update the the tcia_subject_id in patient_dimension */

/* Ivy Gap */

with ivy_gap_subjects as (         
select distinct ir.patient_id, pm.patient_num, 
substring(ir.tissue_id from  position('W' in ir.tissue_id) for 
         position('-' in substring(ir.tissue_id from position('W' in ir.tissue_id))) -1 
         ) as tcia_subject_id   
    from di3sources.ivy_report ir  join di3crcdata.patient_mapping pm on cast(ir.patient_id as varchar) = pm.patient_ide where ir.tissue_id like '%W%'
    )
update di3crcdata.patient_dimension pd set tcia_subject_id = u.tcia_subject_id from ivy_gap_subjects u where pd.patient_num = u.patient_num ;

/* Breast Diagnosis */

with breast_diagnosis_subjects as (
select distinct  d.breast_dx_case , pm.patient_num, d.breast_dx_case as tcia_subject_id 
from di3sources.tcia_breast_clinical_data d join di3crcdata.patient_mapping pm on cast(d.breast_dx_case as varchar) = pm.patient_ide 
)
update di3crcdata.patient_dimension pd set tcia_subject_id = u.tcia_subject_id from breast_diagnosis_subjects u where pd.patient_num = u.patient_num;

/* Breast MRI NACT Pilot */

with breast_mri_nact_subjects as (
select distinct  d.patient_id , pm.patient_num, d.patient_id as tcia_subject_id 
from di3sources.shared_clinical_and_rfs d join di3crcdata.patient_mapping pm on cast(d.patient_id as varchar) = pm.patient_ide 
)
update di3crcdata.patient_dimension pd set tcia_subject_id = u.tcia_subject_id from breast_mri_nact_subjects u where pd.patient_num = u.patient_num;

/* ISpy */

with ispy_subjects as (
select distinct  d.subjectid , pm.patient_num, 'ISPY1_' || cast(d.subjectid as varchar)  as tcia_subject_id 
from di3sources.i_spy_tcia_patient_clinical_subset d join di3crcdata.patient_mapping pm on cast(d.subjectid as varchar) = pm.patient_ide 
)
update di3crcdata.patient_dimension pd set tcia_subject_id = u.tcia_subject_id from ispy_subjects u where pd.patient_num = u.patient_num;

/* TCGA BRCA */

with tcga_brca_subjects as (
select distinct  d.bcr_patient_barcode , pm.patient_num, cast(d.bcr_patient_barcode as varchar)  as tcia_subject_id 
from di3sources.nwc_org_clinical_patient_brca d join di3crcdata.patient_mapping pm on cast(d.bcr_patient_barcode as varchar) = pm.patient_ide 
)
update di3crcdata.patient_dimension pd set tcia_subject_id = u.tcia_subject_id from tcga_brca_subjects u where pd.patient_num = u.patient_num;

return ret_stuff;
END;
$body$
LANGUAGE 'plpgsql' ;
