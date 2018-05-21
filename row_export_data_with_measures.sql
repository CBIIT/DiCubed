drop table if exists row_export_data_with_meas;
create table row_export_data_with_meas as 
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

  /***********************************************************************************************/
  /* Note that because a patient may have more than 1 pdx value we put them in a comma delimited */
  /* string to keep our export format into one row per patient.                                  */
  /***********************************************************************************************/
 
  ( select c_basecode, c_name  from di3metadata.di3 where c_fullname like $$\\Primary Diagnosis\\%$$ ),
  pdx_facts as (select 
  f.patient_num,
         string_agg(f.concept_cd,',') as pdx_ncit,
         string_agg(rc.c_name, ',') as pdx_value
  from di3crcdata.observation_fact f 
 join pdx_concepts rc on f.concept_cd = rc.c_basecode
                group by f.patient_num
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

 ,
 meas_data as (
     select translate(patient_id, '_', '-') as subject_id,
            1 as trownum, 
            ld_1 as ld, 
           'cm' as ld_units,
           ser_volume_1 as volume,
           'cc' as volume_units
           from di3sources.shared_clinical_and_rfs 
          where mri_1 = 'yes' and (ld_1 is not null or ser_volume_1 is not null) 
          union 
   select translate(patient_id, '_', '-') as subject_id,
         2 as trownum,           
         ld_2 as ld, 
         'cm' as ld_units,
         ser_volume_2 as volume,
        'cc' as volume_units
        from di3sources.shared_clinical_and_rfs 
        where mri_2 = 'yes' and (ld_2 is not null or ser_volume_2 is not null)
    union 
    select translate(patient_id, '_', '-') as subject_id,
       3 as trownum,           
       ld_3 as ld, 
       'cm' as ld_units,
       ser_volume_3 as volume,
      'cc' as volume_units
      from di3sources.shared_clinical_and_rfs 
   
     where mri_3 = 'yes' and (ld_3 is not null or ser_volume_3 is not null)
      union 
    select translate(patient_id,'_', '-') as subject_id,
      4 as trownum,            
      ld_4 as ld, 
     'cm' as ld_units,
      ser_volume_4 as volume,
     'cc' as volume_units
   from di3sources.shared_clinical_and_rfs 
     where mri_4 = 'yes' and (ld_4 is not null or ser_volume_4 is not null)
)
,
meas_data_n as (
     select subject_id, trownum, ld, ld_units, volume, volume_units, 
    row_number() over(partition by subject_id order by trownum) as rownum
    from meas_data
     )  ,
     mri_ucsf as 
      (
     select distinct pd.tcia_subject_id, sd.study_date,  sd.studyid, series.modality, dl.loinc                     
     from di3crcdata.patient_dimension pd 
     join di3crcdata.dcm_study_dimension sd on pd.patient_num = sd.patient_num 
    join di3crcdata.dcm_series_dimension series on sd.studyid = series.studyid
    join di3sources.desc_to_loinc dl on dl.orig_desc = sd.description 
    and series.modality = 'MR' where pd.tcia_subject_id like 'UCSF%' 
        ),
     mri_ucsf_index as (
          select 
        row_number() over(partition by m.tcia_subject_id order by m.study_date) as rownum, 
               m.tcia_subject_id, m.study_date, m.studyid, m.modality, m.loinc
      from mri_ucsf m 
                           )    ,
ispy_meas_data as (
    select 'ISPY1_' || subjectid as subject_id,
           1 as trownum, 
           mri_ld_baseline as ld, 
          'mm' as ld_units,
          cast(NULL as numeric ) as volume,
          cast(NULL as varchar ) as volume_units
          from di3sources.i_spy_tcia_patient_clinical_subset
          where mri_ld_baseline is not null 
          union 
    select 'ISPY1_' || subjectid as subject_id,
          2 as trownum, 
          mri_ld_1_3dac as ld, 
         'mm' as ld_units,
          cast(NULL as numeric ) as volume,
          cast(NULL as varchar ) as volume_units
           from di3sources.i_spy_tcia_patient_clinical_subset
         where mri_ld_1_3dac is not null 
         union 
      select 'ISPY1_' || subjectid as subject_id,
         3 as trownum, 
         mri_ld_interreg as ld, 
     'mm' as  ld_units,
      cast(NULL as numeric ) as volume,
      cast(NULL as varchar ) as volume_units
      from di3sources.i_spy_tcia_patient_clinical_subset
      where  mri_ld_interreg is not null 
     union 
     select 'ISPY1_' || subjectid as subject_id,
     4 as trownum, 
     mri_ld_presurg as ld, 
    'mm' as ld_units,
    cast(NULL as numeric ) as volume,
    cast(NULL as varchar ) as volume_units
    from di3sources.i_spy_tcia_patient_clinical_subset
    where mri_ld_presurg is not null 
   )
          ,
 ispy_meas_data_n as (
       select subject_id, trownum, ld, ld_units, volume, volume_units, 
       row_number() over(partition by subject_id order by trownum) as rownum
      from ispy_meas_data
                )  ,
 mri_ispy as 
      (
 select distinct pd.tcia_subject_id, sd.study_date,  sd.studyid, series.modality, dl.loinc                       
  from di3crcdata.patient_dimension pd 
            join di3crcdata.dcm_study_dimension sd on pd.patient_num = sd.patient_num 
     join di3crcdata.dcm_series_dimension series on sd.studyid = series.studyid
    join di3sources.desc_to_loinc dl on dl.orig_desc = sd.description 
      and series.modality = 'MR' where pd.tcia_subject_id like 'ISPY1%' 
                    ),
    mri_ispy_index as (
                 select 
               row_number() over(partition by m.tcia_subject_id order by m.study_date) as rownum, 
       m.tcia_subject_id, m.study_date, m.studyid, m.modality, m.loinc
          from mri_ispy m 
         )   
            ,
     meas_data_1 as (
     /* Studies with measures */  
     select   ms.subject_id , u.study_date, u.studyid, u.modality, u.loinc, ms.trownum as timepoint, ms.rownum, ms.ld, ms.ld_units, ms.volume, 'cc' as volume_units 
        from meas_data_n ms left outer join mri_ucsf_index u on ms.subject_id = u.tcia_subject_id and ms.rownum = u.rownum 
       union	
         select   ms2.subject_id , u2.study_date,u2.studyid, u2.modality, u2.loinc,  ms2.trownum as timepoint,  ms2.rownum, ms2.ld, ms2.ld_units, ms2.volume, ms2.volume_units 
     from ispy_meas_data_n ms2 left outer join mri_ispy_index u2 on ms2.subject_id = u2.tcia_subject_id and ms2.rownum = u2.rownum

     union

/* rest of the studies for all datasets */
 select distinct pd.tcia_subject_id, sd.study_date,  sd.studyid, series.modality, dl.loinc, 
     cast(NULL as int) as timepoint, cast(NULL as int) as rownum, cast(NULL as float) as ld, cast(NULL as varchar(10) ) as ld_units, 
     cast(NULL as float) as volume, cast(NULL as varchar(10) )  as volume_units
     from di3crcdata.patient_dimension pd
     join di3crcdata.dcm_study_dimension sd on pd.patient_num = sd.patient_num
    join di3crcdata.dcm_series_dimension series on sd.studyid = series.studyid
    join di3sources.desc_to_loinc dl on dl.orig_desc = sd.description 
    where pd.tcia_subject_id like 'BreastDx%' or pd.tcia_subject_id like 'W%' or pd.tcia_subject_id = 'TCGA%'
        or (pd.tcia_subject_id like 'ISPY%' and series.modality <> 'MR') or
         (pd.tcia_subject_id like 'UCSF%' and series.modality <> 'MR')

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
        asf.anatomic_site_value,
 md.study_date,
 md.studyid,
 md.modality,
 md.loinc,
 md.timepoint,
 md.ld,
 cast(md.ld_units as varchar) as ld_units,
 md.volume,
 cast(md.volume_units as varchar) as volume_units 

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
 left outer join anatomic_site_facts asf on pd.patient_num = asf.patient_num 
 left outer join meas_data_1 md on pd.tcia_subject_id = md.subject_id
