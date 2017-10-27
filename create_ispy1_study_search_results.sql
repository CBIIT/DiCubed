create table ispy1_study_search_results (
subject_id  varchar(10),
slide_name varchar(100),
relapse_free_survival_time  int, 
survival_status int ,
pathological_complete_response  varchar(10),
pgr  varchar(20),
rcb_class  varchar(100),
relapse_free_survival_indicator  int,
histology varchar(20),
intrinsic_subtype_by_pam50  varchar(100),
neoadjuvant_chemotherapy  int,
overall_survival  int,
experiment_name varchar(40),
her2 varchar(100),
histologic_grade  int,
age numeric(4,2) ,
clinical_t_stage varchar(20), 
clinical_tumor_size  numeric(6,2), 
er varchar(20)

);

\copy ispy1_study_search_results from 'ispy1_study_search_results_fixed.csv' delimiter ',' csv header


