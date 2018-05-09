drop view if exists di3sources.ispy_measures_view;
create view di3sources.ispy_measures_view 
as 
with
ispy_meas_data as (
    select 'ISPY1_' || subjectid as subject_id,
           subjectid as patient_id,
           1 as trownum, 
           mri_ld_baseline as ld, 
          'mm' as ld_units,
          cast(NULL as numeric ) as volume,
          cast(NULL as varchar ) as volume_units
          from di3sources.i_spy_tcia_patient_clinical_subset
          where mri_ld_baseline is not null 
          union 
    select 'ISPY1_' || subjectid as subject_id,
          subjectid as patient_id,
          2 as trownum, 
          mri_ld_1_3dac as ld, 
         'mm' as ld_units,
          cast(NULL as numeric ) as volume,
          cast(NULL as varchar ) as volume_units
           from di3sources.i_spy_tcia_patient_clinical_subset
         where mri_ld_1_3dac is not null 
         union 
      select 'ISPY1_' || subjectid as subject_id,
         subjectid as patient_id,
         3 as trownum, 
         mri_ld_interreg as ld, 
     'mm' as  ld_units,
      cast(NULL as numeric ) as volume,
      cast(NULL as varchar ) as volume_units
      from di3sources.i_spy_tcia_patient_clinical_subset
      where  mri_ld_interreg is not null 
     union 
     select 'ISPY1_' || subjectid as subject_id,
     subjectid as patient_id, 
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
       select subject_id, patient_id , trownum, ld, ld_units, 
       row_number() over(partition by subject_id order by trownum) as rownum
      from ispy_meas_data
                )  ,
 mri_ispy as 
      (
 select distinct pd.tcia_subject_id, sd.study_date,  sd.studyid, series.modality                       
  from di3crcdata.patient_dimension pd 
            join di3crcdata.dcm_study_dimension sd on pd.patient_num = sd.patient_num 
     join di3crcdata.dcm_series_dimension series on sd.studyid = series.studyid
      and series.modality = 'MR' where pd.tcia_subject_id like 'ISPY1%' 
                    ),
    mri_ispy_index as (
                 select 
               row_number() over(partition by m.tcia_subject_id order by m.study_date) as rownum, 
       m.tcia_subject_id, m.study_date, m.studyid, m.modality
          from mri_ispy m 
         )   
,
meas_data_1 as (
 select   ms2.subject_id , ms2.patient_id,  u2.study_date,u2.studyid, u2.modality, ms2.trownum as timepoint, 
    ms2.rownum, ms2.ld, ms2.ld_units
    from ispy_meas_data_n ms2 left outer join mri_ispy_index u2 on ms2.subject_id = u2.tcia_subject_id and ms2.rownum = u2.rownum
                                          )
select * from meas_data_1 where studyid is not null 
;
