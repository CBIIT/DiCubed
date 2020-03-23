 create table i_spy_tcia_patient_clinical_subset (
subjectid   varchar(10),
dataextractdt varchar(10),
age  numeric(4,2),
race_id int,
erpos int,
pgrpos int,
hr_pos int,
her2mostpos int,
hr_her2_category int,
hr_her2_status varchar(40),
bilateralca int,
laterality int,
mri_ld_baseline int,
mri_ld_1_3dac int,
mri_ld_interreg int,
mri_ld_presurg int
);

\copy i_spy_tcia_patient_clinical_subset from 'i_spy_tcia_patient_clinical_subset_fixed.csv' delimiter ',' csv header


