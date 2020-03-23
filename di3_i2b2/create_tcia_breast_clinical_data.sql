drop table if exists tcia_breast_clinical_data;

create table tcia_breast_clinical_data (
breast_dx_case varchar(20),
background varchar(1024),
path_dx varchar(200),
path_which_breast varchar(10),
path_er  varchar(30),
path_pr  varchar(30),
path_her2 varchar(30),
path_e_cadherin varchar(30),
path_ki67 varchar(30),
path_oncotype_score int,
path_oncotype_risk varchar(10),
path_age_decade int,
path_report_notes text,
mri_which_breast varchar(1024),
mri_birad varchar(10),
mri_impression text
);

\copy tcia_breast_clinical_data from 'TCIA_Breast_clinical_data_public.csv' delimiter ',' csv header
