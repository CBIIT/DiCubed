drop table if exists ivy_report;
create table ivy_report
(
patient_id integer,
tissue_id varchar(200),
age integer,
gender varchar(100),
kps int,
location varchar(300),
extent varchar(100),
chemotherapy varchar(10),
radiation varchar(10),
glioblastoma varchar(300),
v_1p19q_deletion varchar(100),
egfr varchar(100),
pten varchar(100),
mgmt_pcr  varchar(100),
mgmt  varchar(100),
mgmt_ms_mlpa_r1 varchar(100),
mgmt_ms_mlpa_r2 varchar(100),
mgmt_ms_mlpa_r3 varchar(100),
idh1 varchar(100),
egfr_viii varchar(100),
time_to_progression varchar(100),
time_to_last_followup varchar(100),
survival varchar(100),
cause_of_death varchar(100)
);

\copy ivy_report from 'ivyReport.fixed.csv' delimiter ',' csv header

