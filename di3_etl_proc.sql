CREATE OR REPLACE FUNCTION di3_etl()
 
RETURNS text  
AS $body$
DECLARE ret_stuff text;
BEGIN

select ispy_obs_fact_proc() into ret_stuff;
delete from di3crcdata.observation_fact;
select load_fact_table('di3crcdata.observation_fact', 'ispy_obs_fact') into ret_stuff;

delete from di3crcdata.concept_dimension;
select load_concept_dim('DI3') into ret_stuff;
return ret_stuff;
END;
$body$
LANGUAGE 'plpgsql' ;
