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


return ret_stuff;
END;
$body$
LANGUAGE 'plpgsql' ;
