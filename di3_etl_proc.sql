CREATE OR REPLACE FUNCTION di3_etl()
 
RETURNS void 
LANGUAGE 'plpgsql' 
AS $body$
BEGIN

perform ispy_obs_fact_proc();
delete from di3crcdata.observation_fact;
perform load_fact_table('di3crcdata.observation_fact', 'ispy_obs_fact');

perform load_concept_dim('di3metadata.receptors');

END;
$body$
