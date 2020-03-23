drop view if exists di3sources.ucsf_measures_view;
create view di3sources.ucsf_measures_view as 
with
meas_data as (
     select translate(patient_id, '_', '-') as subject_id,
             patient_id,
            1 as trownum, 
            ld_1 as ld, 
           'cm' as ld_units,
           ser_volume_1 as volume,
           'cc' as volume_units
           from di3sources.shared_clinical_and_rfs 
          where mri_1 = 'yes' and (ld_1 is not null or ser_volume_1 is not null) 
          union 
   select translate(patient_id, '_', '-') as subject_id,
         patient_id,
         2 as trownum,           
         ld_2 as ld, 
         'cm' as ld_units,
         ser_volume_2 as volume,
        'cc' as volume_units
        from di3sources.shared_clinical_and_rfs 
        where mri_2 = 'yes' and (ld_2 is not null or ser_volume_2 is not null)
    union 
    select translate(patient_id, '_', '-') as subject_id,
       patient_id, 
       3 as trownum,           
       ld_3 as ld, 
       'cm' as ld_units,
       ser_volume_3 as volume,
      'cc' as volume_units
      from di3sources.shared_clinical_and_rfs 
   
     where mri_3 = 'yes' and (ld_3 is not null or ser_volume_3 is not null)
      union 
    select translate(patient_id,'_', '-') as subject_id,
      patient_id, 
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
     select subject_id, patient_id, trownum, ld, ld_units, volume, volume_units, 
    row_number() over(partition by subject_id order by trownum) as rownum
    from meas_data
     )  
    ,
      mri_ucsf as 
      (
     select distinct pd.tcia_subject_id, sd.study_date,  sd.studyid, series.modality                       
     from di3crcdata.patient_dimension pd 
     join di3crcdata.dcm_study_dimension sd on pd.patient_num = sd.patient_num 
    join di3crcdata.dcm_series_dimension series on sd.studyid = series.studyid
    and series.modality = 'MR' where pd.tcia_subject_id like 'UCSF%' 
        )
        ,
             mri_ucsf_index as (
          select 
        row_number() over(partition by m.tcia_subject_id order by m.study_date) as rownum, 
               m.tcia_subject_id, m.study_date, m.studyid, m.modality
      from mri_ucsf m 
                           )  
                           
,
 meas_data_1 as (
     select   ms.subject_id ,ms.patient_id,  u.study_date, u.studyid, u.modality, ms.trownum as timepoint, ms.rownum, ms.ld, ms.ld_units, ms.volume,  volume_units 
        from meas_data_n ms left outer join mri_ucsf_index u on ms.subject_id = u.tcia_subject_id and ms.rownum = u.rownum 
     )
     select * from meas_data_1
