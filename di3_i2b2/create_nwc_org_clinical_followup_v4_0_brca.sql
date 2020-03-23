drop table if exists nwc_org_clinical_follow_up_v4_0_brca ;
create table nwc_org_clinical_follow_up_v4_0_brca (
bcr_patient_uuid varchar(200),
bcr_patient_barcode varchar(100),
bcr_followup_barcode varchar(100),
bcr_followup_uuid varchar(200),
form_completion_date date,
followup_lost_to varchar(20),
radiation_treatment_adjuvant varchar(20),
pharmaceutical_tx_adjuvant varchar(20),
tumor_status varchar(20),
vital_status varchar(20),
last_contact_days_to varchar(20),
death_days_to varchar(20),
new_tumor_event_dx_indicator varchar(20)
) ;

\copy  nwc_org_clinical_follow_up_v4_0_brca from '/home/hickmanhb/data_sources/nationwidechildrens.org_clinical_follow_up_v4.0_brca_fixed.csv' delimiter ',' csv header
