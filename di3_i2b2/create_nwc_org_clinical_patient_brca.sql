drop table if exists nwc_org_clinical_patient_brca;
create table nwc_org_clinical_patient_brca (
bcr_patient_uuid varchar(200),
bcr_patient_barcode varchar(100),
form_completion_date date, 
prospective_collection varchar(10),
retrospective_collection varchar(10),
birth_days_to integer, 
gender varchar(20),
menopause_status varchar(200),
race varchar(100),
ethnicity varchar(100),
history_other_malignancy varchar(10),
history_neoadjuvant_treatment varchar(10),
tumor_status varchar(30),
vital_status varchar(20),
last_contact_days_to integer,
death_days_to varchar(30),
radiation_treatment_adjuvant varchar(20),
pharmaceutical_tx_adjuvant varchar(20),
histologic_diagnosis_other varchar(100),
initial_pathologic_dx_year int,
age_at_diagnosis integer,
method_initial_path_dx varchar(60),
method_initial_path_dx_other varchar(200),
surgical_procedure_first varchar(100),
first_surgical_procedure_other varchar(256),
margin_status varchar(50),
surgery_for_positive_margins varchar(100),
surgery_for_positive_margins_other varchar(20),
margin_status_reexcision varchar(100),
axillary_staging_method	 varchar(100),
axillary_staging_method_other varchar(100),
micromet_detection_by_ihc varchar(40),
lymph_nodes_examined varchar(30),
lymph_nodes_examined_count varchar(30),
lymph_nodes_examined_he_count varchar(30),
lymph_nodes_examined_ihc_count varchar(30),
ajcc_staging_edition varchar(20),
ajcc_tumor_pathologic_pt varchar(20),
ajcc_nodes_pathologic_pn varchar(20),
ajcc_metastasis_pathologic_pm varchar(20),
ajcc_pathologic_tumor_stage varchar(20),
metastasis_site	varchar(20),
metastasis_site_other varchar(20),
er_status_by_ihc varchar(20),
er_status_ihc_Percent_Positive varchar(30),
er_positivity_scale_used varchar(20),
er_ihc_score varchar(50), 
er_positivity_scale_other varchar(50),
er_positivity_method varchar(50),
pr_status_by_ihc varchar(50),
pr_status_ihc_percent_positive varchar(50),
pr_positivity_scale_used  varchar(50),
pr_positivity_ihc_intensity_score  varchar(50),
pr_positivity_scale_other  varchar(50),
pr_positivity_define_method  varchar(50),
her2_status_by_ihc  varchar(50),
her2_ihc_percent_positive  varchar(50),
her2_ihc_score  varchar(50),
her2_positivity_scale_other  varchar(50),
her2_positivity_method_text  varchar(50),
her2_fish_status  varchar(50),
her2_copy_number  varchar(50),
cent17_copy_number  varchar(50),
her2_and_cent17_cells_count  varchar(50),
her2_cent17_ratio  varchar(50),
her2_and_cent17_scale_other  varchar(50),
her2_fish_method  varchar(50),
new_tumor_event_dx_indicator  varchar(50),
nte_er_status  varchar(50),
nte_er_status_ihc__positive  varchar(50),
nte_er_ihc_intensity_score  varchar(50),
nte_er_positivity_other_scale  varchar(50),
nte_er_positivity_define_method  varchar(50),
nte_pr_status_by_ihc  varchar(50),
nte_pr_status_ihc__positive	  varchar(50),
nte_pr_ihc_intensity_score  varchar(50),
nte_pr_positivity_other_scale  varchar(50),
nte_pr_positivity_define_method	  varchar(50),
nte_her2_status	varchar(50),
nte_her2_status_ihc__positive  varchar(50),
nte_her2_positivity_ihc_score  varchar(50),
nte_her2_positivity_other_scale	  varchar(50),
nte_her2_positivity_method  varchar(50),
nte_her2_fish_status  varchar(50),
nte_her2_signal_number  varchar(50),
nte_cent_17_signal_number  varchar(50),
her2_cent17_counted_cells_count	  varchar(50),
nte_cent_17_her2_ratio  varchar(50),
nte_cent17_her2_other_scale  varchar(50),
nte_her2_fish_define_method  varchar(50),
anatomic_neoplasm_subdivision  varchar(500),
clinical_M  varchar(50),
clinical_N  varchar(50),
clinical_T  varchar(50),
clinical_stage  varchar(50),
days_to_initial_pathologic_diagnosis  varchar(50),
days_to_patient_progression_free  varchar(50),
days_to_tumor_progression  varchar(50),
disease_code  varchar(50),
extranodal_involvement  varchar(50),
histological_type  varchar(50),
icd_10	  varchar(50),
icd_o_3_histology  varchar(50),
icd_o_3_site  varchar(50),
informed_consent_verified  varchar(50),
metastatic_tumor_indicator  varchar(50),
patient_id  varchar(50),
project_code  varchar(50),
site_of_primary_tumor_other  varchar(50),
stage_other  varchar(50),
tissue_source_site  varchar(50),
tumor_tissue_site  varchar(50)
);

\copy nwc_org_clinical_patient_brca from '/home/hickmanhb/data_sources/nationwidechildrens.org_clinical_patient_brca_fixed.csv' delimiter ',' csv header
