CREATE OR REPLACE FUNCTION di3_etl()
 
RETURNS text  
AS $body$
DECLARE ret_stuff text;
BEGIN

delete from di3crcdata.patient_mapping;
select dicubed_patient_mapping() into ret_stuff;

delete from di3crcdata.encounter_mapping;
select dicubed_encounter_mapping() into ret_stuff;

delete from di3crcdata.observation_fact;

select ispy_obs_fact_proc() into ret_stuff;
select load_fact_table('di3crcdata.observation_fact', 'ispy_obs_fact') into ret_stuff;

select breast_diagnosis_obs_fact_proc() into ret_stuff;
select load_fact_table('di3crcdata.observation_fact', 'breast_diagnosis_obs_fact') into ret_stuff;

select shared_clinical_obs_fact_proc() into ret_stuff;
select load_fact_table('di3crcdata.observation_fact', 'shared_clinical_obs_fact') into ret_stuff;

select tcia_tcga_obs_fact_proc() into ret_stuff;
select load_fact_table('di3crcdata.observation_fact', 'tcia_tcga_obs_fact') into ret_stuff;

select ivy_report_obs_fact_proc() into ret_stuff;
select load_fact_table('di3crcdata.observation_fact', 'ivy_report_obs_fact') into ret_stuff; 

select ucsf_measures_obs_fact_proc() into ret_stuff;
select load_fact_table('di3crcdata.observation_fact', 'ucsf_measures_obs_fact') into ret_stuff; 

delete from di3crcdata.patient_dimension;

select load_patient_dimension() into ret_stuff;

select load_visit_dimension() into ret_stuff;

delete from di3crcdata.concept_dimension;
select load_concept_dim('DI3') into ret_stuff;
select load_concept_dim('NCI_THESAURUS') into ret_stuff;
select load_concept_dim('MEASURES') into ret_stuff;
return ret_stuff;
END;
$body$
LANGUAGE 'plpgsql' ;
