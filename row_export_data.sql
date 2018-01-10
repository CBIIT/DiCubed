drop table if exists row_export_data;
create table row_export_data as 
with 
  dataset_concepts as 
  (select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Data Set\\%$$ ),
  dataset_facts as 
  ( 
select  
         f.patient_num as patient_num,
         f.concept_cd as dataset_ncit,
         sc.c_name as dataset_value
  from di3crcdata.observation_fact f 
 join dataset_concepts sc on f.concept_cd = sc.c_basecode
  )
,
  sex_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Demographics\\C28421\\%$$ ),
  sex_facts as (select 
         f.patient_num,
         f.concept_cd as sex_ncit,
         sc.c_name as sex_value
  from di3crcdata.observation_fact f  
 join sex_concepts sc on f.concept_cd = sc.c_basecode             
               
               ),
  age_concepts as (select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Demographics\\C69260\\%$$)  ,
  age_facts as (select 
         f.patient_num,
         f.concept_cd as age_ncit,
         f.nval_num as age,
         f.units_cd as age_unit
  from di3crcdata.observation_fact f  
 join age_concepts ac on f.concept_cd = ac.c_basecode)
 ,
  race_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Demographics\\C17049\\%$$ ),
  race_facts as (select 
         f.patient_num,
         f.concept_cd as race_ncit,
         rc.c_name as race_value
  from di3crcdata.observation_fact f  
 join race_concepts rc on f.concept_cd = rc.c_basecode             
               ),
  er_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\A19046186\\A7645769\\%$$ ),
  er_facts as (select 
         f.patient_num,
         f.concept_cd as er_ncit,
         rc.c_name as er_value
  from di3crcdata.observation_fact f  
 join er_concepts rc on f.concept_cd = rc.c_basecode             
               ),
  pr_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\A19046186\\A7659609\\%$$ ),
  pr_facts as (select 
         f.patient_num,
         f.concept_cd as pr_ncit,
         rc.c_name as pr_value
  from di3crcdata.observation_fact f  
 join pr_concepts rc on f.concept_cd = rc.c_basecode             
               ),
  her2_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\A19046186\\A24388448\\%$$ ),
  her2_facts as (select 
         f.patient_num,
         f.concept_cd as her2_ncit,
         rc.c_name as her2_value
  from di3crcdata.observation_fact f  
 join her2_concepts rc on f.concept_cd = rc.c_basecode             
               ),
  lat_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Laterality\\%$$ ),
  lat_facts as (select 
         f.patient_num,
         f.concept_cd as lat_ncit,
         rc.c_name as lat_value
  from di3crcdata.observation_fact f  
 join lat_concepts rc on f.concept_cd = rc.c_basecode             
               ),
  vital_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Survival Status\\%$$ ),
  vital_facts as (select 
         f.patient_num,
         f.concept_cd as vital_ncit,
         rc.c_name as vital_value
  from di3crcdata.observation_fact f  
 join vital_concepts rc on f.concept_cd = rc.c_basecode             
               ),
  pdx_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Primary Diagnosis\\%$$ ),
  pdx_facts as (select 
         f.patient_num,
         f.concept_cd as pdx_ncit,
         rc.c_name as pdx_value
  from di3crcdata.observation_fact f  
 join pdx_concepts rc on f.concept_cd = rc.c_basecode             
               ),
  course_of_disease_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Clinical Course of Disease\\%$$ ),
  course_of_disease_facts as (select 
         f.patient_num,
         f.concept_cd as course_of_disease_ncit,
         rc.c_name as course_of_disease_value
  from di3crcdata.observation_fact f  
 join course_of_disease_concepts rc on f.concept_cd = rc.c_basecode             
               ),
  anatomic_site_concepts as 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Anatomic Site\\%$$ ),
  anatomic_site_facts as (select 
         f.patient_num,
         f.concept_cd as anatomic_site_ncit,
         rc.c_name as anatomic_site_value
  from di3crcdata.observation_fact f  
 join anatomic_site_concepts rc on f.concept_cd = rc.c_basecode             
               )
 select distinct 
        dsf.dataset_value as collection,
        pm.patient_ide as subject_id,
        pd.tcia_subject_id,
        sf.sex_ncit,
        sf.sex_value,
        af.age_ncit,
        af.age,
        af.age_unit,
        rf.race_ncit,
        rf.race_value,
        ef.er_ncit,
        ef.er_value,
        pf.pr_ncit,
        pf.pr_value,
        hf.her2_ncit,
        hf.her2_value,
        lf.lat_ncit,
        lf.lat_value,
        vf.vital_ncit,
        vf.vital_value,
        pdf.pdx_ncit,
        pdf.pdx_value,
        cdf.course_of_disease_ncit,
        cdf.course_of_disease_value,
        asf.anatomic_site_ncit,
        asf.anatomic_site_value

 from di3crcdata.patient_dimension pd  
 join di3crcdata.patient_mapping pm on pd.patient_num = pm.patient_num
 left outer join dataset_facts dsf on pd.patient_num = dsf.patient_num
 left outer join sex_facts sf on pd.patient_num = sf.patient_num
 left outer join age_facts af on pd.patient_num = af.patient_num 
 left outer join race_facts rf on pd.patient_num = rf.patient_num
 left outer join er_facts ef on pd.patient_num = ef.patient_num
 left outer join pr_facts pf on pd.patient_num = pf.patient_num 
 left outer join her2_facts hf on pd.patient_num = hf.patient_num 
 left outer join lat_facts lf on pd.patient_num = lf.patient_num 
 left outer join vital_facts vf on pd.patient_num = vf.patient_num 
 left outer join pdx_facts pdf on pd.patient_num = pdf.patient_num 
 left outer join course_of_disease_facts cdf on pd.patient_num = cdf.patient_num 
 left outer join anatomic_site_facts asf on pd.patient_num = asf.patient_num ;
